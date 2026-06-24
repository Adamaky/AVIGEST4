-- ============================================================
-- Migration 011 — Ajout colonne fournisseur_poussins
-- Table  : bandes
-- Projet : AviGest v26 — Kalycoq / REVAGRO — Ouagadougou
-- Auteur : Adama Désiré
-- Date exécution Supabase : [session antérieure à v26.5]
-- Commit GitHub : session v26.5 — 2026-06-24
-- ------------------------------------------------------------
-- Contexte :
--   Permet d'enregistrer le nom du fournisseur de poussins
--   pour chaque bande. Colonne nullable — les bandes existantes
--   ne sont pas affectées.
-- ============================================================

ALTER TABLE bandes
ADD COLUMN IF NOT EXISTS fournisseur_poussins TEXT;

COMMENT ON COLUMN bandes.fournisseur_poussins IS
  'Nom du fournisseur de poussins pour cette bande';
