-- ============================================================
-- Migration 035 — CRM Étape 1 : tables socle
-- Crée : produits_catalogue + clients
-- Isolation multi-fermes : ferme_id + RLS via get_ferme_id()
-- Aucune modification de l'existant. On ajoute uniquement.
-- ============================================================

-- ------------------------------------------------------------
-- TABLE 1 : produits_catalogue (le "menu" de vente)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.produits_catalogue (
    id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    ferme_id            uuid NOT NULL,
    nom                 text NOT NULL,
    unite               text NOT NULL DEFAULT 'unite',   -- 'unite' | 'kg' | 'sac'
    prix_reference      numeric(12,2) DEFAULT 0,          -- prix indicatif, modifiable à la commande
    decremente_effectif boolean NOT NULL DEFAULT false,   -- true = retire un sujet de la bande (vivant/abattu)
    actif               boolean NOT NULL DEFAULT true,     -- false = masqué sans suppression
    created_at          timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.produits_catalogue ENABLE ROW LEVEL SECURITY;

CREATE POLICY produits_catalogue_isolation ON public.produits_catalogue
    FOR ALL
    USING (ferme_id = public.get_ferme_id())
    WITH CHECK (ferme_id = public.get_ferme_id());

-- ------------------------------------------------------------
-- TABLE 2 : clients (le carnet d'adresses)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.clients (
    id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    ferme_id    uuid NOT NULL,
    nom         text NOT NULL,
    telephone   text,                                     -- pour l'envoi WhatsApp
    type        text DEFAULT 'particulier',               -- 'particulier' | 'revendeur' | 'restaurant' | 'autre'
    note        text,
    actif       boolean NOT NULL DEFAULT true,
    created_at  timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.clients ENABLE ROW LEVEL SECURITY;

CREATE POLICY clients_isolation ON public.clients
    FOR ALL
    USING (ferme_id = public.get_ferme_id())
    WITH CHECK (ferme_id = public.get_ferme_id());

-- ------------------------------------------------------------
-- PRÉ-REMPLISSAGE du catalogue pour les 2 fermes actives
-- REVAGRO  : e56574a9-54c1-430d-b480-b9bdd1090dd7
-- ALIRAH2026 : 40ee764e-d073-463e-b07b-bf95a9d7a675
-- ------------------------------------------------------------
INSERT INTO public.produits_catalogue (ferme_id, nom, unite, decremente_effectif) VALUES
    ('e56574a9-54c1-430d-b480-b9bdd1090dd7', 'Sujet vivant',        'unite', true),
    ('e56574a9-54c1-430d-b480-b9bdd1090dd7', 'Poulet entier abattu','unite', true),
    ('e56574a9-54c1-430d-b480-b9bdd1090dd7', 'Foies & gesiers',     'kg',    false),
    ('e56574a9-54c1-430d-b480-b9bdd1090dd7', 'Cous (tetes + pattes)','kg',   false),
    ('e56574a9-54c1-430d-b480-b9bdd1090dd7', 'Sac de fientes',      'sac',   false),
    ('40ee764e-d073-463e-b07b-bf95a9d7a675', 'Sujet vivant',        'unite', true),
    ('40ee764e-d073-463e-b07b-bf95a9d7a675', 'Poulet entier abattu','unite', true),
    ('40ee764e-d073-463e-b07b-bf95a9d7a675', 'Foies & gesiers',     'kg',    false),
    ('40ee764e-d073-463e-b07b-bf95a9d7a675', 'Cous (tetes + pattes)','kg',   false),
    ('40ee764e-d073-463e-b07b-bf95a9d7a675', 'Sac de fientes',      'sac',   false);

-- ============================================================
-- Fin migration 035
-- ============================================================
