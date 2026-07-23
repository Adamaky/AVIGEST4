-- =====================================================================
-- Migration 047 — Nom commercial des fermes (CRM étape 3, morceau 6)
-- =====================================================================
-- La table fermes possède déjà nom, proprietaire, telephone, ville,
-- pays et email (vérifié en base le 23/07/2026).
--
-- `nom` sert d'identifiant technique (REVAGRO, ALIRAH2026) et s'affiche
-- possiblement au login — on n'y touche pas.
--
-- `nom_commercial` est le nom destiné aux clients : il apparaît en
-- en-tête des reçus de paiement et, plus tard, des bons de commande.
-- Facultatif : si vide, l'app affiche `nom` en repli.
-- =====================================================================

ALTER TABLE public.fermes
  ADD COLUMN nom_commercial text;