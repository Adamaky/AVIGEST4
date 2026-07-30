/* ═══════════════════════════════════════════════════════
   js/tresorerie/tresorerie.js — Écran Trésorerie / Caisse (gérant)
   ───────────────────────────────────────────────────────
   Vue "caisse réelle" de la ferme, distincte des créances
   (séparation OHADA, Bible §16.1). Elle affiche :
     • le SOLDE de caisse (gros chiffre en tête),
     • le détail du calcul (solde initial, encaissé, pénalités,
       dépenses),
     • l'HISTORIQUE des mouvements (50 derniers),
     • un bouton pour RÉGLER le solde initial (traçable).

   SOURCE DES DONNÉES — 3 RPC serveur (Migration 052) :
     get_solde_caisse()       → agrégats + solde + date_debut
     get_historique_caisse()  → liste des mouvements
     modifier_solde_initial() → pose/modifie le solde de départ

   Le solde de départ vit sur fermes.solde_caisse_initial, avec
   une date de début de suivi (date_debut_caisse). On ne compte
   que les mouvements dont la date >= cette date de début.

   Règle motif (option B, traçabilité) : le motif est obligatoire
   pour MODIFIER un solde déjà défini, pas pour la 1re saisie.
   La RPC applique cette règle côté serveur ; l'écran la reflète.
   ═══════════════════════════════════════════════════════ */

import { db, fermeId, estGerant } from '../shared/db.js';
import { esc, toast, zone, fcfa, dateFr } from '../shared/helpers.js';

let _tresoSolde = null;   // ligne renvoyée par get_solde_caisse()
let _tresoMvts  = [];     // lignes renvoyées par get_historique_caisse()


/* ───────────────────────────────────────────────────────
   Point d'entrée — chargement puis rendu
   ─────────────────────────────────────────────────────── */
async function renderTresorerie() {

    if (!estGerant()) {
        toast('Accès réservé au gérant', 'error');
        return;
    }

    const z = zone();
    if (!z) return;
    z.innerHTML = '<div class="section-title">Trésorerie</div>'
                + '<div class="gestion-vide">Chargement…</div>';

    // Deux appels séparés (solde léger + historique). On les lance
    // en parallèle pour ne pas cumuler les temps d'attente.
    let soldeRes, histRes;
    try {
        [soldeRes, histRes] = await Promise.all([
            db().rpc('get_solde_caisse'),
            db().rpc('get_historique_caisse')
        ]);
    } catch (e) {
        console.error('renderTresorerie:', e);
        toast('Erreur de chargement', 'error');
        z.innerHTML = '<div class="section-title">Trésorerie</div>'
                    + '<div class="gestion-vide">Chargement impossible.</div>';
        return;
    }

    if (soldeRes.error) {
        console.error('get_solde_caisse:', soldeRes.error);
        toast('Erreur : ' + soldeRes.error.message, 'error');
        z.innerHTML = '<div class="section-title">Trésorerie</div>'
                    + '<div class="gestion-vide">Chargement impossible.</div>';
        return;
    }

    // get_solde_caisse renvoie exactement 1 ligne (RETURNS TABLE)
    _tresoSolde = (soldeRes.data && soldeRes.data[0]) ? soldeRes.data[0] : {
        solde_initial: 0, date_debut: null, total_encaisse: 0,
        total_penalites: 0, total_depenses: 0, solde: 0
    };

    // L'historique peut échouer sans bloquer l'affichage du solde
    _tresoMvts = (!histRes.error && histRes.data) ? histRes.data : [];

    _dessinerTresorerie();
}


/* ───────────────────────────────────────────────────────
   Rendu principal
   ─────────────────────────────────────────────────────── */
function _dessinerTresorerie() {
    const z = zone();
    const s = _tresoSolde;

    const solde   = Number(s.solde) || 0;
    const initial = Number(s.solde_initial) || 0;
    const encaiss = Number(s.total_encaisse) || 0;
    const penal   = Number(s.total_penalites) || 0;
    const depens  = Number(s.total_depenses) || 0;

    // Couleur du gros solde : vert si >= 0, rouge sinon
    const soldeClass = solde < 0 ? 'gestion-treso-solde-neg'
                                 : 'gestion-treso-solde-pos';

    // Sous-titre : rappelle la date de début de suivi si connue.
    // date_debut est renvoyée par get_solde_caisse().
    const sousTitre = s.date_debut
        ? 'Suivi depuis le ' + dateFr(s.date_debut)
        : 'Aucune date de début définie';

    let html = '<div class="section-title">Trésorerie</div>';

    // Bloc solde principal
    html += ''
        + '<div class="gestion-treso-carte-solde">'
        +   '<div class="gestion-treso-solde-label">Solde de caisse</div>'
        +   '<div class="gestion-treso-solde-montant ' + soldeClass + '">'
        +     esc(fcfa(solde))
        +   '</div>'
        +   '<div class="gestion-treso-solde-sub">' + esc(sousTitre) + '</div>'
        + '</div>';

    // Détail du calcul : 4 mini-cartes (2 x 2)
    html += ''
        + '<div class="gestion-treso-details">'
        +   _miniCarte('Solde initial', fcfa(initial), '')
        +   _miniCarte('Encaissé', '+' + fcfa(encaiss), 'gestion-treso-pos')
        +   _miniCarte('Pénalités', '+' + fcfa(penal), '')
        +   _miniCarte('Dépenses', '−' + fcfa(depens), 'gestion-treso-neg')
        + '</div>';

    // Bouton régler le solde initial
    html += ''
        + '<div class="gestion-actions-bas" style="margin:14px 0 20px">'
        +   '<button class="gestion-pastille gestion-pastille-contour" '
        +     'onclick="_tresoOuvrirReglage()">⚙️ Régler le solde initial</button>'
        + '</div>';

    // Historique
    html += '<div class="gestion-treso-hist-titre">Historique des mouvements</div>';

    if (_tresoMvts.length === 0) {
        html += '<div class="gestion-vide">Aucun mouvement de caisse.</div>';
    } else {
        html += '<div class="gestion-treso-liste">';
        _tresoMvts.forEach(function (m) {
            html += _ligneMvt(m);
        });
        html += '</div>';
    }

    // Retour
    html += ''
        + '<div class="gestion-actions-bas" style="margin-top:18px">'
        +   '<button class="gestion-pastille gestion-pastille-contour" '
        +     'onclick="renderGestion()">← Retour</button>'
        + '</div>';

    z.innerHTML = html;
}


/* ───────────────────────────────────────────────────────
   Une mini-carte du détail (label + valeur colorée)
   ─────────────────────────────────────────────────────── */
function _miniCarte(label, valeur, classeVal) {
    return ''
        + '<div class="gestion-treso-mini">'
        +   '<div class="gestion-treso-mini-label">' + esc(label) + '</div>'
        +   '<div class="gestion-treso-mini-val ' + classeVal + '">'
        +     esc(valeur)
        +   '</div>'
        + '</div>';
}


/* ───────────────────────────────────────────────────────
   Une ligne de l'historique
   source ∈ 'PAIEMENT' | 'PENALITE' | 'DEPENSE'
   montant : positif = entrée (vert), négatif = sortie (rouge)
   ─────────────────────────────────────────────────────── */
function _ligneMvt(m) {
    const montant = Number(m.montant) || 0;
    const entree  = montant >= 0;

    const pastilleClass = entree ? 'gestion-treso-pastille-in'
                                 : 'gestion-treso-pastille-out';
    const fleche = entree ? '↓' : '↑';
    const montantClass = entree ? 'gestion-treso-pos' : 'gestion-treso-neg';
    const signe = entree ? '+' : '−';
    const montantAbs = Math.abs(montant);

    const ref = m.reference ? (' · ' + esc(m.reference)) : '';

    return ''
        + '<div class="gestion-treso-ligne">'
        +   '<div class="gestion-treso-pastille ' + pastilleClass + '">' + fleche + '</div>'
        +   '<div class="gestion-treso-ligne-corps">'
        +     '<div class="gestion-treso-ligne-lib">' + esc(m.libelle || '—') + '</div>'
        +     '<div class="gestion-treso-ligne-meta">' + dateFr(m.date_mvt) + ref + '</div>'
        +   '</div>'
        +   '<div class="gestion-treso-ligne-montant ' + montantClass + '">'
        +     signe + fcfa(montantAbs)
        +   '</div>'
        + '</div>';
}


/* ═══════════════════════════════════════════════════════
   ÉCRAN DE RÉGLAGE DU SOLDE INITIAL
   ═══════════════════════════════════════════════════════ */
async function _tresoOuvrirReglage() {

    const z = zone();
    if (!z) return;

    // On relit fermes pour connaître la valeur actuelle + la date
    // de début + savoir s'il existe déjà des ajustements (→ motif requis)
    const res = await db()
        .from('fermes')
        .select('solde_caisse_initial, date_debut_caisse')
        .eq('id', fermeId())
        .single();

    if (res.error || !res.data) {
        toast('Erreur de chargement', 'error');
        return;
    }

    // Combien d'ajustements déjà faits ? (pour savoir si le motif est requis)
    const cnt = await db()
        .from('caisse_ajustements')
        .select('id', { count: 'exact', head: true })
        .eq('ferme_id', fermeId());

    const dejaDefini = (cnt && typeof cnt.count === 'number' && cnt.count > 0);

    const valActuelle = Number(res.data.solde_caisse_initial) || 0;
    const dateActuelle = res.data.date_debut_caisse || '';

    let html = '<div class="section-title">Solde initial de caisse</div>';

    html += '<div class="gestion-param-info">'
          + 'Indiquez le montant réellement présent en caisse à une '
          + 'date de départ. L\'app comptera ensuite les mouvements à '
          + 'partir de cette date.'
          + '</div>';

    html += '<div class="gestion-form-compact">';

    // Montant
    html += ''
        + '<div class="gestion-form-group">'
        +   '<label class="gestion-form-label">Montant en caisse (F)</label>'
        +   '<input class="gestion-input" id="treso-init-montant" type="number" '
        +     'step="1" value="' + esc(String(valActuelle)) + '">'
        +   '<div class="gestion-param-aide" id="treso-init-warn" style="display:none">'
        +     '⚠️ Solde initial négatif — caisse à découvert au départ ?'
        +   '</div>'
        + '</div>';

    // Date de début
    html += ''
        + '<div class="gestion-form-group">'
        +   '<label class="gestion-form-label">Date de début de suivi</label>'
        +   '<input class="gestion-input" id="treso-init-date" type="date" '
        +     'value="' + esc(dateActuelle) + '">'
        +   '<div class="gestion-param-aide">'
        +     'Les mouvements de ce jour et des suivants seront comptés.'
        +   '</div>'
        + '</div>';

    // Motif — visible seulement si un solde a déjà été défini
    if (dejaDefini) {
        html += ''
            + '<div class="gestion-form-group">'
            +   '<label class="gestion-form-label">Motif de la modification</label>'
            +   '<input class="gestion-input" id="treso-init-motif" type="text" '
            +     'maxlength="120" placeholder="Ex : erreur de comptage initial">'
            +   '<div class="gestion-param-aide">'
            +     'Obligatoire : chaque modification est tracée.'
            +   '</div>'
            + '</div>';
    }

    html += ''
        + '<div class="gestion-actions-bas" style="margin-top:18px">'
        +   '<button class="gestion-pastille gestion-pastille-contour" '
        +     'onclick="renderTresorerie()">← Retour</button>'
        +   '<button class="gestion-pastille gestion-pastille-accent" '
        +     'onclick="_tresoEnregistrerReglage(' + (dejaDefini ? 'true' : 'false') + ')">'
        +     'Enregistrer</button>'
        + '</div>';

    html += '</div>';

    z.innerHTML = html;

    // Avertissement live si montant négatif
    const inp = document.getElementById('treso-init-montant');
    const warn = document.getElementById('treso-init-warn');
    if (inp && warn) {
        const maj = function () {
            warn.style.display = (Number(inp.value) < 0) ? 'block' : 'none';
        };
        inp.addEventListener('input', maj);
        maj();
    }
}


async function _tresoEnregistrerReglage(dejaDefini) {

    const mInp = document.getElementById('treso-init-montant');
    const dInp = document.getElementById('treso-init-date');
    const moInp = document.getElementById('treso-init-motif');

    const montant = mInp ? Number(mInp.value) : NaN;
    const dateVal = dInp && dInp.value ? dInp.value : null;
    const motif = moInp ? moInp.value.trim() : '';

    if (!mInp || isNaN(montant)) {
        toast('Montant invalide', 'error');
        return;
    }

    // Garde-fou côté client : motif requis pour une modification
    if (dejaDefini && !motif) {
        toast('Motif obligatoire pour modifier le solde initial', 'error');
        return;
    }

    const r = await db().rpc('modifier_solde_initial', {
        p_nouveau_montant: montant,
        p_nouvelle_date: dateVal,
        p_motif: motif || null
    });

    if (r.error) {
        toast('Erreur : ' + r.error.message, 'error');
        return;
    }

    // La RPC renvoie { ok:false, error } si le motif manquait côté serveur
    if (r.data && r.data.ok === false) {
        toast(r.data.error || 'Modification refusée', 'error');
        return;
    }

    toast('Solde initial enregistré', 'success');
    renderTresorerie();
}


/* ═══ EXPOSITION SUR window (§17.4) ═══ */
window.renderTresorerie        = renderTresorerie;
window._tresoOuvrirReglage     = _tresoOuvrirReglage;
window._tresoEnregistrerReglage = _tresoEnregistrerReglage;