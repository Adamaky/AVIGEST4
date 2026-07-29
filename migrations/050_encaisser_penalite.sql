-- migrations/050_encaisser_penalite.sql
-- RPC encaisser_penalite(p_penalite_id, p_moyen) — encaissement atomique
-- d'une pénalité de retard : écrit la RECETTE au journal (repli tracé sur
-- bande active si commande sans bande) puis bascule paye=true.
-- Fichier recréé a posteriori en v26.37 depuis pg_get_functiondef (la RPC
-- était en base depuis la session fondations pénalités, jamais committée).

CREATE OR REPLACE FUNCTION public.encaisser_penalite(p_penalite_id uuid, p_moyen text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    v_ferme_id    uuid;
    v_commande_id uuid;
    v_client_id   uuid;
    v_montant     numeric;
    v_numero_seq  integer;
    v_annee       integer;
    v_paye        boolean;
    v_annule      boolean;
    v_bande_id    uuid;
    v_client_nom  text;
    v_repli       boolean := false;
    v_ref         text;
    v_libelle     text;
BEGIN
    -- Garde-fou multi-tenant : fail-closed
    v_ferme_id := get_ferme_id();
    IF v_ferme_id IS NULL THEN
        RAISE EXCEPTION 'Ferme non identifiee';
    END IF;

    -- 1. Charger la pénalité + contrôler qu'elle appartient à cette ferme
    SELECT commande_id, client_id, montant, numero_seq, annee, paye, annule
      INTO v_commande_id, v_client_id, v_montant, v_numero_seq, v_annee, v_paye, v_annule
    FROM penalites
    WHERE id = p_penalite_id AND ferme_id = v_ferme_id;

    IF v_commande_id IS NULL THEN
        RAISE EXCEPTION 'Penalite introuvable pour cette ferme';
    END IF;

    IF v_annule THEN
        RAISE EXCEPTION 'Penalite annulee : encaissement impossible';
    END IF;

    IF v_paye THEN
        RAISE EXCEPTION 'Penalite deja encaissee';
    END IF;

    -- Nom du client (bénéficiaire de la recette)
    SELECT nom INTO v_client_nom
    FROM clients
    WHERE id = v_client_id AND ferme_id = v_ferme_id;

    -- 2. Trouver la bande : 1re bande des lignes de la commande
    SELECT l.bande_id INTO v_bande_id
    FROM commande_lignes l
    WHERE l.commande_id = v_commande_id
      AND l.ferme_id = v_ferme_id
      AND l.bande_id IS NOT NULL
    ORDER BY l.created_at
    LIMIT 1;

    -- Repli (Piste 1) : commande sans bande -> bande active la plus récente
    IF v_bande_id IS NULL THEN
        SELECT id INTO v_bande_id
        FROM bandes
        WHERE ferme_id = v_ferme_id
          AND statut = 'EN COURS'
          AND is_deleted = false
        ORDER BY created_at DESC
        LIMIT 1;

        v_repli := true;
    END IF;

    -- Aucune bande imputables du tout : on refuse plutôt qu'écrire un NULL
    IF v_bande_id IS NULL THEN
        RAISE EXCEPTION 'Aucune bande imputable : impossible d''ecrire la recette de penalite';
    END IF;

    -- 3. Écriture RECETTE au journal (format calqué sur livrer_commande)
    v_ref := 'PEN-' || v_annee || '-' || LPAD(v_numero_seq::text, 4, '0');

    v_libelle := 'Penalite retard ' || v_ref
                 || ' - ' || v_montant || ' FCFA - ' || COALESCE(v_client_nom, 'client')
                 || CASE WHEN v_repli
                         THEN ' [rattachement bande active, commande sans bande]'
                         ELSE '' END;

    INSERT INTO journal (
        ferme_id, bande_id, date_ecriture, type_ecriture, categorie,
        libelle, montant, beneficiaire, reference, statut
    ) VALUES (
        v_ferme_id, v_bande_id, CURRENT_DATE, 'RECETTE', 'Penalite de retard',
        v_libelle, v_montant, v_client_nom, v_ref, 'CONFIRME'
    );

    -- 4. Marquer la pénalité encaissée
    UPDATE penalites
       SET paye = true,
           date_paiement = CURRENT_DATE,
           moyen = p_moyen
     WHERE id = p_penalite_id AND ferme_id = v_ferme_id;

    RETURN jsonb_build_object(
        'ok', true,
        'reference', v_ref,
        'montant', v_montant,
        'bande_id', v_bande_id,
        'repli_bande', v_repli
    );
END;
$function$;