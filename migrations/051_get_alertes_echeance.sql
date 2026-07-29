-- migrations/051_get_alertes_echeance.sql
-- RPC de lecture : commandes livrées non soldées avec échéance de règlement,
-- + catégorie couleur. Source unique de l'alerte échéance (§16.6, §23).
-- Créée en v26.37.

CREATE OR REPLACE FUNCTION public.get_alertes_echeance()
RETURNS TABLE (
    commande_id   uuid,
    client_nom    text,
    date_echeance date,
    jours_restants integer,
    reste_a_payer numeric,
    couleur       text
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_ferme uuid;
BEGIN
    v_ferme := get_ferme_id();
    IF v_ferme IS NULL THEN
        RETURN;
    END IF;

    RETURN QUERY
    WITH totaux AS (
        SELECT
            c.id            AS commande_id,
            c.date_reglement_prevue AS date_echeance,
            cl.nom          AS client_nom,
            COALESCE(SUM(li.quantite * COALESCE(li.prix_reel, li.prix_prevu)), 0) AS total,
            COALESCE((
                SELECT SUM(p.montant) FROM paiements p
                WHERE p.commande_id = c.id AND p.annule = false
            ), 0)           AS paye
        FROM commandes c
        LEFT JOIN clients cl ON cl.id = c.client_id
        LEFT JOIN commande_lignes li ON li.commande_id = c.id
        WHERE c.ferme_id = v_ferme
          AND c.statut = 'LIVREE'
          AND c.date_reglement_prevue IS NOT NULL
        GROUP BY c.id, c.date_reglement_prevue, cl.nom
    )
    SELECT
        t.commande_id,
        t.client_nom,
        t.date_echeance,
        (t.date_echeance - CURRENT_DATE)::integer AS jours_restants,
        (t.total - t.paye)                        AS reste_a_payer,
        CASE
            WHEN t.date_echeance <= CURRENT_DATE     THEN 'ROUGE'
            WHEN t.date_echeance =  CURRENT_DATE + 1 THEN 'JAUNE'
            ELSE 'BLANC'
        END                                       AS couleur
    FROM totaux t
    WHERE (t.total - t.paye) > 0
    ORDER BY t.date_echeance;
END;
$$;