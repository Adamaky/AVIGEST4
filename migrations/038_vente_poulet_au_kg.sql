-- 038_vente_poulet_au_kg.sql
-- Session v26.24 — CRM Etape 3
-- Le poulet entier abattu se vend au kg, et non a l'unite.
-- Consequence : la quantite facturee (kg) n'est plus le nombre de betes
-- sorties de la bande. On dissocie les deux.

-- 1. Corriger l'unite du poulet abattu (les 2 fermes)
UPDATE produits_catalogue
SET unite = 'kg'
WHERE nom = 'Poulet entier abattu';

-- 2. Ajouter le compteur de sujets sur la ligne de commande
ALTER TABLE commande_lignes
ADD COLUMN IF NOT EXISTS nb_sujets INTEGER;

COMMENT ON COLUMN commande_lignes.nb_sujets IS
  'Nombre de sujets retires de l''effectif de la bande. Obligatoire cote applicatif si le produit a decremente_effectif = true. NULL sinon (abats, fientes).';