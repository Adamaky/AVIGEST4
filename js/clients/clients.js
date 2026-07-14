/* ============================================================
   js/clients/clients.js — Module Clients
   ------------------------------------------------------------
   RÔLE : liste, ajout, modification et désactivation des clients
   de la ferme. Accessible depuis l'onglet GESTION du gérant.

   NAVIGATION :
   window.renderClients()           → liste (appelé par Nav)
   window._renderClientForm(id)     → formulaire add/edit
   window._ouvrirClient(id)         → wrapper nav (liste → formulaire)
   window._sauvegarderClient(id)    → INSERT ou UPDATE (depuis onclick)
   window._desactiverClient(id)     → UPDATE actif=false (depuis onclick)
   ============================================================ */

import { db, fermeId } from '../shared/db.js';
import { esc, toast, zone, dateFr } from '../shared/helpers.js';


/* ── Libellés types de client (code DB → affichage FR) ────── */
const TYPE_LABELS = {
    PARTICULIER:  'Particulier',
    REVENDEUR:    'Revendeur',
    ACHETEUR_VIF: 'Acheteur vif',
    RESTAURANT:   'Restaurant',
    INSTITUTION:  'Institution'
};

const TYPES = ['PARTICULIER', 'REVENDEUR', 'ACHETEUR_VIF', 'RESTAURANT', 'INSTITUTION'];


/* ============================================================
   HELPERS INTERNES
   ============================================================ */

/** Ouvre le formulaire client depuis la liste (nav-aware). */
function _ouvrirClient(id) {
    if (window.Nav && typeof window.Nav.push === 'function') {
        window.Nav.push('_renderClientForm', id || null);
    } else {
        _renderClientForm(id || null);
    }
}

/** Retour à la liste après sauvegarde ou désactivation. */
function _clientsRetour() {
    if (window.Nav && typeof window.Nav.back === 'function') {
        window.Nav.back();
    } else {
        renderClients();
    }
}

/** Lecture sécurisée d'un champ du formulaire. */
function _val(id) {
    const el = document.getElementById(id);
    return el ? el.value.trim() : '';
}


/* ============================================================
   1. LISTE DES CLIENTS
   ============================================================ */
async function renderClients() {
    const z = zone();
    if (!z) return;

    z.innerHTML = '<div class="gestion-vide">Chargement…</div>';

    let data, error;
    try {
        ({ data, error } = await db()
            .from('clients')
            .select('id, nom, telephone, type_client, actif')
            .eq('ferme_id', fermeId())
            .order('nom'));
    } catch (e) {
        toast('Erreur de chargement', 'error');
        return;
    }

    if (error) {
        toast('Erreur de chargement', 'error');
        return;
    }

    let html = '<div class="section-title">Clients</div>'
             + '<button class="btn-action btn-primary" style="margin-bottom:14px" '
             + 'onclick="_ouvrirClient(null)">+ Nouveau client</button>';

    if (!data || data.length === 0) {
        html += '<div class="gestion-vide">Aucun client enregistré</div>';
    } else {
        data.forEach(function (c) {
            const inactif = c.actif === false;
            const grisee  = inactif ? ' gestion-tuile-inactive' : '';
            const badge   = inactif
                ? ' <span class="gestion-badge-inactif">Inactif</span>'
                : '';
            const typeLib = TYPE_LABELS[c.type_client] || esc(c.type_client) || '—';
            const tel     = c.telephone ? esc(c.telephone) : '—';

            html += '<div class="gestion-tuile' + grisee + '" '
                  + 'onclick="_ouvrirClient(\'' + esc(c.id) + '\')">'
                  +   '<div class="gestion-client-info">'
                  +     '<div class="gestion-client-nom">' + esc(c.nom) + badge + '</div>'
                  +     '<div class="gestion-client-meta">' + tel + ' · ' + typeLib + '</div>'
                  +   '</div>'
                  +   '<div class="tuile-arrow">›</div>'
                  + '</div>';
        });
    }

    z.innerHTML = html;
}


/* ============================================================
   2. FORMULAIRE AJOUT / MODIFICATION
   ============================================================ */
async function _renderClientForm(clientId) {
    const z = zone();
    if (!z) return;

    z.innerHTML = '<div class="gestion-vide">Chargement…</div>';

    let client = null;

    if (clientId) {
        let data, error;
        try {
            ({ data, error } = await db()
                .from('clients')
                .select('*')
                .eq('id', clientId)
                .eq('ferme_id', fermeId())
                .single());
        } catch (e) {
            toast('Erreur de chargement', 'error');
            return;
        }
        if (error || !data) {
            toast('Client introuvable', 'error');
            return;
        }
        client = data;
    }

    const titre   = client ? 'Modifier le client' : 'Nouveau client';
    const valNom  = client ? esc(client.nom)             : '';
    const valTel  = client ? esc(client.telephone  || '') : '';
    const valAdr  = client ? esc(client.adresse    || '') : '';
    const valNote = client ? esc(client.note       || '') : '';
    const valType = client ? (client.type_client   || 'PARTICULIER') : 'PARTICULIER';
    const idStr   = clientId ? '\'' + esc(clientId) + '\'' : 'null';

    let optionsHTML = '';
    TYPES.forEach(function (k) {
        const sel = (k === valType) ? ' selected' : '';
        optionsHTML += '<option value="' + k + '"' + sel + '>' + TYPE_LABELS[k] + '</option>';
    });

    let html = '<div class="section-title">' + titre + '</div>'
             + '<div class="card">'
             +   '<div class="gestion-form-group">'
             +     '<label class="gestion-form-label">Nom *</label>'
             +     '<input id="cl-nom" class="gestion-input" type="text" '
             +       'value="' + valNom + '" placeholder="Nom du client">'
             +   '</div>'
             +   '<div class="gestion-form-group">'
             +     '<label class="gestion-form-label">Téléphone</label>'
             +     '<input id="cl-tel" class="gestion-input" type="tel" '
             +       'value="' + valTel + '" placeholder="Ex : 77 000 00 00">'
             +   '</div>'
             +   '<div class="gestion-form-group">'
             +     '<label class="gestion-form-label">Adresse</label>'
             +     '<input id="cl-adresse" class="gestion-input" type="text" '
             +       'value="' + valAdr + '" placeholder="Adresse ou quartier">'
             +   '</div>'
             +   '<div class="gestion-form-group">'
             +     '<label class="gestion-form-label">Type de client</label>'
             +     '<select id="cl-type" class="gestion-select">' + optionsHTML + '</select>'
             +   '</div>'
             +   '<div class="gestion-form-group">'
             +     '<label class="gestion-form-label">Note</label>'
             +     '<textarea id="cl-note" class="gestion-input" rows="3" '
             +       'placeholder="Remarques éventuelles">' + valNote + '</textarea>'
             +   '</div>'
             +   '<button class="btn-action btn-primary" style="width:100%;margin-top:4px" '
             +     'onclick="_sauvegarderClient(' + idStr + ')">Enregistrer</button>';

    if (client && client.actif !== false) {
        html += '<button class="btn-action btn-ghost" '
              + 'style="width:100%;margin-top:8px;color:var(--red)" '
              + 'onclick="_desactiverClient(\'' + esc(clientId) + '\')">'
              + 'Désactiver ce client</button>';
    }

    html += '</div>';
    z.innerHTML = html;
}


/* ============================================================
   3. ENREGISTRER — INSERT (clientId null) ou UPDATE
   ============================================================ */
async function _sauvegarderClient(clientId) {
    const nom = _val('cl-nom');
    if (!nom) {
        toast('Le nom est obligatoire', 'error');
        return;
    }

    const telephone   = _val('cl-tel');
    const adresse     = _val('cl-adresse');
    const type_client = _val('cl-type') || 'PARTICULIER';
    const note        = _val('cl-note');

    let error;
    try {
        if (clientId) {
            ({ error } = await db()
                .from('clients')
                .update({ nom, telephone, adresse, type_client, note })
                .eq('id', clientId)
                .eq('ferme_id', fermeId()));
        } else {
            ({ error } = await db()
                .from('clients')
                .insert({ nom, telephone, adresse, type_client, note, ferme_id: fermeId() }));
        }
    } catch (e) {
        toast('Erreur lors de l\'enregistrement', 'error');
        return;
    }

    if (error) {
        toast('Erreur lors de l\'enregistrement', 'error');
        return;
    }

    toast(clientId ? 'Client modifié' : 'Client créé', 'success');
    _clientsRetour();
}


/* ============================================================
   4. DÉSACTIVER — soft delete (jamais de DELETE physique)
   ============================================================ */
async function _desactiverClient(clientId) {
    if (!confirm('Désactiver ce client ? Il restera visible dans la liste mais inactif.')) return;

    let error;
    try {
        ({ error } = await db()
            .from('clients')
            .update({ actif: false })
            .eq('id', clientId)
            .eq('ferme_id', fermeId()));
    } catch (e) {
        toast('Erreur lors de la désactivation', 'error');
        return;
    }

    if (error) {
        toast('Erreur lors de la désactivation', 'error');
        return;
    }

    toast('Client désactivé', 'success');
    _clientsRetour();
}


/* ============================================================
   EXPOSITION SUR window
   Toutes les fonctions appelées depuis un onclick inline ou
   depuis Nav.push() doivent figurer ici.
   ============================================================ */
window.renderClients      = renderClients;
window._ouvrirClient      = _ouvrirClient;
window._renderClientForm  = _renderClientForm;
window._sauvegarderClient = _sauvegarderClient;
window._desactiverClient  = _desactiverClient;
