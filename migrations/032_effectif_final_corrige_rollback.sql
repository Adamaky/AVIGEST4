-- Rollback migration 032 : suppression des colonnes surcharge effectif final
-- À exécuter uniquement pour annuler la migration 032.
-- ATTENTION : supprime toute correction d'effectif déjà saisie par un gérant.

ALTER TABLE bandes
  DROP COLUMN effectif_final_corrige,
  DROP COLUMN effectif_final_note;
