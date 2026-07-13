-- ============================================================
-- Migration 036 — Coeur du CRM : commandes, commande_lignes, paiements
-- Projet AviGest v26 — session v26.22
-- ============================================================
-- CONTEXTE : diagnostic base du 11/07/2026 a révélé deux tables
-- héritées non documentées dans la Bible :
--   - ventes    (0 ligne, aucune occurrence dans index.html)
--   - paiements (0 ligne, aucune occurrence dans index.html, FK vers ventes)
-- Ancien modèle : 1 vente = 1 seul produit (colonnes produit/quantite/
-- prix_unitaire directement sur la ligne de vente) → incompatible avec le
-- besoin réel (commande multi-produits ET multi-bandes).
-- Décision Adama (11/07/2026) : tables mortes supprimées, remplacées par
-- le modèle en-tête + lignes ci-dessous.
--
-- Diagnostic des types (vérifié en base) :
--   clients.id            = uuid
--   produits_catalogue.id = uuid
--   bandes.id             = uuid
--   get_ferme_id()        = uuid
--   Patron RLS repris de clients_isolation :
--     USING (ferme_id = get_ferme_id()) WITH CHECK (idem)
--
-- Décisions métier actées :
--   - Pas de colonne total sur commandes (calcul à la volée depuis les lignes)
--   - Chaque paiement rattaché à UNE commande précise : commande_id NOT NULL
--   - Une ligne = 1 produit + 1 bande (multi-produits ET multi-bandes)
--   - bande_id OPTIONNEL en base (fientes/abats hors bande) — l'écran
--     l'exigera pour les produits avec decremente_effectif = true
--   - Prix prévu (à la commande) + prix réel (à la livraison), les deux gardés
--   - Tous moyens de paiement autorisés
-- ============================================================


-- ------------------------------------------------------------
-- 0. Nettoyage des tables mortes héritées
--    (0 ligne, 0 référence dans le code — suppression sans risque)
--    L'ordre importe : paiements dépend de ventes.
-- ------------------------------------------------------------
DROP TABLE IF EXISTS public.paiements;
DROP TABLE IF EXISTS public.ventes;


-- ------------------------------------------------------------
-- 1. Table commandes (en-tête du bon de commande)
-- ------------------------------------------------------------
CREATE TABLE public.commandes (
    id                    uuid        NOT NULL DEFAULT gen_random_uuid(),
    ferme_id              uuid        NOT NULL,
    client_id             uuid        NOT NULL,
    date_commande         date        NOT NULL DEFAULT CURRENT_DATE,
    statut                text        NOT NULL DEFAULT 'PRECOMMANDE',
    date_reglement_prevue date,       -- pour l'alerte J-1 (NULL si non fixée)
    note                  text,
    created_at            timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT commandes_pkey PRIMARY KEY (id),
    CONSTRAINT commandes_client_id_fkey
        FOREIGN KEY (client_id) REFERENCES public.clients (id),
    CONSTRAINT commandes_statut_check
        CHECK (statut IN ('PRECOMMANDE', 'PLANIFIEE', 'LIVREE', 'ANNULEE'))
);

ALTER TABLE public.commandes ENABLE ROW LEVEL SECURITY;

CREATE POLICY commandes_isolation ON public.commandes
    FOR ALL
    USING (ferme_id = get_ferme_id())
    WITH CHECK (ferme_id = get_ferme_id());


-- ------------------------------------------------------------
-- 2. Table commande_lignes (détail : 1 ligne = 1 produit + 1 bande)
-- ------------------------------------------------------------
CREATE TABLE public.commande_lignes (
    id           uuid        NOT NULL DEFAULT gen_random_uuid(),
    ferme_id     uuid        NOT NULL,
    commande_id  uuid        NOT NULL,
    produit_id   uuid        NOT NULL,
    bande_id     uuid,       -- optionnel : produits hors bande (fientes, abats)
    quantite     numeric     NOT NULL,
    prix_prevu   numeric     NOT NULL DEFAULT 0,  -- prix unitaire à la commande
    prix_reel    numeric,    -- prix unitaire à la livraison (NULL tant que non livré)
    created_at   timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT commande_lignes_pkey PRIMARY KEY (id),
    CONSTRAINT commande_lignes_commande_id_fkey
        FOREIGN KEY (commande_id) REFERENCES public.commandes (id) ON DELETE CASCADE,
    CONSTRAINT commande_lignes_produit_id_fkey
        FOREIGN KEY (produit_id) REFERENCES public.produits_catalogue (id),
    CONSTRAINT commande_lignes_bande_id_fkey
        FOREIGN KEY (bande_id) REFERENCES public.bandes (id)
);

ALTER TABLE public.commande_lignes ENABLE ROW LEVEL SECURITY;

CREATE POLICY commande_lignes_isolation ON public.commande_lignes
    FOR ALL
    USING (ferme_id = get_ferme_id())
    WITH CHECK (ferme_id = get_ferme_id());


-- ------------------------------------------------------------
-- 3. Table paiements (reçus rattachés au bon de commande)
-- ------------------------------------------------------------
CREATE TABLE public.paiements (
    id            uuid        NOT NULL DEFAULT gen_random_uuid(),
    ferme_id      uuid        NOT NULL,
    commande_id   uuid        NOT NULL,   -- chaque paiement = 1 commande précise
    client_id     uuid        NOT NULL,   -- redondance contrôlée (créances client sans jointure)
    montant       numeric     NOT NULL,
    date_paiement date        NOT NULL DEFAULT CURRENT_DATE,
    moyen         text        NOT NULL DEFAULT 'CASH',
    type          text        NOT NULL DEFAULT 'ACOMPTE',
    note          text,
    created_at    timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT paiements_pkey PRIMARY KEY (id),
    CONSTRAINT paiements_commande_id_fkey
        FOREIGN KEY (commande_id) REFERENCES public.commandes (id) ON DELETE CASCADE,
    CONSTRAINT paiements_client_id_fkey
        FOREIGN KEY (client_id) REFERENCES public.clients (id),
    CONSTRAINT paiements_moyen_check
        CHECK (moyen IN ('CASH', 'MOBILE_MONEY', 'VIREMENT', 'CHEQUE', 'AUTRE')),
    CONSTRAINT paiements_type_check
        CHECK (type IN ('ACOMPTE', 'SOLDE'))
);

ALTER TABLE public.paiements ENABLE ROW LEVEL SECURITY;

CREATE POLICY paiements_isolation ON public.paiements
    FOR ALL
    USING (ferme_id = get_ferme_id())
    WITH CHECK (ferme_id = get_ferme_id());


-- ------------------------------------------------------------
-- 4. Index pour les lectures fréquentes
-- ------------------------------------------------------------
CREATE INDEX idx_commandes_client    ON public.commandes (client_id);
CREATE INDEX idx_commande_lignes_cmd ON public.commande_lignes (commande_id);
CREATE INDEX idx_paiements_commande  ON public.paiements (commande_id);
CREATE INDEX idx_paiements_client    ON public.paiements (client_id);

-- ============================================================
-- Fin migration 036
-- ============================================================
