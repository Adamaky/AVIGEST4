-- Migration 007 : imputer_aliment v2
-- Ajouts : ecriture automatique journal + correction 0 kg valide
-- Date : 2026-06-18

CREATE OR REPLACE FUNCTION imputer_aliment(
  p_bande_id   UUID,
  p_quantite   NUMERIC,
  p_session    TEXT,
  p_agent_id   UUID,
  p_ferme_id   UUID
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_lot_id            UUID;
  v_quantite_restante NUMERIC;
  v_unite             TEXT;
  v_cout_unitaire     NUMERIC;
  v_cout_impute       NUMERIC;
  v_note              TEXT;
BEGIN
  -- 1. Verifier qu un lot actif existe pour cette bande
  SELECT id, quantite_restante, unite, cout_unitaire
  INTO v_lot_id, v_quantite_restante, v_unite, v_cout_unitaire
  FROM lots_stock
  WHERE ferme_id = p_ferme_id
    AND bande_id = p_bande_id
    AND LOWER(produit) LIKE '%aliment%'
    AND quantite_restante > 0
  ORDER BY date_fabrication DESC
  LIMIT 1;

  IF v_lot_id IS NULL THEN
    RETURN jsonb_build_object(
      'ok', false,
      'raison', 'Aucun lot aliment actif pour cette bande'
    );
  END IF;

  -- 2. Verifier stock suffisant (0 kg est valide, toujours accepte)
  IF p_quantite > 0 AND v_quantite_restante < p_quantite THEN
    RETURN jsonb_build_object(
      'ok', false,
      'raison', 'Stock insuffisant - disponible : '
                || v_quantite_restante::text || ' kg'
    );
  END IF;

  -- 3. Calculer cout impute
  v_cout_impute := ROUND(COALESCE(v_cout_unitaire, 0) * p_quantite);
  v_note := 'Aliment distribue - Session ' || p_session;

  -- 4. Inserer mouvement stock (seulement si quantite > 0)
  IF p_quantite > 0 THEN
    INSERT INTO mouvements_stock (
      ferme_id,
      lot_id,
      bande_id,
      produit,
      type_mouvement,
      quantite,
      unite,
      session,
      agent_id,
      cout_impute,
      note
    ) VALUES (
      p_ferme_id,
      v_lot_id,
      p_bande_id,
      'ALIMENT',
      'SORTIE',
      p_quantite,
      v_unite,
      p_session,
      p_agent_id,
      v_cout_impute,
      v_note
    );

    -- 5. Inserer ecriture journal automatique
    INSERT INTO journal (
      ferme_id,
      bande_id,
      date_ecriture,
      type_ecriture,
      categorie,
      montant,
      note
    ) VALUES (
      p_ferme_id,
      p_bande_id,
      CURRENT_DATE,
      'DEPENSE',
      'Alimentation',
      -v_cout_impute,
      v_note
    );
  END IF;

  RETURN jsonb_build_object('ok', true);

END;
$$;
