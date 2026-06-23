-- ============================================================
-- Migration 012 — Fix B12 : imputer_aliment() statut EN_ATTENTE
-- AviGest v26.4
-- Problème : INSERT journal utilisait statut = 'CONFIRME'
--            → imputations invisibles dans renderValidationGerant
-- Correction : statut = 'EN_ATTENTE' pour déclencher le flux
--              de validation gérant (B7)
-- Structure mouvements_stock vérifiée le 23/06/2026 :
--   id, ferme_id, bande_id, produit, type_mouvement, quantite,
--   unite, prix_unitaire, montant, note, saisi_par, created_at,
--   lot_id, cout_impute, session, agent_id, journal_id
-- ============================================================

CREATE OR REPLACE FUNCTION imputer_aliment(
  p_bande_id   UUID,
  p_session    TEXT,
  p_quantite   NUMERIC,
  p_ferme_id   UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_lot           RECORD;
  v_cout_impute   NUMERIC;
  v_journal_id    UUID;
BEGIN

  -- 1. Trouver le lot aliment actif pour cette bande
  SELECT * INTO v_lot
  FROM lots_stock
  WHERE ferme_id = p_ferme_id
    AND bande_id = p_bande_id
    AND impute_journal = true
    AND quantite_restante >= p_quantite
    AND LOWER(produit) LIKE '%aliment%'
  ORDER BY date_fabrication ASC
  LIMIT 1;

  IF NOT FOUND THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', 'Aucun lot aliment disponible ou stock insuffisant'
    );
  END IF;

  -- 2. Calculer le coût imputé
  v_cout_impute := p_quantite * v_lot.cout_unitaire;

  -- 3. Décrémenter le stock
  UPDATE lots_stock
  SET quantite_restante = quantite_restante - p_quantite
  WHERE id = v_lot.id;

  -- 4. Écriture journal EN_ATTENTE (FIX B12 : était 'CONFIRME')
  INSERT INTO journal (
    ferme_id,
    bande_id,
    date_ecriture,
    type_ecriture,
    categorie,
    montant,
    libelle,
    statut
  ) VALUES (
    p_ferme_id,
    p_bande_id,
    CURRENT_DATE,
    'DEPENSE',
    'Alimentation',
    v_cout_impute,
    'Aliment distribué — Session ' || p_session,
    'EN_ATTENTE'
  )
  RETURNING id INTO v_journal_id;

  -- 5. Enregistrer le mouvement stock (avec bande_id et journal_id)
  INSERT INTO mouvements_stock (
    ferme_id,
    bande_id,
    lot_id,
    produit,
    type_mouvement,
    quantite,
    cout_impute,
    session,
    note,
    journal_id
  ) VALUES (
    p_ferme_id,
    p_bande_id,
    v_lot.id,
    v_lot.produit,
    'SORTIE',
    p_quantite,
    v_cout_impute,
    p_session,
    'Imputation session ' || p_session,
    v_journal_id
  );

  RETURN jsonb_build_object(
    'success',       true,
    'lot_id',        v_lot.id,
    'produit',       v_lot.produit,
    'quantite',      p_quantite,
    'cout_impute',   v_cout_impute,
    'journal_id',    v_journal_id,
    'statut',        'EN_ATTENTE'
  );

END;
$$;
