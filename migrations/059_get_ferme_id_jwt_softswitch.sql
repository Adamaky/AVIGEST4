-- 059_get_ferme_id_jwt_softswitch.sql
-- Marche 2 (bascule douce) — session du 15/08/2026.
--
-- get_ferme_id() lit désormais le ferme_id depuis le JWT (auth) en PRIORITÉ,
-- avec repli sur le header x-ferme-id si aucun JWT n'est présent
-- (login, écran code-ferme : chemins qui tournent avant setSession).
--
-- Prouvé équivalent avant application : sous vrai JWT en conditions réelles,
-- JWT et header renvoient le même ferme_id (sonde jetable, résultat identique).
-- Signature/retour/volatilité INCHANGÉS vs version d'origine (pas de surcharge).
--
-- ⚠️ LA FAILLE DE FOND N'EST PAS ENCORE FERMÉE : tant que le repli header
-- existe, un appel API sans JWT + header forgé passe encore (état = avant 059).
-- Fermeture du repli = migration ULTÉRIEURE, après audit que le login ne
-- dépend pas de get_ferme_id(). Voir §26.6 / §14.4 / §27.8.

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