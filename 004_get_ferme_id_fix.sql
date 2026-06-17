-- Migration 004 : Correction fonction get_ferme_id()
-- Appliqué : 17 juin 2026
-- Problème : retournait NULL pour le rôle anon
-- Cause    : mauvais cast + absence de SECURITY DEFINER
-- Impact   : 14 tables bloquées (réponses 0B)

CREATE OR REPLACE FUNCTION get_ferme_id()
RETURNS uuid
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT (
    current_setting('request.headers', true)::json->>'x-ferme-id'
  )::uuid;
$$;
