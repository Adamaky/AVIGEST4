/* ═══════════════════════════════════════════════════════
   js/gestion/gestion.js — Page GESTION (tuiles)
   ───────────────────────────────────────────────────────
   RÔLE : l'écran d'accueil du nouvel onglet GESTION du gérant.
   Il affiche des tuiles menant aux sous-modules (Clients,
   Commandes, Trésorerie, Stock...).

   COMMENT IL EST APPELÉ :
   Le Nav d'index.html exécute window[fn]() où fn vient de
   NAVBAR_CONFIG. On expose donc UNE SEULE fonction sur window :
   window.renderGestion. Tout le reste du module reste privé.
   ═══════════════════════════════════════════════════════ */

import { estGerant } from '../shared/db.js';
import { zone, toast } from '../shared/helpers.js';
import '../clients/clients.js';
import '../commandes/commandes.js';
import '../parametres/parametres.js';


/* ───────────────────────────────────────────────────────
   Définition des tuiles.
   `dispo: false` = tuile grisée, module pas encore construit.
   ─────────────────────────────────────────────────────── */
const TUILES = [
    {
        id: 'clients',
        icon: '👥',
        label: 'Clients',
        sub: 'Fiches, contacts',
        fn: 'renderClients',
        dispo: true
    },
    {
        id: 'commandes',
        icon: '📋',
        label: 'Commandes',
        sub: 'Ventes, livraisons',
        fn: 'renderCommandes',
        dispo: true
    },
    {
        id: 'tresorerie',
        icon: '💰',
        label: 'Trésorerie',
        sub: 'Caisse de la ferme',
        fn: 'renderTresorerie',
        dispo: false
    },
    {
        id: 'stock',
        icon: '📦',
        label: 'Stock',
        sub: 'Lots, imputations',
        fn: 'renderStockGerant',
        dispo: false
    },
    {
        id: 'parametres',
        icon: '⚙️',
        label: 'Paramètres',
        sub: 'Identité de la ferme',
        fn: 'renderParametres',
        dispo: true
    }
];


/* ───────────────────────────────────────────────────────
   Rendu de la page GESTION
   ─────────────────────────────────────────────────────── */
function renderGestion() {

    // Garde-fou : réservé au gérant
    if (!estGerant()) {
        toast('Accès réservé au gérant', 'error');
        return;
    }

    const z = zone();
    if (!z) return;

    let html = '<div class="section-title">Gestion</div>';

    TUILES.forEach(function (t) {
        const grisee = t.dispo ? '' : ' gestion-tuile-inactive';
        const clic = t.dispo
            ? ' onclick="_gestionOuvrir(\'' + t.fn + '\')"'
            : ' onclick="_gestionBientot()"';

        html += ''
            + '<div class="tuile gestion-tuile' + grisee + '"' + clic + '>'
            +   '<div class="tuile-icon">' + t.icon + '</div>'
            +   '<div>'
            +     '<div class="tuile-label">' + t.label + '</div>'
            +     '<div class="tuile-sub">' + t.sub + (t.dispo ? '' : ' — bientôt') + '</div>'
            +   '</div>'
            +   '<div class="tuile-arrow">›</div>'
            + '</div>';
    });

    z.innerHTML = html;
}


/* ───────────────────────────────────────────────────────
   Ouverture d'un sous-module via le Nav existant.
   ─────────────────────────────────────────────────────── */
function _gestionOuvrir(fn) {
    if (typeof window[fn] !== 'function') {
        toast('Module en cours de chargement — réessayez', 'warning');
        return;
    }
    if (window.Nav && typeof window.Nav.push === 'function') {
        window.Nav.push(fn, null);
    } else {
        window[fn]();
    }
}


function _gestionBientot() {
    toast('Module bientôt disponible', 'warning');
}


/* ───────────────────────────────────────────────────────
   EXPOSITION SUR window
   ─────────────────────────────────────────────────────── */
window.renderGestion  = renderGestion;
window._gestionOuvrir = _gestionOuvrir;
window._gestionBientot = _gestionBientot;