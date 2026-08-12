-- Migration 058 — Adapter la contrainte quote_part au modèle FCFA (module Partenaire)
-- Avant : quote_part devait être entre 0 et 100 (ancien modèle pourcentage).
-- Après : quote_part est un montant investi en FCFA, donc simplement > 0 (sans plafond).
-- Contexte : la Brique A stocke des montants, pas des pourcentages ; le % est calculé à l'affichage.

ALTER TABLE partenaires_bandes
  DROP CONSTRAINT partenaires_bandes_quote_part_check;

ALTER TABLE partenaires_bandes
  ADD CONSTRAINT partenaires_bandes_quote_part_check CHECK (quote_part > 0);