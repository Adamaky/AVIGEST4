-- =====================================================================
-- Migration 046 — Numérotation et annulation des paiements (CRM étape 3)
-- =====================================================================
-- Ajoute à la table paiements :
--   · annee       : année du reçu (2026, 2027...)
--   · numero_seq  : compteur, repart à 1 chaque année et pour chaque ferme
--   · annule      : marque un paiement annulé (jamais de suppression)
--
-- Numéro affiché reconstruit côté app : REC-{annee}-{numero_seq sur 4 chiffres}
-- Exemple : annee=2026, numero_seq=1  ->  REC-2026-0001
--
-- Table vide au moment de cette migration (0 ligne vérifiée),
-- donc aucune reprise de données nécessaire.
-- =====================================================================

ALTER TABLE public.paiements
  ADD COLUMN annee      integer NOT NULL DEFAULT EXTRACT(YEAR FROM CURRENT_DATE),
  ADD COLUMN numero_seq integer NOT NULL,
  ADD COLUMN annule     boolean NOT NULL DEFAULT false;

-- Garantit qu'il ne peut jamais exister deux reçus portant
-- le même numéro pour une même ferme la même année.
ALTER TABLE public.paiements
  ADD CONSTRAINT paiements_numero_unique
  UNIQUE (ferme_id, annee, numero_seq);

-- Protection oubliée à la création de la table : pas de montant nul ou négatif.
ALTER TABLE public.paiements
  ADD CONSTRAINT paiements_montant_positif
  CHECK (montant > 0);

-- Accélère la recherche des paiements d'une commande (bloc Règlement).
CREATE INDEX IF NOT EXISTS idx_paiements_commande
  ON public.paiements (commande_id);