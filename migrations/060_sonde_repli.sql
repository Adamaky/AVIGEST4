-- 060_sonde_repli.sql
-- Marche 2, étape 2 — sonde de repli (session 2026-08-16).
--
-- Objectif : observer en production quelle source retourne get_ferme_id()
-- (JWT vs header x-ferme-id) et si les deux valeurs convergent.
--
-- La fonction bascule en plpgsql VOLATILE pour pouvoir écrire dans sonde_repli.
-- La sonde est entièrement silencieuse : tout échec est absorbé par
-- EXCEPTION WHEN OTHERS THEN NULL ; un ON CONFLICT DO NOTHING évite les
-- conflits d'unicité si plusieurs requêtes arrivent le même jour sous le
-- même role_ctx.
-- La logique métier (COALESCE JWT → header) est strictement inchangée.
--
-- Rollback : 060_rollback.sql

-- ── Table de sonde ───────────────────────────────────────────────────────────
-- Une ligne par (jour, role_ctx) : premier appel de la journée gagne.
-- v_jwt et v_header permettent de vérifier la convergence en production.

CREATE TABLE IF NOT EXISTS public.sonde_repli (
    jour      DATE NOT NULL,
    role_ctx  TEXT NOT NULL DEFAULT '',
    v_jwt     UUID,
    v_header  UUID,
    PRIMARY KEY (jour, role_ctx)
);

-- ── get_ferme_id() — plpgsql VOLATILE SECURITY DEFINER ──────────────────────

DROP FUNCTION IF EXISTS public.get_ferme_id();

CREATE FUNCTION public.get_ferme_id()
RETURNS uuid
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
AS $function$
DECLARE
    v_jwt    uuid;
    v_header uuid;
BEGIN
    -- Source 1 : JWT (app_metadata.ferme_id)
    BEGIN
        v_jwt := (
            current_setting('request.jwt.claims', true)::json
            -> 'app_metadata' ->> 'ferme_id'
        )::uuid;
    EXCEPTION WHEN OTHERS THEN
        v_jwt := NULL;
    END;

    -- Source 2 : header x-ferme-id (repli)
    BEGIN
        v_header := (
            current_setting('request.headers', true)::json
            ->> 'x-ferme-id'
        )::uuid;
    EXCEPTION WHEN OTHERS THEN
        v_header := NULL;
    END;

    -- Sonde : enregistrer le premier appel du jour par role_ctx (silencieux)
    BEGIN
        INSERT INTO public.sonde_repli (jour, role_ctx, v_jwt, v_header)
        VALUES (CURRENT_DATE, current_user, v_jwt, v_header)
        ON CONFLICT DO NOTHING;
    EXCEPTION WHEN OTHERS THEN
        NULL;
    END;

    RETURN COALESCE(v_jwt, v_header);
END;
$function$;
