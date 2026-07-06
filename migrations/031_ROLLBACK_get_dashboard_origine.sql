-- =====================================================================
-- ROLLBACK Migration 031 — Restaure get_dashboard() dans son état
-- D'ORIGINE (avant correctif sécurité v26.19).
-- =====================================================================
-- USAGE : si le correctif 031 casse le tableau de bord, coller CE
--   fichier dans le SQL Editor et Run pour revenir instantanément à
--   la version qui fonctionnait avant.
-- Contenu = copie EXACTE de get_dashboard tel que lu via
--   pg_get_functiondef le 03/07/2026 (session v26.19), AVANT tout ajout.
-- =====================================================================

CREATE OR REPLACE FUNCTION public.get_dashboard(p_bande_id uuid)
 RETURNS json
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
AS $function$
DECLARE
    v_result JSON;
BEGIN
    SELECT json_build_object(
        'success', true,
        'performance', json_build_object(
            'effectifInitial', vd.effectif_initial,
            'effectif',        vd.effectif_actuel,
            'morts',           vd.morts_cumul,
            'ageJours',        vd.age_jours,
            'stockSacs',       COALESCE((SELECT solde FROM vue_stock_actuel
                                         WHERE bande_id = p_bande_id
                                           AND produit = 'ALIMENT'), 0) / 50
        ),
        'terrain', json_build_object(
            'mortaliteJour', vd.mortalite_jour,
            'tempMax',       vd.temp_max_jour,
            'hygro',         vd.hygro_jour,
            'poidsMoyen',    vd.poids_moyen_g
        ),
        'finance', json_build_object(
            'totalDepenses',    vd.total_depenses,
            'totalDepensesCRU', vd.total_depenses_cru,
            'recettes',         vd.total_recettes,
            'solde',            vd.marge_nette
        )
    )
    INTO v_result
    FROM vue_dashboard_bande vd
    WHERE vd.bande_id = p_bande_id;

    RETURN COALESCE(v_result, '{"success":false,"error":"Bande introuvable"}'::JSON);
END;
$function$;
