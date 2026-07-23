-- Migration 044 — Ménage doublons policies (suite 043)
-- Même cas : acces_par_ferme (anon) gardée, ferme_isolation (public) supprimée.
-- NB : partenaire_ses_bandes sur bandes est une policy métier, NON touchée.
DROP POLICY IF EXISTS ferme_isolation ON public.journal;
DROP POLICY IF EXISTS ferme_isolation ON public.mouvements_stock;
DROP POLICY IF EXISTS ferme_isolation ON public.saisies_techniques;
DROP POLICY IF EXISTS ferme_isolation ON public.bandes;