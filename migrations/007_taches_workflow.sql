-- ============================================
-- Migration 007_taches_workflow.sql
-- AviGest v26 — 18 juin 2026
-- Refonte workflow tâches gérant→agent
-- ============================================
-- Contexte : Suppression tâches quotidiennes
-- automatiques. Nouveau circuit :
-- PLANIFIEE → ENVOYEE → EXECUTEE → VALIDEE
-- Rejet unique possible → retour EXECUTEE
-- ============================================

-- BLOC 1 : Nettoyage données
-- (exécuté séparément pour sécurité)
-- DELETE FROM taches WHERE type_tache = 'QUOTIDIEN';
-- UPDATE taches SET statut = 'PLANIFIEE' WHERE statut = 'A FAIRE';

-- BLOC 2 : Nouvelles colonnes
ALTER TABLE taches
  ADD COLUMN IF NOT EXISTS session_cible  TEXT
    CHECK (session_cible IN ('Matin','Midi','PM','Nuit')),
  ADD COLUMN IF NOT EXISTS motif_rejet    TEXT,
  ADD COLUMN IF NOT EXISTS envoyee_le     TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS executee_le    TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS nb_rejets      INTEGER DEFAULT 0;

-- Contrainte CHECK statut
ALTER TABLE taches
  ADD CONSTRAINT taches_statut_check
  CHECK (statut IN (
    'PLANIFIEE',
    'ENVOYEE',
    'EXECUTEE',
    'VALIDEE',
    'REJETEE'
  ));

-- Contrainte CHECK type_tache
ALTER TABLE taches
  ADD CONSTRAINT taches_type_tache_check
  CHECK (type_tache IN (
    'SPECIFIQUE',
    'HEBDOMADAIRE',
    'BANDE',
    'ABATTAGE',
    'SEMAINE_VIDE'
  ));
