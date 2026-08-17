-- 060_sonde_repli.sql
-- Marche 2, étape 2 — sonde de repli (session 2026-08-17).
--
-- Objectif : observer en production quelle source retourne get_ferme_id()
-- (JWT vs header x-ferme-id) et si les deux valeurs convergent.
--
-- CREATE OR REPLACE (pas DROP) : get_ferme_id() est référencée par une
-- trentaine de policies RLS — un DROP échoue (ERROR 2BP01, dépendances).
-- CREATE OR REPLACE remplace le corps sans casser les dépendances, et
-- autorise le passage sql STABLE -> plpgsql (signature identique).
-- VOLATILE implicite (défaut plpgsql) : requis pour écrire dans la sonde.
-- La sonde est silencieuse : EXCEPTION WHEN OTHERS THEN NULL + ON CONFLICT.
-- Logique métier (COALESCE JWT -> header) strictement inchangée.
--
-- Rollback : 060_rollback.sql

CREATE TABLE IF NOT EXISTS public.sonde_repli (
    jour      DATE NOT NULL,
    role_ctx  TEXT NOT NULL DEFAULT '',
    v_jwt     UUID,
    v_header  UUID,
    PRIMARY KEY (jour, role_ctx)
);

CREATE OR REPLACE FUNCTION public.get_ferme_id()
RETURNS uuid
LANGUAGE plpgsql
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

    -- Sonde : premier appel du jour par role_ctx (silencieux)
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
