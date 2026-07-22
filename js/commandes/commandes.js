/* ═══════════════════════════════════════════════════════
   js/commandes/commandes.js — Écran Commandes
   ───────────────────────────────────────────────────────
   ÉTAPE 1 : liste  ✅
   ÉTAPE 2 : création  ✅
   ÉTAPE 3 : détail / livraison
     · morceau 1 : affichage détail  ✅
     · morceau 2 : Précommande → Planifiée (assigner bande)  ✅
     · morceau 3 : Planifiée → Livrée (écran confirmation + RPC)  ← ici
   ═══════════════════════════════════════════════════════ */

import { db, fermeId } from '../shared/db.js';
import { esc, toast, zone, fcfa, dateFr } from '../shared/helpers.js';

const LIB_STATUT = {
    PRECOMMANDE: 'Précommande',
    PLANIFIEE:   'Planifiée',
    LIVREE:      'Livrée',
    ANNULEE:     'Annulée'
};

let _panier = [];
let _clients = [];
let _produits = [];
let _planifCmd = null;
let _bandes = [];
let _livrCmd = null;
let _annulCmd = null;


/* ═══════════════════ LISTE ═══════════════════ */
async function renderCommandes() {
    const z = zone();
    if (!z) return;
    z.innerHTML = '<div class="section-title">Commandes</div>'
                + '<div class="gestion-vide">Chargement…</div>';

    const res = await db()
        .from('commandes')
        .select('id, date_commande, statut, date_livraison_prevue, clients(nom), '
              + 'commande_lignes(quantite, prix_prevu, prix_reel)')
        .eq('ferme_id', fermeId())
        .order('date_commande', { ascending: false });

    if (res.error) {
        toast('Erreur : ' + res.error.message, 'error');
        z.innerHTML = '<div class="section-title">Commandes</div>'
                    + '<div class="gestion-vide">Chargement impossible.</div>';
        return;
    }

    const cmds = res.data || [];

    let html = '<div class="gestion-header-cmd">'
             + '<div class="section-title" style="margin:0">Commandes</div>'
             + '<button class="gestion-pastille gestion-pastille-accent" onclick="_nouvelleCommande()">+ Nouvelle</button>'
             + '</div>';

    if (cmds.length === 0) {
        html += '<div class="gestion-vide">Aucune commande pour le moment.</div>';
        z.innerHTML = html;
        return;
    }

    cmds.forEach(function (c) {
        const nom = c.clients ? c.clients.nom : '(client supprimé)';
        const lignes = c.commande_lignes || [];
        let total = 0;
        lignes.forEach(function (l) {
            const p = (l.prix_reel === null || l.prix_reel === undefined)
                    ? l.prix_prevu : l.prix_reel;
            total += Number(l.quantite) * Number(p);
        });
        const cls = 'gestion-badge-' + c.statut.toLowerCase();
        const nbTxt = lignes.length + ' ligne' + (lignes.length > 1 ? 's' : '');
        html += ''
            + '<div class="gestion-carte-cmd" onclick="_ouvrirCommande(\'' + c.id + '\')">'
            +   '<div class="gestion-carte-cmd-info">'
            +     '<div class="gestion-carte-cmd-nom">' + esc(nom) + '</div>'
            +     '<div class="gestion-carte-cmd-meta">'
            +       dateFr(c.date_commande) + ' · ' + nbTxt + ' · ' + fcfa(total)
            +     '</div>'
            +     (c.date_livraison_prevue
                    ? '<div class="gestion-carte-cmd-meta">📅 Livraison prévue : ' + dateFr(c.date_livraison_prevue) + '</div>'
                    : '')
            +   '</div>'
            +   '<span class="gestion-badge ' + cls + '">' + LIB_STATUT[c.statut] + '</span>'
            +   '<span class="gestion-carte-cmd-fleche">›</span>'
            + '</div>';
    });

    z.innerHTML = html;
}


/* ═══════════════════ CRÉATION ═══════════════════ */
async function _nouvelleCommande() {
    const z = zone();
    if (!z) return;
    z.innerHTML = '<div class="section-title">Nouvelle commande</div>'
                + '<div class="gestion-vide">Chargement…</div>';

    const fid = fermeId();
    const [rc, rp] = await Promise.all([
        db().from('clients')
            .select('id, nom, type_client')
            .eq('ferme_id', fid).eq('actif', true)
            .order('nom'),
        db().from('produits_catalogue')
            .select('id, nom, unite, decremente_effectif')
            .eq('ferme_id', fid).eq('actif', true)
            .order('nom')
    ]);

    if (rc.error || rp.error) {
        toast('Erreur de chargement', 'error');
        renderCommandes();
        return;
    }

    _clients = rc.data || [];
    _produits = rp.data || [];
    _panier = [];

    if (_clients.length === 0) {
        z.innerHTML = '<div class="section-title">Nouvelle commande</div>'
            + '<div class="gestion-vide">Aucun client actif. '
            + 'Créez d\'abord un client dans l\'écran Clients.</div>'
            + '<div class="gestion-actions-bas">'
            + '<button class="gestion-pastille gestion-pastille-contour" onclick="renderCommandes()">← Retour</button>'
            + '</div>';
        return;
    }

    _dessinerFormulaire();
}

function _dessinerFormulaire() {
    const z = zone();

    let optClients = '<option value="">— Choisir un client —</option>';
    _clients.forEach(function (c) {
        optClients += '<option value="' + c.id + '">' + esc(c.nom) + '</option>';
    });

    let optProduits = '<option value="">— Produit —</option>';
    _produits.forEach(function (p) {
        optProduits += '<option value="' + p.id + '">'
                     + esc(p.nom) + ' (' + p.unite + ')</option>';
    });

    let lignesHtml = '';
    let total = 0;
    _panier.forEach(function (l, i) {
        const sousTotal = Number(l.quantite) * Number(l.prix_prevu);
        total += sousTotal;
        lignesHtml += ''
            + '<div class="gestion-ligne-panier">'
            +   '<div class="gestion-ligne-info">'
            +     '<div class="gestion-ligne-nom">' + esc(l.produit_nom) + '</div>'
            +     '<div class="gestion-ligne-detail">'
            +       l.quantite + ' ' + l.unite + ' × ' + fcfa(l.prix_prevu)
            +       ' = ' + fcfa(sousTotal)
            +     '</div>'
            +   '</div>'
            +   '<button class="gestion-ligne-suppr" onclick="_retirerLigne(' + i + ')">✕</button>'
            + '</div>';
    });
    if (_panier.length === 0) {
        lignesHtml = '<div class="gestion-lignes-vide">Aucune ligne. Ajoutez un produit ci-dessous.</div>';
    }

    z.innerHTML = ''
        + '<div class="section-title">Nouvelle commande</div>'
        + '<div class="gestion-form-compact">'
        +   '<div class="gestion-form-group">'
        +     '<label class="gestion-form-label">Client</label>'
        +     '<select class="gestion-select" id="cmd-client">' + optClients + '</select>'
        +   '</div>'
        +   '<div class="gestion-form-label" style="margin-top:16px">Lignes de la commande</div>'
        +   '<div id="cmd-panier">' + lignesHtml + '</div>'
        +   '<div class="gestion-bloc-ajout">'
        +     '<select class="gestion-select" id="cmd-produit">' + optProduits + '</select>'
        +     '<div class="gestion-ligne-champs">'
        +       '<input class="gestion-input" id="cmd-qte" type="number" min="0" step="0.01" placeholder="Quantité">'
        +       '<input class="gestion-input" id="cmd-prix" type="number" min="0" step="1" placeholder="Prix unit.">'
        +     '</div>'
        +     '<button class="gestion-btn-ajout-ligne" onclick="_ajouterLigne()">+ Ajouter la ligne</button>'
        +   '</div>'
        +   '<div class="gestion-form-total"><span>Total</span><span>' + fcfa(total) + '</span></div>'
        +   '<div class="gestion-actions-bas">'
        +     '<button class="gestion-pastille gestion-pastille-contour" onclick="renderCommandes()">Annuler</button>'
        +     '<button class="gestion-pastille gestion-pastille-accent" onclick="_enregistrerCommande()">Enregistrer</button>'
        +   '</div>'
        + '</div>';
}

function _ajouterLigne() {
    const produitId = document.getElementById('cmd-produit').value;
    const qte = parseFloat(document.getElementById('cmd-qte').value);
    const prix = parseFloat(document.getElementById('cmd-prix').value);

    if (!produitId) { toast('Choisissez un produit', 'warning'); return; }
    if (!qte || qte <= 0) { toast('Quantité invalide', 'warning'); return; }
    if (prix === null || isNaN(prix) || prix < 0) { toast('Prix invalide', 'warning'); return; }

    const prod = _produits.find(function (p) { return p.id === produitId; });
    if (!prod) { toast('Produit introuvable', 'error'); return; }

    _panier.push({
        produit_id: produitId,
        produit_nom: prod.nom,
        unite: prod.unite,
        quantite: qte,
        prix_prevu: prix
    });

    _dessinerFormulaire();
}

function _retirerLigne(i) {
    _panier.splice(i, 1);
    _dessinerFormulaire();
}

async function _enregistrerCommande() {
    const clientId = document.getElementById('cmd-client').value;
    if (!clientId) { toast('Choisissez un client', 'warning'); return; }
    if (_panier.length === 0) { toast('Ajoutez au moins une ligne', 'warning'); return; }

    const fid = fermeId();

    const rc = await db().from('commandes').insert({
        ferme_id: fid,
        client_id: clientId,
        date_commande: new Date().toISOString().slice(0, 10),
        statut: 'PRECOMMANDE'
    }).select('id').single();

    if (rc.error) {
        toast('Erreur : ' + rc.error.message, 'error');
        return;
    }

    const cmdId = rc.data.id;

    const lignes = _panier.map(function (l) {
        return {
            ferme_id: fid,
            commande_id: cmdId,
            produit_id: l.produit_id,
            quantite: l.quantite,
            prix_prevu: l.prix_prevu
        };
    });

    const rl = await db().from('commande_lignes').insert(lignes);

    if (rl.error) {
        toast('Commande créée mais erreur sur les lignes : ' + rl.error.message, 'error');
        renderCommandes();
        return;
    }

    toast('Commande enregistrée', 'success');
    _panier = [];
    renderCommandes();
}


/* ═══════════════════ DÉTAIL ═══════════════════ */

function _formatPrixLigne(l) {
    const aReel = (l.prix_reel !== null && l.prix_reel !== undefined);
    const prix = aReel ? l.prix_reel : l.prix_prevu;
    let html = fcfa(prix);
    if (!aReel) {
        html += '<span class="gestion-tag-prevu">prévu</span>';
    }
    return html;
}

async function _ouvrirCommande(id) {
    const z = zone();
    if (!z) return;
    z.innerHTML = '<div class="section-title">Commande</div>'
                + '<div class="gestion-vide">Chargement…</div>';

    const res = await db()
        .from('commandes')
        .select('id, date_commande, statut, clients(nom), '
              + 'commande_lignes(id, quantite, prix_prevu, prix_reel, nb_sujets, bande_id, '
              + 'produits_catalogue(nom, unite, decremente_effectif), '
              + 'bandes(id_bande))')
        .eq('ferme_id', fermeId())
        .eq('id', id)
        .single();

    if (res.error || !res.data) {
        toast('Commande introuvable', 'error');
        renderCommandes();
        return;
    }

    const c = res.data;
    const nom = c.clients ? c.clients.nom : '(client supprimé)';
    const lignes = c.commande_lignes || [];
    const cls = 'gestion-badge-' + c.statut.toLowerCase();

    let total = 0;
    lignes.forEach(function (l) {
        const p = (l.prix_reel === null || l.prix_reel === undefined)
                ? l.prix_prevu : l.prix_reel;
        total += Number(l.quantite) * Number(p);
    });

    let html = ''
        + '<div class="gestion-detail-tete">'
        +   '<div class="gestion-detail-client">' + esc(nom) + '</div>'
        +   '<span class="gestion-badge ' + cls + '">' + LIB_STATUT[c.statut] + '</span>'
        + '</div>'
        + '<div class="gestion-detail-date">' + dateFr(c.date_commande) + '</div>';

    if (lignes.length === 0) {
        html += '<div class="gestion-lignes-vide">Aucune ligne sur cette commande.</div>';
    } else {
        lignes.forEach(function (l) {
            const prod = l.produits_catalogue;
            const nomProd = prod ? prod.nom : '(produit supprimé)';
            const unite = prod ? prod.unite : '';
            const prixLigne = (l.prix_reel === null || l.prix_reel === undefined)
                            ? l.prix_prevu : l.prix_reel;
            const sousTotal = Number(l.quantite) * Number(prixLigne);

            // Affichage de la bande assignée (si présente)
            let bandeHtml = '';
            if (l.bande_id && l.bandes && l.bandes.id_bande) {
                bandeHtml = '<div class="gestion-detail-ligne-bande">🐔 '
                          + esc(l.bandes.id_bande) + '</div>';
            }

            html += ''
                + '<div class="gestion-detail-ligne">'
                +   '<div>'
                +     '<div class="gestion-detail-ligne-nom">' + esc(nomProd) + '</div>'
                +     '<div class="gestion-detail-ligne-calc">'
                +       l.quantite + ' ' + esc(unite) + ' × ' + _formatPrixLigne(l)
                +     '</div>'
                +     bandeHtml
                +   '</div>'
                +   '<div class="gestion-detail-ligne-total">' + fcfa(sousTotal) + '</div>'
                + '</div>';
        });
    }

    html += ''
        + '<div class="gestion-detail-total">'
        +   '<span>Total</span>'
        +   '<span>' + fcfa(total) + '</span>'
        + '</div>';

    html += '<div class="gestion-actions-bas">'
          + '<button class="gestion-pastille gestion-pastille-contour" onclick="renderCommandes()">← Retour</button>';
    if (c.statut === 'PRECOMMANDE') {
        html += '<button class="gestion-pastille gestion-pastille-accent" onclick="_planifierCommande(\'' + c.id + '\')">Planifier →</button>';
    }
    if (c.statut === 'PLANIFIEE') {
        html += '<button class="gestion-pastille gestion-pastille-valider" onclick="_livrerCommande(\'' + c.id + '\')">Livrer</button>';
    }
    if (c.statut === 'PRECOMMANDE' || c.statut === 'PLANIFIEE') {
        html += '<button class="gestion-pastille gestion-pastille-danger" onclick="_annulerCommande(\'' + c.id + '\')">Annuler</button>';
    }
    html += '</div>';

    z.innerHTML = html;
}


/* ═══════════════════ PLANIFIER (morceau 2) ═══════════════════ */

async function _planifierCommande(id) {
    const z = zone();
    if (!z) return;
    z.innerHTML = '<div class="section-title">Planifier la commande</div>'
                + '<div class="gestion-vide">Chargement…</div>';

    const fid = fermeId();

    const [rc, rb] = await Promise.all([
        db().from('commandes')
            .select('id, statut, clients(nom), '
                  + 'commande_lignes(id, quantite, prix_prevu, bande_id, '
                  + 'produits_catalogue(nom, unite, decremente_effectif))')
            .eq('ferme_id', fid)
            .eq('id', id)
            .single(),
        db().from('bandes')
            .select('id, id_bande')
            .eq('ferme_id', fid)
            .eq('is_deleted', false)
            .eq('statut', 'EN COURS')
            .order('date_arrivee', { ascending: false })
    ]);

    if (rc.error || !rc.data) {
        toast('Commande introuvable', 'error');
        renderCommandes();
        return;
    }
    if (rb.error) {
        toast('Erreur chargement bandes', 'error');
        _ouvrirCommande(id);
        return;
    }

    _planifCmd = rc.data;
    _bandes = rb.data || [];

    const aBesoinBande = (_planifCmd.commande_lignes || []).some(function (l) {
        return l.produits_catalogue && l.produits_catalogue.decremente_effectif;
    });
    if (aBesoinBande && _bandes.length === 0) {
        z.innerHTML = '<div class="section-title">Planifier la commande</div>'
            + '<div class="gestion-vide">Aucune bande en cours d\'élevage. '
            + 'Impossible d\'assigner un poulet à une bande.</div>'
            + '<div class="gestion-actions-bas">'
            + '<button class="gestion-pastille gestion-pastille-contour" onclick="_ouvrirCommande(\'' + id + '\')">← Retour</button>'
            + '</div>';
        return;
    }

    _dessinerPlanification();
}

function _dessinerPlanification() {
    const z = zone();
    const c = _planifCmd;
    const nom = c.clients ? c.clients.nom : '(client supprimé)';
    const lignes = c.commande_lignes || [];

    let optBandes = '';
    _bandes.forEach(function (b) {
        optBandes += '<option value="' + b.id + '">' + esc(b.id_bande) + '</option>';
    });

    let html = ''
        + '<div class="gestion-detail-tete">'
        +   '<div class="gestion-detail-client">' + esc(nom) + '</div>'
        +   '<span class="gestion-badge gestion-badge-precommande">Précommande</span>'
        + '</div>'
        + '<div class="gestion-detail-date" style="margin-bottom:16px">'
        +   'Choisissez la bande qui fournira chaque poulet.'
        + '</div>'
        + '<div class="gestion-form-group" style="margin-bottom:16px">'
        +   '<label class="gestion-form-label">📅 Date de livraison prévue</label>'
        +   '<input class="gestion-input" type="date" id="plan-date-livraison">'
        + '</div>';

    lignes.forEach(function (l) {
        const prod = l.produits_catalogue;
        const nomProd = prod ? prod.nom : '(produit supprimé)';
        const unite = prod ? prod.unite : '';
        const decremente = prod && prod.decremente_effectif;
        const sousTotal = Number(l.quantite) * Number(l.prix_prevu);

        const tagEffectif = decremente
            ? '<span class="gestion-tag-effectif">retire de l\'effectif</span>'
            : '';

        html += ''
            + '<div class="gestion-detail-ligne" style="display:block">'
            +   '<div style="display:flex; justify-content:space-between; align-items:center; gap:12px">'
            +     '<div>'
            +       '<div class="gestion-detail-ligne-nom">' + esc(nomProd) + tagEffectif + '</div>'
            +       '<div class="gestion-detail-ligne-calc">'
            +         l.quantite + ' ' + esc(unite) + ' × ' + fcfa(l.prix_prevu)
            +       '</div>'
            +     '</div>'
            +     '<div class="gestion-detail-ligne-total">' + fcfa(sousTotal) + '</div>'
            +   '</div>';

        if (decremente) {
            html += ''
                + '<div class="gestion-bande-select">'
                +   '<label>Bande</label>'
                +   '<select class="gestion-select" id="bande-' + l.id + '">'
                +     optBandes
                +   '</select>'
                + '</div>';
        }

        html += '</div>';
    });

    html += '<div class="gestion-actions-bas" style="margin-top:18px">'
          + '<button class="gestion-pastille gestion-pastille-contour" onclick="_ouvrirCommande(\'' + c.id + '\')">← Retour</button>'
          + '<button class="gestion-pastille gestion-pastille-accent" onclick="_validerPlanification()">Planifier →</button>'
          + '</div>';

    z.innerHTML = html;
}

async function _validerPlanification() {
    const c = _planifCmd;
    const lignes = c.commande_lignes || [];

    const dateLivr = document.getElementById('plan-date-livraison');
    const dateLivraison = dateLivr ? dateLivr.value : '';
    if (!dateLivraison) {
        toast('Indiquez la date de livraison prévue', 'warning');
        return;
    }

    const majLignes = [];
    for (let i = 0; i < lignes.length; i++) {
        const l = lignes[i];
        const prod = l.produits_catalogue;
        const decremente = prod && prod.decremente_effectif;
        if (!decremente) continue;

        const sel = document.getElementById('bande-' + l.id);
        const bandeId = sel ? sel.value : '';
        if (!bandeId) {
            const nomProd = prod ? prod.nom : 'cette ligne';
            toast('La ligne « ' + nomProd + ' » doit avoir une bande', 'warning');
            return;
        }
        majLignes.push({ id: l.id, bande_id: bandeId });
    }

    const fid = fermeId();

    for (let i = 0; i < majLignes.length; i++) {
        const m = majLignes[i];
        const ru = await db().from('commande_lignes')
            .update({ bande_id: m.bande_id })
            .eq('ferme_id', fid)
            .eq('id', m.id);
        if (ru.error) {
            toast('Erreur assignation bande : ' + ru.error.message, 'error');
            return;
        }
    }

    const rc = await db().from('commandes')
        .update({ statut: 'PLANIFIEE', date_livraison_prevue: dateLivraison })
        .eq('ferme_id', fid)
        .eq('id', c.id);

    if (rc.error) {
        toast('Erreur changement de statut : ' + rc.error.message, 'error');
        return;
    }

    toast('Commande planifiée', 'success');
    _ouvrirCommande(c.id);
}


/* ═══════════════════ LIVRER (morceau 3) ═══════════════════ */

async function _livrerCommande(id) {
    const z = zone();
    if (!z) return;
    z.innerHTML = '<div class="section-title">Livrer la commande</div>'
                + '<div class="gestion-vide">Chargement…</div>';

    const fid = fermeId();

    const rc = await db()
        .from('commandes')
        .select('id, statut, clients(nom), '
              + 'commande_lignes(id, quantite, prix_prevu, prix_reel, nb_sujets, bande_id, '
              + 'produits_catalogue(nom, unite, decremente_effectif), '
              + 'bandes(id_bande))')
        .eq('ferme_id', fid)
        .eq('id', id)
        .single();

    if (rc.error || !rc.data) {
        toast('Commande introuvable', 'error');
        renderCommandes();
        return;
    }

    if (rc.data.statut !== 'PLANIFIEE') {
        toast('Seule une commande planifiée peut être livrée', 'warning');
        _ouvrirCommande(id);
        return;
    }

    _livrCmd = rc.data;
    _dessinerLivraison();
}

function _dessinerLivraison() {
    const z = zone();
    const c = _livrCmd;
    const nom = c.clients ? c.clients.nom : '(client supprimé)';
    const lignes = c.commande_lignes || [];

    let html = ''
        + '<div class="gestion-detail-tete">'
        +   '<div class="gestion-detail-client">' + esc(nom) + '</div>'
        +   '<span class="gestion-badge gestion-badge-planifiee">Planifiée</span>'
        + '</div>'
        + '<div class="gestion-detail-date" style="margin-bottom:16px">'
        +   'Renseignez ce qui a réellement été livré, puis confirmez.'
        + '</div>';

    lignes.forEach(function (l) {
        const prod = l.produits_catalogue;
        const nomProd = prod ? prod.nom : '(produit supprimé)';
        const unite = prod ? prod.unite : '';
        const decremente = prod && prod.decremente_effectif;
        const prixPrevu = (l.prix_reel !== null && l.prix_reel !== undefined)
                        ? l.prix_reel : l.prix_prevu;

        const bandeTxt = (l.bandes && l.bandes.id_bande)
                       ? '<div class="gestion-detail-ligne-bande">🐔 ' + esc(l.bandes.id_bande) + '</div>'
                       : '';

        const tagEffectif = decremente
            ? '<span class="gestion-tag-effectif">retire de l\'effectif</span>'
            : '';

        html += ''
            + '<div class="gestion-detail-ligne" style="display:block">'
            +   '<div class="gestion-detail-ligne-nom">' + esc(nomProd) + tagEffectif + '</div>'
            +   bandeTxt;

        if (decremente) {
            // Ligne vivante : nombre + poids moyen + prix, poids total & montant calculés
            html += ''
                + '<div class="gestion-livr-champs">'
                +   '<div class="gestion-livr-champ">'
                +     '<label>Nombre de poulets</label>'
                +     '<input class="gestion-input" type="number" min="0" step="1" '
                +       'id="livr-nb-' + l.id + '" '
                +       'oninput="_recalcLivraison(\'' + l.id + '\')">'
                +   '</div>'
                +   '<div class="gestion-livr-champ">'
                +     '<label>Poids moyen (kg)</label>'
                +     '<input class="gestion-input" type="number" min="0" step="0.01" '
                +       'id="livr-pm-' + l.id + '" '
                +       'oninput="_recalcLivraison(\'' + l.id + '\')">'
                +   '</div>'
                +   '<div class="gestion-livr-champ">'
                +     '<label>Prix de vente (F/kg)</label>'
                +     '<input class="gestion-input" type="number" min="0" step="1" '
                +       'id="livr-prix-' + l.id + '" value="' + prixPrevu + '" '
                +       'oninput="_recalcLivraison(\'' + l.id + '\')">'
                +   '</div>'
                + '</div>'
                + '<div class="gestion-livr-calc" id="livr-calc-' + l.id + '">'
                +   'Poids total : — · Montant : —'
                + '</div>';
        } else {
            // Ligne non vivante : quantité fixe + prix modifiable
            html += ''
                + '<div class="gestion-detail-ligne-calc">'
                +   'Quantité : ' + l.quantite + ' ' + esc(unite) + ' (fixe)'
                + '</div>'
                + '<div class="gestion-livr-champs">'
                +   '<div class="gestion-livr-champ">'
                +     '<label>Prix (F/' + esc(unite) + ')</label>'
                +     '<input class="gestion-input" type="number" min="0" step="1" '
                +       'id="livr-prix-' + l.id + '" value="' + prixPrevu + '" '
                +       'oninput="_recalcLivraison(\'' + l.id + '\')">'
                +   '</div>'
                + '</div>'
                + '<div class="gestion-livr-calc" id="livr-calc-' + l.id + '">'
                +   'Montant : —'
                + '</div>';
        }

        html += '</div>';
    });

    html += '<div class="gestion-livr-recap" id="livr-recap">'
          + 'Complétez les lignes pour voir le récapitulatif.'
          + '</div>';

    html += '<div class="gestion-actions-bas" style="margin-top:18px">'
          + '<button class="gestion-pastille gestion-pastille-contour" onclick="_ouvrirCommande(\'' + c.id + '\')">← Annuler</button>'
          + '<button class="gestion-pastille gestion-pastille-valider" onclick="_validerLivraison()">✓ Confirmer</button>'
          + '</div>';

    z.innerHTML = html;

    // Premier calcul (les lignes non vivantes ont déjà un prix pré-rempli)
    lignes.forEach(function (l) { _recalcLivraison(l.id); });
}

function _recalcLivraison(ligneId) {
    const c = _livrCmd;
    const lignes = c.commande_lignes || [];
    const l = lignes.find(function (x) { return x.id === ligneId; });
    if (!l) return;

    const prod = l.produits_catalogue;
    const decremente = prod && prod.decremente_effectif;

    const calcDiv = document.getElementById('livr-calc-' + ligneId);
    const prixInput = document.getElementById('livr-prix-' + ligneId);
    const prix = prixInput ? parseFloat(prixInput.value) : NaN;

    if (decremente) {
        const nbInput = document.getElementById('livr-nb-' + ligneId);
        const pmInput = document.getElementById('livr-pm-' + ligneId);
        const nb = nbInput ? parseFloat(nbInput.value) : NaN;
        const pm = pmInput ? parseFloat(pmInput.value) : NaN;

        if (!isNaN(nb) && !isNaN(pm)) {
            const poidsTotal = nb * pm;
            const montant = !isNaN(prix) ? poidsTotal * prix : NaN;
            if (calcDiv) {
                calcDiv.innerHTML = 'Poids total : ' + poidsTotal.toFixed(2) + ' kg'
                    + ' · Montant : ' + (isNaN(montant) ? '—' : fcfa(Math.round(montant)));
            }
        } else if (calcDiv) {
            calcDiv.innerHTML = 'Poids total : — · Montant : —';
        }
    } else {
        const montant = !isNaN(prix) ? Number(l.quantite) * prix : NaN;
        if (calcDiv) {
            calcDiv.innerHTML = 'Montant : ' + (isNaN(montant) ? '—' : fcfa(Math.round(montant)));
        }
    }

    _majRecapLivraison();
}

function _majRecapLivraison() {
    const c = _livrCmd;
    const lignes = c.commande_lignes || [];
    const recapDiv = document.getElementById('livr-recap');
    if (!recapDiv) return;

    let recettes = [];
    let totalEffectif = 0;
    let complet = true;

    lignes.forEach(function (l) {
        const prod = l.produits_catalogue;
        const decremente = prod && prod.decremente_effectif;
        const nomProd = prod ? prod.nom : 'produit';
        const bandeTxt = (l.bandes && l.bandes.id_bande) ? l.bandes.id_bande : '';

        const prixInput = document.getElementById('livr-prix-' + l.id);
        const prix = prixInput ? parseFloat(prixInput.value) : NaN;

        if (decremente) {
            const nbInput = document.getElementById('livr-nb-' + l.id);
            const pmInput = document.getElementById('livr-pm-' + l.id);
            const nb = nbInput ? parseFloat(nbInput.value) : NaN;
            const pm = pmInput ? parseFloat(pmInput.value) : NaN;
            if (isNaN(nb) || nb <= 0 || isNaN(pm) || pm <= 0 || isNaN(prix)) {
                complet = false;
                return;
            }
            const montant = Math.round(nb * pm * prix);
            totalEffectif += nb;
            recettes.push(fcfa(montant) + (bandeTxt ? ' sur ' + esc(bandeTxt) : ''));
        } else {
            if (isNaN(prix)) { complet = false; return; }
            const montant = Math.round(Number(l.quantite) * prix);
            recettes.push(fcfa(montant));
        }
    });

    if (!complet || recettes.length === 0) {
        recapDiv.innerHTML = 'Complétez les lignes pour voir le récapitulatif.';
        return;
    }

    let html = 'Ceci créera ' + recettes.length + ' recette'
             + (recettes.length > 1 ? 's' : '') + ' :';
    html += '<ul class="gestion-livr-recap-liste">';
    recettes.forEach(function (r) { html += '<li>' + r + '</li>'; });
    html += '</ul>';
    if (totalEffectif > 0) {
        html += '<div class="gestion-livr-recap-effectif">'
              + 'Effectif retiré : ' + totalEffectif + ' sujet'
              + (totalEffectif > 1 ? 's' : '') + '</div>';
    }

    recapDiv.innerHTML = html;
}

async function _validerLivraison() {
    const c = _livrCmd;
    const lignes = c.commande_lignes || [];

    const payload = [];

    for (let i = 0; i < lignes.length; i++) {
        const l = lignes[i];
        const prod = l.produits_catalogue;
        const decremente = prod && prod.decremente_effectif;
        const nomProd = prod ? prod.nom : 'cette ligne';

        const prixInput = document.getElementById('livr-prix-' + l.id);
        const prix = prixInput ? parseFloat(prixInput.value) : NaN;
        if (isNaN(prix) || prix < 0) {
            toast('Prix manquant pour « ' + nomProd + ' »', 'warning');
            return;
        }

        if (decremente) {
            const nbInput = document.getElementById('livr-nb-' + l.id);
            const pmInput = document.getElementById('livr-pm-' + l.id);
            const nb = nbInput ? parseInt(nbInput.value, 10) : NaN;
            const pm = pmInput ? parseFloat(pmInput.value) : NaN;

            if (isNaN(nb) || nb <= 0) {
                toast('Indiquez le nombre de poulets pour « ' + nomProd + ' »', 'warning');
                return;
            }
            if (isNaN(pm) || pm <= 0) {
                toast('Indiquez le poids moyen pour « ' + nomProd + ' »', 'warning');
                return;
            }

            const quantite = Number((nb * pm).toFixed(2));
            payload.push({
                id: l.id,
                quantite: quantite,
                prix_reel: prix,
                nb_sujets: nb
            });
        } else {
            payload.push({
                id: l.id,
                quantite: Number(l.quantite),
                prix_reel: prix
            });
        }
    }

    if (payload.length === 0) {
        toast('Aucune ligne à livrer', 'warning');
        return;
    }

    const r = await db().rpc('livrer_commande', {
        p_commande_id: c.id,
        p_lignes: payload
    });

    if (r.error) {
        toast('Erreur livraison : ' + r.error.message, 'error');
        return;
    }

    const res = r.data || {};
    const total = res.total !== undefined ? fcfa(res.total) : '';
    toast('Commande livrée' + (total ? ' — ' + total : ''), 'success');
    _livrCmd = null;
    _ouvrirCommande(c.id);
}


/* ═══════════════════ ANNULER (morceau 4) ═══════════════════ */

async function _annulerCommande(id) {
    const z = zone();
    if (!z) return;
    z.innerHTML = '<div class="section-title">Annuler la commande</div>'
                + '<div class="gestion-vide">Chargement…</div>';

    const fid = fermeId();

    const rc = await db()
        .from('commandes')
        .select('id, statut, clients(nom), '
              + 'commande_lignes(quantite, prix_prevu, prix_reel)')
        .eq('ferme_id', fid)
        .eq('id', id)
        .single();

    if (rc.error || !rc.data) {
        toast('Commande introuvable', 'error');
        renderCommandes();
        return;
    }

    if (rc.data.statut !== 'PRECOMMANDE' && rc.data.statut !== 'PLANIFIEE') {
        toast('Cette commande ne peut plus être annulée', 'warning');
        _ouvrirCommande(id);
        return;
    }

    _annulCmd = rc.data;
    _dessinerAnnulation();
}

function _dessinerAnnulation() {
    const z = zone();
    const c = _annulCmd;
    const nom = c.clients ? c.clients.nom : '(client supprimé)';
    const lignes = c.commande_lignes || [];

    let total = 0;
    lignes.forEach(function (l) {
        const p = (l.prix_reel === null || l.prix_reel === undefined)
                ? l.prix_prevu : l.prix_reel;
        total += Number(l.quantite) * Number(p);
    });
    const nbTxt = lignes.length + ' ligne' + (lignes.length > 1 ? 's' : '');

    z.innerHTML = ''
        + '<div class="section-title">Annuler la commande</div>'
        + '<div class="gestion-annul-bloc">'
        +   '<div class="gestion-annul-client">' + esc(nom) + '</div>'
        +   '<div class="gestion-annul-meta">' + nbTxt + ' · ' + fcfa(total) + '</div>'
        +   '<div class="gestion-annul-texte">'
        +     'Cette commande sera marquée « Annulée ». '
        +     'Elle ne pourra plus être planifiée ni livrée. '
        +     'Aucune écriture comptable n\'est créée.'
        +   '</div>'
        + '</div>'
        + '<div class="gestion-actions-bas" style="margin-top:18px">'
        +   '<button class="gestion-pastille gestion-pastille-contour" onclick="_ouvrirCommande(\'' + c.id + '\')">← Retour</button>'
        +   '<button class="gestion-pastille gestion-pastille-danger" onclick="_confirmerAnnulation()">Confirmer l\'annulation</button>'
        + '</div>';
}

async function _confirmerAnnulation() {
    const c = _annulCmd;
    const fid = fermeId();

    const rc = await db().from('commandes')
        .update({ statut: 'ANNULEE' })
        .eq('ferme_id', fid)
        .eq('id', c.id)
        .in('statut', ['PRECOMMANDE', 'PLANIFIEE']);

    if (rc.error) {
        toast('Erreur annulation : ' + rc.error.message, 'error');
        return;
    }

    toast('Commande annulée', 'success');
    _annulCmd = null;
    _ouvrirCommande(c.id);
}


/* ═══ EXPOSITION SUR window ═══ */
window.renderCommandes    = renderCommandes;
window._nouvelleCommande  = _nouvelleCommande;
window._ajouterLigne      = _ajouterLigne;
window._retirerLigne      = _retirerLigne;
window._enregistrerCommande = _enregistrerCommande;
window._ouvrirCommande    = _ouvrirCommande;
window._planifierCommande = _planifierCommande;
window._validerPlanification = _validerPlanification;
window._livrerCommande    = _livrerCommande;
window._dessinerLivraison = _dessinerLivraison;
window._recalcLivraison   = _recalcLivraison;
window._validerLivraison  = _validerLivraison;
window._annulerCommande   = _annulerCommande;
window._dessinerAnnulation = _dessinerAnnulation;
window._confirmerAnnulation = _confirmerAnnulation;