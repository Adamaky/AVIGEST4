-- ============================================================
-- Migration 006 — Stock Dashboard RPC
-- AviGest v26 — Étape 4
-- Date : 17 juin 2026
-- Auteur : Adama Désiré / REVAGRO
-- Objectif : Créer la fonction get_stock_dashboard()
--
-- STRUCTURE CONFIRMÉE lots_stock :
--   - Identifiant lot  : produit + reference
--   - Seuil d'alerte   : seuil_alerte (numeric, défaut 0)
--   - Date entrée      : date_fabrication
--   - Statut actif     : statut = 'EN STOCK'
-- ============================================================

CREATE OR REPLACE FUNCTION get_stock_dashboard(p_ferme_id UUID)
RETURNS TABLE (
  lot_id              UUID,
  produit             TEXT,
  reference           TEXT,
  unite               TEXT,
  date_fabrication    DATE,
  quantite_initiale   NUMERIC,
  quantite_restante   NUMERIC,
  seuil_alerte        NUMERIC,
  en_alerte           BOOLEAN,
  consomme_total      NUMERIC,
  consomme_7j         NUMERIC,
  derniere_imputation TIMESTAMPTZ,
  statut              TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT
    ls.id                                          AS lot_id,
    ls.produit                                     AS produit,
    ls.reference                                   AS reference,
    ls.unite                                       AS unite,
    ls.date_fabrication                            AS date_fabrication,
    ls.quantite_initiale                           AS quantite_initiale,
    ls.quantite_restante                           AS quantite_restante,
    ls.seuil_alerte                                AS seuil_alerte,

    -- Alerte : vrai si stock restant <= seuil (et seuil > 0)
    (ls.seuil_alerte > 0 AND ls.quantite_restante <= ls.seuil_alerte)
                                                   AS en_alerte,

    -- Total consommé depuis création (somme des SORTIES)
    COALESCE(
      (SELECT SUM(ms.quantite)
       FROM mouvements_stock ms
       WHERE ms.lot_id = ls.id
         AND ms.type_mouvement = 'SORTIE'),
      0
    )                                              AS consomme_total,

    -- Consommé sur les 7 derniers jours glissants
    COALESCE(
      (SELECT SUM(ms.quantite)
       FROM mouvements_stock ms
       WHERE ms.lot_id = ls.id
         AND ms.type_mouvement = 'SORTIE'
         AND ms.created_at >= NOW() - INTERVAL '7 days'),
      0
    )                                              AS consomme_7j,

    -- Date/heure de la dernière imputation (dernière SORTIE)
    (SELECT MAX(ms.created_at)
     FROM mouvements_stock ms
     WHERE ms.lot_id = ls.id
       AND ms.type_mouvement = 'SORTIE')           AS derniere_imputation,

    ls.statut                                      AS statut

  FROM lots_stock ls
  WHERE ls.ferme_id = p_ferme_id
    AND ls.statut = 'EN STOCK'
  ORDER BY ls.date_fabrication DESC;
END;
$$;

-- Permissions : accès autorisé pour le rôle anon (frontend PIN-based)
GRANT EXECUTE ON FUNCTION get_stock_dashboard(UUID) TO anon;

-- ============================================================
-- TEST DE VALIDATION — À exécuter immédiatement après
-- ============================================================
-- SELECT * FROM get_stock_dashboard('e56574a9-54c1-430d-b480-b9bdd1090dd7');
--
-- Résultat attendu :
--   lot_id            → uuid du lot Aliment de démarrage
--   produit           → 'Aliment de démarrage' (ou nom exact saisi)
--   quantite_initiale → 500
--   quantite_restante → 470
--   seuil_alerte      → 0 (défaut actuel)
--   en_alerte         → false (seuil = 0 → condition désactivée)
--   consomme_total    → 30 (500 - 470)
--   consomme_7j       → dépend des dates des mouvements
--   derniere_imputation → timestamp de la dernière session agent
-- ============================================================
