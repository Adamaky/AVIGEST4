-- migrations/047_fermes_nom_commercial.sql
-- Ajoute nom_commercial sur fermes : nom affiché en tête des reçus/factures,
-- distinct du nom technique du tenant (ex. REVAGRO → « Kalycoq »).
-- Colonne nullable, repli sur fermes.nom si vide (voir §20).
-- Fichier recréé a posteriori en v26.37 (joué en base en v26.34, jamais committé).

ALTER TABLE public.fermes ADD COLUMN IF NOT EXISTS nom_commercial text;