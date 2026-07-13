/* ============================================================
   js/shared/db.js — Accès à la base de données
   ------------------------------------------------------------
   RÔLE : donner aux nouveaux modules un accès propre au contexte
   de l'application (client Supabase, ferme, rôle), SANS créer un
   deuxième client et SANS toucher aux variables internes.

   POURQUOI UN "GUICHET" :
   Dans index.html, les variables App et FERME_ID sont déclarées
   avec const/let — elles NE SONT PAS sur window, donc invisibles
   depuis un module externe (vérifié en console le 11/07/2026 :
   window.App = undefined, window.FERME_ID = undefined).

   index.html expose donc UNE fonction, window.avigestContext(),
   qui renvoie une PHOTO de l'état courant. C'est l'unique frontière
   entre l'ancien code et les nouveaux modules.

   RÈGLE ABSOLUE : appeler ctx() au moment de s'en servir, jamais
   en cache. Le client sb est réaffecté au login (index.html ~526) :
   une copie gardée en mémoire porterait le mauvais header x-ferme-id.
   ============================================================ */


/**
 * Photo du contexte applicatif courant.
 * @returns {{sb: object|null, role: string|null, fermeId: string|null}}
 */
function ctx() {
    if (typeof window.avigestContext !== 'function') {
        throw new Error(
            'Guichet avigestContext() absent — index.html n\'est pas a jour.'
        );
    }
    return window.avigestContext();
}


/**
 * Renvoie le client Supabase courant.
 * A appeler a CHAQUE requete — jamais stocke dans une variable.
 * @throws {Error} si le client n'est pas encore initialise (avant login)
 */
export function db() {
    const client = ctx().sb;
    if (!client) {
        throw new Error('Client Supabase non initialise — ferme non selectionnee.');
    }
    return client;
}


/**
 * Renvoie l'identifiant de la ferme courante.
 * Toute lecture/ecriture Supabase doit etre filtree dessus
 * (regle absolue — lecon audit securite 14.2).
 * @throws {Error} si aucune ferme n'est selectionnee
 */
export function fermeId() {
    const id = ctx().fermeId;
    if (!id) {
        throw new Error('FERME_ID absent — aucune ferme selectionnee.');
    }
    return id;
}


/**
 * Renvoie le role de l'utilisateur connecte.
 * @returns {string|null} 'GERANT' | 'AGENT' | 'PARTENAIRE' | null
 */
export function role() {
    return ctx().role;
}


/**
 * Garde-fou : les ecrans GESTION sont reserves au gerant.
 * @returns {boolean}
 */
export function estGerant() {
    return role() === 'GERANT';
}
