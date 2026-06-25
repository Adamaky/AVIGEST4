-- Migration 018 — Colonnes abattage/vente sur taches
-- AviGest v26.7 — juin 2026
-- Auteur : Adama Désiré / REVAGRO
-- Objectif : Enrichir la table taches pour supporter
--            le workflow abattage/vente progressif
--            Gérant planifie → Agent exécute → Gérant valide
-- Colonnes ajoutées :
--   nb_sujets_prevus : prévu par le gérant à la planification
--   type_operation   : ABATTAGE ou VENTE_VIF
--   client_cible     : acheteur optionnel (gérant)
--   nb_sujets_reels  : saisi par l'agent le jour J
--   montant_recu     : saisi par le gérant après validation
--                      → déclenche écriture RECETTE dans journal
-- Exécutée en base le 25/06/2026

ALTER TABLE taches
  ADD COLUMN IF NOT EXISTS nb_sujets_prevus INTEGER,
  ADD COLUMN IF NOT EXISTS type_operation   TEXT CHECK (type_operation IN ('ABATTAGE','VENTE_VIF')),
  ADD COLUMN IF NOT EXISTS client_cible     TEXT,
  ADD COLUMN IF NOT EXISTS nb_sujets_reels  INTEGER,
  ADD COLUMN IF NOT EXISTS montant_recu     NUMERIC;
