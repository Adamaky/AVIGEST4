-- ============================================================
-- Migration 015 — RPC imputer_stock_type_b()
-- Projet : AviGest v26 — Kalycoq / REVAGRO — Ouagadougou
-- Auteur : Adama Désiré
-- Date   : 2026-06-24
-- ------------------------------------------------------------
-- Objectif : Stock Étape 6 — Imputation produits Type B
--   (litière + tout produit gérant sans écriture journal)
--
-- Comportement :
--   1. Vérifie que le lot existe, appartient à la bande,
--      et a impute_journal = false (Type B)
--   2. Vérifie que quantite_restante >= p_quantite
--   3. Décrémente quantite_restante dans lots_stock
--   4. Insère dans mouvements_stock statut EN_ATTENTE
--   5. N'écrit PAS dans journal
--   6. Retourne le mouvement créé
--
-- Validation gérant : réutilise valider_imputation_gerant()
-- ============================================================

CREATE OR REPLACE FUNCTION imputer_stock_type_b(
  p_lot_id    UUID,
  p_bande_id  UUID,
  p_quantite  NUMERIC,
  p_session   TEXT DEFAULT NULL,
  p_note      TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_ferme_id    UUID;
  v_lot         RECORD;
  v_mouvement   RECORD;
BEGIN

  -- Récupération ferme_id depuis header x-ferme-id
  v_ferme_id := get_ferme_id();

  -- Vérification existence et appartenance du lot
  SELECT *
  INTO v_lot
  FROM lots_stock
  WHERE id        = p_lot_id
    AND bande_id  = p_bande_id
    AND ferme_id  = v_ferme_id
    AND statut    = 'EN STOCK';

  IF NOT FOUND THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Lot introuvable ou inactif'
    );
  END IF;

  -- Vérification que c'est bien un lot Type B
  IF v_lot.impute_journal = true THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Ce lot est de Type A — utiliser imputer_aliment()'
    );
  END IF;

  -- Vérification stock suffisant
  IF v_lot.quantite_restante < p_quantite THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Stock insuffisant — disponible : ' 
               || v_lot.quantite_restante 
               || ' ' || v_lot.unite
    );
  END IF;

  -- Décrémentation stock
  UPDATE lots_stock
  SET quantite_restante = quantite_restante - p_quantite
  WHERE id = p_lot_id;

  -- Insertion mouvement EN_ATTENTE (validation gérant requise)
  INSERT INTO mouvements_stock (
    ferme_id,
    lot_id,
    type_mouvement,
    quantite,
    session,
    note,
    statut
  )
  VALUES (
    v_ferme_id,
    p_lot_id,
    'SORTIE',
    p_quantite,
    p_session,
    p_note,
    'EN_ATTENTE'
  )
  RETURNING * INTO v_mouvement;

  RETURN json_build_object(
    'success',      true,
    'mouvement_id', v_mouvement.id,
    'lot_id',       p_lot_id,
    'produit',      v_lot.produit,
    'quantite',     p_quantite,
    'unite',        v_lot.unite,
    'restant',      v_lot.quantite_restante - p_quantite
  );

END;
$$;
