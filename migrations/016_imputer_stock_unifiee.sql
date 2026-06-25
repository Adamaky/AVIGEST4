-- Migration 016 — RPC imputer_stock() unifiée
-- AviGest v26.6 — juin 2026
-- Auteur : Adama Désiré / REVAGRO
-- Objectif : Imputation générique tous produits stock
--            depuis les sessions agent (aliment + litière +
--            vaccin + médicament + tout produit gérant)
-- Remplace le rôle de imputer_aliment() — celle-ci est
--            conservée en base pour compatibilité
-- Logique :
--   1. Récupère ferme_id via get_ferme_id() (header x-ferme-id)
--   2. Trouve le lot actif via LOWER(produit) LIKE p_produit_like
--   3. Vérifie stock suffisant
--   4. Insère SORTIE dans mouvements_stock
--      → trigger fn_decrementer_stock décrémente quantite_restante
--   5. Si impute_journal = true → INSERT dans journal (EN_ATTENTE)
-- Retourne : {ok: true} ou {ok: false, raison: '...'}

CREATE OR REPLACE FUNCTION imputer_stock(
  p_bande_id     UUID,
  p_produit_like TEXT,
  p_quantite     NUMERIC,
  p_session      TEXT,
  p_note         TEXT DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_ferme_id          UUID;
  v_lot_id            UUID;
  v_quantite_restante NUMERIC;
  v_unite             TEXT;
  v_impute_journal    BOOLEAN;
  v_produit_nom       TEXT;
  v_cout_unitaire     NUMERIC;
BEGIN
  v_ferme_id := get_ferme_id();
  IF v_ferme_id IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'raison', 'Ferme non identifiée');
  END IF;

  SELECT id, quantite_restante, unite, impute_journal,
         produit, cout_unitaire
  INTO   v_lot_id, v_quantite_restante, v_unite,
         v_impute_journal, v_produit_nom, v_cout_unitaire
  FROM   lots_stock
  WHERE  bande_id  = p_bande_id
    AND  ferme_id  = v_ferme_id
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

  INSERT INTO mouvements_stock (
    ferme_id, lot_id, bande_id, produit,
    type_mouvement, quantite, unite, session, note
  ) VALUES (
    v_ferme_id, v_lot_id, p_bande_id, v_produit_nom,
    'SORTIE', p_quantite, v_unite, p_session, p_note
  );

  IF v_impute_journal = true THEN
    INSERT INTO journal (
      ferme_id, bande_id, date_ecriture, type_ecriture,
      categorie, montant, statut, libelle
    ) VALUES (
      v_ferme_id, p_bande_id, CURRENT_DATE, 'DEPENSE',
      CASE
        WHEN LOWER(v_produit_nom) LIKE '%aliment%' THEN 'Alimentation'
        WHEN LOWER(v_produit_nom) LIKE '%vaccin%'  THEN 'Vaccin'
        WHEN LOWER(v_produit_nom) LIKE '%medic%'   THEN 'Médicament'
        ELSE 'Autre'
      END,
      COALESCE(v_cout_unitaire, 0) * p_quantite,
      'EN_ATTENTE',
      COALESCE(p_note, v_produit_nom || ' — ' || p_session)
    );
  END IF;

  RETURN jsonb_build_object('ok', true);
END;
$$;

GRANT EXECUTE ON FUNCTION imputer_stock(UUID, TEXT, NUMERIC, TEXT, TEXT) TO anon;
