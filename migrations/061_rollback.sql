-- Rollback Migration 061 — Restaure le repli header dans get_ferme_id()
-- À N'EXÉCUTER QUE si la fermeture du repli (061) cause un problème en production.
-- Rétablit le comportement "bascule douce" de la Migration 059 :
--   COALESCE(v_jwt, v_header) => le header redevient un repli si le JWT est absent.
--
-- ⚠️ Rouvre la faille de fond (§26.6) : un header forgé sans JWT repasse.
--    N'utiliser que temporairement, le temps de diagnostiquer le chemin fautif.
-- ⚠️ CREATE OR REPLACE obligatoire (jamais DROP) : ~30 policies en dépendent.

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

  -- Retour bascule douce : JWT prioritaire, repli header si JWT absent.
  RETURN COALESCE(v_jwt, v_header);
END;
$function$;