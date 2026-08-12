-- Migration 055 — Colonnes pour le module Partenaire (Brique A)
-- A1 : plomberie en base pour l'assignation des quotes-parts
-- commission_pct : % de commission gérant, par partenaire (Décision 2)
-- budget_previsionnel : budget cible de la bande, référence de l'alerte sur les mises

ALTER TABLE partenaires_bandes
  ADD COLUMN commission_pct numeric NOT NULL DEFAULT 0;

ALTER TABLE bandes
  ADD COLUMN budget_previsionnel numeric;