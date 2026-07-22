-- Migration 042 — Ménage doublon policy sur clients
-- Suppression de ferme_isolation (redondante avec clients_isolation).
-- Isolation inchangée : testé croisé (refusé) + légitime (passe) en rôle anon.
DROP POLICY IF EXISTS ferme_isolation ON public.clients;