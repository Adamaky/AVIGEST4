-- =====================================================================
-- Migration 031 — Correctif fuite lecture cross-tenant get_dashboard
-- Session v26.20 — Audit sécurité — Chantier A (priorité 1)
-- =====================================================================
-- >>> TRAÇABILITÉ / EXCEPTION AU WORKFLOW HABITUEL <<<
--   Ce correctif a été APPLIQUÉ MANUELLEMENT dans Supabase SQL Editor
--   le 03/07/2026 (session v26.20), AVANT son archivage GitHub —
--   ordre INVERSÉ par rapport au workflow habituel (normalement :
--   GitHub d'abord, exécution ensuite). Exception justifiée : test
--   d'un correctif de sécurité en conditions réelles.
--
--   TESTÉ ET VALIDÉ (preuve croisée sur Bande-2026-002, id
--   928f44ef-b6f5-4874-bbb8-3fac51437b8a, REVAGRO) :
--     - header REVAGRO (e56574a9-...) -> {"success":true, ...}
--         => accès légitime PRÉSERVÉ (dashboard fonctionne)
--     - header ALIRAH  (40ee764e-...) -> {"success":false,...}
--         => accès cross-ferme BLOQUÉ (fuite colmatée)
--   Même bande, seul le header change, résultat opposé => c'est bien
--   le filtre ferme_id ajouté qui agit.
--
--   ROLLBACK disponible : 031_ROLLBACK_get_dashboard_origine.sql
-- =====================================================================
-- PROBLÈME : get_dashboard() filtrait uniquement par bande_id.
--   La vue vue_dashboard_bande ne filtre pas par ferme_id et tourne en
--   security_invoker=false (RLS bypassée). Un appel API direct
--   get_dashboard('<bande d une autre ferme>') remontait donc les
--   finances (recettes, marge) d une bande étrangère.
--
-- CORRECTIF (chirurgical, calé sur pg_get_functiondef réel) :
--   Corps d origine conservé À L IDENTIQUE (calcul stockSacs /50,
--   produit = 'ALIMENT', tous les noms de colonnes réels), on AJOUTE
--   seulement 3 verrous de sécurité :
--     1. v_ferme_id := get_ferme_id()  (dérive la ferme du header)
--     2. fail-closed si v_ferme_id IS NULL
--     3. AND ferme_id = v_ferme_id sur les DEUX lectures :
--          - le WHERE principal (vue_dashboard_bande)
--          - la sous-requête stockSacs (vue_stock_actuel)
--
-- EFFET DE BORD : aucun. get_dashboard a un seul consommateur
--   (front index.html ligne 693) qui passe toujours la bande active de
--   la ferme courante -> comportement légitime préservé (confirmé par
--   le test header REVAGRO ci-dessus).
-- =====================================================================

CREATE OR REPLACE FUNCTION public.get_dashboard(p_bande_id uuid)
 RETURNS json
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
AS $function$
DECLARE
    v_result   JSON;
    v_ferme_id UUID;
BEGIN
    -- [AJOUT 1] Dériver la ferme depuis le header x-ferme-id
    v_ferme_id := get_ferme_id();

    -- [AJOUT 2] Fail-closed : pas de ferme identifiée => refus
    IF v_ferme_id IS NULL THEN
        RETURN '{"success":false,"error":"Ferme non identifiee"}'::JSON;
    END IF;

    SELECT json_build_object(
        'success', true,
        'performance', json_build_object(
            'effectifInitial', vd.effectif_initial,
            'effectif',        vd.effectif_actuel,
            'morts',           vd.morts_cumul,
            'ageJours',        vd.age_jours,
            'stockSacs',       COALESCE((SELECT solde FROM vue_stock_actuel
                                         WHERE bande_id = p_bande_id
                                           AND produit  = 'ALIMENT'
                                           AND ferme_id = v_ferme_id   -- [AJOUT 3a] verrou sous-requête stock
                                        ), 0) / 50
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
    WHERE vd.bande_id = p_bande_id
      AND vd.ferme_id = v_ferme_id;   -- [AJOUT 3b] verrou lecture principale

    RETURN COALESCE(v_result, '{"success":false,"error":"Bande introuvable"}'::JSON);
END;
$function$;
