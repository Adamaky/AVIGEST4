/* ═══════════════════════════════════════════════════════
   js/commandes/commandes.js — Écran Commandes
   ───────────────────────────────────────────────────────
   ÉTAPE 1 : liste  ✅
   ÉTAPE 2 : création (formulaire, lignes en mémoire)  ← ici
   ÉTAPE 3 : livraison (à venir)
   ═══════════════════════════════════════════════════════ */

import { db, fermeId } from '../shared/db.js';
import { esc, toast, zone, fcfa, dateFr } from '../shared/helpers.js';

const LIB_STATUT = {
    PRECOMMANDE: 'Précommande',
    PLANIFIEE:   'Planifiée',
    LIVREE:      'Livrée',
    ANNULEE:     'Annulée'
};

/* Panier en mémoire pendant la création (jamais en base avant Enregistrer) */
let _panier = [];
let _clients = [];
let _produits = [];


/* ═══════════════════ LISTE ═══════════════════ */
async function renderCommandes() {
    const z = zone();
    if (!z) return;
    z.innerHTML = '<div class="section-title">Commandes</div>'
                + '<div class="gestion-vide">Chargement…</div>';

    const res = await db()
        .from('commandes')
        .select('id, date_commande, statut, clients(nom), '
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
    let html = '<div class="gestion-header-row">'
             + '<div class="section-title">Commandes</div>'
             + '<button class="gestion-btn-ajout" onclick="_nouvelleCommande()">+ Nouvelle</button>'
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
            + '<div class="gestion-carte" onclick="_ouvrirCommande(\'' + c.id + '\')">'
            +   '<div class="gestion-client-info">'
            +     '<div class="gestion-client-nom">' + esc(nom) + '</div>'
            +     '<div class="gestion-client-meta">'
            +       dateFr(c.date_commande) + ' · ' + nbTxt + ' · ' + fcfa(total)
            +     '</div>'
            +   '</div>'
            +   '<span class="gestion-badge ' + cls + '">' + LIB_STATUT[c.statut] + '</span>'
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

    // Charger clients actifs + produits actifs en parallèle
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
            + '<button class="gestion-btn-retour" onclick="renderCommandes()">← Retour</button>';
        return;
    }

    _dessinerFormulaire();
}

function _dessinerFormulaire() {
    const z = zone();

    // Options clients
    let optClients = '<option value="">— Choisir un client —</option>';
    _clients.forEach(function (c) {
        optClients += '<option value="' + c.id + '">' + esc(c.nom) + '</option>';
    });

    // Options produits
    let optProduits = '<option value="">— Produit —</option>';
    _produits.forEach(function (p) {
        optProduits += '<option value="' + p.id + '">'
                     + esc(p.nom) + ' (' + p.unite + ')</option>';
    });

    // Lignes déjà au panier
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
        lignesHtml = '<div class="gestion-vide-mini">Aucune ligne. Ajoutez un produit ci-dessous.</div>';
    }

    z.innerHTML = ''
        + '<div class="section-title">Nouvelle commande</div>'

        // Client
        + '<div class="gestion-form-group">'
        +   '<label class="gestion-form-label">Client</label>'
        +   '<select class="gestion-select" id="cmd-client">' + optClients + '</select>'
        + '</div>'

        // Panier de lignes
        + '<div class="gestion-form-label" style="margin-top:16px">Lignes de la commande</div>'
        + '<div id="cmd-panier">' + lignesHtml + '</div>'
        + '<div class="gestion-total-ligne">Total : ' + fcfa(total) + '</div>'

        // Ajout d'une ligne
        + '<div class="gestion-ajout-ligne">'
        +   '<select class="gestion-select" id="cmd-produit">' + optProduits + '</select>'
        +   '<div class="gestion-ligne-champs">'
        +     '<input class="gestion-input" id="cmd-qte" type="number" min="0" step="0.01" placeholder="Quantité">'
        +     '<input class="gestion-input" id="cmd-prix" type="number" min="0" step="1" placeholder="Prix unitaire">'
        +   '</div>'
        +   '<button class="gestion-btn-ligne" onclick="_ajouterLigne()">+ Ajouter la ligne</button>'
        + '</div>'

        // Actions
        + '<div class="gestion-form-actions">'
        +   '<button class="gestion-btn-retour" onclick="renderCommandes()">Annuler</button>'
        +   '<button class="gestion-btn-valider" onclick="_enregistrerCommande()">Enregistrer (Précommande)</button>'
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
    // Restaurer le client sélectionné (le redraw a réinitialisé le select)
    // -> on le relit avant le redraw dans une version future ; ici on laisse simple
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

    // 1. Créer la commande
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

    // 2. Créer les lignes
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


/* ═══════════════════ DÉTAIL (étape 3) ═══════════════════ */
function _ouvrirCommande(id) {
    toast('Détail de commande — bientôt disponible', 'warning');
}


/* ═══ EXPOSITION SUR window ═══ */
window.renderCommandes    = renderCommandes;
window._nouvelleCommande  = _nouvelleCommande;
window._ajouterLigne      = _ajouterLigne;
window._retirerLigne      = _retirerLigne;
window._enregistrerCommande = _enregistrerCommande;
window._ouvrirCommande    = _ouvrirCommande;