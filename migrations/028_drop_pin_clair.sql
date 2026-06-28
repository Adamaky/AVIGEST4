-- Migration 028 — Suppression colonne pin en clair
-- S2 validé en production — les PIN hashés sont actifs
ALTER TABLE utilisateurs DROP COLUMN pin;
