-- Migration 005 : Fonction RPC imputer_aliment
-- Appliqué : 17 juin 2026
-- Objectif : Imputation automatique du stock aliment
--            depuis les sessions agent (Matin + Midi + PM)
-- Appelé par : _confirmerEtEnvoyer() dans index.html
-- Retourne : {ok: true} ou {ok: false, raison: '...'}

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
  v_lot_id          UUID;
  v_quantite_restante NUMERIC;
BEGIN
  -- 1. Vérifier qu'un lot actif existe pour cette bande
  SELECT id, quantite_restante
  INTO v_lot_id, v_quantite_restante
  FROM lots_stock
  WHERE bande_id  = p_bande_id
    AND ferme_id  = p_ferme_id
    AND statut    = 'EN STOCK'
    AND type_produit = 'ALIMENT'
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

  -- 3. Insérer le mouvement → trigger décrémente automatiquement
  INSERT INTO mouvements_stock (
    ferme_id,
    lot_id,
    bande_id,
    type_mouvement,
    quantite,
    session,
    agent_id
  ) VALUES (
    p_ferme_id,
    v_lot_id,
    p_bande_id,
    'CONSOMMATION',
    p_quantite,
    p_session,
    p_agent_id
  );

  RETURN jsonb_build_object('ok', true);

END;
$$;
