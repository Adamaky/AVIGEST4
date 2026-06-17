-- Migration 005 : Fonction RPC imputer_aliment
-- Appliqué : 17 juin 2026
-- Objectif : Imputation automatique du stock aliment
--            depuis les sessions agent (Matin + Midi + PM)
-- Appelé par : _confirmerEtEnvoyer() dans index.html
-- Retourne : {ok: true} ou {ok: false, raison: '...'}
-- Corrections appliquées :
--   v1 : type_produit → produit (nom réel colonne)
--   v2 : LIKE '%aliment%' (valeur réelle = 'Aliment de démarrage')
--   v3 : produit + unite ajoutés dans INSERT (colonnes NOT NULL)
--   v4 : produit = 'ALIMENT' (code normalisé CHECK constraint)
--   v5 : type_mouvement = 'SORTIE' (CHECK: ENTREE/SORTIE uniquement)

CREATE OR REPLACE FUNCTION imputer_aliment(
  p_bande_id    UUID,
  p_quantite    NUMERIC,
  p_session     TEXT,
  p_agent_id    UUID,
  p_ferme_id    UUID
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_lot_id            UUID;
  v_quantite_restante NUMERIC;
  v_unite             TEXT;
BEGIN
  -- 1. Vérifier qu'un lot actif existe pour cette bande
  SELECT id, quantite_restante, unite
  INTO v_lot_id, v_quantite_restante, v_unite
  FROM lots_stock
  WHERE bande_id  = p_bande_id
    AND ferme_id  = p_ferme_id
    AND statut    = 'EN STOCK'
    AND LOWER(produit) LIKE '%aliment%'
  ORDER BY created_at DESC
  LIMIT 1;

  IF v_lot_id IS NULL THEN
    RETURN jsonb_build_object(
      'ok', false,
      'raison', 'Aucun lot aliment actif pour cette bande'
    );
  END IF;

  -- 2. Vérifier stock suffisant
  IF v_quantite_restante < p_quantite THEN
    RETURN jsonb_build_object(
      'ok', false,
      'raison', 'Stock insuffisant — disponible : '
                || v_quantite_restante::text || ' kg'
    );
  END IF;

  -- 3. Insérer mouvement
  --    produit = 'ALIMENT' (code normalisé)
  --    type_mouvement = 'SORTIE' (CHECK: ENTREE/SORTIE)
  --    → trigger fn_decrementer_stock décrémente automatiquement
  INSERT INTO mouvements_stock (
    ferme_id,
    lot_id,
    bande_id,
    produit,
    type_mouvement,
    quantite,
    unite,
    session,
    agent_id
  ) VALUES (
    p_ferme_id,
    v_lot_id,
    p_bande_id,
    'ALIMENT',
    'SORTIE',
    p_quantite,
    v_unite,
    p_session,
    p_agent_id
  );

  RETURN jsonb_build_object('ok', true);

END;
$$;
