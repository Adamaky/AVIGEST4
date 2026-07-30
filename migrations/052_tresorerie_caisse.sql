-- ============================================================
-- Migration 052 — Module Trésorerie / Caisse (§16.2 étape 5)
-- ============================================================
-- Reflète l'état réel en base au 30/07/2026 (v26.39). Construite
-- par étapes lors de la session, consolidée ici en un seul fichier
-- (règle : un fichier migration = l'état réel en base).
--
-- OBJECTIF : vue "caisse réelle" de la ferme, distincte des
-- créances (séparation OHADA, §16.1). La caisse est GLOBALE par
-- ferme (un seul tiroir, l'argent est fongible). La rentabilité
-- PAR BANDE est un autre chantier (s'appuiera sur journal.bande_id
-- + get_dashboard) — ne jamais fusionner les deux notions.
--
-- DIAGNOSTIC FONDATEUR (base réelle, session du jour) :
--   - `paiements` = encaissements de commandes uniquement, n'écrit
--     jamais dans `journal` (vérifié : 59 000 F de paiements ≠
--     181 500 F de ventes journal).
--   - `journal` catégories 'Vente ...' = la VENTE à la livraison =
--     une CRÉANCE, PAS un encaissement → EXCLUE de la caisse.
--   - `journal` catégorie 'Penalite de retard' = écrite au moment
--     de l'encaissement réel (§22.5) = vrai mouvement de caisse →
--     INCLUSE (vérifié : 0 paiement ne référence une pénalité).
--   - Toutes les DEPENSE du journal = sorties de caisse réelles,
--     Y COMPRIS 'Achat stock' : l'argent quitte physiquement le
--     tiroir même si on reçoit du stock en échange. CHOIX ASSUMÉ.
--     ⚠️ DIFFÉRENCE VOLONTAIRE AVEC LE CRU : le CRU exclut 'Achat
--     stock' (pas une charge consommée, §4.1), la CAISSE l'inclut
--     (décaissement réel). Deux règles, deux questions distinctes —
--     ne pas "aligner" la caisse sur le CRU par erreur.
--
-- SOLDE INITIAL : la base ne connaissait pas le montant en tiroir
-- au démarrage. Ajouté au niveau ferme, avec une DATE DE DÉBUT DE
-- SUIVI. On ne compte que les mouvements dont la date >= cette date
-- (jour J inclus). Le solde initial = montant AU TOUT DÉBUT de
-- date_debut_caisse, avant tout mouvement de ce jour.
-- Modification traçable (option B) : table caisse_ajustements +
-- RPC modifier_solde_initial (motif obligatoire pour une modif,
-- pas pour la 1re saisie).
--
-- Formule :
--   Solde = solde_caisse_initial
--         + SUM(paiements non annulés, date >= date_debut)
--         + SUM(journal 'Penalite de retard', date >= date_debut)
--         − SUM(journal DEPENSE, date >= date_debut)
-- ============================================================

-- ------------------------------------------------------------
-- 1) Colonnes solde initial + date de début sur `fermes`
--    (numeric accepte 0 et négatif : solde à découvert possible)
-- ------------------------------------------------------------
ALTER TABLE fermes
  ADD COLUMN IF NOT EXISTS solde_caisse_initial numeric NOT NULL DEFAULT 0;

ALTER TABLE fermes
  ADD COLUMN IF NOT EXISTS date_debut_caisse date;

-- ------------------------------------------------------------
-- 2) Table caisse_ajustements — carnet des changements du solde
--    initial (traçabilité, principe d'intangibilité comptable)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS caisse_ajustements (
  id                uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  ferme_id          uuid NOT NULL,
  ancienne_valeur   numeric NOT NULL,
  nouvelle_valeur   numeric NOT NULL,
  ancienne_date     date,
  nouvelle_date     date,
  motif             text,
  saisi_par         uuid,
  created_at        timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE caisse_ajustements ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS caisse_ajustements_isolation ON caisse_ajustements;
CREATE POLICY caisse_ajustements_isolation
  ON caisse_ajustements
  FOR ALL
  TO anon
  USING (ferme_id = get_ferme_id())
  WITH CHECK (ferme_id = get_ferme_id());

-- ------------------------------------------------------------
-- 3) RPC get_solde_caisse() — agrégats + solde + date_debut
--    (1 ligne ; appel léger pour l'écran et un futur badge)
-- ------------------------------------------------------------
DROP FUNCTION IF EXISTS public.get_solde_caisse();

CREATE OR REPLACE FUNCTION public.get_solde_caisse()
RETURNS TABLE(
  solde_initial   numeric,
  date_debut      date,
  total_encaisse  numeric,
  total_penalites numeric,
  total_depenses  numeric,
  solde           numeric
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_ferme_id   uuid;
  v_initial    numeric;
  v_debut      date;
  v_encaisse   numeric;
  v_penalites  numeric;
  v_depenses   numeric;
BEGIN
  v_ferme_id := get_ferme_id();
  IF v_ferme_id IS NULL THEN
    RAISE EXCEPTION 'ferme_id introuvable';
  END IF;

  SELECT COALESCE(solde_caisse_initial, 0), date_debut_caisse
    INTO v_initial, v_debut
  FROM fermes WHERE id = v_ferme_id;
  v_initial := COALESCE(v_initial, 0);

  SELECT COALESCE(SUM(montant), 0) INTO v_encaisse
  FROM paiements
  WHERE ferme_id = v_ferme_id AND annule = false
    AND (v_debut IS NULL OR date_paiement >= v_debut);

  SELECT COALESCE(SUM(montant), 0) INTO v_penalites
  FROM journal
  WHERE ferme_id = v_ferme_id AND type_ecriture = 'RECETTE'
    AND categorie = 'Penalite de retard'
    AND (v_debut IS NULL OR date_ecriture >= v_debut);

  SELECT COALESCE(SUM(montant), 0) INTO v_depenses
  FROM journal
  WHERE ferme_id = v_ferme_id AND type_ecriture = 'DEPENSE'
    AND (v_debut IS NULL OR date_ecriture >= v_debut);

  RETURN QUERY SELECT
    v_initial, v_debut, v_encaisse, v_penalites, v_depenses,
    (v_initial + v_encaisse + v_penalites - v_depenses);
END;
$$;

-- ------------------------------------------------------------
-- 4) RPC get_historique_caisse() — liste unifiée des mouvements
--    de caisse réels (paiements + pénalités encaissées + dépenses),
--    à partir de date_debut_caisse, tri date décroissante, LIMIT 50.
--    AUCUNE ligne de vente/créance ('Vente ...').
--    Le sous-SELECT enveloppant est nécessaire pour appliquer
--    ORDER BY + LIMIT à l'ensemble de l'UNION.
-- ------------------------------------------------------------
DROP FUNCTION IF EXISTS public.get_historique_caisse();

CREATE OR REPLACE FUNCTION public.get_historique_caisse()
RETURNS TABLE(
  source     text,
  date_mvt   date,
  libelle    text,
  montant    numeric,
  reference  text
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_ferme_id uuid;
  v_debut    date;
BEGIN
  v_ferme_id := get_ferme_id();
  IF v_ferme_id IS NULL THEN
    RAISE EXCEPTION 'ferme_id introuvable';
  END IF;

  SELECT date_debut_caisse INTO v_debut
  FROM fermes WHERE id = v_ferme_id;

  RETURN QUERY
  SELECT * FROM (
    -- Paiements de commandes (non annulés)
    SELECT
      'PAIEMENT'::text AS source,
      p.date_paiement  AS date_mvt,
      ('Paiement — ' || COALESCE(cl.nom, 'client'))::text AS libelle,
      p.montant        AS montant,
      ('REC-' || p.annee || '-' || lpad(p.numero_seq::text, 4, '0'))::text AS reference
    FROM paiements p
    LEFT JOIN clients cl ON cl.id = p.client_id
    WHERE p.ferme_id = v_ferme_id AND p.annule = false
      AND (v_debut IS NULL OR p.date_paiement >= v_debut)

    UNION ALL

    -- Pénalités encaissées (RECETTE journal, catégorie dédiée)
    SELECT
      'PENALITE'::text,
      j.date_ecriture,
      j.beneficiaire::text,
      j.montant,
      j.reference::text
    FROM journal j
    WHERE j.ferme_id = v_ferme_id AND j.type_ecriture = 'RECETTE'
      AND j.categorie = 'Penalite de retard'
      AND (v_debut IS NULL OR j.date_ecriture >= v_debut)

    UNION ALL

    -- Dépenses (toutes catégories, y compris 'Achat stock')
    -- montant en négatif (sortie)
    SELECT
      'DEPENSE'::text,
      j.date_ecriture,
      COALESCE(j.libelle, j.categorie)::text,
      -j.montant,
      j.categorie::text
    FROM journal j
    WHERE j.ferme_id = v_ferme_id AND j.type_ecriture = 'DEPENSE'
      AND (v_debut IS NULL OR j.date_ecriture >= v_debut)
  ) mvts
  ORDER BY date_mvt DESC
  LIMIT 50;
END;
$$;

-- ------------------------------------------------------------
-- 5) RPC modifier_solde_initial(montant, date, motif)
--    Atomique : met à jour fermes ET trace dans caisse_ajustements.
--    Motif obligatoire si un ajustement existe déjà (= modification).
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.modifier_solde_initial(
  p_nouveau_montant numeric,
  p_nouvelle_date   date DEFAULT NULL,
  p_motif           text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_ferme_id   uuid;
  v_ancien     numeric;
  v_ancienne_d date;
  v_nb_ajust   integer;
  v_motif      text;
BEGIN
  v_ferme_id := get_ferme_id();
  IF v_ferme_id IS NULL THEN
    RAISE EXCEPTION 'ferme_id introuvable';
  END IF;

  SELECT COALESCE(solde_caisse_initial, 0), date_debut_caisse
    INTO v_ancien, v_ancienne_d
  FROM fermes WHERE id = v_ferme_id;

  SELECT COUNT(*) INTO v_nb_ajust
  FROM caisse_ajustements WHERE ferme_id = v_ferme_id;

  v_motif := NULLIF(trim(COALESCE(p_motif, '')), '');
  IF v_nb_ajust > 0 AND v_motif IS NULL THEN
    RETURN jsonb_build_object(
      'ok', false,
      'error', 'Motif obligatoire pour modifier un solde initial déjà défini.'
    );
  END IF;

  UPDATE fermes
  SET solde_caisse_initial = p_nouveau_montant,
      date_debut_caisse    = COALESCE(p_nouvelle_date, date_debut_caisse),
      updated_at           = now()
  WHERE id = v_ferme_id;

  INSERT INTO caisse_ajustements (
    ferme_id, ancienne_valeur, nouvelle_valeur,
    ancienne_date, nouvelle_date, motif
  ) VALUES (
    v_ferme_id, v_ancien, p_nouveau_montant,
    v_ancienne_d, COALESCE(p_nouvelle_date, v_ancienne_d), v_motif
  );

  RETURN jsonb_build_object(
    'ok', true,
    'ancien', v_ancien,
    'nouveau', p_nouveau_montant
  );
END;
$$;