-- Migration 032 : colonnes surcharge manuelle effectif final (phase 2 clôture de bande)
-- Ajoute deux colonnes nullables sur bandes pour permettre au gérant de corriger
-- l'effectif final calculé, avec note obligatoire (décision Option C, Bible §15).
-- NULL par défaut = le calcul auto (effectif_initial - mortalités - effectif_vendu) fait foi.
-- Migration sûre : colonnes nullables, sans défaut, aucun impact sur les lignes existantes.

ALTER TABLE bandes
  ADD COLUMN effectif_final_corrige integer,
  ADD COLUMN effectif_final_note text;

COMMENT ON COLUMN bandes.effectif_final_corrige IS 'Effectif final surcharge manuellement par le gerant (NULL = calcul auto fait foi)';
COMMENT ON COLUMN bandes.effectif_final_note IS 'Motif obligatoire de la correction effectif';
