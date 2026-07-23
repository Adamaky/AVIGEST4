-- Migration 040 : ajout date de livraison prévue sur commandes
ALTER TABLE commandes
ADD COLUMN date_livraison_prevue date;

COMMENT ON COLUMN commandes.date_livraison_prevue IS 'Date de livraison probable, saisie manuellement par le gérant';