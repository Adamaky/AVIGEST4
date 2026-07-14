-- 039_rpc_livrer_commande.sql
-- Session v26.24 - CRM Etape 3
-- Livraison atomique d'une commande : tout ou rien.

DROP FUNCTION IF EXISTS livrer_commande(uuid, jsonb);

CREATE OR REPLACE FUNCTION livrer_commande(
  p_commande_id uuid,
  p_lignes jsonb
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_ferme_id    uuid;
  v_client      text;
  v_statut      text;
  v_ligne       jsonb;
  v_ligne_id    uuid;
  v_bande_id    uuid;
  v_prod_nom    text;
  v_prod_decr   boolean;
  v_prod_unite  text;
  v_qte         numeric;
  v_prix        numeric;
  v_nb          integer;
  v_montant     numeric;
  v_total       numeric := 0;
  v_nb_ecr      integer := 0;
BEGIN
  -- Garde-fou multi-tenant : fail-closed
  v_ferme_id := get_ferme_id();
  IF v_ferme_id IS NULL THEN
    RAISE EXCEPTION 'Ferme non identifiee';
  END IF;

  -- La commande appartient-elle bien a cette ferme ?
  SELECT c.statut, cl.nom
    INTO v_statut, v_client
  FROM commandes c
  JOIN clients cl ON cl.id = c.client_id
  WHERE c.id = p_commande_id AND c.ferme_id = v_ferme_id;

  IF v_client IS NULL THEN
    RAISE EXCEPTION 'Commande introuvable pour cette ferme';
  END IF;

  IF v_statut = 'LIVREE' THEN
    RAISE EXCEPTION 'Commande deja livree';
  END IF;

  -- Boucle sur les lignes transmises
  FOR v_ligne IN SELECT * FROM jsonb_array_elements(p_lignes)
  LOOP
    v_ligne_id := (v_ligne->>'id')::uuid;
    v_qte      := (v_ligne->>'quantite')::numeric;
    v_prix     := (v_ligne->>'prix_reel')::numeric;
    v_nb       := NULLIF(v_ligne->>'nb_sujets','')::integer;

    -- La base est la source de verite pour le produit et la bande
    SELECT l.bande_id, p.nom, p.decremente_effectif, p.unite
      INTO v_bande_id, v_prod_nom, v_prod_decr, v_prod_unite
    FROM commande_lignes l
    JOIN produits_catalogue p ON p.id = l.produit_id
    WHERE l.id = v_ligne_id
      AND l.commande_id = p_commande_id
      AND l.ferme_id = v_ferme_id;

    IF v_prod_nom IS NULL THEN
      RAISE EXCEPTION 'Ligne introuvable dans cette commande';
    END IF;

    IF v_bande_id IS NULL THEN
      RAISE EXCEPTION 'Ligne sans bande : impossible d''imputer la recette';
    END IF;

    IF v_prod_decr AND (v_nb IS NULL OR v_nb <= 0) THEN
      RAISE EXCEPTION 'Nombre de sujets obligatoire pour le produit %', v_prod_nom;
    END IF;

    v_montant := ROUND(v_qte * v_prix);
    v_total   := v_total + v_montant;

    -- 1. Figer le reel sur la ligne
    UPDATE commande_lignes
       SET prix_reel = v_prix,
           quantite  = v_qte,
           nb_sujets = v_nb
     WHERE id = v_ligne_id;

    -- 2. Ecriture RECETTE au journal, sur la bande de la ligne
    INSERT INTO journal (
      ferme_id, bande_id, date_ecriture, type_ecriture, categorie,
      libelle, unite, quantite, prix_unitaire, montant, beneficiaire, statut
    ) VALUES (
      v_ferme_id, v_bande_id, CURRENT_DATE, 'RECETTE',
      'Vente ' || v_prod_nom,
      v_prod_nom || ' - ' || v_qte || ' ' || v_prod_unite
        || COALESCE(' (' || v_nb || ' sujets)', '')
        || ' - ' || v_prix || ' FCFA/' || v_prod_unite
        || ' - ' || v_montant || ' FCFA - ' || v_client,
      v_prod_unite, v_qte, v_prix, v_montant, v_client, 'CONFIRME'
    );
    v_nb_ecr := v_nb_ecr + 1;

    -- 3. Sortie d'effectif si le produit decremente
    IF v_prod_decr THEN
      UPDATE bandes
         SET effectif_vendu = COALESCE(effectif_vendu, 0) + v_nb
       WHERE id = v_bande_id AND ferme_id = v_ferme_id;
    END IF;
  END LOOP;

  -- 4. Cloturer la commande
  UPDATE commandes
     SET statut = 'LIVREE'
   WHERE id = p_commande_id AND ferme_id = v_ferme_id;

  RETURN jsonb_build_object(
    'ok', true,
    'total', v_total,
    'ecritures', v_nb_ecr
  );
END;
$$;

GRANT EXECUTE ON FUNCTION livrer_commande(uuid, jsonb) TO anon, authenticated;