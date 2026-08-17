-- 060_rollback.sql
-- Rollback de 060_sonde_repli.sql.
-- Retour à l'état 059 : get_ferme_id() en LANGUAGE sql STABLE SECURITY DEFINER.
-- Suppression de la table sonde_repli.

DROP FUNCTION IF EXISTS public.get_ferme_id();

CREATE OR REPLACE FUNCTION public.get_ferme_id()
RETURNS uuid
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $function$
  SELECT COALESCE(
    (current_setting('request.jwt.claims', true)::json
       -> 'app_metadata' ->> 'ferme_id')::uuid,
    (current_setting('request.headers', true)::json
       ->> 'x-ferme-id')::uuid
  );
$function$;

DROP TABLE public.sonde_repli;
