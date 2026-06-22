-- ============================================================
-- Migration 010 — Filtre CRU dans vue_dashboard_bande
-- AviGest v26 — 22 juin 2026
-- Objectif : corriger le calcul CRU (bug B6)
-- Catégories CRU : Alimentation, Vaccin, Médicament, Poussin
-- ============================================================

CREATE OR REPLACE VIEW vue_dashboard_bande AS
SELECT 
    b.id AS bande_id,
    b.ferme_id,
    b.id_bande,
    b.date_arrivee,
    b.effectif_initial,
    b.race,
    b.statut,
    bat.numero AS batiment_num,
    CURRENT_DATE - b.date_arrivee AS age_jours,
    COALESCE(sum(
        CASE
            WHEN st.categorie = ANY (ARRAY['MortaliteMatin'::text, 'MortaliteSoir'::text]) THEN st.valeur
            ELSE 0::numeric
        END), 0::numeric) AS morts_cumul,
    b.effectif_initial::numeric - COALESCE(sum(
        CASE
            WHEN st.categorie = ANY (ARRAY['MortaliteMatin'::text, 'MortaliteSoir'::text]) THEN st.valeur
            ELSE 0::numeric
        END), 0::numeric) AS effectif_actuel,
    (SELECT st2.valeur FROM saisies_techniques st2
        WHERE st2.bande_id = b.id AND st2.categorie = 'PoidsMoyen'::text
        ORDER BY st2.date_saisie DESC LIMIT 1) AS poids_moyen_g,
    (SELECT st3.valeur FROM saisies_techniques st3
        WHERE st3.bande_id = b.id AND st3.categorie = 'Temperature'::text 
        AND st3.date_saisie = CURRENT_DATE
        ORDER BY st3.valeur DESC LIMIT 1) AS temp_max_jour,
    (SELECT st4.valeur FROM saisies_techniques st4
        WHERE st4.bande_id = b.id AND st4.categorie = 'Hygrometrie'::text 
        AND st4.date_saisie = CURRENT_DATE
        ORDER BY st4.created_at DESC LIMIT 1) AS hygro_jour,
    COALESCE((SELECT sum(st5.valeur) AS sum FROM saisies_techniques st5
        WHERE st5.bande_id = b.id 
        AND (st5.categorie = ANY (ARRAY['MortaliteMatin'::text, 'MortaliteSoir'::text])) 
        AND st5.date_saisie = CURRENT_DATE), 0::numeric) AS mortalite_jour,
    COALESCE((SELECT sum(j.montant) AS sum
        FROM journal j
        WHERE j.bande_id = b.id 
        AND j.type_ecriture = 'DEPENSE'::text), 0::numeric) AS total_depenses,
    -- NOUVEAU : total dépenses CRU uniquement (bug B6 corrigé)
    COALESCE((SELECT sum(j_cru.montant) AS sum
        FROM journal j_cru
        WHERE j_cru.bande_id = b.id 
        AND j_cru.type_ecriture = 'DEPENSE'::text
        AND j_cru.categorie IN ('Alimentation','Vaccin','Médicament','Poussin')
        ), 0::numeric) AS total_depenses_cru,
    COALESCE((SELECT sum(j2.montant) AS sum
        FROM journal j2
        WHERE j2.bande_id = b.id 
        AND j2.type_ecriture = 'RECETTE'::text), 0::numeric) AS total_recettes,
    COALESCE((SELECT sum(
        CASE
            WHEN j3.type_ecriture = 'RECETTE'::text THEN j3.montant
            ELSE - j3.montant
        END) AS sum
        FROM journal j3
        WHERE j3.bande_id = b.id), 0::numeric) AS marge_nette
FROM bandes b
JOIN batiments bat ON bat.id = b.batiment_id
LEFT JOIN saisies_techniques st ON st.bande_id = b.id
GROUP BY b.id, b.ferme_id, b.id_bande, b.date_arrivee, b.effectif_initial, b.race, b.statut, bat.numero;

-- Permissions
GRANT SELECT ON vue_dashboard_bande TO anon;
