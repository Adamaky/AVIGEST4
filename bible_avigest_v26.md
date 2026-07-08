# 🐔 AviGest v26

Bible du Projet — Document de Référence Permanent

*Version 26 — Adama Désiré — Ouagadougou, Burkina Faso*

> **Synchronisation** : ce `.md` est régénéré à partir de `bible_avigest_v26.docx` — dernière synchronisation le **08/07/2026** (session v26.20). Le `.docx` reste la référence unique ; ce `.md` est une copie dérivée lue par Claude Code depuis le repo, à côté de `SCHEMA.md`. Ne jamais éditer ce `.md` comme source — toujours régénérer depuis le `.docx` à jour.

# 1. Contexte et Objectif

AviGest est une Progressive Web App (PWA) de gestion avicole à Ouagadougou. Elle gère un élevage de poulets de chair sur plusieurs poulaillers, avec trois rôles : gérant, agent, partenaires investisseurs.

**Contraintes clés :**

- Connexion variable — mode hors ligne prévu (non encore implémenté)

- Agent peu familier avec le numérique — interface pavé numérique, un champ à la fois

- Backend : Supabase PostgreSQL + Realtime · Frontend : GitHub Pages · SDK local supabase.js

# 2. Architecture Technique

## 2.1 URLs et Identifiants

| **Élément**           | **Valeur**                                          |
|-----------------------|-----------------------------------------------------|
| URL Frontend          | https://adamaky.github.io/AVIGEST4/                 |
| GitHub Repo           | https://github.com/Adamaky/AVIGEST4                 |
| Supabase URL          | https://jzlmnpxcnrcajludtkpt.supabase.co            |
| Supabase Project ID   | Jzlmnpxcnrcajludtkpt                                |
| Ferme ID (REVAGRO)    | e56574a9-54c1-430d-b480-b9bdd1090dd7                |
| Ferme ID (ALIRAH2026) | 40ee764e-d073-463e-b07b-bf95a9d7a675                |
| Client Supabase       | sb (toujours sb, jamais supabase)                   |
| SDK local             | supabase.js ligne 17 (téléchargé depuis unpkg.com)  |
| Session               | 12 heures · Avertissement 1h avant expiration       |
| Fichier de travail    | C:\Users\kyada\Documents\GitHub\AVIGEST4\index.html |

## 2.2 Terminologie — Deux niveaux

| **Terme visible (interface)** | **Terme technique (code)** | **Explication**                   |
|-------------------------------|----------------------------|-----------------------------------|
| Poulailler 1, 2...            | Batiment-1, Batiment-2...  | Salle d'élevage physique          |
| Bande                         | bande / bande_id           | Lot de poulets dans un poulailler |
| Agent                         | AGENT / role               | Responsable terrain               |
| Partenaire                    | PARTENAIRE / role          | Investisseur                      |
| Gérant                        | GERANT / role              | Gestionnaire principal            |

## 2.3 Format ID Bande

Format : Bande-YYYY-NNN (ex : Bande-2026-001)

- Regex de validation : /^Bande-\d{4}-\d{3}\$/

- Auto-génération avec possibilité de saisie manuelle

- Soft-delete : toujours ajouter .eq('is_deleted', false) sur les requêtes bandes

## 2.4 Architecture Supabase — Tables principales

| **Table**          | **Colonnes / Rôle**                                                                                                                      |
|--------------------|------------------------------------------------------------------------------------------------------------------------------------------|
| bandes             | id, ferme_id, nom, race, effectif_initial, date_arrivee, statut, is_deleted                                                              |
| saisies_techniques | id, ferme_id, bande_id, date_saisie, session, categorie, valeur, valeur2, unite, note, rôle                                              |
| taches             | id, ferme_id, bande_id, titre, statut, type_tache, date_creation, date_validation                                                        |
| journal            | id, ferme_id, bande_id, date_ecriture, type_ecriture, categorie, montant, note                                                           |
| lots_stock         | id, ferme_id, bande_id, produit, reference, quantite_initiale, quantite_restante, cout_unitaire (généré), seuil_alerte, date_fabrication |
| mouvements_stock   | id, ferme_id, lot_id, type_mouvement (ENTREE/SORTIE), quantite, session, cout_impute, note                                               |
| rapports_hebdo     | id, ferme_id, bande_id, semaine, contenu_agent, contenu_gerant, lu_par_agent, lu_par_gerant                                              |
| sessions_actives   | id, ferme_id, user_id, device_fingerprint — RLS désactivée — verrouillage multi-appareils                                                |

## 2.5 Migrations SQL — GitHub

| **Fichier**                 | **Contenu**                                                             |
|-----------------------------|-------------------------------------------------------------------------|
| 001_schema_initial.sql      | Tables de base : bandes, saisies_techniques, taches, journal            |
| 002_stock_tables.sql        | Tables lots_stock et mouvements_stock                                   |
| 003_rls_policies.sql        | Politiques RLS sur les 14 tables                                        |
| 004_get_ferme_id_fix.sql    | Correction SECURITY DEFINER + cast JSON sur get_ferme_id()              |
| 005_imputer_aliment_rpc.sql | RPC imputer_aliment() — imputation atomique stock depuis sessions agent |
| 006_stock_dashboard_rpc.sql | RPC pour vue stock dashboard gérant                                     |

# 3. Utilisateurs et Rôles

| **Rôle**   | **Limite** | **PIN actuel**     | **Accès**                                                        |
|------------|------------|--------------------|------------------------------------------------------------------|
| GERANT     | Max 2      | 0000 (Adama)       | Tout — supervision, planif, compta, poulaillers, stock, rapports |
| AGENT      | Max 2      | 1111 (Agent Ferme) | Terrain — sessions, saisies, tâches                              |
| PARTENAIRE | Illimité   | PIN individuel     | Ses bandes — résultats, état lot, créances                       |

# 4. Règles Techniques Critiques

## 4.1 Règles Supabase

- Client toujours nommé sb — jamais supabase

- Header x-ferme-id injecté globalement à la création du client (ligne 427)

- RLS active sur toutes les tables sauf sessions_actives

- get_ferme_id() avec SECURITY DEFINER — retourne l'ID ferme depuis le header

- Statelessness REST : set_config ne persiste pas entre requêtes — utiliser le header global

- Avant tout INSERT : vérifier colonnes NOT NULL, defaults, et colonnes générées

- cout_unitaire dans lots_stock est une colonne GÉNÉRÉE — ne jamais l'inclure dans un INSERT

- lots_stock.produit : noms complets (ex : 'Aliment de démarrage') — chercher avec LOWER(produit) LIKE

- mouvements_stock.type_mouvement : uniquement 'ENTREE' ou 'SORTIE'

## 4.2 Règles JavaScript

- Apostrophes dans les chaînes JS : toujours échapper avec \\ ou utiliser des guillemets doubles

- Ne jamais imbriquer des template literals dans .map() — utiliser la concaténation

- &quot; au lieu d'apostrophes dans les attributs onclick inline

- node --check échoue sur les fichiers .html — utiliser la commande PowerShell d'extraction JS

- jsDelivr CDN inaccessible depuis le Burkina Faso — utiliser unpkg.com ou le fichier local

## 4.3 Règles de travail

- Fichier unique : C:\Users\kyada\Documents\GitHub\AVIGEST4\index.html

- Workflow : VS Code → Claude Code → vérification syntaxe PowerShell → GitHub Desktop → Push

- Chaque modification SQL = un nouveau fichier de migration numéroté dans migrations/

- APP_VERSION mis à jour à chaque session

- Sélectionner 'Yes, allow all edits this session' dans Claude Code pour les sessions multi-patches

- Vérification après patch : commandes Ctrl+Shift+F avec nombre d'occurrences attendu

RÈGLE STOCK — Deux types de lots

Avant tout INSERT lots_stock, vérifier le flag

impute_journal (BOOLEAN) :

→ true : RPC déclenche écriture journal

→ false : RPC décrémente stock uniquement,

pas d'écriture journal

RÈGLE CRU — Filtre catégories charges consommées

CRU = SUM(montant) WHERE categorie IN

('Alimentation','Vaccin','Médicament')

/ effectif_vivants

NE PAS inclure : Salaire, Prestation, Transport,

Glace, Achat stock, Autre

RÈGLE JOURNAL — Catégories prédéfinies (v2)

Charges consommées (CRU) :

→ Alimentation (auto RPC)

→ Vaccin [type + unité + qté + PU]

→ Médicament [type + unité + qté + PU]

Charges exploitation (hors CRU) :

→ Salaire [forfait ou qté×PU]

→ Prestation de service [forfait ou qté×PU]

→ Transport [forfait ou qté×PU]

→ Glace [forfait ou qté×PU]

→ Autre [texte libre + montant]

Hors charges (mouvement stock) :

→ Achat stock [lié à lots_stock]

# 5. Score Santé — Règle de Calcul

Validé session 18 juin 2026 — Cobb 500, Ouagadougou, J14+

| **Paramètre**    | **Bon 🟢** | **Passable 🟡** | **Mauvais 🔴** |
|------------------|------------|-----------------|----------------|
| Température (°C) | 26–32°C    | 33–35°C         | <26 ou >35°C |
| Hygrométrie (%)  | 50–70%     | 71–80%          | <50 ou >80%  |
| Mortalité/jour   | 0–2 morts  | 3–5 morts       | >5 morts      |

**Règle de calcul : Score final = le PIRE des 3 scores individuels**

Surcharge manuelle : l'agent peut modifier le score calculé + saisir une note explicative

# 6. Module Stock — Architecture complète

```
TYPE DE LOT STOCK
─────────────────────────────────────────────

Type A — Avec imputation journal (charge)

 → Aliment, Vaccin, Médicament, Litière

 → Décrémente stock + écriture journal auto

 → Entre dans le CRU (sauf catégorie "Achat stock")

Type B — Sans imputation journal

 → Produits créés par le gérant avec impute_journal = false

 → Décrémente stock uniquement

 → N'entre PAS dans le CRU

FLAG sur lots_stock (implémenté) : 

 impute_journal BOOLEAN DEFAULT false
 categorie_cru TEXT (v26.16) — catégorie comptable du lot,
 lue en priorité par imputer_stock(), avec repli sur
 l'ancien CASE (nom produit) si NULL

─────────────────────────────────────────────

ÉTAPES MODULE STOCK
Étape 1 — Schéma SQL ✅ Validé
Étape 2 — Interface création lot ✅ Validé
Étape 3 — Imputation auto sessions agent ✅ Validé
Étape 4 — Vue stock dashboard gérant ✅ Validé
Étape 5 — Validation gérant alimentation ✅ Validé — mécanisme EN_ATTENTE + écran validation gérant opérationnel
Étape 6 — RPC litière (Type A, alignée aliment) ✅ Validé — Migration 029, testé en conditions réelles 01/07/2026
Étape 7 — Formulaire dépense enrichi ○ À faire
Étape 8 — CRU filtré charges consommées ○ À faire
```

# 13. Tableau de Suivi — Outil Permanent du Non-Codeur

Cette section est la mémoire vivante du projet. Claude la lit à chaque session pour savoir où en est le projet sans qu'Adama ait besoin de tout réexpliquer.

## 13.1 Légende des Statuts

| **Statut**  | **Signification**                       | **Action suivante**                            |
|-------------|-----------------------------------------|------------------------------------------------|
| ✅ Validé   | Testé sur l'app et confirmé fonctionnel | Passer à la prochaine fonctionnalité           |
| ⏳ En cours | Code produit mais pas encore testé      | Tester sur https://adamaky.github.io/AVIGEST4/ |
| 🐛 Bug      | Testé — comportement incorrect observé  | Décrire le bug précis à Claude                 |
| ○ À faire   | Pas encore commencé                     | Briefer Claude quand c'est la priorité         |
| ☁️ SaaS     | Fonctionnalité prévue multi-fermes      | À planifier après stabilisation v1             |

## 13.2 Tableau de Suivi des Fonctionnalités

| **Fonctionnalité**                  | **Statut**      | **Note / Bug connu**                                                         | **SaaS** |
|-------------------------------------|-----------------|------------------------------------------------------------------------------|----------|
| **FONDATIONS**                      |                 |                                                                              |          |
| Login PIN + session 12h             | **✅ Validé**   | Testé PIN 0000 → OK                                                          |          |
| Verrouillage multi-appareils        | **✅ Validé**   | Table sessions_actives + device fingerprint                                  |          |
| Écran blocage session concurrente   | **✅ Validé**   | Ex-B2 — écran dédié screen-blocage (au lieu d'injection dans app-main caché) |          |
| Bouton Forcer déconnexion           | **✅ Validé**   | Ex-B9 — role passé en paramètre, corrige dépendance circulaire localStorage  |          |
| Système de navigation Nav           | **✅ Validé**   | Bug pavé PIN corrigé                                                         |          |
| Mode hors ligne + sync auto         | **○ À faire**   | Queue localStorage à implémenter                                             |          |
| Notifications OneSignal             | **○ À faire**   | Géré en arrière-plan                                                         |          |
| **AGENT**                           |                 |                                                                              |          |
| Tuiles sessions dans onglet Tâches  | **✅ Validé**   | 4 sessions : Matin/Midi/PM/Nuit                                              |          |
| Session Matin — 6 étapes            | **✅ Validé**   | Pavé numérique fonctionnel                                                   |          |
| Session Midi — 3 étapes             | **✅ Validé**   | Testé 18/06/2026                                                             |          |
| Session PM — 3 étapes               | **✅ Validé**   | Testé 18/06/2026                                                             |          |
| Session Nuit — 4 étapes             | **✅ Validé**   | Testé 18/06/2026                                                             |          |
| Score santé — calcul auto           | **🐛 Bug**      | B1 : 'Score undefined' — à corriger prochaine session                        |          |
| Score santé — surcharge manuelle    | **○ À faire**   | Prévu : bouton Bon/Passable/Mauvais + note agent                             |          |
| Blocage sessions hors plage horaire | **🐛 Bug**      | B3 : sessions accessibles hors horaire — à corriger                          |          |
| Écran abattage — 3 étapes           | **○ À faire**   | Calcul poids moyen auto                                                      |          |
| **GÉRANT**                          |                 |                                                                              |          |
| Accueil gérant — navigation         | **✅ Validé**   | ACCUEIL · BANDES · ANALYSES                                                  |          |
| Onglet Tâches gérant                | **✅ Validé**   | B4 corrigé 18/06 — termineesHTML déclarée                                    |          |
| Planifier tâches agent              | **✅ Validé**   | 3 types : Quotidienne · Hebdomadaire · Abattage                              |          |
| Journal comptable                   | **✅ Validé**   | Dépenses + Recettes + CRU/sujet                                              |          |
| Analyses — zootechnie               | **🐛 Bug**      | B5 : Poids moyen et IC vides — données manquantes                            |          |
| Analyses — finance                  | **✅ Validé**   | Marge nette · Dépenses · Recettes                                            |          |
| Planifier abattage                  | **✅ Validé**   | Formulaire Date + Nb sujets + Client cible                                   |          |
| Rapports hebdomadaires              | **⏳ En cours** | À tester prochaine session                                                   |          |
| Rapport fin de bande + WhatsApp     | **○ À faire**   | Export texte structuré                                                       |          |
| Gestion utilisateurs                | **○ À faire**   | Créer / activer / désactiver                                                 |          |
| **STOCK**                           |                 |                                                                              |          |
| Étape 1 — Schéma SQL                | **✅ Validé**   | Tables lots_stock + mouvements_stock                                         |          |
| Étape 2 — Interface création lot    | **✅ Validé**   | Formulaire gérant fonctionnel                                                |          |
| Étape 3 — Imputation auto sessions  | **✅ Validé**   | RPC imputer_aliment() validé 18/06 — -50kg/-20kg/-10kg OK                    |          |
| Étape 4 — Vue stock dashboard       | **✅ Validé**   | Synthèse + détail + seuil + historique mouvements                            |          |
| Navigation retour vues stock        | **✅ Validé**   | Testé 18/06/2026                                                             |          |
| **PARTENAIRE**                      |                 |                                                                              |          |
| Interface partenaire — 3 tuiles     | **○ À faire**   | Filtré par idPartenaire                                                      |          |
| Assignation quotes-parts            | **○ À faire**   | Total ≤ 100%                                                                 |          |
| **PROCESSUS**                       |                 |                                                                              |          |
| Clôture bande — 6 phases            | **○ À faire**   | 14 jours minimum                                                             |          |
| Fabrication aliment                 | **○ À faire**   | Lignes dynamiques                                                            |          |
| Alertes automatiques in-app         | **○ À faire**   | 7 KPI configurés                                                             |          |
| Abattage progressif — 6 étapes      | **○ À faire**   | Plan → Exec → Validation                                                     |          |
| **VISION SAAS**                     |                 |                                                                              |          |
| Multi-fermes (multi-tenant)         | **✅ Validé**   | 2 fermes actives (REVAGRO, ALIRAH2026) — chaque ferme = espace isolé         | ☁️       |
| Authentification sécurisée SaaS     | **○ À faire**   | PIN → tokens JWT ou équivalent                                               | ☁️       |
| Plans tarifaires (Free / Pro)       | **○ À faire**   | Gestion abonnements                                                          | ☁️       |
| Dashboard gérant SaaS               | **○ À faire**   | Vue de toutes les fermes                                                     | ☁️       |
| Onboarding nouvelle ferme           | **○ À faire**   | Option A : intégré (pas subdomain)                                           | ☁️       |

## 13.3 Bugs ouverts — À corriger prochaine session

## 13.4 Protocole de Brief de Session

Avant chaque session avec Claude, Adama colle ce bloc en début de message :

**📋 BRIEF SESSION AVIGEST v26**

Objectif du jour : [une phrase]

Dernière chose validée : [fonctionnalité]

Bug en suspens : [description ou 'Aucun']

## 13.5 Multi-fermes — État actuel et Feuille de Route SaaS

**ÉTAT ACTUEL (production) :**

AviGest gère aujourd'hui 2 fermes actives sur une architecture multi-tenant déjà fonctionnelle : un seul frontend GitHub Pages, sélection de ferme via code d'accès au login (écran-code-ferme), isolation des données par ferme_id + header x-ferme-id + RLS Supabase.

→ REVAGRO (ferme_id : e56574a9-54c1-430d-b480-b9bdd1090dd7)

→ ALIRAH2026 (ferme_id : 40ee764e-d073-463e-b07b-bf95a9d7a675)

**EN COURS D'ENGAGEMENT :**

Un 3e client est actuellement en cours d'intégration sur cette même architecture. Détails à préciser dans une prochaine mise à jour de la Bible.

**VISION SAAS (extension future au-delà des clients déjà engagés) :**

La vision SaaS plus large (accueil de clients externes non encore identifiés, abonnements, dashboard central multi-fermes) reste documentée ici pour que chaque fonctionnalité v1 soit conçue de façon compatible. Ne pas commencer le chantier SaaS élargi avant que les sections Fondations, Agent et Gérant soient toutes à statut Validé.

| **Pré-requis SaaS élargi**           | **Condition de démarrage**                                        |
|--------------------------------------|-------------------------------------------------------------------|
| v1 stable                            | Zéro bug ouvert en Fondations + Agent + Gérant + Stock            |
| Architecture multi-tenant            | **✅ Déjà en place et validée en production (2 fermes actives)**  |
| Authentification sécurisée           | Remplacer PIN seul par token JWT avec expiration                  |
| Plans tarifaires                     | Définir Free (1 poulailler) vs Pro (6+ poulaillers)               |
| Onboarding                           | Option A : écran onboarding intégré — pas de subdomains par ferme |
| Client(s) au-delà des 3 déjà engagés | Cible : début janvier 2027                                        |

## 13.6 Checklists anti-régression

Checklists opérationnelles à dérouler à chaque étape sensible. Intégrées depuis `bible_updates_v26.9.md` (session v26.20).

**Avant chaque déploiement :**

- Mettre à jour `CACHE_NAME` dans `sw.js` (format `'avigest-v26-XX'`) — force les navigateurs à vider leur cache, sinon les utilisateurs voient une ancienne version.

- Vérifier que `APP_VERSION` dans `index.html` correspond à la version déployée.

**Avant chaque test terrain :**

- Ouvrir un onglet InPrivate (`Ctrl+Shift+N`).

- `Ctrl+Shift+R` pour forcer le rechargement sans cache.

- Vérifier que le numéro de version affiché en bas de l'écran d'accueil correspond au dernier commit poussé.

- Si la version ne correspond pas, désinscrire le Service Worker via la console :

```js
navigator.serviceWorker.getRegistrations().then(function(r) {
for (let reg of r) { reg.unregister(); }
location.reload(true);
});
```

**Avant tout SQL (règle absolue) :**

- Lire `SCHEMA.md` depuis GitHub.

- Vérifier les types exacts des colonnes avant tout INSERT/UPDATE :

```sql
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'NOM_TABLE'
ORDER BY ordinal_position;
```

- Ne jamais supposer un type — toujours vérifier. `SCHEMA.md` est mis à jour après chaque migration.

# 14. Sécurité — État et Audit

Section consolidée le 04/07/2026 (session v26.19). Fusionne les résultats des audits sécurité successifs en un état unique et à jour.

## 14.1 — Chantiers sécurité fermés (historique)

S1 à S4 (validés v26.9/v26.10) : protection brute force PIN, hachage bcrypt des PIN, erreurs contextuelles via showToast, remplacement de sbTemp par fetch natif. Tous fermés.

## 14.2 — Audit RLS des tables (isolation cross-tenant confirmée)

Méthode : audit du code JS (repérage des opérations sans filtre ferme_id) PUIS audit de la base réelle (pg_tables, pg_policies). Les 5 tables signalées à risque par l'audit de code se sont révélées saines en base.

Résultat — 5 tables, isolation cross-tenant confirmée en base (RLS active + policies ferme_id = get_ferme_id()) :

- bandes : RLS active ; policies acces_par_ferme (anon), ferme_isolation (public), partenaire_ses_bandes (SELECT). ✅ Confirmée

- batiments : RLS active ; 5 policies découpées par commande, toutes ferme_id = get_ferme_id() (INSERT via with_check). ✅ Confirmée

- taches : RLS active ; acces_par_ferme (anon) + ferme_isolation (public). ✅ Confirmée

- lots_stock : RLS active ; acces_par_ferme (anon). ✅ Confirmée

- mouvements_stock : RLS active ; acces_par_ferme (anon) + ferme_isolation (public). ✅ Confirmée

Note de méthode : l'audit de code v26.18 signalait bandes/batiments en risque élevé et taches/lots_stock/mouvements_stock en risque moyen (opérations par id seul sans filtre ferme_id côté JS). Le diagnostic base montre que RLS compense intégralement côté serveur : chaque UPDATE/DELETE/SELECT par id est re-filtré par PostgreSQL via ferme_id = get_ferme_id(). Leçon transversale : un risque détecté à l'audit de code n'est un vrai trou que si RLS ne compense pas en base — les deux audits sont complémentaires, jamais l'un sans l'autre.

Note factuelle ALIRAH : au moment de l'audit, la table bandes ne contient aucune bande pour ALIRAH2026 (ferme onboardée, cycle d'élevage pas encore lancé). Le test cross-tenant a donc été mené en miroir (header ALIRAH ciblant une bande REVAGRO). Sans impact sécurité.

> *💡 En clair : chaque ferme est comme un appartement dans un immeuble. On a vérifié que les serrures (RLS) empêchent bien un locataire d'entrer chez le voisin. Les 5 pièces principales (les données de base : bandes, bâtiments, tâches, stock) sont correctement cloisonnées entre fermes.*

## 14.3 — Session RLS dédiée : socle et tests dynamiques

Socle vérifié — get_ferme_id() : LANGUAGE sql, STABLE SECURITY DEFINER, lit current_setting('request.headers', true)::json->>'x-ferme-id' cast en uuid. Fail-closed sur header absent (retourne NULL → ferme_id = NULL exclut toutes les lignes). ✅ Propre.

Tests dynamiques (rôle anon simulé via SET LOCAL role, transaction ROLLBACK) :

- Test A — header absent → count(bandes) = 0. ✅ Fail-closed prouvé.

- Test B — header REVAGRO → count(bandes) = 6. ✅ Laisse passer la bonne ferme.

- Test C — header ALIRAH, cible bande REVAGRO Bande-2026-002 (id 928f44ef-b6f5-4874-bbb8-3fac51437b8a) → count = 0. ✅ Blocage cross-tenant frontal confirmé.

Conclusion : isolation cross-tenant démontrée, statique + dynamique, sur les 5 tables prioritaires. Volet isolation RLS clos.

Réserve méthodologique : tests effectués via SET LOCAL role anon dans le SQL Editor (~95 % fidèle au chemin PostgREST réel, mais pas un test end-to-end via l'API REST). Fidélité jugée suffisante pour l'objectif d'audit.

> *💡 En clair : on a testé les serrures pour de vrai, pas juste sur le papier. Sans clé de ferme : rien ne s'ouvre (bon réflexe). Avec la clé REVAGRO : on voit REVAGRO. Avec la clé ALIRAH en essayant d'ouvrir une porte REVAGRO : bloqué. La preuve que le cloisonnement fonctionne dans les trois cas.*

## 14.4 — Audit des RPC et des vues (session v26.19)

RPC réellement câblées par le front (index.html) : get_dashboard (ligne 693), verifier_pin (1706), get_stock_dashboard (2262), imputer_stock ×2 (5067 aliment / 5101 autres produits, signature V1), valider_imputation_gerant ×2 (5435/5454).

imputer_stock — DEUX versions coexistent en base : V1 (p_bande_id, p_produit_like… ; RETURNS jsonb ; écrit DEPENSE + categorie_cru) = seule appelée par le front (sessions agent), isolation ✅. V2 (p_lot_id, p_montant, p_prix_unitaire, p_libelle ; RETURNS json ; écrit CHARGE) = imputation manuelle gérant, chantier voulu mais écran front pas encore développé, orpheline, isolation ✅.

Vues — les 3 vues du schéma sont toutes en security_invoker = false (reloptions NULL), donc RLS bypassée en lecture via ces vues :

- vue_dashboard_bande : ne filtre pas ferme_id en interne → non protégée (à l'origine de la fuite get_dashboard, voir 14.6 Chantier A).

- vue_stock_actuel : expose ferme_id, non filtrée en interne MAIS ses 2 consommateurs front (lignes 754, 5484) filtrent par .eq('ferme_id', FERME_ID). ✅ Protégée applicativement.

- vue_taches_agent : non filtrée, orpheline (aucun consommateur). Risque pratique nul.

> *💡 En clair : les « RPC » et les « vues » sont des raccourcis que l'app utilise pour lire les données. Certains de ces raccourcis contournaient les serrures : c'est par là que fuyait le tableau de bord financier (corrigé, voir 14.6). Les autres raccourcis sont soit protégés, soit inutilisés.*

## 14.5 — Limite structurelle assumée

L'isolation repose sur la confidentialité de l'UUID ferme_id (transmis via header x-ferme-id, visible en devtools d'un utilisateur légitime). Modèle suffisant pour clients de confiance (2-3 fermes actuelles qui se connaissent). Un UUID forgé ou intercepté permettrait à un tiers d'agir dans une ferme dont il connaît l'identifiant. À remplacer par une vraie authentification (JWT) pour un SaaS ouvert à des clients externes non liés. Ce n'est PAS un trou d'isolation RLS (l'isolation fonctionne), mais une limite du modèle d'authentification. Renvoi feuille de route SaaS : PIN → JWT.

## 14.6 — Chantiers sécurité (état au 04/07/2026)

CHANTIER A (PRIORITÉ 1) — Fuite lecture cross-tenant get_dashboard. ✅ CORRIGÉ ET DÉPLOYÉ (v26.19, 03-04/07/2026). Problème : get_dashboard filtrait par bande_id seul ; vue vue_dashboard_bande non filtrée + security_invoker=false + SECURITY DEFINER → un appel API direct get_dashboard('<bande d'une autre ferme>') remontait les finances (recettes, marge) d'une autre ferme. Correctif : Migration 031 — ajout de v_ferme_id := get_ferme_id(), fail-closed si NULL, et AND ferme_id = v_ferme_id sur les deux lectures (WHERE principal + sous-requête stockSacs). Testé et validé : header REVAGRO → données visibles ; header ALIRAH sur bande REVAGRO → success:false (bloqué). Appliqué en base, testé en conditions réelles (login + dashboard OK), archivé dans migrations/ (031_fix + 031_ROLLBACK).

CHANTIER B (PRIORITÉ 2) — Contrôle de rôle serveur valider_imputation_gerant. 🔴 OUVERT. Isolation ferme ✅ mais aucun contrôle de rôle : tout utilisateur de la ferme (agent inclus) peut valider/rejeter une imputation via appel API direct, court-circuitant le contrôle gérant. Protection actuelle = le front cache le bouton (contournable). Couvre aussi le branchement futur de V2 imputer_stock (même besoin). Pré-requis : définir comment la base authentifie « gérant » (PIN re-vérifié via verifier_pin ? header signé ? fondation PIN→JWT). Priorité 2 : intra-ferme, atténué par le front.

Correctif sessions_actives DELETE cross-tenant : ✅ déployé v26.19 (ajout .eq('ferme_id', FERME_ID) sur le DELETE de nettoyage ligne 1741 dans doLogin). Testé (login OK).

Vigilance : V2 imputer_stock est appelable via l'API (écriture CHARGE intra-ferme) même si aucun écran ne l'appelle. À sécuriser au moment du branchement (relève du Chantier B).

Principes d'architecture à graver : (1) toute vue = security_invoker=true OU filtre ferme_id en dur ; (2) toute RPC SECURITY DEFINER lisant une vue filtre ferme_id explicitement, jamais déléguer l'isolation à la vue.

Hors périmètre (chantiers antérieurs, non traités) : table fermes policy lecture_publique_code_acces (qual=true) toujours à corriger ; mode offline ; dashboard SaaS central. Convergence long terme : Chantiers A+B → auth JWT (rôle + ferme signés).

> *💡 En clair : il restait deux problèmes de sécurité. Le premier (la fenêtre financière ouverte à tous) est RÉPARÉ et testé aujourd'hui. Le second (n'importe qui peut valider à la place du gérant) reste à faire : c'est le prochain chantier. Le reste est sain.*

— Fin de la section 14 — Consolidée le 04/07/2026 (session v26.19) —
