/* ============================================================
   js/shared/helpers.js — Boîte à outils commune
   ------------------------------------------------------------
   RÔLE : les petites fonctions dont tous les nouveaux modules
   ont besoin. Elles réutilisent celles d'index.html quand elles
   existent, avec une solution de repli au cas où.

   POURQUOI DES REPLIS : si un jour index.html est redécoupé, ces
   fonctions ne disparaîtront pas sous les pieds des modules.
   ============================================================ */


/**
 * Échappe le HTML pour éviter qu'un nom de client contenant
 * des chevrons casse la page (ou pire).
 * Réutilise esc() d'index.html si présent.
 */
export function esc(txt) {
    if (typeof window.esc === 'function') return window.esc(txt);
    if (txt === null || txt === undefined) return '';
    return String(txt)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#39;');
}


/**
 * Affiche un message flottant.
 * Réutilise showToast() d'index.html.
 * @param {string} msg
 * @param {string} type - 'success' | 'error' | 'warning'
 */
export function toast(msg, type = 'success', duree = 3000) {
    if (typeof window.showToast === 'function') {
        window.showToast(msg, type, duree);
    } else {
        console.log('[' + type + '] ' + msg);
    }
}


/**
 * Renvoie le conteneur unique où chaque écran écrit son contenu.
 * C'est le <div id="app-container"> d'index.html.
 * Tout écran fait : zone().innerHTML = '...'
 */
export function zone() {
    if (typeof window.zone === 'function') return window.zone();
    return document.getElementById('app-container');
}


/**
 * Formate un montant en francs CFA.
 * Ex : 125000 -> "125 000 F"
 */
export function fcfa(montant) {
    const n = Number(montant) || 0;
    return n.toLocaleString('fr-FR').replace(/\u202f|\u00a0/g, ' ') + ' F';
}


/**
 * Formate une date ISO (2026-07-11) en format lisible (11/07/2026).
 */
export function dateFr(iso) {
    if (!iso) return '—';
    const parts = String(iso).slice(0, 10).split('-');
    if (parts.length !== 3) return String(iso);
    return parts[2] + '/' + parts[1] + '/' + parts[0];
}
