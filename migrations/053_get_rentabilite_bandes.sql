-- 053_get_rentabilite_bandes.sql
-- Rentabilité par bande EN COURS — lecture de vue_dashboard_bande (source unique).
-- CRU unitaire = total_depenses_cru / effectif_actuel (règle §4.1), protégé contre /0.

CREATE OR REPLACE FUNCTION public.get_rentabilite_bandes()
RETURNS TABLE (
  bande_id            uuid,
  id_bande            text,
  age_jours           integer,
  effectif_actuel     numeric,
  total_depenses      numeric,
  total_depenses_cru  numeric,
  cru_unitaire        numeric,
  total_recettes      numeric,
  marge_nette         numeric
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_ferme_id uuid;
BEGIN
  -- Fail-closed : pas de ferme identifiée => aucune ligne
  v_ferme_id := get_ferme_id();
  IF v_ferme_id IS NULL THEN
    RETURN;
  END IF;

  RETURN QUERY
  SELECT
    vd.bande_id,
    vd.id_bande,
    vd.age_jours,
    vd.effectif_actuel,
    vd.total_depenses,
    vd.total_depenses_cru,
    ROUND(vd.total_depenses_cru / NULLIF(vd.effectif_actuel, 0), 2) AS cru_unitaire,
    vd.total_recettes,
    vd.marge_nette
  FROM vue_dashboard_bande vd
  WHERE vd.ferme_id = v_ferme_id
    AND vd.statut = 'EN COURS'
  ORDER BY vd.date_arrivee DESC;
END;
$$;