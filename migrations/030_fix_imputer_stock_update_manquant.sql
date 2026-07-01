
-- Migration 030 — Correctif imputer_stock() : UPDATE lots_stock manquant
-- Date : 2026-07-01 (session v26.15/v26.16)
-- Contexte :
--   La fonction imputer_stock() (OID 18919) vérifiait le stock disponible,
--   créait un mouvement SORTIE dans mouvements_stock, et créait une écriture
--   journal si impute_journal = true — mais ne décrémentait JAMAIS
--   lots_stock.quantite_restante. Conséquence : le stock affiché ne bougeait
--   jamais automatiquement depuis les sessions agent (aliment, vaccin,
--   médicament, litière), et le contrôle "stock insuffisant" comparait
--   toujours à une valeur figée, donc ne bloquait jamais réellement un agent.
--
-- Correctif :
--   1. Ajout d'un UPDATE lots_stock AVANT l'INSERT mouvements_stock
--      (garantit la cohérence : si l'UPDATE échoue, aucun mouvement n'est
--      enregistré — pas de trace fantôme en base).
--   2. Clause défensive WHERE quantite_restante >= p_quantite pour éviter
--      toute race condition (double-clic, requête rejouée après timeout).
--   3. IF NOT FOUND THEN renvoie une erreur propre côté agent.
--   4. Ajout de la lecture de categorie_cru (nouvelle colonne, voir plus bas)
--      avec repli automatique (COALESCE) sur l'ancien CASE si NULL —
--      garantit qu'un lot existant ou mal configuré continue de fonctionner
--      sans jamais bloquer l'agent pour une raison administrative.
--
-- Signature inchangée : p_bande_id uuid, p_produit_like text, p_quantite numeric,
--                        p_session text, p_note text DEFAULT NULL::text
-- (le DEFAULT NULL::text sur p_note a dû être réintroduit explicitement —
--  un premier essai sans DEFAULT a échoué avec ERROR 42P13 "cannot remove
--  parameter defaults from existing function")
--
-- Correction rétroactive des données (exécutée séparément le même jour) :
--   2 lots "Aliment de démarrage" avaient un écart entre quantite_restante
--   et la valeur théorique (quantite_initiale - SUM(sorties)) :
--     - lot a6406295-31ce-4c8c-8389-5101c775fece (bande f3153372-...) :
--       107.00 -> 317.00 (écart -210.00)
--     - lot ed777438-5fb9-4b22-bec2-d575af8ad419 (bande 0bd712f2-...) :
--       70.00 -> 220.00 (écart -150.00)
--   Les 8 autres lots actifs (REVAGRO + ALIRAH2026) avaient un écart de 0.00
--   (jamais utilisés via imputer_stock, donc jamais affectés par le bug).
--
-- Colonne categorie_cru ajoutée séparément (ALTER TABLE lots_stock
-- ADD COLUMN categorie_cru TEXT ; sans DEFAULT, NULL par défaut) puis
-- remplie rétroactivement sur les lots existants avec le même mapping
-- que le CASE ci-dessous.

CREATE OR REPLACE FUNCTION public.imputer_stock(p_bande_id uuid, p_produit_like text, p_quantite numeric, p_session text, p_note text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  v_ferme_id          UUID;
  v_lot_id            UUID;
  v_quantite_restante NUMERIC;
  v_unite             TEXT;
  v_impute_journal    BOOLEAN;
  v_produit_nom       TEXT;
  v_cout_unitaire     NUMERIC;
  v_categorie_cru     TEXT;
  v_categorie_finale  TEXT;
BEGIN
  SET LOCAL row_security = off;

  v_ferme_id := get_ferme_id();
  IF v_ferme_id IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'raison', 'Ferme non identifiée');
  END IF;

  SELECT id, quantite_restante, unite, impute_journal,
         produit, cout_unitaire, categorie_cru
  INTO   v_lot_id, v_quantite_restante, v_unite,
         v_impute_journal, v_produit_nom, v_cout_unitaire, v_categorie_cru
  FROM   lots_stock
  WHERE  bande_id = p_bande_id
    AND  ferme_id = v_ferme_id
    AND  statut    = 'EN STOCK'
    AND  LOWER(produit) LIKE LOWER(p_produit_like)
  ORDER BY created_at DESC
  LIMIT 1;

  IF v_lot_id IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'raison', 'Aucun lot actif trouvé pour ce produit');
  END IF;

  IF p_quantite <= 0 THEN
    RETURN jsonb_build_object('ok', false, 'raison', 'Quantité doit être supérieure à zéro');
  END IF;

  IF v_quantite_restante < p_quantite THEN
    RETURN jsonb_build_object(
      'ok', false,
      'raison', 'Stock insuffisant — disponible : ' || v_quantite_restante::text || ' ' || v_unite
    );
  END IF;

  UPDATE lots_stock
  SET quantite_restante = quantite_restante - p_quantite,
      updated_at = now()
  WHERE id = v_lot_id
    AND quantite_restante >= p_quantite;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'raison', 'Stock insuffisant au moment de la mise à jour — veuillez réessayer');
  END IF;

  INSERT INTO mouvements_stock (
    ferme_id, lot_id, bande_id, produit,
    type_mouvement, quantite, unite, session, note
  ) VALUES (
    v_ferme_id, v_lot_id, p_bande_id, v_produit_nom,
    'SORTIE', p_quantite, v_unite, p_session, p_note
  );

  IF v_impute_journal = true THEN
    -- Priorité à categorie_cru si renseignée ; sinon repli sur l'ancien CASE (nom produit)
    v_categorie_finale := COALESCE(
      v_categorie_cru,
      CASE
        WHEN LOWER(v_produit_nom) LIKE '%aliment%' THEN 'Alimentation'
        WHEN LOWER(v_produit_nom) LIKE '%vaccin%'  THEN 'Vaccin'
        WHEN LOWER(v_produit_nom) LIKE '%medic%'   THEN 'Médicament'
        WHEN LOWER(v_produit_nom) LIKE '%liti%'    THEN 'Litiere'
        ELSE 'Autre'
      END
    );

    INSERT INTO journal (
      ferme_id, bande_id, date_ecriture, type_ecriture,
      categorie, montant, statut, libelle
    ) VALUES (
      v_ferme_id, p_bande_id, CURRENT_DATE, 'DEPENSE',
      v_categorie_finale,
      COALESCE(v_cout_unitaire, 0) * p_quantite,
      'EN_ATTENTE',
      COALESCE(p_note, v_produit_nom || ' — ' || p_session)
    );
  END IF;

  RETURN jsonb_build_object('ok', true);
END;
$function$