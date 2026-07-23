/* ═══════════════════════════════════════════════════════
   js/parametres/parametres.js — Écran Paramètres (gérant)
   ───────────────────────────────────────────────────────
   Identité de la ferme, telle qu'elle apparaît sur les
   documents remis aux clients (reçus de paiement).

   La table `fermes` possédait déjà nom, proprietaire,
   telephone, ville, pays, email. La Migration 047 y ajoute
   `nom_commercial` — le nom destiné aux clients, distinct
   de `nom` qui reste l'identifiant technique (REVAGRO).
   ═══════════════════════════════════════════════════════ */

import { db, fermeId, estGerant } from '../shared/db.js';
import { esc, toast, zone } from '../shared/helpers.js';

let _param = null;

async function renderParametres() {

    if (!estGerant()) {
        toast('Accès réservé au gérant', 'error');
        return;
    }

    const z = zone();
    if (!z) return;
    z.innerHTML = '<div class="section-title">Paramètres</div>'
                + '<div class="gestion-vide">Chargement…</div>';

    const res = await db()
        .from('fermes')
        .select('id, nom, nom_commercial, proprietaire, telephone, ville, pays, email')
        .eq('id', fermeId())
        .single();

    if (res.error || !res.data) {
        toast('Erreur de chargement', 'error');
        z.innerHTML = '<div class="section-title">Paramètres</div>'
                    + '<div class="gestion-vide">Chargement impossible.</div>';
        return;
    }

    _param = res.data;
    _dessinerParametres();
}

function _dessinerParametres() {
    const z = zone();
    const f = _param;

    z.innerHTML = ''
        + '<div class="section-title">Paramètres</div>'
        + '<div class="gestion-param-info">'
        +   'Ces informations apparaissent en en-tête des reçus '
        +   'remis à vos clients.'
        + '</div>'
        + '<div class="gestion-form-compact">'
        +   '<div class="gestion-form-group">'
        +     '<label class="gestion-form-label">Nom commercial</label>'
        +     '<input class="gestion-input" id="par-nom-com" type="text" maxlength="80" '
        +       'placeholder="' + esc(f.nom || 'Nom de la ferme') + '" '
        +       'value="' + esc(f.nom_commercial || '') + '">'
        +     '<div class="gestion-param-aide">'
        +       'Si vide, le reçu affichera « ' + esc(f.nom || 'AviGest') + ' ».'
        +     '</div>'
        +   '</div>'
        +   '<div class="gestion-form-group">'
        +     '<label class="gestion-form-label">Téléphone</label>'
        +     '<input class="gestion-input" id="par-tel" type="tel" maxlength="30" '
        +       'value="' + esc(f.telephone || '') + '">'
        +   '</div>'
        +   '<div class="gestion-form-group">'
        +     '<label class="gestion-form-label">Ville</label>'
        +     '<input class="gestion-input" id="par-ville" type="text" maxlength="60" '
        +       'value="' + esc(f.ville || '') + '">'
        +   '</div>'
        +   '<div class="gestion-actions-bas" style="margin-top:18px">'
        +     '<button class="gestion-pastille gestion-pastille-contour" '
        +       'onclick="renderGestion()">← Retour</button>'
        +     '<button class="gestion-pastille gestion-pastille-accent" '
        +       'onclick="_enregistrerParametres()">Enregistrer</button>'
        +   '</div>'
        + '</div>';
}

async function _enregistrerParametres() {
    const nc = document.getElementById('par-nom-com');
    const tel = document.getElementById('par-tel');
    const vil = document.getElementById('par-ville');

    const nomCom = nc ? nc.value.trim() : '';
    const telVal = tel ? tel.value.trim() : '';
    const vilVal = vil ? vil.value.trim() : '';

    const r = await db().from('fermes')
        .update({
            nom_commercial: nomCom || null,
            telephone: telVal || null,
            ville: vilVal || null
        })
        .eq('id', fermeId());

    if (r.error) {
        toast('Erreur : ' + r.error.message, 'error');
        return;
    }

    // Mémorise l'identité pour les reçus, sans nouvelle requête
    window._avigestFerme = {
        nom: _param.nom,
        nom_commercial: nomCom || null,
        telephone: telVal || null,
        ville: vilVal || null
    };

    toast('Paramètres enregistrés', 'success');
    renderGestion();
}


/* ═══ EXPOSITION SUR window ═══ */
window.renderParametres       = renderParametres;
window._enregistrerParametres = _enregistrerParametres;
