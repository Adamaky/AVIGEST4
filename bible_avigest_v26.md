# 🐔 AviGest v26

## Bible du Projet --- Document de Référence Permanent

*Version 26 --- Adama Désiré --- Ouagadougou, Burkina Faso*

> **Synchronisation** : cette version `.md` est générée à partir de `bible_avigest_v26.docx` --- dernière synchronisation le **10/07/2026 (session v26.21).**. Le `.docx` reste la référence unique pour toute modification manuelle ; ce fichier `.md` est une copie dérivée destinée à être lue par Claude Code depuis le repo GitHub, à côté de `SCHEMA.md`. Ne jamais éditer ce `.md` comme source --- toujours régénérer depuis le `.docx` à jour.

------------------------------------------------------------------------

## 1. Contexte et Objectif

AviGest est une Progressive Web App (PWA) de gestion avicole à Ouagadougou. Elle gère un élevage de poulets de chair sur plusieurs poulaillers, avec trois rôles : gérant, agent, partenaires investisseurs.

**Contraintes clés :**

- Connexion variable --- mode hors ligne prévu (non encore implémenté)
- Agent peu familier avec le numérique --- interface pavé numérique, un champ à la fois
- Backend : Supabase PostgreSQL + Realtime · Frontend : GitHub Pages · SDK local supabase.js

------------------------------------------------------------------------

## 2. Architecture Technique

### 2.1 URLs et Identifiants

  ------------------------------------------------------------------------------------
  Élément                 Valeur
  ----------------------- ------------------------------------------------------------
  URL Frontend            https://adamaky.github.io/AVIGEST4/

  GitHub Repo             https://github.com/Adamaky/AVIGEST4

  Supabase URL            https://jzlmnpxcnrcajludtkpt.supabase.co

  Supabase Project ID     jzlmnpxcnrcajludtkpt

  Ferme ID (REVAGRO)      e56574a9-54c1-430d-b480-b9bdd1090dd7

  Ferme ID (ALIRAH2026)   40ee764e-d073-463e-b07b-bf95a9d7a675

  Client Supabase         sb (toujours sb, jamais supabase)

  SDK local               supabase.js ligne 17 (téléchargé depuis unpkg.com)

  Session                 12 heures · Avertissement 1h avant expiration

  Fichier de travail      C:.html

  **Version actuelle**    **APP_VERSION = 'v26.19' · CACHE_NAME = 'avigest-v26-19'**
  ------------------------------------------------------------------------------------

### 2.2 Terminologie --- Deux niveaux

  -------------------------------------------------------------------------------------------
  Terme visible (interface)   Terme technique (code)      Explication
  --------------------------- --------------------------- -----------------------------------
  Poulailler 1, 2...          Batiment-1, Batiment-2...   Salle d'élevage physique

  Bande                       bande / bande_id            Lot de poulets dans un poulailler

  Agent                       AGENT / role                Responsable terrain

  Partenaire                  PARTENAIRE / role           Investisseur

  Gérant                      GERANT / role               Gestionnaire principal
  -------------------------------------------------------------------------------------------

### 2.3 Format ID Bande

Format : `Bande-YYYY-NNN` (ex : `Bande-2026-001`)

- Regex de validation : `/^Bande-\d{4}-\d{3}$/`
- Auto-génération avec possibilité de saisie manuelle
- Soft-delete : toujours ajouter `.eq('``is_deleted``', false)` sur les requêtes bandes

### 2.4 Architecture Supabase --- Tables principales

  ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Table                Colonnes / Rôle
  -------------------- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  bandes               id (UUID, clé primaire), id_bande (identifiant lisible ex. \"Bande-2026-999\", text), ferme_id (UUID), batiment_id (UUID), race, effectif_initial (int), effectif_vendu (int), date_arrivee (date), date_cloture (date), statut (text), prep_terminee (bool), abattage_demarre (bool), fournisseur_poussins (text), effectif_final_corrige (int), effectif_final_note (text), commentaire (text), created_at, updated_at, is_deleted (bool)

  saisies_techniques   id, ferme_id, bande_id, date_saisie, session, categorie, valeur, valeur2, unite, note, rôle

  taches               id, ferme_id, bande_id, titre, statut, type_tache, date_creation, date_validation

  journal              id, ferme_id, bande_id, date_ecriture, type_ecriture, categorie, montant, note

  lots_stock           id, ferme_id, bande_id, produit, reference, quantite_initiale, quantite_restante, cout_unitaire (généré), seuil_alerte, date_fabrication, categorie_cru

  mouvements_stock     id, ferme_id, lot_id, type_mouvement (ENTREE/SORTIE), quantite, session, cout_impute, note

  rapports_hebdo       id, ferme_id, bande_id, semaine, contenu_agent, contenu_gerant, lu_par_agent, lu_par_gerant

  sessions_actives     id, ferme_id, user_id, device_fingerprint --- RLS désactivée (choix documenté) --- verrouillage multi-appareils. **Voir section 14 --- Audit sécurité v26.18 : DELETE cross-tenant corrigé v26.19.**
  ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

### 💡 *En clair : on garde la bonne version (dans le tableau, en haut) et on efface la copie en double (en bas, après sessions_actives). Il ne doit rester qu\'une seule ligne « bandes ».*

### 2.5 Migrations SQL --- GitHub

  ------------------------------------------------------------------------------------------------------------------
  Fichier                       Contenu
  ----------------------------- ------------------------------------------------------------------------------------
  001_schema_initial.sql        Tables de base : bandes, saisies_techniques, taches, journal

  002_stock_tables.sql          Tables lots_stock et mouvements_stock

  003_rls_policies.sql          Politiques RLS sur les 14 tables

  004_get_ferme_id_fix.sql      Correction SECURITY DEFINER + cast JSON sur get_ferme_id()

  005_imputer_aliment_rpc.sql   RPC imputer_aliment() --- imputation atomique stock depuis sessions agent

  006_stock_dashboard_rpc.sql   RPC pour vue stock dashboard gérant

  ...                           (migrations suivantes numérotées jusqu'à 030 --- voir dossier migrations/ du repo)
  ------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------

## 3. Utilisateurs et Rôles

  -----------------------------------------------------------------------------------------------------------------
  Rôle         Limite     PIN actuel           Accès
  ------------ ---------- -------------------- --------------------------------------------------------------------
  GERANT       Max 2      0000 (Adama)         Tout --- supervision, planif, compta, poulaillers, stock, rapports

  AGENT        Max 2      1111 (Agent Ferme)   Terrain --- sessions, saisies, tâches

  PARTENAIRE   Illimité   PIN individuel       Ses bandes --- résultats, état lot, créances
  -----------------------------------------------------------------------------------------------------------------

> PIN stocké en bcrypt via RPC `verifier_pin``()` (colonne PIN en clair supprimée --- Migration 028).

------------------------------------------------------------------------

## 4. Règles Techniques Critiques

### 4.1 Règles Supabase

- Client toujours nommé `sb` --- jamais `supabase`
- Header `x-ferme-id` injecté globalement à la création du client (ligne 427)
- RLS active sur toutes les tables sauf `sessions_actives`
- `get_ferme_id``()` avec SECURITY DEFINER --- retourne l'ID ferme depuis le header
- Statelessness REST : `set_config` ne persiste pas entre requêtes --- utiliser le header global
- Avant tout INSERT : vérifier colonnes NOT NULL, defaults, et colonnes générées
- `cout_unitaire` dans `lots_stock` est une colonne GÉNÉRÉE --- ne jamais l'inclure dans un INSERT
- `lots_stock.produit` : noms complets (ex : 'Aliment de démarrage') --- chercher avec `LOWER(produit) LIKE`
- `mouvements_stock.type_mouvement` : uniquement 'ENTREE' ou 'SORTIE'
- `SET LOCAL ``row_security`` = off` dans les RPCs SECURITY DEFINER qui interrogent `utilisateurs`, pour bypasser RLS
- Appeler `extensions.crypt``()` et non `crypt``()` --- pgcrypto est dans le schéma extensions
- **Toute opération DELETE/UPDATE sur une table sans RLS (ex:** `sessions_actives`**) doit systématiquement filtrer par** `ferme_id` **côté client --- leçon de l'audit sécurité v26.18 (voir section 14)**

### 4.2 Règles JavaScript

- Apostrophes dans les chaînes JS : toujours échapper avec `\'` ou utiliser des guillemets doubles
- Ne jamais imbriquer des template literals dans `.``map``()` --- utiliser la concaténation
- `&``quot``;` au lieu d'apostrophes dans les attributs onclick inline
- `node`` --check` échoue sur les fichiers `.html` --- utiliser la commande PowerShell d'extraction JS
- jsDelivr CDN inaccessible depuis le Burkina Faso --- utiliser unpkg.com ou le fichier local

### 4.3 Règles de travail

- Fichier unique : `C:\Users\kyada\Documents\GitHub\AVIGEST4\index.html`
- Workflow : VS Code → Claude Code → vérification syntaxe PowerShell → GitHub Desktop → Push
- Chaque modification SQL = un nouveau fichier de migration numéroté dans `migrations/`
- `APP_VERSION` (ligne \~463 index.html) mis à jour EN MÊME TEMPS que `CACHE_NAME` (ligne 9 sw.js) à chaque session --- format `'v26.XX'`
- Sélectionner 'Yes, allow all edits this session' dans Claude Code pour les sessions multi-patches
- Vérification après patch : commandes `Ctrl+Shift+F` avec nombre d'occurrences attendu
- **Un seul changement par patch** --- ne jamais mixer des modifications non liées dans un même commit (leçon B6/isolation stricte)
- **Séquence de vérification stricte (confirmée v26.18)** : édition → `node`` --check` (confirmation explicite du résultat, ne jamais supposer que c'est fait) → diff GitHub Desktop complet → incrément version si dernier changement de la session → commit avec message combiné (version + description)

**RÈGLE STOCK --- Deux types de lots**

Avant tout INSERT `lots_stock`, vérifier le flag `impute_journal` (BOOLEAN) : - `true` : RPC déclenche écriture journal - `false` : RPC décrémente stock uniquement, pas d'écriture journal

**RÈGLE CRU --- Filtre catégories charges consommées (définitive, ne pas modifier)**

    CRU = SUM(montant) WHERE type_ecriture = 'DEPENSE' 
                        AND categorie != 'Achat stock'
          / effectif_vivants

Filtre par **exclusion**, pas par liste fermée. La litière (comme tout produit avec `impute_journal`` = ``true`) entre correctement dans le CRU via ce filtre --- ne jamais ajouter de catégorie spécifique au filtre, l'exclusion `!= 'Achat stock'` suffit et gère tout automatiquement.

**RÈGLE JOURNAL --- Catégories prédéfinies (v2)**

Charges consommées (CRU) : - Alimentation (auto RPC) - Vaccin \[type + unité + qté + PU\] - Médicament \[type + unité + qté + PU\] - Litière \[type + unité + qté + PU\] --- traitée comme l'aliment (Type A)

Charges exploitation (hors CRU par exclusion, mais toujours DEPENSE) : - Salaire \[forfait ou qté×PU\] - Prestation de service \[forfait ou qté×PU\] - Transport \[forfait ou qté×PU\] - Glace \[forfait ou qté×PU\] - Autre \[texte libre + montant\]

Hors charges (mouvement stock, jamais dans le CRU) : - Achat stock \[lié à lots_stock\]

------------------------------------------------------------------------

## 5. Score Santé --- Règle de Calcul

Validé session 18 juin 2026 --- Cobb 500, Ouagadougou, J14+

  --------------------------------------------------------------
  Paramètre          Bon 🟢       Passable 🟡   Mauvais 🔴
  ------------------ ------------ ------------- ----------------
  Température (°C)   26--32°C     33--35°C      \<26 ou \>35°C

  Hygrométrie (%)    50--70%      71--80%       \<50 ou \>80%

  Mortalité/jour     0--2 morts   3--5 morts    \>5 morts
  --------------------------------------------------------------

**Règle de calcul : Score final = le PIRE des 3 scores individuels**

Surcharge manuelle : l'agent peut modifier le score calculé + saisir une note explicative

> **Bug cosmétique (v26.17, toujours non résolu, priorité moyenne)** : écran de confirmation agent affiche le score santé avec balises HTML brutes (`<``strong``>BON</``strong``>` au lieu de **BON** en gras). Cause : la fonction `esc()` échappe les balises `<``strong``>` volontairement insérées dans `_``renderSessionResume``()`. Correctif prêt (retrait de `<``strong``>`/`</``strong``>`, le CSS `.rapport-ligne ``span:last-child` gère déjà le gras) --- non encore appliqué. Estimé 5 minutes.

------------------------------------------------------------------------

## 6. Module Stock --- Architecture complète (CHANTIER CLOS --- v26.18)

**TYPE DE LOT STOCK**

**Type A --- Avec imputation journal (charge)** - → Aliment, Vaccin, Médicament, Litière - → Décrémente stock + écriture journal auto - → Entre dans le CRU (sauf catégorie "Achat stock")

**Type B --- Sans imputation journal** - → Produits créés par le gérant avec `impute_journal`` = false` - → Décrémente stock uniquement - → N'entre PAS dans le CRU

**FLAG sur lots_stock (implémenté) :**

    impute_journal BOOLEAN DEFAULT false
    categorie_cru TEXT (v26.16) — catégorie comptable du lot,
      lue en priorité par imputer_stock(), avec repli sur
      l'ancien CASE (nom produit) si NULL

**Imputation générique multi-produits depuis sessions agent (confirmé v26.18) :** L'étape `stock_autres` (« Autres produits utilisés ») est présente dans les 4 sessions agent (Matin/Midi/PM/Nuit), pas seulement Matin. Elle liste tout lot dont le produit n'est pas l'aliment (`.not('produit', '``ilike``', '%aliment%')`) et impute chaque quantité saisie via `imputer_stock``()` --- mécanisme générique, non câblé spécifiquement pour un produit donné. Testé en conditions réelles avec deux produits distincts, flux complet jusqu'à validation gérant (EN_ATTENTE → CONFIRME) confirmé pour les deux : - **Litière** --- B8, testé 01/07/2026 - **Médicament** --- testé, session v26.18 (02/07/2026)

Le vaccin n'a pas fait l'objet d'un test terrain distinct, mais utilise exactement le même mécanisme générique que la litière et le médicament --- risque de comportement différent jugé très faible.

### ÉTAPES MODULE STOCK

  --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Étape                                                                         Statut
  ----------------------------------------------------------------------------- --------------------------------------------------------------------------------------------------------------------------------------
  Étape 1 --- Schéma SQL                                                        ✅ Validé

  Étape 2 --- Interface création lot                                            ✅ Validé

  Étape 3 --- Imputation auto sessions agent                                    ✅ Validé

  Étape 4 --- Vue stock dashboard gérant                                        ✅ Validé

  Étape 5 --- Validation gérant alimentation                                    ✅ Validé --- mécanisme EN_ATTENTE + écran validation gérant opérationnel

  Étape 6 --- RPC litière (Type A, alignée aliment)                             ✅ Validé --- Migration 029, testé en conditions réelles 01/07/2026

  Étape 7 --- Formulaire dépense enrichi                                        ✅ Validé --- confirmé session v26.18, `renderNouvelleEcriture``()` avec `<``optgroup``>` Charges CRU / Mouvement stock, mode Qté×PU

  Étape 8 --- CRU filtré charges consommées                                     ✅ Validé --- confirmé session v26.18, filtre `categorie`` !== 'Achat stock'` présent et cohérent à 3 endroits du code

  Imputation multi-produits (litière/vaccin/médicament) depuis sessions agent   ✅ Validé --- confirmé session v26.18, voir détail ci-dessus
  --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

**Le module Stock est désormais entièrement clos --- zéro item ouvert.**

------------------------------------------------------------------------

## 13. Tableau de Suivi --- Outil Permanent du Non-Codeur

Cette section est la mémoire vivante du projet. Claude la lit à chaque session pour savoir où en est le projet sans qu'Adama ait besoin de tout réexpliquer.

### 13.1 Légende des Statuts

  -----------------------------------------------------------------------------------------------------------------------
  Statut         Signification                              Action suivante
  -------------- ------------------------------------------ -------------------------------------------------------------
  ✅ Validé      Testé sur l'app et confirmé fonctionnel    Passer à la prochaine fonctionnalité

  ⏳ En cours    Code produit mais pas encore testé         Tester sur https://adamaky.github.io/AVIGEST4/

  🐛 Bug         Testé --- comportement incorrect observé   Décrire le bug précis à Claude

  ○ À faire      Pas encore commencé                        Briefer Claude quand c'est la priorité

  ☁️ SaaS        Fonctionnalité prévue multi-fermes         À planifier après stabilisation v1

  ⏹️ Abandonné   Décision définitive de ne pas traiter      Aucune --- ne jamais rouvrir sans demande explicite d'Adama
  -----------------------------------------------------------------------------------------------------------------------

### 13.2 Tableau de Suivi des Fonctionnalités

**FONDATIONS**

  ----------------------------------------------------------------------------------------------------------------------------------------------------------------
  Fonctionnalité                                               Statut          Note / Bug connu
  ------------------------------------------------------------ --------------- -----------------------------------------------------------------------------------
  Login PIN + session 12h                                      ✅ Validé       Testé PIN 0000 → OK

  Verrouillage multi-appareils                                 ✅ Validé       Table sessions_actives + device fingerprint

  Écran blocage session concurrente                            ✅ Validé       Ex-B2 --- écran dédié screen-blocage (au lieu d'injection dans app-main caché)

  Bouton Forcer déconnexion                                    ✅ Validé       Ex-B9 --- role passé en paramètre, corrige dépendance circulaire localStorage

  Système de navigation Nav                                    ✅ Validé       Bug pavé PIN corrigé

  **Correctif RLS --- sessions_actives DELETE cross-tenant**   **✅ Validé**   **v26.19 --- filtre** `.eq('``ferme_id``', FERME_ID)` **ajouté, voir section 14**

  Mode hors ligne + sync auto                                  ○ À faire       Queue localStorage à implémenter

  Notifications OneSignal                                      ○ À faire       Géré en arrière-plan
  ----------------------------------------------------------------------------------------------------------------------------------------------------------------

**AGENT**

  ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Fonctionnalité                        Statut         Note / Bug connu
  ------------------------------------- -------------- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Tuiles sessions dans onglet Tâches    ✅ Validé      4 sessions : Matin/Midi/PM/Nuit

  Session Matin --- 6 étapes            ✅ Validé      Pavé numérique fonctionnel

  Session Midi --- 3 étapes             ✅ Validé      Testé 18/06/2026

  Session PM --- 3 étapes               ✅ Validé      Testé 18/06/2026

  Session Nuit --- 4 étapes             ✅ Validé      Testé 18/06/2026

  Score santé --- calcul auto           ⏹️ Abandonné   Ex-B1 : "Score undefined" --- décision définitive d'Adama (session v26.18) de ne pas traiter, non prioritaire. Distinct du bug cosmétique `<``strong``>` (voir section 5), toujours actif celui-là

  Score santé --- surcharge manuelle    ○ À faire      Prévu : bouton Bon/Passable/Mauvais + note agent

  Blocage sessions hors plage horaire   ✅ Validé      Ex-B3 --- confirmé implémenté dans `renderSession``()` : plages par session (Matin 5h-10h, Midi 10h-14h, PM 14h-19h, Nuit 19h-5h), double protection (bouton désactivé + re-vérification fonction)

  Écran abattage --- 3 étapes           ○ À faire      Calcul poids moyen auto
  ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

**GÉRANT**

  ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Fonctionnalité                    Statut        Note / Bug connu
  --------------------------------- ------------- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Accueil gérant --- navigation     ✅ Validé     ACCUEIL · BANDES · ANALYSES

  Onglet Tâches gérant              ✅ Validé     Ex-B4 --- confirmé résolu (termineesHTML déclarée) ; collision historique de numérotation avec un autre B4 cité ailleurs restée non éclaircie mais sans impact pratique --- voir Points en suspens

  Planifier tâches agent            ✅ Validé     3 types : Quotidienne · Hebdomadaire · Abattage

  Journal comptable                 ✅ Validé     Dépenses + Recettes + CRU/sujet

  Analyses --- zootechnie           ✅ Validé     Ex-B5 : Poids moyen et IC --- confirmé résolu par Adama (testé/observé récemment, session v26.18)

  Analyses --- finance              ✅ Validé     Marge nette · Dépenses · Recettes

  Planifier abattage                ✅ Validé     Formulaire Date + Nb sujets + Client cible

  Rapports hebdomadaires            ⏳ En cours   À tester prochaine session

  Rapport fin de bande + WhatsApp   ✅ Validé     Export texte structuré (fermé v26.9)

  Gestion utilisateurs              ○ À faire     Créer / activer / désactiver
  ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

**STOCK**

Voir section 6 --- module entièrement clos (8 étapes + imputation multi-produits, toutes ✅ Validé).

**PARTENAIRE**

  -------------------------------------------------------------------------
  Fonctionnalité                      Statut      Note / Bug connu
  ----------------------------------- ----------- -------------------------
  Interface partenaire --- 3 tuiles   ○ À faire   Filtré par idPartenaire

  Assignation quotes-parts            ○ À faire   Total ≤ 100%
  -------------------------------------------------------------------------

**PROCESSUS**

  --------------------------------------------------------------------------
  Fonctionnalité                     Statut      Note / Bug connu
  ---------------------------------- ----------- ---------------------------
  Clôture bande --- 6 phases         ○ À faire   14 jours minimum

  Fabrication aliment                ○ À faire   Lignes dynamiques

  Alertes automatiques in-app        ○ À faire   7 KPI configurés

  Abattage progressif --- 6 étapes   ○ À faire   Plan → Exec → Validation
  --------------------------------------------------------------------------

**VISION SAAS**

  ---------------------------------------------------------------------------------------------------------------------------------------------------------------
  Fonctionnalité                    Statut      Note / Bug connu                                                                                           SaaS
  --------------------------------- ----------- ---------------------------------------------------------------------------------------------------------- ------
  Multi-fermes (multi-tenant)       ✅ Validé   2 fermes actives (REVAGRO, ALIRAH2026), 3e client en cours d'intégration --- chaque ferme = espace isolé   ☁️

  Authentification sécurisée SaaS   ○ À faire   PIN → tokens JWT ou équivalent                                                                             ☁️

  Plans tarifaires (Free / Pro)     ○ À faire   Gestion abonnements                                                                                        ☁️

  Dashboard gérant SaaS             ○ À faire   Vue de toutes les fermes                                                                                   ☁️

  Onboarding nouvelle ferme         ○ À faire   Option A : intégré (pas subdomain)                                                                         ☁️
  ---------------------------------------------------------------------------------------------------------------------------------------------------------------

### 13.3 Registre des bugs (créé session v26.18)

Registre centralisé transversal, source unique de numérotation des bugs. Les tableaux de section (AGENT, GÉRANT, etc.) ci-dessus restent la référence de lecture rapide, mais tout nouveau bug détecté à partir de maintenant doit être numéroté ici en premier.

**Règles établies (session v26.18) :** - Numérotation strictement croissante, jamais réutilisée, identique dans tous les documents (Bible + mémoire de session) - Sync Bible déclenchée proactivement par Claude dès qu'une ligne passe à ✅ Validé (granularité fine, pas d'attente de fin de chantier) --

*« B10 fermé en v26.21. Prochain numéro disponible : B11. »*

  --------------------------------------------------------------------------------------------------------------------------------------
  **Numéro**   **Titre court**                                **Domaine**   **Statut**   **Session ouverture**   **Session fermeture**
  ------------ ---------------------------------------------- ------------- ------------ ----------------------- -----------------------
  B10          Statut \'TERMINEE\' invalide (→ \'CLOTURE\')   Clôture       ✅ Fermé     v26.18                  v26.21

  --------------------------------------------------------------------------------------------------------------------------------------

### 13.4 Protocole de Brief de Session

Avant chaque session avec Claude, Adama colle ce bloc en début de message :

    📋 BRIEF SESSION AVIGEST v26

    Objectif du jour : [une phrase]
    Dernière chose validée : [fonctionnalité]
    Bug en suspens : [description ou 'Aucun']

### 13.5 Multi-fermes --- État actuel et Feuille de Route SaaS

**ÉTAT ACTUEL (production) :**

AviGest gère aujourd'hui 2 fermes actives sur une architecture multi-tenant déjà fonctionnelle : un seul frontend GitHub Pages, sélection de ferme via code d'accès au login (écran-code-ferme), isolation des données par `ferme_id` + header `x-ferme-id` + RLS Supabase.

- → REVAGRO (ferme_id : e56574a9-54c1-430d-b480-b9bdd1090dd7)
- → ALIRAH2026 (ferme_id : 40ee764e-d073-463e-b07b-bf95a9d7a675)

**EN COURS D'ENGAGEMENT :**

Un 3e client est actuellement en cours d'intégration sur cette même architecture. Détails à préciser dans une prochaine mise à jour de la Bible.

**VISION SAAS (extension future au-delà des clients déjà engagés) :**

La vision SaaS plus large (accueil de clients externes non encore identifiés, abonnements, dashboard central multi-fermes) reste documentée ici pour que chaque fonctionnalité v1 soit conçue de façon compatible. Ne pas commencer le chantier SaaS élargi avant que les sections Fondations, Agent et Gérant soient toutes à statut Validé.

  -------------------------------------------------------------------------------------------------------------------------------------------------------
  Pré-requis SaaS élargi                 Condition de démarrage
  -------------------------------------- ----------------------------------------------------------------------------------------------------------------
  v1 stable                              Zéro bug ouvert en Fondations + Agent + Gérant + Stock --- **Stock atteint ce seuil depuis la session v26.18**

  Architecture multi-tenant              ✅ Déjà en place et validée en production (2 fermes actives)

  Authentification sécurisée             Remplacer PIN seul par token JWT avec expiration

  Plans tarifaires                       Définir Free (1 poulailler) vs Pro (6+ poulaillers)

  Onboarding                             Option A : écran onboarding intégré --- pas de subdomains par ferme

  Client(s) au-delà des 3 déjà engagés   Cible : début janvier 2027
  -------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------

## 14. Sécurité --- État et Audit (nouvelle section, session v26.18)

### 14.1 Chantiers sécurité fermés (historique)

S1-S4 --- voir version précédente de la Bible : protection brute force PIN, hachage bcrypt, erreurs contextuelles showToast, fetch natif remplaçant sbTemp. Tous validés v26.9/v26.10.

### 14.2 Audit RLS --- session v26.18 (via Claude Code)

Premier audit structuré de sécurité RLS effectué le 02/07/2026. Méthode : analyse exhaustive du code JS (`index.html`) pour repérer les opérations sans filtre `ferme_id` ; accès direct aux policies RLS réelles en base non disponible dans cette passe (nécessite Supabase Studio/psql).

**Point CRITIQUE confirmé et corrigé :** - `sessions_actives` --- RLS désactivée (choix documenté) + un DELETE cross-tenant sans filtre `ferme_id` trouvé ligne \~1739 (`doLogin``()`, nettoyage sessions expirées). **Corrigé v26.19** : ajout de `.eq('``ferme_id``', FERME_ID)`. Commit : `"v26.19 - Fix RLS gap: DELETE ``sessions_actives`` sans filtre ``ferme_id`` (audit sécurité v26.18)"`. - Limite du correctif : protège contre l'erreur applicative côté code légitime, mais ne remplace pas une policy RLS réelle --- un accès direct via devtools/clé anon pourrait théoriquement encore contourner ce filtre tant que RLS reste désactivée sur cette table.

**Points restés CONDITIONNELS (état RLS réel non vérifié) :**

  --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Table                                                                  Filtre ferme_id côté code                                                       Risque si RLS off                                   Exemple
  ---------------------------------------------------------------------- ------------------------------------------------------------------------------- --------------------------------------------------- ---------------------------------------------------------
  bandes                                                                 Partiel --- \~20 opérations sans ferme_id, dont des UPDATE/DELETE par id seul   🔴 Élevé                                            Soft-delete bande, changement statut, par id seul

  batiments                                                              Absent --- 4 UPDATE par id seul                                                 🔴 Élevé                                            Changement statut poulailler par id seul

  taches                                                                 Partiel --- \~10 opérations sans ferme_id                                       🟠 Moyen-élevé                                      Marquer tâche exécutée par id seul

  lots_stock / mouvements_stock                                          Absent sur SELECT/UPDATE détail                                                 🟠 Moyen                                            Détail lot, historique mouvements par id seul

  RPCs (`get_dashboard`, `imputer_stock`, `valider_imputation_gerant`)   Pas de ferme_id explicite en paramètre                                          Inconnu --- dépend de la vérification interne SQL   À lire directement en base

  utilisateurs                                                           Absent --- UPDATE last_login par id seul                                        🟡 Faible                                           Impact métier faible

  partenaires_bandes                                                     Absent --- SELECT par utilisateur_id seul                                       🟡 Faible                                           Pertinent si un utilisateur multi-fermes existe un jour
  --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

**Tables jugées saines (filtre ferme_id systématique côté code) :** journal, rapports_hebdo, composants_lot, vue_stock_actuel.

### 14.3 Session RLS dédiée --- programmée, non planifiée dans le temps

**Objectif** : lever l'incertitude sur l'état RLS réel des tables listées ci-dessus. Nécessite l'exécution directe en base (Supabase Studio ou psql) des requêtes suivantes :

    SELECT schemaname, tablename, rowsecurity FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;
    SELECT schemaname, tablename, policyname, cmd, roles, qual, with_check FROM pg_policies WHERE schemaname = 'public' ORDER BY tablename, policyname;
    SELECT routine_name, routine_definition FROM information_schema.routines
    WHERE routine_schema = 'public' AND routine_name IN ('get_dashboard','imputer_stock','valider_imputation_gerant','get_ferme_id','verifier_pin');

Une fois ces résultats obtenus, les points conditionnels du tableau 14.2 deviendront des diagnostics fermes, exploitables pour prioriser d'éventuels correctifs. **Aucun correctif ne doit être appliqué avant validation explicite d'Adama, patch par patch, comme pour le point sessions_actives.**

------------------------------------------------------------------------

## Points en suspens (à clarifier avec Adama)

1.  **~~Collision de numérotation B1~~** --- **Refermé session v26.18.** B1 "score santé" passé au statut ⏹️ Abandonné, décision définitive d'Adama.
2.  **B4** --- collision historique entre deux mentions du même numéro reste non éclaircie (un B4 "corrigé 18/06" dans GÉRANT vs un B4 parfois cité en basse priorité ailleurs), **mais sans conséquence pratique** : le comportement fonctionnel est confirmé résolu par Adama (session v26.18). Point purement historique, non bloquant.
3.  **Bug cosmétique score santé** (balises `<``strong``>` brutes) : toujours non résolu, priorité moyenne --- voir section 5. Le blocage technique précédent ("0 changed files" GitHub Desktop) n'a pas été creusé ; à la reprise, vérifier d'abord la sauvegarde (Ctrl+S) avant de retenter l'édition.
4.  **Cohérence .md/.docx** : cette version .md (v26.18) doit être répercutée manuellement par Adama dans le `.docx`, qui reste l'unique source. Après édition du `.docx`, il faudra confirmer avec Adama s'il souhaite une régénération .md à committer dans le repo GitHub, à côté de SCHEMA.md.
5.  **Prochaine priorité de développement** : à redéfinir. Le chantier initialement annoncé comme "priorité haute" (imputation multi-produits stock) est en réalité déjà clos (voir section 6). Restent en attente : bug cosmétique score santé (priorité moyenne, 5 min), session RLS dédiée (section 14.3), verrou session agent non déblocable à distance par le gérant (limitation connue, chantier futur), mode offline et dashboard SaaS (vision long terme).

------------------------------------------------------------------------

**15. Module Clôture de Bande (CHANTIER CLOS --- v26.21)**

Le module clôture permet au gérant de terminer définitivement une bande : archiver son statut, valoriser le stock restant, libérer le bâtiment et générer un rapport final. Architecture en **6 phases**, fonction principale renderClotureBande(bandeId).

💡 *En clair : c\'est l\'étape « fin de cycle ». Quand les poulets sont partis, le gérant clôture la bande --- l\'app fait le bilan, remet le poulailler à disposition, et fige les chiffres.*

**15.1 Les 6 phases**

  -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  **Phase**                            **Rôle**                                                                                                                                  **Statut**
  ------------------------------------ ----------------------------------------------------------------------------------------------------------------------------------------- ------------
  Phase 1 --- Éligibilité              Vérifie l\'ancienneté (14 jours minimum) et le statut clôturable                                                                          ✅ Validé

  Phase 2 --- Effectif final           Affiche l\'effectif restant, avec correction manuelle possible (colonnes effectif_final_corrige, effectif_final_note --- migration 032)   ✅ Validé

  Phase 3 --- Reliquat stock           Valorise le stock restant en écriture RECETTE (catégorie \'Reliquat stock\')                                                              ✅ Validé

  Phase 4 --- Bilan financier          5 lignes lues depuis get_dashboard : recettes, dépenses, CRU, marge nette, reliquat estimé                                                ✅ Validé

  Phase 5 --- Validation PIN gérant    Pavé PIN dédié, contrôle serveur via verifier_pin (rôle GERANT)                                                                           ✅ Validé

  Phase 6 --- Archivage + libération   Passe la bande en \'CLOTURE\' et libère le bâtiment (\'LIBRE\')                                                                           ✅ Validé
  -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

**15.2 Migrations associées**

  ----------------------------------------------------------------------------------------------------------------------------
  **Migration**   **Contenu**
  --------------- ------------------------------------------------------------------------------------------------------------
  032             Colonnes effectif_final_corrige, effectif_final_note sur bandes (correction manuelle de l\'effectif final)

  033             RPC cloturer_phase3_reliquat --- écrit l\'écriture RECETTE du reliquat stock

  034             RPC calculer_reliquat_stock --- calcul en lecture seule pour l\'affichage (ne modifie rien)
  ----------------------------------------------------------------------------------------------------------------------------

**15.3 Règle reliquat --- hors CRU**

Le reliquat stock est enregistré comme une **RECETTE** (pas une dépense). Il reste donc automatiquement **hors CRU** (le CRU ne compte que les DEPENSE hors \'Achat stock\'). Aucun filtre spécial nécessaire.

💡 *En clair : le stock qui reste en fin de bande a de la valeur --- c\'est de l\'argent « récupéré », pas une charge. On le compte donc comme une recette, et il n\'alourdit pas le coût de revient par poulet.*

**15.4 Validation PIN gérant (Piste A)**

La clôture définitive exige le PIN du gérant. Le front appelle verifier_pin (p_role = \'GERANT\') côté serveur ; si le PIN est correct, il enchaîne l\'écriture du reliquat (cloturer_phase3_reliquat) puis \_confirmerCloture (archivage bande + libération bâtiment).

Fonctions du pavé PIN : \_pinClotureTap, \_pinClotureDel, \_updateDotsCloture, \_validerCloturePin, \_showClotErr. Variable globale \_pinCloture. Pavé isolé du login (classes pin-key, points dot-clot-0 à dot-clot-3).

💡 *En clair : pour éviter qu\'un agent clôture une bande par erreur, seul le gérant peut valider --- en tapant son code secret, vérifié directement par le serveur.*

**15.5 Bug B10 --- fermé (v26.21)**

Le code écrivait statut = \'TERMINEE\', valeur **invalide** (la contrainte bandes_statut_check n\'accepte que \'PREPARATION\', \'EN COURS\', \'CLOTURE\', \'ARCHIVE\'). Corrigé aux 3 endroits : l\'écriture réelle du statut, la détection « déjà clôturée », et le texte affiché (« CLÔTURÉE »). Ajout au passage du filtre .eq(\'ferme_id\', FERME_ID) sur l\'UPDATE de clôture (sécurité multi-fermes).

**15.6 Limite connue --- clôture non atomique**

L\'enchaînement archivage bande → libération bâtiment se fait en deux écritures séparées (via Promise.all), pas dans une transaction unique. **Risque théorique** : si la libération du bâtiment échoue après l\'archivage réussi (coupure réseau), la bande serait clôturée mais le bâtiment resterait « occupé ». Impact faible et réparable manuellement (remettre le bâtiment en \'LIBRE\'). Chantier futur si observé sur le terrain : basculer vers une RPC unique tout-ou-rien.

💡 *En clair : dans un cas très rare (coupure au mauvais moment), le poulailler pourrait rester marqué « occupé » alors que la bande est finie. Facile à corriger à la main. On blindera seulement si ça arrive vraiment.*

*--- Fin de la Bible AviGest v26 --- Version .md générée le 10/07/2026 (session v26.21), à répercuter manuellement dans le .docx ---*
