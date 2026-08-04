/* ═══════════════════════════════════════════════════════
   js/rentabilite/rentabilite.js — Rentabilité par bande (gérant)
   ───────────────────────────────────────────────────────
   Vue économique PAR BANDE (distincte de la Trésorerie, qui est
   GLOBALE par ferme — Bible §24.2). Une carte par bande EN COURS :
     • CRU par sujet (chiffre principal, neutre — pas de seuil,
       le gérant juge selon l'objectif de la bande),
     • âge + effectif en contexte,
     • marge nette : grise « recettes à venir » si la bande n'a
       encore rien vendu, verte/rouge seulement si recettes réelles.

   SOURCE UNIQUE — RPC serveur get_rentabilite_bandes() (Migration
   053), qui lit vue_dashboard_bande. Le CRU (§4.1) est calculé
   côté serveur, JAMAIS dupliqué ici — cohérent avec la démarche
   anti-doublon (Bible §23.2).

   Seul le GÉRANT y accède. Bandes EN COURS uniquement.
   ═══════════════════════════════════════════════════════ */

import { db, estGerant } from '../shared/db.js';
import { esc, toast, zone, fcfa, dateFr } from '../shared/helpers.js';

let _rentaBandes = [];   // lignes renvoyées par get_rentabilite_bandes()


/* ───────────────────────────────────────────────────────
   Point d'entrée — chargement puis rendu
   ─────────────────────────────────────────────────────── */
async function renderRentabilite() {

    if (!estGerant()) {
        toast('Accès réservé au gérant', 'error');
        return;
    }

    const z = zone();
    if (!z) return;
    z.innerHTML = '<div class="section-title">Rentabilité par bande</div>'
                + '<div class="gestion-vide">Chargement…</div>';

    let res;
    try {
        res = await db().rpc('get_rentabilite_bandes');
    } catch (e) {
        console.error('renderRentabilite:', e);
        toast('Erreur de chargement', 'error');
        z.innerHTML = '<div class="section-title">Rentabilité par bande</div>'
                    + '<div class="gestion-vide">Chargement impossible.</div>';
        return;
    }

    if (res.error) {
        console.error('get_rentabilite_bandes:', res.error);
        toast('Erreur : ' + res.error.message, 'error');
        z.innerHTML = '<div class="section-title">Rentabilité par bande</div>'
                    + '<div class="gestion-vide">Chargement impossible.</div>';
        return;
    }

    _rentaBandes = (res.data && Array.isArray(res.data)) ? res.data : [];
    _dessinerRentabilite();
}


/* ───────────────────────────────────────────────────────
   Rendu principal
   ─────────────────────────────────────────────────────── */
function _dessinerRentabilite() {
    const z = zone();

    let html = '<div class="section-title">Rentabilité par bande</div>';

    html += '<div class="gestion-param-info">'
          + 'Coût de revient par sujet (CRU) et marge de chaque bande '
          + 'en cours. Une bande non encore vendue affiche « recettes à '
          + 'venir » — c\'est normal, la marge se réalise à la vente.'
          + '</div>';

    if (_rentaBandes.length === 0) {
        html += '<div class="gestion-vide">Aucune bande en cours.</div>';
    } else {
        html += '<div class="gestion-renta-liste">';
        _rentaBandes.forEach(function (b) {
            html += _carteBande(b);
        });
        html += '</div>';
    }

    html += ''
        + '<div class="gestion-actions-bas" style="margin-top:18px">'
        +   '<button class="gestion-pastille gestion-pastille-contour" '
        +     'onclick="renderGestion()">← Retour</button>'
        + '</div>';

    z.innerHTML = html;
}


/* ───────────────────────────────────────────────────────
   Une carte de bande.

   cru_unitaire peut être NULL (effectif = 0, protégé côté RPC
   par NULLIF) → on affiche « — ».

   Marge :
     • recettes = 0  → état neutre « recettes à venir » (gris)
     • recettes > 0  → marge verte si ≥ 0, rouge sinon
   ─────────────────────────────────────────────────────── */
function _carteBande(b) {
    const cru       = (b.cru_unitaire === null || b.cru_unitaire === undefined)
                        ? null : Number(b.cru_unitaire);
    const effectif  = Number(b.effectif_actuel) || 0;
    const age       = Number(b.age_jours) || 0;
    const depenses  = Number(b.total_depenses) || 0;
    const recettes  = Number(b.total_recettes) || 0;
    const marge     = Number(b.marge_nette) || 0;

    const aVendu = recettes > 0;

    // Bloc marge : neutre tant qu'aucune vente, coloré sinon
    let margeHtml;
    if (!aVendu) {
        margeHtml = ''
            + '<div class="gestion-renta-marge gestion-renta-marge-neutre">'
            +   '<span class="gestion-renta-marge-label">Marge</span>'
            +   '<span class="gestion-renta-marge-val">Recettes à venir</span>'
            + '</div>';
    } else {
        const mClass = marge >= 0 ? 'gestion-renta-pos' : 'gestion-renta-neg';
        const signe  = marge >= 0 ? '+' : '−';
        margeHtml = ''
            + '<div class="gestion-renta-marge">'
            +   '<span class="gestion-renta-marge-label">Marge</span>'
            +   '<span class="gestion-renta-marge-val ' + mClass + '">'
            +     signe + fcfa(Math.abs(marge))
            +   '</span>'
            + '</div>';
    }

    const cruTxt = (cru === null) ? '—' : fcfa(cru) + '/sujet';

    return ''
        + '<div class="gestion-renta-carte">'
        +   '<div class="gestion-renta-entete">'
        +     '<span class="gestion-renta-nom">' + esc(b.id_bande || '—') + '</span>'
        +     '<span class="gestion-renta-age">' + age + ' j · '
        +       effectif.toLocaleString('fr-FR').replace(/\u202f|\u00a0/g, ' ')
        +       ' sujets</span>'
        +   '</div>'
        +   '<div class="gestion-renta-cru">'
        +     '<span class="gestion-renta-cru-label">Coût de revient</span>'
        +     '<span class="gestion-renta-cru-val">' + esc(cruTxt) + '</span>'
        +   '</div>'
        +   '<div class="gestion-renta-detail">'
        +     '<span>Dépenses : ' + fcfa(depenses) + '</span>'
        +     '<span>Recettes : ' + fcfa(recettes) + '</span>'
        +   '</div>'
        +   margeHtml
        + '</div>';
}


/* ═══ EXPOSITION SUR window (§17.4) ═══ */
window.renderRentabilite = renderRentabilite;