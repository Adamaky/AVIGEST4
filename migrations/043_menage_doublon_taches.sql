-- Migration 043 — Ménage doublon policy sur taches
-- Doublon : acces_par_ferme (anon, gardée) + ferme_isolation (public, redondante).
DROP POLICY IF EXISTS ferme_isolation ON public.taches;