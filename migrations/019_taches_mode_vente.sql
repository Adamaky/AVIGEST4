-- Migration 019 — Mode vente sur taches
-- AviGest v26.7 — juin 2026
-- Auteur : Adama Désiré / REVAGRO
-- Objectif : Ajouter mode_vente et quantite_prevue
--            pour le formulaire plan de vente gérant
-- mode_vente      : UNITE (nb sujets) ou POIDS (kg)
-- quantite_prevue : nb sujets prévus ou poids prévu selon mode
-- Exécutée en base le 26/06/2026

ALTER TABLE taches
  ADD COLUMN IF NOT EXISTS mode_vente      TEXT CHECK (mode_vente IN ('UNITE','POIDS')),
  ADD COLUMN IF NOT EXISTS quantite_prevue NUMERIC;
