# 🐔 AviGest v26

## Bible du Projet — Document de Référence Permanent

*Version 26 — Adama Désiré — Ouagadougou, Burkina Faso*

> **Synchronisation** : cette version `.md` est générée à partir de
> `bible_avigest_v26.docx` — dernière synchronisation le **22/07/2026
> (session v26.30).**. Le `.docx` reste la référence unique pour toute
> modification manuelle ; ce fichier `.md` est une copie dérivée
> destinée à être lue par Claude Code depuis le repo GitHub, à côté de
> `SCHEMA.md`. Ne jamais éditer ce `.md` comme source — toujours
> régénérer depuis le `.docx` à jour.

## 1. Contexte et Objectif

AviGest est une Progressive Web App (PWA) de gestion avicole à
Ouagadougou. Elle gère un élevage de poulets de chair sur plusieurs
poulaillers, avec trois rôles : gérant, agent, partenaires
investisseurs.

**Contraintes clés :**

- Connexion variable — mode hors ligne prévu (non encore implémenté)
- Agent peu familier avec le numérique — interface pavé numérique, un
  champ à la fois
- Backend : Supabase PostgreSQL + Realtime · Frontend : GitHub Pages ·
  SDK local supabase.js

## 2. Architecture Technique

### 2.1 URLs et Identifiants

| Élément               | Valeur                                                     |
|-----------------------|------------------------------------------------------------|
| URL Frontend          | https://adamaky.github.io/AVIGEST4/                        |
| GitHub Repo           | https://github.com/Adamaky/AVIGEST4                        |
| Supabase URL          | https://jzlmnpxcnrcajludtkpt.supabase.co                   |
| Supabase Project ID   | jzlmnpxcnrcajludtkpt                                       |
| Ferme ID (REVAGRO)    | e56574a9-54c1-430d-b480-b9bdd1090dd7                       |
| Ferme ID (ALIRAH2026) | 40ee764e-d073-463e-b07b-bf95a9d7a675                       |
| Client Supabase       | sb (toujours sb, jamais supabase)                          |
| SDK local             | supabase.js ligne 17 (téléchargé depuis unpkg.com)         |
| Session               | 12 heures · Avertissement 1h avant expiration              |
| Fichier de travail    | C:.html                                                    |
| **Version actuelle**  | **APP_VERSION = ‘v26.28’ · CACHE_NAME = ‘avigest-v26-28’** |

### 2.2 Terminologie — Deux niveaux

| Terme visible (interface) | Terme technique (code)  | Explication                       |
|---------------------------|-------------------------|-----------------------------------|
| Poulailler 1, 2…          | Batiment-1, Batiment-2… | Salle d’élevage physique          |
| Bande                     | bande / bande_id        | Lot de poulets dans un poulailler |
| Agent                     | AGENT / role            | Responsable terrain               |
| Partenaire                | PARTENAIRE / role       | Investisseur                      |
| Gérant                    | GERANT / role           | Gestionnaire principal            |

### 2.3 Format ID Bande

Format : `Bande-YYYY-NNN` (ex : `Bande-2026-001`)

- Regex de validation : `/^Bande-\d{4}-\d{3}$/`
- Auto-génération avec possibilité de saisie manuelle
- Soft-delete : toujours ajouter `.eq('is_deleted', false)` sur les
  requêtes bandes

### 2.4 Architecture Supabase — Tables principales

### 2.4 Architecture Supabase — Tables

### Liste exhaustive vérifiée en base le 11/07/2026 (session v26.22) — 18 tables. Toute nouvelle table doit être ajoutée ici. Toute création de table doit être précédée d'une vérification en base (voir règle 4.1).

<table>
<colgroup>
<col style="width: 22%" />
<col style="width: 77%" />
</colgroup>
<thead>
<tr class="header">
<th><h3 id="table">Table</h3></th>
<th><h3 id="rôle">Rôle</h3></th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><h3 id="bandes">bandes</h3></td>
<td><h3
id="lots-de-poulets-id-ferme_id-nom-race-effectif_initial-date_arrivee-statut-is_deleted">Lots
de poulets — id, ferme_id, nom, race, effectif_initial, date_arrivee,
statut, is_deleted</h3></td>
</tr>
<tr class="even">
<td><h3 id="batiments">batiments</h3></td>
<td><h3 id="poulaillers-physiques">Poulaillers physiques</h3></td>
</tr>
<tr class="odd">
<td><h3 id="clients">clients</h3></td>
<td><h3
id="crm-nom-telephone-adresse-type_client-note-actif-migration-035">CRM
— nom, telephone, adresse, type_client, note, actif (Migration
035)</h3></td>
</tr>
<tr class="even">
<td><h3 id="clotures">clotures</h3></td>
<td><h3 id="clôtures-de-bande-module-v26.21">Clôtures de bande (module
v26.21)</h3></td>
</tr>
<tr class="odd">
<td><h3 id="commande_lignes">commande_lignes</h3></td>
<td><h3
id="crm-détail-commande-1-ligne-1-produit-1-bande-migration-036">CRM —
détail commande : 1 ligne = 1 produit + 1 bande (Migration
036)</h3></td>
</tr>
<tr class="even">
<td><h3 id="commandes">commandes</h3></td>
<td><h3 id="crm-en-tête-bon-de-commande-migration-036">CRM — en-tête bon
de commande (Migration 036)</h3></td>
</tr>
<tr class="odd">
<td><h3 id="composants_lot">composants_lot</h3></td>
<td><h3 id="composition-des-lots-daliment-fabriqué">Composition des lots
d'aliment fabriqué</h3></td>
</tr>
<tr class="even">
<td><h3 id="config">config</h3></td>
<td><h3 id="paramètres-applicatifs">Paramètres applicatifs</h3></td>
</tr>
<tr class="odd">
<td><h3 id="croissance_standard">croissance_standard</h3></td>
<td><h3 id="courbes-de-référence-zootechniques-cobb-500">Courbes de
référence zootechniques (Cobb 500)</h3></td>
</tr>
<tr class="even">
<td><h3 id="fermes">fermes</h3></td>
<td><h3 id="tenants-une-ligne-par-ferme-cliente">Tenants — une ligne par
ferme cliente</h3></td>
</tr>
<tr class="odd">
<td><h3 id="journal">journal</h3></td>
<td><h3 id="écritures-comptables-depense-recette">Écritures comptables —
DEPENSE / RECETTE</h3></td>
</tr>
<tr class="even">
<td><h3 id="lots_stock">lots_stock</h3></td>
<td><h3
id="lots-de-stock-cout_unitaire-généré-categorie_cru-impute_journal">Lots
de stock — cout_unitaire GÉNÉRÉ, categorie_cru, impute_journal</h3></td>
</tr>
<tr class="odd">
<td><h3 id="mouvements_stock">mouvements_stock</h3></td>
<td><h3 id="entree-sortie-de-stock">ENTREE / SORTIE de stock</h3></td>
</tr>
<tr class="even">
<td><h3 id="paiements">paiements</h3></td>
<td><h3
id="crm-encaissements-rattachés-à-une-commande-migration-036">CRM —
encaissements rattachés à une commande (Migration 036)</h3></td>
</tr>
<tr class="odd">
<td><h3 id="partenaires_bandes">partenaires_bandes</h3></td>
<td><h3
id="quotes-parts-des-partenaires-investisseurs-par-bande">Quotes-parts
des partenaires investisseurs par bande</h3></td>
</tr>
<tr class="even">
<td><h3 id="produits_catalogue">produits_catalogue</h3></td>
<td><h3 id="crm-produits-vendables-migration-035">CRM — produits
vendables (Migration 035)</h3></td>
</tr>
<tr class="odd">
<td><h3 id="rapports_hebdo">rapports_hebdo</h3></td>
<td><h3 id="rapports-hebdomadaires-agentgérant">Rapports hebdomadaires
agent/gérant</h3></td>
</tr>
<tr class="even">
<td><h3 id="saisies_techniques">saisies_techniques</h3></td>
<td><h3 id="saisies-agent-température-hygrométrie-mortalité...">Saisies
agent (température, hygrométrie, mortalité...)</h3></td>
</tr>
<tr class="odd">
<td><h3 id="sessions_actives">sessions_actives</h3></td>
<td><h3
id="verrouillage-multi-appareils-rls-désactivée-choix-documenté-voir-14">Verrouillage
multi-appareils — RLS désactivée (choix documenté, voir §14)</h3></td>
</tr>
<tr class="even">
<td><h3 id="taches">taches</h3></td>
<td><h3 id="tâches-planifiées">Tâches planifiées</h3></td>
</tr>
<tr class="odd">
<td><h3 id="utilisateurs">utilisateurs</h3></td>
<td><h3 id="comptes-pin-bcrypt-via-verifier_pin">Comptes — PIN bcrypt
via verifier_pin()</h3></td>
</tr>
</tbody>
</table>

### ⚠️ Tables supprimées en v26.22 : ventes et paiements (ancienne version) existaient en base sans être documentées. Vides (0 ligne), aucune occurrence dans index.html. Modèle incompatible (1 vente = 1 seul produit). Supprimées par la Migration 036, remplacées par commandes + commande_lignes + paiements (nouveau modèle).

### 2.5 Migrations SQL — GitHub

| Fichier                     | Contenu                                                                          |
|-----------------------------|----------------------------------------------------------------------------------|
| 001_schema_initial.sql      | Tables de base : bandes, saisies_techniques, taches, journal                     |
| 002_stock_tables.sql        | Tables lots_stock et mouvements_stock                                            |
| 003_rls_policies.sql        | Politiques RLS sur les 14 tables                                                 |
| 004_get_ferme_id_fix.sql    | Correction SECURITY DEFINER + cast JSON sur get_ferme_id()                       |
| 005_imputer_aliment_rpc.sql | RPC imputer_aliment() — imputation atomique stock depuis sessions agent          |
| 006_stock_dashboard_rpc.sql | RPC pour vue stock dashboard gérant                                              |
| …                           | (migrations suivantes numérotées jusqu’à 030 — voir dossier migrations/ du repo) |

## 3. Utilisateurs et Rôles

| Rôle       | Limite   | PIN actuel         | Accès                                                            |
|------------|----------|--------------------|------------------------------------------------------------------|
| GERANT     | Max 2    | 0000 (Adama)       | Tout — supervision, planif, compta, poulaillers, stock, rapports |
| AGENT      | Max 2    | 1111 (Agent Ferme) | Terrain — sessions, saisies, tâches                              |
| PARTENAIRE | Illimité | PIN individuel     | Ses bandes — résultats, état lot, créances                       |

> PIN stocké en bcrypt via RPC `verifier_pin()` (colonne PIN en clair
> supprimée — Migration 028).

## 4. Règles Techniques Critiques

### 4.1 Règles Supabase

- Client toujours nommé `sb` — jamais `supabase`
- Header `x-ferme-id` injecté globalement à la création du client (ligne
  427)
- RLS active sur toutes les tables, y compris `sessions_actives`
  (vérifié en base le 22/07/2026, session v26.30 — la Bible indiquait à
  tort que sessions_actives était sans RLS)
- `get_ferme_id()` avec SECURITY DEFINER — retourne l’ID ferme depuis le
  header
- Statelessness REST : `set_config` ne persiste pas entre requêtes —
  utiliser le header global
- Avant tout INSERT : vérifier colonnes NOT NULL, defaults, et colonnes
  générées
- `cout_unitaire` dans `lots_stock` est une colonne GÉNÉRÉE — ne jamais
  l’inclure dans un INSERT
- `lots_stock.produit` : noms complets (ex : ‘Aliment de démarrage’) —
  chercher avec `LOWER(produit) LIKE`
- `mouvements_stock.type_mouvement` : uniquement ‘ENTREE’ ou ‘SORTIE’
- `SET LOCAL row_security = off` dans les RPCs SECURITY DEFINER qui
  interrogent `utilisateurs`, pour bypasser RLS
- Appeler `extensions.crypt()` et non `crypt()` — pgcrypto est dans le
  schéma extensions
- **Toute opération DELETE/UPDATE sur une table sans RLS (ex:**
  `sessions_actives`**) doit systématiquement filtrer par** `ferme_id`
  **côté client — leçon de l’audit sécurité v26.18 (voir section 14)**

> Avant toute création de table : vérifier qu'elle n'existe pas déjà en
> base.
>
> SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY
> tablename;
>
> Leçon session v26.22 : les tables ventes et paiements existaient en
> base sans figurer dans la Bible. La Migration 036 a échoué sur
> relation "paiements" already exists. La documentation ne suffit pas —
> **la base est la seule vérité**. Corollaire du principe « diagnostic
> avant de coder ».

- **Une migration SQL est transactionnelle** : si une instruction
  échoue, TOUT est annulé, y compris les instructions déjà passées.
  Aucun état intermédiaire n'est possible.

### 4.2 Règles JavaScript

- Apostrophes dans les chaînes JS : toujours échapper avec `\'` ou
  utiliser des guillemets doubles
- Ne jamais imbriquer des template literals dans `.map()` — utiliser la
  concaténation
- `&quot;` au lieu d’apostrophes dans les attributs onclick inline
- `node --check` échoue sur les fichiers `.html` — utiliser la commande
  PowerShell d’extraction JS
- jsDelivr CDN inaccessible depuis le Burkina Faso — utiliser unpkg.com
  ou le fichier local

### 4.3 Règles de travail

- Fichier unique : `C:\Users\kyada\Documents\GitHub\AVIGEST4\index.html`
- Workflow : VS Code → Claude Code → vérification syntaxe PowerShell →
  GitHub Desktop → Push
- Chaque modification SQL = un nouveau fichier de migration numéroté
  dans `migrations/`
- `APP_VERSION` (ligne ~463 index.html) mis à jour EN MÊME TEMPS que
  `CACHE_NAME` (ligne 9 sw.js) à chaque session — format `'v26.XX'`
- Sélectionner ‘Yes, allow all edits this session’ dans Claude Code pour
  les sessions multi-patches
- Vérification après patch : commandes `Ctrl+Shift+F` avec nombre
  d’occurrences attendu
- **Un seul changement par patch** — ne jamais mixer des modifications
  non liées dans un même commit (leçon B6/isolation stricte)
- **Séquence de vérification stricte (confirmée v26.18)** : édition →
  `node --check` (confirmation explicite du résultat, ne jamais supposer
  que c’est fait) → diff GitHub Desktop complet → incrément version si
  dernier changement de la session → commit avec message combiné
  (version + description)

**RÈGLE STOCK — Deux types de lots**

Avant tout INSERT `lots_stock`, vérifier le flag `impute_journal`
(BOOLEAN) : - `true` : RPC déclenche écriture journal - `false` : RPC
décrémente stock uniquement, pas d’écriture journal

**RÈGLE CRU — Filtre catégories charges consommées (définitive, ne pas
modifier)**

    CRU = SUM(montant) WHERE type_ecriture = 'DEPENSE' 
                        AND categorie != 'Achat stock'
          / effectif_vivants

Filtre par **exclusion**, pas par liste fermée. La litière (comme tout
produit avec `impute_journal = true`) entre correctement dans le CRU via
ce filtre — ne jamais ajouter de catégorie spécifique au filtre,
l’exclusion `!= 'Achat stock'` suffit et gère tout automatiquement.

**RÈGLE JOURNAL — Catégories prédéfinies (v2)**

Charges consommées (CRU) : - Alimentation (auto RPC) - Vaccin \[type +
unité + qté + PU\] - Médicament \[type + unité + qté + PU\] - Litière
\[type + unité + qté + PU\] — traitée comme l’aliment (Type A)

Charges exploitation (hors CRU par exclusion, mais toujours DEPENSE) : -
Salaire \[forfait ou qté×PU\] - Prestation de service \[forfait ou
qté×PU\] - Transport \[forfait ou qté×PU\] - Glace \[forfait ou
qté×PU\] - Autre \[texte libre + montant\]

Hors charges (mouvement stock, jamais dans le CRU) : - Achat stock \[lié
à lots_stock\]

**4.4 Cadre de design**

Cadre de design boutons (figé v26.25) : couleur = sens, jamais
décoration. Bleu (--blue) = action « avance » (Nouvelle, Planifier) ·
Vert (--green) = confirmation d'argent/effectif réel (Livrer), texte
sombre · Rouge (--red) = danger/annulation · Gris (--bg3) = action
secondaire (Retour). Classe de base .gestion-pastille (pastille ≥44px,
cible tactile). Une seule action vive par écran. Toute action engageant
argent/effectif passe par un écran de confirmation, jamais un clic
direct.

## 5. Score Santé — Règle de Calcul

Validé session 18 juin 2026 — Cobb 500, Ouagadougou, J14+

| Paramètre        | Bon 🟢    | Passable 🟡 | Mauvais 🔴     |
|------------------|-----------|-------------|----------------|
| Température (°C) | 26–32°C   | 33–35°C     | \<26 ou \>35°C |
| Hygrométrie (%)  | 50–70%    | 71–80%      | \<50 ou \>80%  |
| Mortalité/jour   | 0–2 morts | 3–5 morts   | \>5 morts      |

**Règle de calcul : Score final = le PIRE des 3 scores individuels**

Surcharge manuelle : l’agent peut modifier le score calculé + saisir une
note explicative

> **Bug cosmétique (v26.17, toujours non résolu, priorité moyenne)** :
> écran de confirmation agent affiche le score santé avec balises HTML
> brutes (`<strong>BON</strong>` au lieu de **BON** en gras). Cause : la
> fonction `esc()` échappe les balises `<strong>` volontairement
> insérées dans `_renderSessionResume()`. Correctif prêt (retrait de
> `<strong>`/`</strong>`, le CSS `.rapport-ligne span:last-child` gère
> déjà le gras) — non encore appliqué. Estimé 5 minutes.

## 6. Module Stock — Architecture complète (CHANTIER CLOS — v26.18)

**TYPE DE LOT STOCK**

**Type A — Avec imputation journal (charge)** - → Aliment, Vaccin,
Médicament, Litière - → Décrémente stock + écriture journal auto - →
Entre dans le CRU (sauf catégorie “Achat stock”)

**Type B — Sans imputation journal** - → Produits créés par le gérant
avec `impute_journal = false` - → Décrémente stock uniquement - →
N’entre PAS dans le CRU

**FLAG sur lots_stock (implémenté) :**

    impute_journal BOOLEAN DEFAULT false
    categorie_cru TEXT (v26.16) — catégorie comptable du lot,
      lue en priorité par imputer_stock(), avec repli sur
      l'ancien CASE (nom produit) si NULL

**Imputation générique multi-produits depuis sessions agent (confirmé
v26.18) :** L’étape `stock_autres` (« Autres produits utilisés ») est
présente dans les 4 sessions agent (Matin/Midi/PM/Nuit), pas seulement
Matin. Elle liste tout lot dont le produit n’est pas l’aliment
(`.not('produit', 'ilike', '%aliment%')`) et impute chaque quantité
saisie via `imputer_stock()` — mécanisme générique, non câblé
spécifiquement pour un produit donné. Testé en conditions réelles avec
deux produits distincts, flux complet jusqu’à validation gérant
(EN_ATTENTE → CONFIRME) confirmé pour les deux : - **Litière** — B8,
testé 01/07/2026 - **Médicament** — testé, session v26.18 (02/07/2026)

Le vaccin n’a pas fait l’objet d’un test terrain distinct, mais utilise
exactement le même mécanisme générique que la litière et le médicament —
risque de comportement différent jugé très faible.

### ÉTAPES MODULE STOCK

| Étape                                                                       | Statut                                                                                                                       |
|-----------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------|
| Étape 1 — Schéma SQL                                                        | ✅ Validé                                                                                                                    |
| Étape 2 — Interface création lot                                            | ✅ Validé                                                                                                                    |
| Étape 3 — Imputation auto sessions agent                                    | ✅ Validé                                                                                                                    |
| Étape 4 — Vue stock dashboard gérant                                        | ✅ Validé                                                                                                                    |
| Étape 5 — Validation gérant alimentation                                    | ✅ Validé — mécanisme EN_ATTENTE + écran validation gérant opérationnel                                                      |
| Étape 6 — RPC litière (Type A, alignée aliment)                             | ✅ Validé — Migration 029, testé en conditions réelles 01/07/2026                                                            |
| Étape 7 — Formulaire dépense enrichi                                        | ✅ Validé — confirmé session v26.18, `renderNouvelleEcriture()` avec `<optgroup>` Charges CRU / Mouvement stock, mode Qté×PU |
| Étape 8 — CRU filtré charges consommées                                     | ✅ Validé — confirmé session v26.18, filtre `categorie !== 'Achat stock'` présent et cohérent à 3 endroits du code           |
| Imputation multi-produits (litière/vaccin/médicament) depuis sessions agent | ✅ Validé — confirmé session v26.18, voir détail ci-dessus                                                                   |

**Le module Stock est désormais entièrement clos — zéro item ouvert.**

## 13. Tableau de Suivi — Outil Permanent du Non-Codeur

Cette section est la mémoire vivante du projet. Claude la lit à chaque
session pour savoir où en est le projet sans qu’Adama ait besoin de tout
réexpliquer.

### 13.1 Légende des Statuts

| Statut       | Signification                           | Action suivante                                           |
|--------------|-----------------------------------------|-----------------------------------------------------------|
| ✅ Validé    | Testé sur l’app et confirmé fonctionnel | Passer à la prochaine fonctionnalité                      |
| ⏳ En cours  | Code produit mais pas encore testé      | Tester sur https://adamaky.github.io/AVIGEST4/            |
| 🐛 Bug       | Testé — comportement incorrect observé  | Décrire le bug précis à Claude                            |
| ○ À faire    | Pas encore commencé                     | Briefer Claude quand c’est la priorité                    |
| ☁️ SaaS      | Fonctionnalité prévue multi-fermes      | À planifier après stabilisation v1                        |
| ⏹️ Abandonné | Décision définitive de ne pas traiter   | Aucune — ne jamais rouvrir sans demande explicite d’Adama |

### 13.2 Tableau de Suivi des Fonctionnalités

**FONDATIONS**

| Fonctionnalité                                           | Statut        | Note / Bug connu                                                             |
|----------------------------------------------------------|---------------|------------------------------------------------------------------------------|
| Login PIN + session 12h                                  | ✅ Validé     | Testé PIN 0000 → OK                                                          |
| Verrouillage multi-appareils                             | ✅ Validé     | Table sessions_actives + device fingerprint                                  |
| Écran blocage session concurrente                        | ✅ Validé     | Ex-B2 — écran dédié screen-blocage (au lieu d’injection dans app-main caché) |
| Bouton Forcer déconnexion                                | ✅ Validé     | Ex-B9 — role passé en paramètre, corrige dépendance circulaire localStorage  |
| Système de navigation Nav                                | ✅ Validé     | Bug pavé PIN corrigé                                                         |
| **Correctif RLS — sessions_actives DELETE cross-tenant** | **✅ Validé** | **v26.19 — filtre** `.eq('ferme_id', FERME_ID)` **ajouté, voir section 14**  |
| Mode hors ligne + sync auto                              | ○ À faire     | Queue localStorage à implémenter                                             |
| Notifications OneSignal                                  | ○ À faire     | Géré en arrière-plan                                                         |

**AGENT**

| Fonctionnalité                      | Statut       | Note / Bug connu                                                                                                                                                                               |
|-------------------------------------|--------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Tuiles sessions dans onglet Tâches  | ✅ Validé    | 4 sessions : Matin/Midi/PM/Nuit                                                                                                                                                                |
| Session Matin — 6 étapes            | ✅ Validé    | Pavé numérique fonctionnel                                                                                                                                                                     |
| Session Midi — 3 étapes             | ✅ Validé    | Testé 18/06/2026                                                                                                                                                                               |
| Session PM — 3 étapes               | ✅ Validé    | Testé 18/06/2026                                                                                                                                                                               |
| Session Nuit — 4 étapes             | ✅ Validé    | Testé 18/06/2026                                                                                                                                                                               |
| Score santé — calcul auto           | ⏹️ Abandonné | Ex-B1 : “Score undefined” — décision définitive d’Adama (session v26.18) de ne pas traiter, non prioritaire. Distinct du bug cosmétique `<strong>` (voir section 5), toujours actif celui-là   |
| Score santé — surcharge manuelle    | ○ À faire    | Prévu : bouton Bon/Passable/Mauvais + note agent                                                                                                                                               |
| Blocage sessions hors plage horaire | ✅ Validé    | Ex-B3 — confirmé implémenté dans `renderSession()` : plages par session (Matin 5h-10h, Midi 10h-14h, PM 14h-19h, Nuit 19h-5h), double protection (bouton désactivé + re-vérification fonction) |
| Écran abattage — 3 étapes           | ○ À faire    | Calcul poids moyen auto                                                                                                                                                                        |

**GÉRANT**

| Fonctionnalité                  | Statut      | Note / Bug connu                                                                                                                                                                               |
|---------------------------------|-------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Accueil gérant — navigation     | ✅ Validé   | ACCUEIL · BANDES · ANALYSES                                                                                                                                                                    |
| Onglet Tâches gérant            | ✅ Validé   | Ex-B4 — confirmé résolu (termineesHTML déclarée) ; collision historique de numérotation avec un autre B4 cité ailleurs restée non éclaircie mais sans impact pratique — voir Points en suspens |
| Planifier tâches agent          | ✅ Validé   | 3 types : Quotidienne · Hebdomadaire · Abattage                                                                                                                                                |
| Journal comptable               | ✅ Validé   | Dépenses + Recettes + CRU/sujet                                                                                                                                                                |
| Analyses — zootechnie           | ✅ Validé   | Ex-B5 : Poids moyen et IC — confirmé résolu par Adama (testé/observé récemment, session v26.18)                                                                                                |
| Analyses — finance              | ✅ Validé   | Marge nette · Dépenses · Recettes                                                                                                                                                              |
| Planifier abattage              | ✅ Validé   | Formulaire Date + Nb sujets + Client cible                                                                                                                                                     |
| Rapports hebdomadaires          | ⏳ En cours | À tester prochaine session                                                                                                                                                                     |
| Rapport fin de bande + WhatsApp | ✅ Validé   | Export texte structuré (fermé v26.9)                                                                                                                                                           |
| Gestion utilisateurs            | ○ À faire   | Créer / activer / désactiver                                                                                                                                                                   |

**STOCK**

Voir section 6 — module entièrement clos (8 étapes + imputation
multi-produits, toutes ✅ Validé).

**PARTENAIRE**

| Fonctionnalité                  | Statut    | Note / Bug connu        |
|---------------------------------|-----------|-------------------------|
| Interface partenaire — 3 tuiles | ○ À faire | Filtré par idPartenaire |
| Assignation quotes-parts        | ○ À faire | Total ≤ 100%            |

**PROCESSUS**

| Fonctionnalité                 | Statut    | Note / Bug connu         |
|--------------------------------|-----------|--------------------------|
| Clôture bande — 6 phases       | ○ À faire | 14 jours minimum         |
| Fabrication aliment            | ○ À faire | Lignes dynamiques        |
| Alertes automatiques in-app    | ○ À faire | 7 KPI configurés         |
| Abattage progressif — 6 étapes | ○ À faire | Plan → Exec → Validation |

**VISION SAAS**

| Fonctionnalité                  | Statut    | Note / Bug connu                                                                                       | SaaS |
|---------------------------------|-----------|--------------------------------------------------------------------------------------------------------|------|
| Multi-fermes (multi-tenant)     | ✅ Validé | 2 fermes actives (REVAGRO, ALIRAH2026), 3e client en cours d’intégration — chaque ferme = espace isolé | ☁️   |
| Authentification sécurisée SaaS | ○ À faire | PIN → tokens JWT ou équivalent                                                                         | ☁️   |
| Plans tarifaires (Free / Pro)   | ○ À faire | Gestion abonnements                                                                                    | ☁️   |
| Dashboard gérant SaaS           | ○ À faire | Vue de toutes les fermes                                                                               | ☁️   |
| Onboarding nouvelle ferme       | ○ À faire | Option A : intégré (pas subdomain)                                                                     | ☁️   |

### 13.3 Registre des bugs (créé session v26.18)

Registre centralisé transversal, source unique de numérotation des bugs.
Les tableaux de section (AGENT, GÉRANT, etc.) ci-dessus restent la
référence de lecture rapide, mais tout nouveau bug détecté à partir de
maintenant doit être numéroté ici en premier.

**Règles établies (session v26.18) :** - Numérotation strictement
croissante, jamais réutilisée, identique dans tous les documents
(Bible + mémoire de session) - Sync Bible déclenchée proactivement par
Claude dès qu’une ligne passe à ✅ Validé (granularité fine, pas
d’attente de fin de chantier) –

*« B10 fermé en v26.21. Prochain numéro disponible : B11. »*

| **Numéro** | **Titre court**                          | **Domaine** | **Statut** | **Session ouverture** | **Session fermeture** |
|------------|------------------------------------------|-------------|------------|-----------------------|-----------------------|
| B10        | Statut 'TERMINEE' invalide (→ 'CLOTURE') | Clôture     | ✅ Fermé   | v26.18                | v26.21                |

### 13.4 Protocole de Brief de Session

Avant chaque session avec Claude, Adama colle ce bloc en début de
message :

    📋 BRIEF SESSION AVIGEST v26

    Objectif du jour : [une phrase]
    Dernière chose validée : [fonctionnalité]
    Bug en suspens : [description ou 'Aucun']

### 13.5 Multi-fermes — État actuel et Feuille de Route SaaS

**ÉTAT ACTUEL (production) :**

AviGest gère aujourd’hui 2 fermes actives sur une architecture
multi-tenant déjà fonctionnelle : un seul frontend GitHub Pages,
sélection de ferme via code d’accès au login (écran-code-ferme),
isolation des données par `ferme_id` + header `x-ferme-id` + RLS
Supabase.

- → REVAGRO (ferme_id : e56574a9-54c1-430d-b480-b9bdd1090dd7)
- → ALIRAH2026 (ferme_id : 40ee764e-d073-463e-b07b-bf95a9d7a675)

**EN COURS D’ENGAGEMENT :**

Un 3e client est actuellement en cours d’intégration sur cette même
architecture. Détails à préciser dans une prochaine mise à jour de la
Bible.

**VISION SAAS (extension future au-delà des clients déjà engagés) :**

La vision SaaS plus large (accueil de clients externes non encore
identifiés, abonnements, dashboard central multi-fermes) reste
documentée ici pour que chaque fonctionnalité v1 soit conçue de façon
compatible. Ne pas commencer le chantier SaaS élargi avant que les
sections Fondations, Agent et Gérant soient toutes à statut Validé.

| Pré-requis SaaS élargi               | Condition de démarrage                                                                                       |
|--------------------------------------|--------------------------------------------------------------------------------------------------------------|
| v1 stable                            | Zéro bug ouvert en Fondations + Agent + Gérant + Stock — **Stock atteint ce seuil depuis la session v26.18** |
| Architecture multi-tenant            | ✅ Déjà en place et validée en production (2 fermes actives)                                                 |
| Authentification sécurisée           | Remplacer PIN seul par token JWT avec expiration                                                             |
| Plans tarifaires                     | Définir Free (1 poulailler) vs Pro (6+ poulaillers)                                                          |
| Onboarding                           | Option A : écran onboarding intégré — pas de subdomains par ferme                                            |
| Client(s) au-delà des 3 déjà engagés | Cible : début janvier 2027                                                                                   |

## 14. Sécurité — État et Audit (nouvelle section, session v26.18)

### 14.1 Chantiers sécurité fermés (historique)

S1-S4 — voir version précédente de la Bible : protection brute force
PIN, hachage bcrypt, erreurs contextuelles showToast, fetch natif
remplaçant sbTemp. Tous validés v26.9/v26.10.

### 14.2 Audit RLS — session v26.18 (via Claude Code)

\[MISE À JOUR v26.30 : cet audit ne lisait que le code JS ; ses points «
conditionnels » ont été confirmés OU corrigés en base le 22/07/2026 —
voir §14.4 pour les diagnostics fermes. Notamment, le risque « écriture
» était surestimé, PostgreSQL appliquant USING comme WITH CHECK par
défaut.\] Premier audit structuré de sécurité RLS effectué le
02/07/2026. Méthode : analyse exhaustive du code JS (`index.html`) pour
repérer les opérations sans filtre `ferme_id` ; accès direct aux
policies RLS réelles en base non disponible dans cette passe (nécessite
Supabase Studio/psql).

**Point CRITIQUE confirmé et corrigé :** - `sessions_actives` — RLS
désactivée (choix documenté) + un DELETE cross-tenant sans filtre
`ferme_id` trouvé ligne ~1739 (`doLogin()`, nettoyage sessions
expirées). **Corrigé v26.19** : ajout de `.eq('ferme_id', FERME_ID)`.
Commit :
`"v26.19 - Fix RLS gap: DELETE sessions_actives sans filtre ferme_id (audit sécurité v26.18)"`. -
Limite du correctif : protège contre l’erreur applicative côté code
légitime, mais ne remplace pas une policy RLS réelle — un accès direct
via devtools/clé anon pourrait théoriquement encore contourner ce filtre
tant que RLS reste désactivée sur cette table.

**Points restés CONDITIONNELS (état RLS réel non vérifié) :**

| Table                                                                | Filtre ferme_id côté code                                                  | Risque si RLS off                               | Exemple                                                 |
|----------------------------------------------------------------------|----------------------------------------------------------------------------|-------------------------------------------------|---------------------------------------------------------|
| bandes                                                               | Partiel — ~20 opérations sans ferme_id, dont des UPDATE/DELETE par id seul | 🔴 Élevé                                        | Soft-delete bande, changement statut, par id seul       |
| batiments                                                            | Absent — 4 UPDATE par id seul                                              | 🔴 Élevé                                        | Changement statut poulailler par id seul                |
| taches                                                               | Partiel — ~10 opérations sans ferme_id                                     | 🟠 Moyen-élevé                                  | Marquer tâche exécutée par id seul                      |
| lots_stock / mouvements_stock                                        | Absent sur SELECT/UPDATE détail                                            | 🟠 Moyen                                        | Détail lot, historique mouvements par id seul           |
| RPCs (`get_dashboard`, `imputer_stock`, `valider_imputation_gerant`) | Pas de ferme_id explicite en paramètre                                     | Inconnu — dépend de la vérification interne SQL | À lire directement en base                              |
| utilisateurs                                                         | Absent — UPDATE last_login par id seul                                     | 🟡 Faible                                       | Impact métier faible                                    |
| partenaires_bandes                                                   | Absent — SELECT par utilisateur_id seul                                    | 🟡 Faible                                       | Pertinent si un utilisateur multi-fermes existe un jour |

**Tables jugées saines (filtre ferme_id systématique côté code) :**
journal, rapports_hebdo, composants_lot, vue_stock_actuel.

### 14.3 Session RLS dédiée — programmée, non planifiée dans le temps

**Objectif** : lever l’incertitude sur l’état RLS réel des tables
listées ci-dessus. Nécessite l’exécution directe en base (Supabase
Studio ou psql) des requêtes suivantes :

    SELECT schemaname, tablename, rowsecurity FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;
    SELECT schemaname, tablename, policyname, cmd, roles, qual, with_check FROM pg_policies WHERE schemaname = 'public' ORDER BY tablename, policyname;
    SELECT routine_name, routine_definition FROM information_schema.routines
    WHERE routine_schema = 'public' AND routine_name IN ('get_dashboard','imputer_stock','valider_imputation_gerant','get_ferme_id','verifier_pin');

Une fois ces résultats obtenus, les points conditionnels du tableau 14.2
deviendront des diagnostics fermes, exploitables pour prioriser
d’éventuels correctifs. **Aucun correctif ne doit être appliqué avant
validation explicite d’Adama, patch par patch, comme pour le point
sessions_actives.**

**14.4 Session RLS dédiée — RÉALISÉE (session v26.30, 22/07/2026)**

Les trois requêtes de diagnostic du §14.3 ont été exécutées en base (SQL
Editor Supabase). Les points « CONDITIONNELS » du tableau 14.2 sont
désormais des diagnostics fermes. Résultat global : l’isolation
multi-tenant est réellement appliquée au niveau serveur, pas seulement
dans le code JS.

**Diagnostic 1a (RLS on/off) :** RLS activée sur TOUTES les tables du
schéma public, y compris sessions_actives (que la Bible croyait sans
RLS). Le risque « si RLS off » du tableau 14.2 tombe donc entièrement —
la condition n’est jamais remplie.

**Diagnostic 1b (policies réelles) :** chaque table possède au moins une
policy filtrant (ferme_id = get_ferme_id()). Les tables classées «
risque élevé » (bandes, batiments) et « moyen » (taches, lots_stock,
mouvements_stock) sont en fait protégées. Cas particulier fermes :
policy lecture_publique_code_acces (SELECT, qual=true, rôles
anon+authenticated) volontaire, nécessaire au login par code ferme — à
conserver.

**Diagnostic 1c (RPCs sensibles) :** les 5 RPCs filtrent correctement.
get_ferme_id() lit le header et cast en uuid ; get_dashboard,
imputer_stock (2 versions coexistent — voir note),
valider_imputation_gerant et verifier_pin dérivent toutes ferme_id via
get_ferme_id() ou le header, avec fail-closed sur NULL.
valider_imputation_gerant vérifie en plus le rôle GERANT par PIN. Le
point « Inconnu » du tableau 14.2 passe donc au vert.

**Découverte technique importante (rectifie 14.2) :** l’audit 14.2
surestimait le risque « écriture ». En PostgreSQL, une policy
ALL/INSERT/UPDATE sans clause WITH CHECK explicite utilise
automatiquement sa clause USING comme WITH CHECK. Les policies
acces_par_ferme (USING renseigné, with_check NULL) protégeaient donc
DÉJÀ l’écriture croisée, avant tout correctif. Prouvé par test en rôle
anon : insertion croisée refusée (ERROR 42501), insertion légitime
acceptée.

**Migration 041 — ABANDONNÉE (no-op) :** rédigée pour ajouter un WITH
CHECK explicite, elle ciblait un nom de policy inexistant («
acces_par_terme » au lieu de « acces_par_ferme »). Elle n’a donc rien
créé ni cassé. Non commitée, supprimée avant push. Aucune trace en base.
Numéro 041 laissé vacant.

**Migration 042 — FAITE et poussée (v26.30) :** nettoyage du doublon de
policy sur clients — suppression de ferme_isolation (redondante,
with_check hérité) ; clients_isolation (qual + with_check explicites)
conservée. Testé : isolation inchangée (croisé refusé, légitime accepté
en rôle anon). Résout le point en suspens n°8.

**Reste à nettoyer (futures migrations 043+) :** le même doublon
acces_par_ferme (anon) + ferme_isolation (public) subsiste sur bandes,
journal, mouvements_stock, saisies_techniques, taches. Même recette que
la 042, en gardant la policy du rôle anon (celui réellement utilisé par
l’app). Sans urgence — aucune faille, uniquement du rangement.

**Limite de fond NON couverte (à traiter au niveau authentification) :**
le header x-ferme-id est posé côté navigateur (depuis localStorage) et
repose sur la clé anon publique, unique pour tous les rôles. Un
utilisateur de l’app peut donc modifier son header et se faire passer
pour une autre ferme : dans ce cas header et ferme_id concordent, la RLS
laisse passer. Aucune policy ne corrige cela — c’est le rôle du futur
chantier authentification (PIN → token JWT, vision SaaS). Point de
sécurité prioritaire suivant.

**À clarifier — numérotation des migrations :** le dossier migrations/
présente des numéros intermédiaires manquants (017, 020–025, 029,
033–034 — vraisemblablement des migrations fusionnées, renommées ou
jamais créées ; le 041 est volontairement vacant, migration abandonnée).
La 040 (040_date_livraison_commandes.sql) existe bien et reste la
dernière migration réellement appliquée avant la 042. Trou de
numérotation sans conséquence, à documenter au besoin.

## Points en suspens (à clarifier avec Adama)

1.  **~~Collision de numérotation B1~~** — **Refermé session v26.18.**
    B1 “score santé” passé au statut ⏹️ Abandonné, décision définitive
    d’Adama.
2.  **B4** — collision historique entre deux mentions du même numéro
    reste non éclaircie (un B4 “corrigé 18/06” dans GÉRANT vs un B4
    parfois cité en basse priorité ailleurs), **mais sans conséquence
    pratique** : le comportement fonctionnel est confirmé résolu par
    Adama (session v26.18). Point purement historique, non bloquant.
3.  **Bug cosmétique score santé** (balises `<strong>` brutes) :
    toujours non résolu, priorité moyenne — voir section 5. Le blocage
    technique précédent (“0 changed files” GitHub Desktop) n’a pas été
    creusé ; à la reprise, vérifier d’abord la sauvegarde (Ctrl+S) avant
    de retenter l’édition.
4.  **Cohérence .md/.docx** : cette version .md (v26.18) doit être
    répercutée manuellement par Adama dans le `.docx`, qui reste
    l’unique source. Après édition du `.docx`, il faudra confirmer avec
    Adama s’il souhaite une régénération .md à committer dans le repo
    GitHub, à côté de SCHEMA.md.
5.  **Prochaine priorité de développement** : à redéfinir. Le chantier
    initialement annoncé comme “priorité haute” (imputation
    multi-produits stock) est en réalité déjà clos (voir section 6).
    Restent en attente : bug cosmétique score santé (priorité moyenne, 5
    min), session RLS dédiée (section 14.3), verrou session agent non
    déblocable à distance par le gérant (limitation connue, chantier
    futur), mode offline et dashboard SaaS (vision long terme).

**15. Module Clôture de Bande (CHANTIER CLOS — v26.21)**

Le module clôture permet au gérant de terminer définitivement une bande
: archiver son statut, valoriser le stock restant, libérer le bâtiment
et générer un rapport final. Architecture en **6 phases**, fonction
principale renderClotureBande(bandeId).

💡 *En clair : c'est l'étape « fin de cycle ». Quand les poulets sont
partis, le gérant clôture la bande — l'app fait le bilan, remet le
poulailler à disposition, et fige les chiffres.*

**15.1 Les 6 phases**

| **Phase**                        | **Rôle**                                                                                                                             | **Statut** |
|----------------------------------|--------------------------------------------------------------------------------------------------------------------------------------|------------|
| Phase 1 — Éligibilité            | Vérifie l'ancienneté (14 jours minimum) et le statut clôturable                                                                      | ✅ Validé  |
| Phase 2 — Effectif final         | Affiche l'effectif restant, avec correction manuelle possible (colonnes effectif_final_corrige, effectif_final_note — migration 032) | ✅ Validé  |
| Phase 3 — Reliquat stock         | Valorise le stock restant en écriture RECETTE (catégorie 'Reliquat stock')                                                           | ✅ Validé  |
| Phase 4 — Bilan financier        | 5 lignes lues depuis get_dashboard : recettes, dépenses, CRU, marge nette, reliquat estimé                                           | ✅ Validé  |
| Phase 5 — Validation PIN gérant  | Pavé PIN dédié, contrôle serveur via verifier_pin (rôle GERANT)                                                                      | ✅ Validé  |
| Phase 6 — Archivage + libération | Passe la bande en 'CLOTURE' et libère le bâtiment ('LIBRE')                                                                          | ✅ Validé  |

**15.2 Migrations associées**

| **Migration** | **Contenu**                                                                                               |
|---------------|-----------------------------------------------------------------------------------------------------------|
| 032           | Colonnes effectif_final_corrige, effectif_final_note sur bandes (correction manuelle de l'effectif final) |
| 033           | RPC cloturer_phase3_reliquat — écrit l'écriture RECETTE du reliquat stock                                 |
| 034           | RPC calculer_reliquat_stock — calcul en lecture seule pour l'affichage (ne modifie rien)                  |

**15.3 Règle reliquat — hors CRU**

Le reliquat stock est enregistré comme une **RECETTE** (pas une
dépense). Il reste donc automatiquement **hors CRU** (le CRU ne compte
que les DEPENSE hors 'Achat stock'). Aucun filtre spécial nécessaire.

💡 *En clair : le stock qui reste en fin de bande a de la valeur — c'est
de l'argent « récupéré », pas une charge. On le compte donc comme une
recette, et il n'alourdit pas le coût de revient par poulet.*

**15.4 Validation PIN gérant (Piste A)**

La clôture définitive exige le PIN du gérant. Le front appelle
verifier_pin (p_role = 'GERANT') côté serveur ; si le PIN est correct,
il enchaîne l'écriture du reliquat (cloturer_phase3_reliquat) puis
\_confirmerCloture (archivage bande + libération bâtiment).

Fonctions du pavé PIN : \_pinClotureTap, \_pinClotureDel,
\_updateDotsCloture, \_validerCloturePin, \_showClotErr. Variable
globale \_pinCloture. Pavé isolé du login (classes pin-key, points
dot-clot-0 à dot-clot-3).

💡 *En clair : pour éviter qu'un agent clôture une bande par erreur,
seul le gérant peut valider — en tapant son code secret, vérifié
directement par le serveur.*

**15.5 Bug B10 — fermé (v26.21)**

Le code écrivait statut = 'TERMINEE', valeur **invalide** (la contrainte
bandes_statut_check n'accepte que 'PREPARATION', 'EN COURS', 'CLOTURE',
'ARCHIVE'). Corrigé aux 3 endroits : l'écriture réelle du statut, la
détection « déjà clôturée », et le texte affiché (« CLÔTURÉE »). Ajout
au passage du filtre .eq('ferme_id', FERME_ID) sur l'UPDATE de clôture
(sécurité multi-fermes).

**15.6 Limite connue — clôture non atomique**

L'enchaînement archivage bande → libération bâtiment se fait en deux
écritures séparées (via Promise.all), pas dans une transaction unique.
**Risque théorique** : si la libération du bâtiment échoue après
l'archivage réussi (coupure réseau), la bande serait clôturée mais le
bâtiment resterait « occupé ». Impact faible et réparable manuellement
(remettre le bâtiment en 'LIBRE'). Chantier futur si observé sur le
terrain : basculer vers une RPC unique tout-ou-rien.

💡 *En clair : dans un cas très rare (coupure au mauvais moment), le
poulailler pourrait rester marqué « occupé » alors que la bande est
finie. Facile à corriger à la main. On blindera seulement si ça arrive
vraiment.*

**NOUVELLE SECTION 16 — Module CRM Clients**

**16. Module CRM Clients (chantier en cours — démarré v26.21/v26.22)**

**16.1 Objectif**

Permettre au gérant de gérer ses clients, leurs commandes (précommandes
puis livraisons), et le suivi des paiements/créances. Séparation
comptable OHADA : **CRÉANCES** (qui me doit) distinctes de la **CAISSE**
(combien j'ai réellement).

**Seul le GÉRANT saisit.** Réservé à l'onglet GESTION.

**16.2 Découpage en 6 étapes**

| **Étape** | **Contenu**                                    | **Statut**       |
|-----------|------------------------------------------------|------------------|
| 1         | Clients + catalogue produits                   | ✅ Migration 035 |
| 2         | Livraison → vente → recette journal            | ○ À faire        |
| 3         | Suivi paiements / créances                     | ○ À faire        |
| 4         | Export WhatsApp commande                       | ○ À faire        |
| 5         | Écran Trésorerie / Caisse                      | ○ À faire        |
| 6         | Mouvements hors-bande + injections partenaires | ○ À faire        |

**16.3 Migration 035 — Socle (exécutée)**

- produits_catalogue : nom, unite, prix_reference,
  **decremente_effectif**, actif

- clients : nom, telephone, adresse, type_client, note, actif

- 5 produits pré-remplis × 2 fermes : Sujet vivant (decremente=true),
  Poulet entier abattu (true), Foies & gésiers (kg, false), Cous
  têtes+pattes (kg, false), Sac de fientes (sac, false)

**16.4 Migration 036 — Cœur CRM (exécutée v26.22)**

Trois tables, toutes avec ferme_id NOT NULL + RLS (ferme_id =
get_ferme_id()) :

**commandes** — en-tête du bon de commande

- client_id, date_commande, statut, date_reglement_prevue, note

- statut ∈ PRECOMMANDE / PLANIFIEE / LIVREE / ANNULEE

- **Pas de colonne total** — calculé à la volée depuis les lignes

**commande_lignes** — 1 ligne = 1 produit + 1 bande

- commande_id (CASCADE), produit_id, bande_id, quantite, prix_prevu,
  prix_reel

- **bande_id OPTIONNEL en base** (fientes, abats hors bande)

- **Mais OBLIGATOIRE à l'écran** pour les produits avec
  decremente_effectif = true

- Prix **prévu** (à la commande) et **réel** (à la livraison) : les deux
  conservés

**paiements** — encaissements

- commande_id **NOT NULL** (chaque paiement = 1 commande précise),
  client_id, montant, date_paiement, moyen, type, note

- moyen ∈ CASH / MOBILE_MONEY / VIREMENT / CHEQUE / AUTRE

- type ∈ ACOMPTE / SOLDE

- client_id est une **redondance contrôlée** (accessible via commande,
  mais évite une jointure sur chaque calcul de créance client)

**16.5 Décisions métier actées (ne pas rouvrir sans demande explicite)**

1.  **Total calculé, jamais stocké** — il existe un total prévu ET un
    total réel ; les stocker créerait un risque de désynchronisation.

2.  **Chaque paiement rattaché à une commande précise** — pas d'acompte
    flottant.

3.  **Commande multi-produits ET multi-bandes** — d'où le modèle
    en-tête + lignes.

4.  **Abattage = module futur séparé.** Le CRM enregistre la vente de
    produits abattus sans toucher l'effectif de la bande.

5.  **Injections partenaires** : s'appuieront sur partenaires_bandes (il
    n'existe PAS de table partenaires seule).

**16.6 Alerte échéance (à implémenter, étape 3)**

Rappel J-1 sur l'accueil gérant : « Facture client X à régler demain ».
Trois couleurs : 🟡 J-1 à relancer · 🔴 échéance dépassée impayée · ⚪
lointaine. Compteur également sur la tuile Clients.

**16.7 État actuel (fin v26.22)**

- ✅ Tables en base (035 + 036)

- ✅ Onglet GESTION + page tuiles (Clients active, Trésorerie/Stock
  grisées)

- ○ Écran Clients (liste, ajout, modification) — **prochain chantier**

**④ NOUVELLE SECTION 17 — Architecture modules séparés**

**17. Architecture modules séparés (établie v26.22)**

**17.1 Le problème**

index.html fait ~5900 lignes, tout le code dans un seul \<script\>
inline. Ajouter le CRM, la trésorerie et l'abattage dedans reviendrait à
aggraver le spaghetti.

**Décision** : les nouveaux modules sont construits **dans des dossiers
séparés**, en **vrais modules ES** (type="module"). index.html **n'est
PAS redécoupé** — trop risqué. On greffe proprement à côté ; la
migration de l'ancien code viendra plus tard.

**17.2 Structure de fichiers**

AVIGEST4/

├── index.html ← existant, 4 lignes ajoutées seulement

├── sw.js

├── migrations/

│

├── css/

│ └── gestion.css

│

└── js/

├── shared/

│ ├── db.js ← accès Supabase + contexte (guichet)

│ └── helpers.js ← esc, toast, zone, fcfa, dateFr

├── gestion/

│ └── gestion.js ← page GESTION (tuiles)

└── clients/ ← à venir

**17.3 Le "guichet" avigestContext() — point clé**

**Problème découvert en v26.22** (vérifié en console) :

| **Variable** | **Déclarée avec** | **Visible depuis un module ?**       |
|--------------|-------------------|--------------------------------------|
| sb           | var (ligne ~549)  | ✅ Oui — var global va sur window    |
| App          | const/let         | ❌ Non — window.App = undefined      |
| FERME_ID     | const/let         | ❌ Non — window.FERME_ID = undefined |

Sans FERME_ID, aucun module ne peut filtrer ses requêtes par ferme → CRM
impossible.

**Solution retenue** : index.html expose **une seule fonction**, en fin
de script inline :

javascript

window.avigestContext = function () {

return {

sb: (typeof sb !== 'undefined') ? sb : null,

role: (typeof App !== 'undefined' && App) ? App.role : null,

fermeId: (typeof FERME_ID !== 'undefined') ? FERME_ID : null

};

};

C'est **l'unique frontière** entre l'ancien code et les nouveaux
modules. Les modules **lisent** une photo de l'état ; ils ne peuvent pas
modifier les originaux.

**RÈGLE ABSOLUE** : ne jamais mettre sb en cache dans une variable de
module. sb est **réaffecté au login** (index.html ~526) une fois le
FERME_ID connu. Une copie gardée en mémoire porterait le mauvais header
x-ferme-id. Toujours appeler db() au moment de s'en servir.

**17.4 Branchement sur le Nav existant**

NAVBAR_CONFIG (ligne ~1402) est une simple liste d'objets. Le clic
exécute \_navTap(id, fn) qui appelle window\[fn\]().

Un module isolé n'est pas dans window — il doit **s'exposer
explicitement**, mais **une seule porte d'entrée** :

javascript

window.renderGestion = renderGestion; // la "sonnette" du module

Tout le reste du fichier reste privé → **zéro collision** avec les ~5900
lignes d'index.html.

**17.5 Serveur local obligatoire en développement**

Les modules ES **ne se chargent pas** depuis un fichier ouvert en
double-clic (file:///...). Le navigateur les refuse.

**Commande à lancer avant chaque session de dev**, depuis le dossier du
projet :

npx serve

Puis tester sur http://localhost:3000. Laisser le terminal ouvert
(Ctrl+C pour arrêter).

**En production sur GitHub Pages : aucun problème** — GitHub Pages *est*
un serveur. La contrainte est purement locale.

**17.6 Greffe dans index.html (4 lignes au total)**

1.  NAVBAR_CONFIG → { id:'gestion', icon:'📋', label:'Gestion',
    fn:'renderGestion' },

2.  \<head\> → \<link rel="stylesheet" href="css/gestion.css"\>

3.  Fin de \<script\> inline → la fonction avigestContext()

4.  Avant \</body\> → \<script type="module"
    src="js/gestion/gestion.js"\>\</script\>

**⑤ AJOUTER — Points en suspens**

**Ajouter à la liste des points en suspens :**

6.  **sw.js — STATIC_URLS incomplet** (ouvert v26.22) : la liste ne
    contient que /AVIGEST4/ et /AVIGEST4/index.html. Les nouveaux
    fichiers (css/gestion.css, js/shared/db.js, js/shared/helpers.js,
    js/gestion/gestion.js) n'y figurent pas. **Conséquence** : le module
    GESTION **ne fonctionnera pas hors ligne**. Fonctionne correctement
    en ligne (testé en production le 11/07/2026, fenêtre InPrivate). À
    corriger dans un commit dédié.

7.  **Warning Multiple GoTrueClient instances detected** (observé
    v26.22) : deux clients Supabase coexistent dans la page — création
    ligne 549 puis réaffectation ligne 526 d'index.html. Sans gravité
    constatée à ce jour, mais à surveiller.

8.  **Doublon de policy RLS sur clients** (observé v26.22) — RÉSOLU en
    v26.30 (Migration 042) : la policy redondante ferme_isolation a été
    supprimée, clients_isolation conservée. Le même doublon subsiste sur
    bandes, journal, mouvements_stock, saisies_techniques et taches
    (futures migrations 043+, sans urgence — voir §14.4).

**⑥ METTRE À JOUR — Section 2.1 (version)**

\| **Version actuelle** \| **APP_VERSION = 'v26.22' · CACHE_NAME =
'avigest-v26-22'** \|

**⑦ METTRE À JOUR — Section 2.5 (migrations)**

Ajouter les deux dernières lignes :

\| 035_crm_clients_catalogue.sql \| Tables clients + produits_catalogue
(CRM étape 1) \| \| 036_crm_commandes.sql \| Tables commandes,
commande_lignes, paiements + suppression tables mortes ventes/paiements
\|

*— Fin de la mise à jour Bible session v26.22 —*

**18. Module CRM Commandes (CHANTIER CLOS — v26.25)**

**18.1 Objectif et périmètre**

Le CRM Commandes est le **chemin de vente officiel** d'AviGest depuis
v26.26. Il remplace intégralement l'ancien circuit « Vente » (voir
§18.6). Le gérant crée un bon de commande multi-produits / multi-bandes,
le fait passer de précommande à planifiée, puis le livre — la livraison
étant le seul moment où l'effectif de la bande et la recette au journal
sont réellement impactés.

**Seul le GÉRANT saisit.** Réservé à l'onglet GESTION, module
js/commandes/commandes.js.

**18.2 Les 4 morceaux (tous validés)**

| **Morceau**    | **Contenu**                                                          | **Statut**         |
|----------------|----------------------------------------------------------------------|--------------------|
| 1 — Détail     | Écran détail de commande en lecture seule                            | ✅ v26.23          |
| 2 — Workflow   | Transition Précommande → Planifiée (avec date livraison obligatoire) | ✅ v26.24 / v26.27 |
| 3 — Livraison  | Écran Livraison → RPC livrer_commande (atomique)                     | ✅ v26.25          |
| 4 — Annulation | Passage d'une commande au statut ANNULEE                             | ✅ v26.25          |

**18.3 Le RPC livrer_commande (Migration 039)**

Signature : **livrer_commande(p_commande_id uuid, p_lignes jsonb)**.

Opération **atomique** : elle lit get_ferme_id() (isolation
multi-tenant), enregistre les prix réels ligne par ligne, décrémente
l'effectif de la bande pour les produits marqués decremente_effectif =
true, écrit la recette au journal, et fait passer la commande au statut
LIVREE. Tout réussit ensemble ou rien — pas de demi-livraison possible.

Test en base : SET LOCAL request.headers =
'{"x-ferme-id":"e56574a9..."}' dans le SQL Editor avant l'appel.

**18.4 Les deux dates d'une commande (ne pas confondre)**

Une commande porte **deux dates distinctes**, chacune dans sa propre
colonne :

| **Colonne**           | **Sens**                                                     | **Depuis**             |
|-----------------------|--------------------------------------------------------------|------------------------|
| date_reglement_prevue | Date à laquelle le client doit régler (échéance de paiement) | Migration 036          |
| date_livraison_prevue | Date à laquelle la commande doit être livrée physiquement    | Migration 040 (v26.27) |

Règle de saisie : la **date de livraison prévue est OBLIGATOIRE** au
moment de la planification (garde dans \_validerPlanification, écran
\_dessinerPlanification). Elle s'affiche ensuite dans la liste des
commandes (« 📅 Livraison prévue : … », ligne conditionnelle).

**18.5 Design figé (v26.25)**

Classes CSS dédiées, respectant le cadre couleur = sens :
.gestion-livr-\* (écran de livraison), .gestion-annul-\* (écran
d'annulation). Une seule action vive par écran, confirmation avant tout
impact argent/effectif — conformément au cadre de design boutons figé
v26.25.

**18.6 Amputation de l'ancien chemin « Vente » (v26.26 — anti
double-comptage)**

Une fois le CRM devenu le chemin de vente officiel, l'ancien écran de
vente devait cesser de produire des effets comptables, sinon chaque
vente serait comptée deux fois. **Deux effets ont été débranchés :**

6.  **Recette** — fonction \_enregistrerJournalVente (index.html) :
    l'ancien écran n'écrit plus de recette au journal. Il marque juste
    la tâche COMPTABILISEE, affiche un toast « Les ventes se gèrent
    maintenant dans les Commandes » et redirige. Ajout de
    .eq('ferme_id', FERME_ID) sur l'UPDATE tâche (isolation, absente
    avant).

7.  **Effectif vendu** — fonction \_soumettreAbattageAgent (index.html)
    : l'agent ne touche plus au compteur effectif_vendu de la bande. Il
    saisit toujours nb_sujets_reels (suivi terrain), mais l'effectif est
    désormais géré uniquement par la livraison CRM via livrer_commande.

Testé de bout en bout : ancien chemin = 0 recette, CRM = 1 recette avec
bénéficiaire rattaché à la bande. Confirmé.

**18.7 Renommage onglet « Vente » → « Abattage » (v26.28)**

Fonction renderCycleVie (index.html) : le label de l'onglet
id:'abattage' passe de « Vente » à « Abattage » (un seul mot changé).
**Décision de périmètre :** on n'a PAS touché la tuile « Vente » ni les
écrans renderPlanVente / \_renderTabAbattage — ils appartiennent au
circuit en voie d'extinction (remplacé par le CRM), inutile de les
renommer.

**18.8 Données de test CRM (référence)**

Vrai client des commandes : **67a139ea-9108-4f2e-b86b-0c7c07abbbcb** (⚠️
PAS 6b78a4a9 — ancien id erroné d'un vieux brief).

Produit test : Poulet entier abattu 96dec36b-19f0-4cb2-961d-682169b126b0
(unité kg, decremente_effectif = true).

Bande test : Bande-2026-999 33631a47-93c4-49d9-8771-45f8ee2d4278
(REVAGRO). Après tests d'abattage : restaurer effectif_vendu = 0 et
supprimer les tâches ABATTAGE de test.

**Note de mise à jour — Section 16.2 (découpage CRM)**

L'étape 2 du découpage CRM (« Livraison → vente → recette journal ») est
désormais **✅ Validé** — réalisée par le module CRM Commandes (voir
§18, RPC livrer_commande). Les étapes 3 à 6 (suivi paiements/créances,
export WhatsApp, écran Trésorerie/Caisse, mouvements hors-bande) restent
○ À faire.

**Mise à jour — Section 2.1 (version) et 2.5 (migrations)**

**Version actuelle : APP_VERSION = 'v26.28' · CACHE_NAME =
'avigest-v26-28'**.

Migrations ajoutées depuis v26.22 :

| **Fichier**                      | **Contenu**                                                                       |
|----------------------------------|-----------------------------------------------------------------------------------|
| 039_livrer_commande.sql          | RPC livrer_commande — livraison atomique CRM (effectif + recette + statut LIVREE) |
| 040_date_livraison_commandes.sql | ALTER TABLE commandes ADD COLUMN date_livraison_prevue date                       |

Dernière migration : **040**.

**Chantiers ouverts à la reprise (session v26.29)**

**🐛 Bouton « Forcer la déconnexion » ne libère pas le verrou** —
fonction \_forcerDeconnexion (index.html). Elle fait un DELETE sur
sessions_actives WHERE user_pin = window.\_pinSaisi. Or
window.\_pinSaisi n'est renseigné qu'APRÈS un login réussi — donc quand
on est bloqué à la porte (avant login), il vaut undefined et le DELETE
ne cible rien. Le verrou ne se lève jamais. Contournement actuel :
DELETE manuel en base. Piste : ne pas dépendre de window.\_pinSaisi
avant login (cibler par device_id, ou repenser le flux).

**🐛 Bug cosmétique score santé (balises \<strong\> brutes)** — toujours
ouvert, priorité moyenne (~5 min). Écran confirmation agent affiche «
\<strong\>BON\</strong\> » au lieu de BON en gras. Cause : esc() échappe
les balises dans \_renderSessionResume(). Correctif : retirer les
\<strong\>/\</strong\> (le CSS .rapport-ligne span:last-child gère déjà
le gras). Chercher « Santé du lot » dans index.html.

**🔒 Session RLS dédiée (§14.3)** — lever l'incertitude sur l'état RLS
réel de plusieurs tables (bandes, batiments, taches, lots_stock…).
Nécessite l'exécution en base des requêtes pg_policies / pg_tables.
Aucun correctif sans validation explicite d'Adama, patch par patch.

**🔒 Doublon de policy RLS sur la table clients** — à traiter dans la
session RLS (déjà noté en point en suspens n°8).

— Fin de la mise à jour Bible session v26.28 —

*— Fin de la Bible AviGest v26 — Version .md générée le 13/07/2026
(session v26.22), à répercuter manuellement dans le .docx —*
