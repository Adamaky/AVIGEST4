-- Migration 061 — Fermeture du repli header dans get_ferme_id()
-- Marche 2 finale (§26.6) : le header x-ferme-id ne fait PLUS autorité.
-- get_ferme_id() ne lit désormais que le JWT (app_metadata.ferme_id).
-- Comportement fail-closed : pas de JWT => NULL.
-- Garde-fou tracé : si JWT absent mais header présent (cas suspect / chemin oublié),
--   on enregistre une ligne dans sonde_repli AVANT de renvoyer NULL, sans jamais
--   faire échouer la fonction (ON CONFLICT + EXCEPTION).
--
-- ⚠️ CREATE OR REPLACE obligatoire (jamais DROP) : ~30 policies RLS dépendent de
--    cette fonction (erreur 2BP01 sinon). Signature inchangée, pas de surcharge.
--
-- Prérequis vérifiés avant application (session du 20/08/2026) :
--   - valider_code_ferme et verifier_pin n'appellent pas get_ferme_id() (audit base)
--   - index.html ne contient aucune occurrence de get_ferme_id (audit front, 0 résultat)
--   - login front : setSession() posé AVANT startApp() => JWT présent pour toute lecture
--   - 3 tests isolés validés : JWT seul => ferme_id ; header seul => NULL + trace ;
--     JWT + header d'une autre ferme => JWT (header menteur ignoré)
--   - test app réel post-bascule : accueil, bandes, analyses, journal => 200, Realtime OK

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

  -- Source 2 : header x-ferme-id (NE SERT PLUS QU'À LA DÉTECTION, jamais de retour)
  BEGIN
    v_header := (
      current_setting('request.headers', true)::json
      ->> 'x-ferme-id'
    )::uuid;
  EXCEPTION WHEN OTHERS THEN
    v_header := NULL;
  END;

  -- Garde-fou tracé : JWT absent MAIS header présent => cas suspect, on enregistre
  IF v_jwt IS NULL AND v_header IS NOT NULL THEN
    BEGIN
      INSERT INTO public.sonde_repli (jour, role_ctx, v_jwt, v_header)
      VALUES (CURRENT_DATE, current_user, v_jwt, v_header)
      ON CONFLICT (jour, role_ctx) DO NOTHING;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
  END IF;

  -- Retour : le header ne fait PLUS autorité. Pas de JWT => NULL => fail-closed.
  RETURN v_jwt;
END;
$function$;