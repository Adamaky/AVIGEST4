# ðŸ” AviGest v26

## Bible du Projet â€” Document de RÃ©fÃ©rence Permanent

*Version 26 â€” Adama DÃ©sirÃ© â€” Ouagadougou, Burkina Faso*

> **Synchronisation** : cette version `.md` est gÃ©nÃ©rÃ©e Ã  partir de `bible_avigest_v26.docx` â€” derniÃ¨re synchronisation le **10/07/2026 (session v26.21).**. Le `.docx` reste la rÃ©fÃ©rence unique pour toute modification manuelle ; ce fichier `.md` est une copie dÃ©rivÃ©e destinÃ©e Ã  Ãªtre lue par Claude Code depuis le repo GitHub, Ã  cÃ´tÃ© de `SCHEMA.md`. Ne jamais Ã©diter ce `.md` comme source â€” toujours rÃ©gÃ©nÃ©rer depuis le `.docx` Ã  jour.

------------------------------------------------------------------------

## 1. Contexte et Objectif

AviGest est une Progressive Web App (PWA) de gestion avicole Ã  Ouagadougou. Elle gÃ¨re un Ã©levage de poulets de chair sur plusieurs poulaillers, avec trois rÃ´les : gÃ©rant, agent, partenaires investisseurs.

**Contraintes clÃ©s :**

- Connexion variable â€” mode hors ligne prÃ©vu (non encore implÃ©mentÃ©)
- Agent peu familier avec le numÃ©rique â€” interface pavÃ© numÃ©rique, un champ Ã  la fois
- Backend : Supabase PostgreSQL + Realtime Â· Frontend : GitHub Pages Â· SDK local supabase.js

------------------------------------------------------------------------

## 2. Architecture Technique

### 2.1 URLs et Identifiants

| Ã‰lÃ©ment | Valeur |
|----|----|
| URL Frontend | https://adamaky.github.io/AVIGEST4/ |
| GitHub Repo | https://github.com/Adamaky/AVIGEST4 |
| Supabase URL | https://jzlmnpxcnrcajludtkpt.supabase.co |
| Supabase Project ID | jzlmnpxcnrcajludtkpt |
| Ferme ID (REVAGRO) | e56574a9-54c1-430d-b480-b9bdd1090dd7 |
| Ferme ID (ALIRAH2026) | 40ee764e-d073-463e-b07b-bf95a9d7a675 |
| Client Supabase | sb (toujours sb, jamais supabase) |
| SDK local | supabase.js ligne 17 (tÃ©lÃ©chargÃ© depuis unpkg.com) |
| Session | 12 heures Â· Avertissement 1h avant expiration |
| Fichier de travail | C:.html |
| **Version actuelle** | **APP_VERSION = â€˜v26.19â€™ Â· CACHE_NAME = â€˜avigest-v26-19â€™** |

### 2.2 Terminologie â€” Deux niveaux

| Terme visible (interface) | Terme technique (code) | Explication |
|----|----|----|
| Poulailler 1, 2â€¦ | Batiment-1, Batiment-2â€¦ | Salle dâ€™Ã©levage physique |
| Bande | bande / bande_id | Lot de poulets dans un poulailler |
| Agent | AGENT / role | Responsable terrain |
| Partenaire | PARTENAIRE / role | Investisseur |
| GÃ©rant | GERANT / role | Gestionnaire principal |

### 2.3 Format ID Bande

Format : `Bande-YYYY-NNN` (ex : `Bande-2026-001`)

- Regex de validation : `/^Bande-\d{4}-\d{3}$/`
- Auto-gÃ©nÃ©ration avec possibilitÃ© de saisie manuelle
- Soft-delete : toujours ajouter `.eq('``is_deleted``', false)` sur les requÃªtes bandes

### 2.4 Architecture Supabase â€” Tables principales

### 2.4 Architecture Supabase â€” Tables

### Liste exhaustive vÃ©rifiÃ©e en base le 11/07/2026 (session v26.22) â€” 18 tables. Toute nouvelle table doit Ãªtre ajoutÃ©e ici. Toute crÃ©ation de table doit Ãªtre prÃ©cÃ©dÃ©e d'une vÃ©rification en base (voir rÃ¨gle 4.1).

<table>
<colgroup>
<col style="width: 22%" />
<col style="width: 77%" />
</colgroup>
<thead>
<tr>
<th><h3 id="table">Table</h3></th>
<th><h3 id="rÃ´le">RÃ´le</h3></th>
</tr>
</thead>
<tbody>
<tr>
<td><h3 id="bandes">bandes</h3></td>
<td><h3 id="lots-de-poulets-id-ferme_id-nom-race-effectif_initial-date_arrivee-statut-is_deleted">Lots de poulets â€” id, ferme_id, nom, race, effectif_initial, date_arrivee, statut, is_deleted</h3></td>
</tr>
<tr>
<td><h3 id="batiments">batiments</h3></td>
<td><h3 id="poulaillers-physiques">Poulaillers physiques</h3></td>
</tr>
<tr>
<td><h3 id="clients">clients</h3></td>
<td><h3 id="crm-nom-telephone-adresse-type_client-note-actif-migration-035">CRM â€” nom, telephone, adresse, type_client, note, actif (Migration 035)</h3></td>
</tr>
<tr>
<td><h3 id="clotures">clotures</h3></td>
<td><h3 id="clÃ´tures-de-bande-module-v26.21">ClÃ´tures de bande (module v26.21)</h3></td>
</tr>
<tr>
<td><h3 id="commande_lignes">commande_lignes</h3></td>
<td><h3 id="crm-dÃ©tail-commande-1-ligne-1-produit-1-bande-migration-036">CRM â€” dÃ©tail commande : 1 ligne = 1 produit + 1 bande (Migration 036)</h3></td>
</tr>
<tr>
<td><h3 id="commandes">commandes</h3></td>
<td><h3 id="crm-en-tÃªte-bon-de-commande-migration-036">CRM â€” en-tÃªte bon de commande (Migration 036)</h3></td>
</tr>
<tr>
<td><h3 id="composants_lot">composants_lot</h3></td>
<td><h3 id="composition-des-lots-daliment-fabriquÃ©">Composition des lots d'aliment fabriquÃ©</h3></td>
</tr>
<tr>
<td><h3 id="config">config</h3></td>
<td><h3 id="paramÃ¨tres-applicatifs">ParamÃ¨tres applicatifs</h3></td>
</tr>
<tr>
<td><h3 id="croissance_standard">croissance_standard</h3></td>
<td><h3 id="courbes-de-rÃ©fÃ©rence-zootechniques-cobb-500">Courbes de rÃ©fÃ©rence zootechniques (Cobb 500)</h3></td>
</tr>
<tr>
<td><h3 id="fermes">fermes</h3></td>
<td><h3 id="tenants-une-ligne-par-ferme-cliente">Tenants â€” une ligne par ferme cliente</h3></td>
</tr>
<tr>
<td><h3 id="journal">journal</h3></td>
<td><h3 id="Ã©critures-comptables-depense-recette">Ã‰critures comptables â€” DEPENSE / RECETTE</h3></td>
</tr>
<tr>
<td><h3 id="lots_stock">lots_stock</h3></td>
<td><h3 id="lots-de-stock-cout_unitaire-gÃ©nÃ©rÃ©-categorie_cru-impute_journal">Lots de stock â€” cout_unitaire GÃ‰NÃ‰RÃ‰, categorie_cru, impute_journal</h3></td>
</tr>
<tr>
<td><h3 id="mouvements_stock">mouvements_stock</h3></td>
<td><h3 id="entree-sortie-de-stock">ENTREE / SORTIE de stock</h3></td>
</tr>
<tr>
<td><h3 id="paiements">paiements</h3></td>
<td><h3 id="crm-encaissements-rattachÃ©s-Ã -une-commande-migration-036">CRM â€” encaissements rattachÃ©s Ã  une commande (Migration 036)</h3></td>
</tr>
<tr>
<td><h3 id="partenaires_bandes">partenaires_bandes</h3></td>
<td><h3 id="quotes-parts-des-partenaires-investisseurs-par-bande">Quotes-parts des partenaires investisseurs par bande</h3></td>
</tr>
<tr>
<td><h3 id="produits_catalogue">produits_catalogue</h3></td>
<td><h3 id="crm-produits-vendables-migration-035">CRM â€” produits vendables (Migration 035)</h3></td>
</tr>
<tr>
<td><h3 id="rapports_hebdo">rapports_hebdo</h3></td>
<td><h3 id="rapports-hebdomadaires-agentgÃ©rant">Rapports hebdomadaires agent/gÃ©rant</h3></td>
</tr>
<tr>
<td><h3 id="saisies_techniques">saisies_techniques</h3></td>
<td><h3 id="saisies-agent-tempÃ©rature-hygromÃ©trie-mortalitÃ©...">Saisies agent (tempÃ©rature, hygromÃ©trie, mortalitÃ©...)</h3></td>
</tr>
<tr>
<td><h3 id="sessions_actives">sessions_actives</h3></td>
<td><h3 id="verrouillage-multi-appareils-rls-dÃ©sactivÃ©e-choix-documentÃ©-voir-14">Verrouillage multi-appareils â€” RLS dÃ©sactivÃ©e (choix documentÃ©, voir Â§14)</h3></td>
</tr>
<tr>
<td><h3 id="taches">taches</h3></td>
<td><h3 id="tÃ¢ches-planifiÃ©es">TÃ¢ches planifiÃ©es</h3></td>
</tr>
<tr>
<td><h3 id="utilisateurs">utilisateurs</h3></td>
<td><h3 id="comptes-pin-bcrypt-via-verifier_pin">Comptes â€” PIN bcrypt via verifier_pin()</h3></td>
</tr>
</tbody>
</table>

### âš ï¸ Tables supprimÃ©es en v26.22 : ventes et paiements (ancienne version) existaient en base sans Ãªtre documentÃ©es. Vides (0 ligne), aucune occurrence dans index.html. ModÃ¨le incompatible (1 vente = 1 seul produit). SupprimÃ©es par la Migration 036, remplacÃ©es par commandes + commande_lignes + paiements (nouveau modÃ¨le).

### 2.5 Migrations SQL â€” GitHub

| Fichier | Contenu |
|----|----|
| 001_schema_initial.sql | Tables de base : bandes, saisies_techniques, taches, journal |
| 002_stock_tables.sql | Tables lots_stock et mouvements_stock |
| 003_rls_policies.sql | Politiques RLS sur les 14 tables |
| 004_get_ferme_id_fix.sql | Correction SECURITY DEFINER + cast JSON sur get_ferme_id() |
| 005_imputer_aliment_rpc.sql | RPC imputer_aliment() â€” imputation atomique stock depuis sessions agent |
| 006_stock_dashboard_rpc.sql | RPC pour vue stock dashboard gÃ©rant |
| â€¦ | (migrations suivantes numÃ©rotÃ©es jusquâ€™Ã  030 â€” voir dossier migrations/ du repo) |

------------------------------------------------------------------------

## 3. Utilisateurs et RÃ´les

| RÃ´le | Limite | PIN actuel | AccÃ¨s |
|----|----|----|----|
| GERANT | Max 2 | 0000 (Adama) | Tout â€” supervision, planif, compta, poulaillers, stock, rapports |
| AGENT | Max 2 | 1111 (Agent Ferme) | Terrain â€” sessions, saisies, tÃ¢ches |
| PARTENAIRE | IllimitÃ© | PIN individuel | Ses bandes â€” rÃ©sultats, Ã©tat lot, crÃ©ances |

> PIN stockÃ© en bcrypt via RPC `verifier_pin``()` (colonne PIN en clair supprimÃ©e â€” Migration 028).

------------------------------------------------------------------------

## 4. RÃ¨gles Techniques Critiques

### 4.1 RÃ¨gles Supabase

- Client toujours nommÃ© `sb` â€” jamais `supabase`
- Header `x-ferme-id` injectÃ© globalement Ã  la crÃ©ation du client (ligne 427)
- RLS active sur toutes les tables sauf `sessions_actives`
- `get_ferme_id``()` avec SECURITY DEFINER â€” retourne lâ€™ID ferme depuis le header
- Statelessness REST : `set_config` ne persiste pas entre requÃªtes â€” utiliser le header global
- Avant tout INSERT : vÃ©rifier colonnes NOT NULL, defaults, et colonnes gÃ©nÃ©rÃ©es
- `cout_unitaire` dans `lots_stock` est une colonne GÃ‰NÃ‰RÃ‰E â€” ne jamais lâ€™inclure dans un INSERT
- `lots_stock.produit` : noms complets (ex : â€˜Aliment de dÃ©marrageâ€™) â€” chercher avec `LOWER(produit) LIKE`
- `mouvements_stock.type_mouvement` : uniquement â€˜ENTREEâ€™ ou â€˜SORTIEâ€™
- `SET LOCAL ``row_security`` = off` dans les RPCs SECURITY DEFINER qui interrogent `utilisateurs`, pour bypasser RLS
- Appeler `extensions.crypt``()` et non `crypt``()` â€” pgcrypto est dans le schÃ©ma extensions
- **Toute opÃ©ration DELETE/UPDATE sur une table sans RLS (ex:** `sessions_actives`**) doit systÃ©matiquement filtrer par** `ferme_id` **cÃ´tÃ© client â€” leÃ§on de lâ€™audit sÃ©curitÃ© v26.18 (voir section 14)**

> Avant toute crÃ©ation de table : vÃ©rifier qu'elle n'existe pas dÃ©jÃ  en base.
>
> SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;
>
> LeÃ§on session v26.22 : les tables ventes et paiements existaient en base sans figurer dans la Bible. La Migration 036 a Ã©chouÃ© sur relation "paiements" already exists. La documentation ne suffit pas â€” **la base est la seule vÃ©ritÃ©**. Corollaire du principe Â« diagnostic avant de coder Â».

- **Une migration SQL est transactionnelle** : si une instruction Ã©choue, TOUT est annulÃ©, y compris les instructions dÃ©jÃ  passÃ©es. Aucun Ã©tat intermÃ©diaire n'est possible.

### 4.2 RÃ¨gles JavaScript

- Apostrophes dans les chaÃ®nes JS : toujours Ã©chapper avec `\'` ou utiliser des guillemets doubles
- Ne jamais imbriquer des template literals dans `.``map``()` â€” utiliser la concatÃ©nation
- `&``quot``;` au lieu dâ€™apostrophes dans les attributs onclick inline
- `node`` --check` Ã©choue sur les fichiers `.html` â€” utiliser la commande PowerShell dâ€™extraction JS
- jsDelivr CDN inaccessible depuis le Burkina Faso â€” utiliser unpkg.com ou le fichier local

### 4.3 RÃ¨gles de travail

- Fichier unique : `C:\Users\kyada\Documents\GitHub\AVIGEST4\index.html`
- Workflow : VS Code â†’ Claude Code â†’ vÃ©rification syntaxe PowerShell â†’ GitHub Desktop â†’ Push
- Chaque modification SQL = un nouveau fichier de migration numÃ©rotÃ© dans `migrations/`
- `APP_VERSION` (ligne ~463 index.html) mis Ã  jour EN MÃŠME TEMPS que `CACHE_NAME` (ligne 9 sw.js) Ã  chaque session â€” format `'v26.XX'`
- SÃ©lectionner â€˜Yes, allow all edits this sessionâ€™ dans Claude Code pour les sessions multi-patches
- VÃ©rification aprÃ¨s patch : commandes `Ctrl+Shift+F` avec nombre dâ€™occurrences attendu
- **Un seul changement par patch** â€” ne jamais mixer des modifications non liÃ©es dans un mÃªme commit (leÃ§on B6/isolation stricte)
- **SÃ©quence de vÃ©rification stricte (confirmÃ©e v26.18)** : Ã©dition â†’ `node`` --check` (confirmation explicite du rÃ©sultat, ne jamais supposer que câ€™est fait) â†’ diff GitHub Desktop complet â†’ incrÃ©ment version si dernier changement de la session â†’ commit avec message combinÃ© (version + description)

**RÃˆGLE STOCK â€” Deux types de lots**

Avant tout INSERT `lots_stock`, vÃ©rifier le flag `impute_journal` (BOOLEAN) : - `true` : RPC dÃ©clenche Ã©criture journal - `false` : RPC dÃ©crÃ©mente stock uniquement, pas dâ€™Ã©criture journal

**RÃˆGLE CRU â€” Filtre catÃ©gories charges consommÃ©es (dÃ©finitive, ne pas modifier)**

    CRU = SUM(montant) WHERE type_ecriture = 'DEPENSE' 
                        AND categorie != 'Achat stock'
          / effectif_vivants

Filtre par **exclusion**, pas par liste fermÃ©e. La litiÃ¨re (comme tout produit avec `impute_journal`` = ``true`) entre correctement dans le CRU via ce filtre â€” ne jamais ajouter de catÃ©gorie spÃ©cifique au filtre, lâ€™exclusion `!= 'Achat stock'` suffit et gÃ¨re tout automatiquement.

**RÃˆGLE JOURNAL â€” CatÃ©gories prÃ©dÃ©finies (v2)**

Charges consommÃ©es (CRU) : - Alimentation (auto RPC) - Vaccin [type + unitÃ© + qtÃ© + PU] - MÃ©dicament [type + unitÃ© + qtÃ© + PU] - LitiÃ¨re [type + unitÃ© + qtÃ© + PU] â€” traitÃ©e comme lâ€™aliment (Type A)

Charges exploitation (hors CRU par exclusion, mais toujours DEPENSE) : - Salaire [forfait ou qtÃ©Ã—PU] - Prestation de service [forfait ou qtÃ©Ã—PU] - Transport [forfait ou qtÃ©Ã—PU] - Glace [forfait ou qtÃ©Ã—PU] - Autre [texte libre + montant]

Hors charges (mouvement stock, jamais dans le CRU) : - Achat stock [liÃ© Ã  lots_stock]

------------------------------------------------------------------------

## 5. Score SantÃ© â€” RÃ¨gle de Calcul

ValidÃ© session 18 juin 2026 â€” Cobb 500, Ouagadougou, J14+

| ParamÃ¨tre        | Bon ðŸŸ¢    | Passable ðŸŸ¡ | Mauvais ðŸ”´     |
|------------------|-----------|-------------|----------------|
| TempÃ©rature (Â°C) | 26â€“32Â°C   | 33â€“35Â°C     | <26 ou >35Â°C |
| HygromÃ©trie (%)  | 50â€“70%    | 71â€“80%      | <50 ou >80%  |
| MortalitÃ©/jour   | 0â€“2 morts | 3â€“5 morts   | >5 morts      |

**RÃ¨gle de calcul : Score final = le PIRE des 3 scores individuels**

Surcharge manuelle : lâ€™agent peut modifier le score calculÃ© + saisir une note explicative

> **Bug cosmÃ©tique (v26.17, toujours non rÃ©solu, prioritÃ© moyenne)** : Ã©cran de confirmation agent affiche le score santÃ© avec balises HTML brutes (`<``strong``>BON</``strong``>` au lieu de **BON** en gras). Cause : la fonction `esc()` Ã©chappe les balises `<``strong``>` volontairement insÃ©rÃ©es dans `_``renderSessionResume``()`. Correctif prÃªt (retrait de `<``strong``>`/`</``strong``>`, le CSS `.rapport-ligne ``span:last-child` gÃ¨re dÃ©jÃ  le gras) â€” non encore appliquÃ©. EstimÃ© 5 minutes.

------------------------------------------------------------------------

## 6. Module Stock â€” Architecture complÃ¨te (CHANTIER CLOS â€” v26.18)

**TYPE DE LOT STOCK**

**Type A â€” Avec imputation journal (charge)** - â†’ Aliment, Vaccin, MÃ©dicament, LitiÃ¨re - â†’ DÃ©crÃ©mente stock + Ã©criture journal auto - â†’ Entre dans le CRU (sauf catÃ©gorie â€œAchat stockâ€)

**Type B â€” Sans imputation journal** - â†’ Produits crÃ©Ã©s par le gÃ©rant avec `impute_journal`` = false` - â†’ DÃ©crÃ©mente stock uniquement - â†’ Nâ€™entre PAS dans le CRU

**FLAG sur lots_stock (implÃ©mentÃ©) :**

    impute_journal BOOLEAN DEFAULT false
    categorie_cru TEXT (v26.16) â€” catÃ©gorie comptable du lot,
      lue en prioritÃ© par imputer_stock(), avec repli sur
      l'ancien CASE (nom produit) si NULL

**Imputation gÃ©nÃ©rique multi-produits depuis sessions agent (confirmÃ© v26.18) :** Lâ€™Ã©tape `stock_autres` (Â« Autres produits utilisÃ©s Â») est prÃ©sente dans les 4 sessions agent (Matin/Midi/PM/Nuit), pas seulement Matin. Elle liste tout lot dont le produit nâ€™est pas lâ€™aliment (`.not('produit', '``ilike``', '%aliment%')`) et impute chaque quantitÃ© saisie via `imputer_stock``()` â€” mÃ©canisme gÃ©nÃ©rique, non cÃ¢blÃ© spÃ©cifiquement pour un produit donnÃ©. TestÃ© en conditions rÃ©elles avec deux produits distincts, flux complet jusquâ€™Ã  validation gÃ©rant (EN_ATTENTE â†’ CONFIRME) confirmÃ© pour les deux : - **LitiÃ¨re** â€” B8, testÃ© 01/07/2026 - **MÃ©dicament** â€” testÃ©, session v26.18 (02/07/2026)

Le vaccin nâ€™a pas fait lâ€™objet dâ€™un test terrain distinct, mais utilise exactement le mÃªme mÃ©canisme gÃ©nÃ©rique que la litiÃ¨re et le mÃ©dicament â€” risque de comportement diffÃ©rent jugÃ© trÃ¨s faible.

### Ã‰TAPES MODULE STOCK

| Ã‰tape | Statut |
|----|----|
| Ã‰tape 1 â€” SchÃ©ma SQL | âœ… ValidÃ© |
| Ã‰tape 2 â€” Interface crÃ©ation lot | âœ… ValidÃ© |
| Ã‰tape 3 â€” Imputation auto sessions agent | âœ… ValidÃ© |
| Ã‰tape 4 â€” Vue stock dashboard gÃ©rant | âœ… ValidÃ© |
| Ã‰tape 5 â€” Validation gÃ©rant alimentation | âœ… ValidÃ© â€” mÃ©canisme EN_ATTENTE + Ã©cran validation gÃ©rant opÃ©rationnel |
| Ã‰tape 6 â€” RPC litiÃ¨re (Type A, alignÃ©e aliment) | âœ… ValidÃ© â€” Migration 029, testÃ© en conditions rÃ©elles 01/07/2026 |
| Ã‰tape 7 â€” Formulaire dÃ©pense enrichi | âœ… ValidÃ© â€” confirmÃ© session v26.18, `renderNouvelleEcriture``()` avec `<``optgroup``>` Charges CRU / Mouvement stock, mode QtÃ©Ã—PU |
| Ã‰tape 8 â€” CRU filtrÃ© charges consommÃ©es | âœ… ValidÃ© â€” confirmÃ© session v26.18, filtre `categorie`` !== 'Achat stock'` prÃ©sent et cohÃ©rent Ã  3 endroits du code |
| Imputation multi-produits (litiÃ¨re/vaccin/mÃ©dicament) depuis sessions agent | âœ… ValidÃ© â€” confirmÃ© session v26.18, voir dÃ©tail ci-dessus |

**Le module Stock est dÃ©sormais entiÃ¨rement clos â€” zÃ©ro item ouvert.**

------------------------------------------------------------------------

## 13. Tableau de Suivi â€” Outil Permanent du Non-Codeur

Cette section est la mÃ©moire vivante du projet. Claude la lit Ã  chaque session pour savoir oÃ¹ en est le projet sans quâ€™Adama ait besoin de tout rÃ©expliquer.

### 13.1 LÃ©gende des Statuts

| Statut | Signification | Action suivante |
|----|----|----|
| âœ… ValidÃ© | TestÃ© sur lâ€™app et confirmÃ© fonctionnel | Passer Ã  la prochaine fonctionnalitÃ© |
| â³ En cours | Code produit mais pas encore testÃ© | Tester sur https://adamaky.github.io/AVIGEST4/ |
| ðŸ› Bug | TestÃ© â€” comportement incorrect observÃ© | DÃ©crire le bug prÃ©cis Ã  Claude |
| â—‹ Ã€ faire | Pas encore commencÃ© | Briefer Claude quand câ€™est la prioritÃ© |
| â˜ï¸ SaaS | FonctionnalitÃ© prÃ©vue multi-fermes | Ã€ planifier aprÃ¨s stabilisation v1 |
| â¹ï¸ AbandonnÃ© | DÃ©cision dÃ©finitive de ne pas traiter | Aucune â€” ne jamais rouvrir sans demande explicite dâ€™Adama |

### 13.2 Tableau de Suivi des FonctionnalitÃ©s

**FONDATIONS**

| FonctionnalitÃ© | Statut | Note / Bug connu |
|----|----|----|
| Login PIN + session 12h | âœ… ValidÃ© | TestÃ© PIN 0000 â†’ OK |
| Verrouillage multi-appareils | âœ… ValidÃ© | Table sessions_actives + device fingerprint |
| Ã‰cran blocage session concurrente | âœ… ValidÃ© | Ex-B2 â€” Ã©cran dÃ©diÃ© screen-blocage (au lieu dâ€™injection dans app-main cachÃ©) |
| Bouton Forcer dÃ©connexion | âœ… ValidÃ© | Ex-B9 â€” role passÃ© en paramÃ¨tre, corrige dÃ©pendance circulaire localStorage |
| SystÃ¨me de navigation Nav | âœ… ValidÃ© | Bug pavÃ© PIN corrigÃ© |
| **Correctif RLS â€” sessions_actives DELETE cross-tenant** | **âœ… ValidÃ©** | **v26.19 â€” filtre** `.eq('``ferme_id``', FERME_ID)` **ajoutÃ©, voir section 14** |
| Mode hors ligne + sync auto | â—‹ Ã€ faire | Queue localStorage Ã  implÃ©menter |
| Notifications OneSignal | â—‹ Ã€ faire | GÃ©rÃ© en arriÃ¨re-plan |

**AGENT**

| FonctionnalitÃ© | Statut | Note / Bug connu |
|----|----|----|
| Tuiles sessions dans onglet TÃ¢ches | âœ… ValidÃ© | 4 sessions : Matin/Midi/PM/Nuit |
| Session Matin â€” 6 Ã©tapes | âœ… ValidÃ© | PavÃ© numÃ©rique fonctionnel |
| Session Midi â€” 3 Ã©tapes | âœ… ValidÃ© | TestÃ© 18/06/2026 |
| Session PM â€” 3 Ã©tapes | âœ… ValidÃ© | TestÃ© 18/06/2026 |
| Session Nuit â€” 4 Ã©tapes | âœ… ValidÃ© | TestÃ© 18/06/2026 |
| Score santÃ© â€” calcul auto | â¹ï¸ AbandonnÃ© | Ex-B1 : â€œScore undefinedâ€ â€” dÃ©cision dÃ©finitive dâ€™Adama (session v26.18) de ne pas traiter, non prioritaire. Distinct du bug cosmÃ©tique `<``strong``>` (voir section 5), toujours actif celui-lÃ  |
| Score santÃ© â€” surcharge manuelle | â—‹ Ã€ faire | PrÃ©vu : bouton Bon/Passable/Mauvais + note agent |
| Blocage sessions hors plage horaire | âœ… ValidÃ© | Ex-B3 â€” confirmÃ© implÃ©mentÃ© dans `renderSession``()` : plages par session (Matin 5h-10h, Midi 10h-14h, PM 14h-19h, Nuit 19h-5h), double protection (bouton dÃ©sactivÃ© + re-vÃ©rification fonction) |
| Ã‰cran abattage â€” 3 Ã©tapes | â—‹ Ã€ faire | Calcul poids moyen auto |

**GÃ‰RANT**

| FonctionnalitÃ© | Statut | Note / Bug connu |
|----|----|----|
| Accueil gÃ©rant â€” navigation | âœ… ValidÃ© | ACCUEIL Â· BANDES Â· ANALYSES |
| Onglet TÃ¢ches gÃ©rant | âœ… ValidÃ© | Ex-B4 â€” confirmÃ© rÃ©solu (termineesHTML dÃ©clarÃ©e) ; collision historique de numÃ©rotation avec un autre B4 citÃ© ailleurs restÃ©e non Ã©claircie mais sans impact pratique â€” voir Points en suspens |
| Planifier tÃ¢ches agent | âœ… ValidÃ© | 3 types : Quotidienne Â· Hebdomadaire Â· Abattage |
| Journal comptable | âœ… ValidÃ© | DÃ©penses + Recettes + CRU/sujet |
| Analyses â€” zootechnie | âœ… ValidÃ© | Ex-B5 : Poids moyen et IC â€” confirmÃ© rÃ©solu par Adama (testÃ©/observÃ© rÃ©cemment, session v26.18) |
| Analyses â€” finance | âœ… ValidÃ© | Marge nette Â· DÃ©penses Â· Recettes |
| Planifier abattage | âœ… ValidÃ© | Formulaire Date + Nb sujets + Client cible |
| Rapports hebdomadaires | â³ En cours | Ã€ tester prochaine session |
| Rapport fin de bande + WhatsApp | âœ… ValidÃ© | Export texte structurÃ© (fermÃ© v26.9) |
| Gestion utilisateurs | â—‹ Ã€ faire | CrÃ©er / activer / dÃ©sactiver |

**STOCK**

Voir section 6 â€” module entiÃ¨rement clos (8 Ã©tapes + imputation multi-produits, toutes âœ… ValidÃ©).

**PARTENAIRE**

| FonctionnalitÃ©                  | Statut    | Note / Bug connu        |
|---------------------------------|-----------|-------------------------|
| Interface partenaire â€” 3 tuiles | â—‹ Ã€ faire | FiltrÃ© par idPartenaire |
| Assignation quotes-parts        | â—‹ Ã€ faire | Total â‰¤ 100%            |

**PROCESSUS**

| FonctionnalitÃ©                 | Statut    | Note / Bug connu         |
|--------------------------------|-----------|--------------------------|
| ClÃ´ture bande â€” 6 phases       | â—‹ Ã€ faire | 14 jours minimum         |
| Fabrication aliment            | â—‹ Ã€ faire | Lignes dynamiques        |
| Alertes automatiques in-app    | â—‹ Ã€ faire | 7 KPI configurÃ©s         |
| Abattage progressif â€” 6 Ã©tapes | â—‹ Ã€ faire | Plan â†’ Exec â†’ Validation |

**VISION SAAS**

| FonctionnalitÃ© | Statut | Note / Bug connu | SaaS |
|----|----|----|----|
| Multi-fermes (multi-tenant) | âœ… ValidÃ© | 2 fermes actives (REVAGRO, ALIRAH2026), 3e client en cours dâ€™intÃ©gration â€” chaque ferme = espace isolÃ© | â˜ï¸ |
| Authentification sÃ©curisÃ©e SaaS | â—‹ Ã€ faire | PIN â†’ tokens JWT ou Ã©quivalent | â˜ï¸ |
| Plans tarifaires (Free / Pro) | â—‹ Ã€ faire | Gestion abonnements | â˜ï¸ |
| Dashboard gÃ©rant SaaS | â—‹ Ã€ faire | Vue de toutes les fermes | â˜ï¸ |
| Onboarding nouvelle ferme | â—‹ Ã€ faire | Option A : intÃ©grÃ© (pas subdomain) | â˜ï¸ |

### 13.3 Registre des bugs (crÃ©Ã© session v26.18)

Registre centralisÃ© transversal, source unique de numÃ©rotation des bugs. Les tableaux de section (AGENT, GÃ‰RANT, etc.) ci-dessus restent la rÃ©fÃ©rence de lecture rapide, mais tout nouveau bug dÃ©tectÃ© Ã  partir de maintenant doit Ãªtre numÃ©rotÃ© ici en premier.

**RÃ¨gles Ã©tablies (session v26.18) :** - NumÃ©rotation strictement croissante, jamais rÃ©utilisÃ©e, identique dans tous les documents (Bible + mÃ©moire de session) - Sync Bible dÃ©clenchÃ©e proactivement par Claude dÃ¨s quâ€™une ligne passe Ã  âœ… ValidÃ© (granularitÃ© fine, pas dâ€™attente de fin de chantier) â€“

*Â« B10 fermÃ© en v26.21. Prochain numÃ©ro disponible : B11. Â»*

| **NumÃ©ro** | **Titre court** | **Domaine** | **Statut** | **Session ouverture** | **Session fermeture** |
|----|----|----|----|----|----|
| B10 | Statut 'TERMINEE' invalide (â†’ 'CLOTURE') | ClÃ´ture | âœ… FermÃ© | v26.18 | v26.21 |

### 13.4 Protocole de Brief de Session

Avant chaque session avec Claude, Adama colle ce bloc en dÃ©but de message :

    ðŸ“‹ BRIEF SESSION AVIGEST v26

    Objectif du jour : [une phrase]
    DerniÃ¨re chose validÃ©e : [fonctionnalitÃ©]
    Bug en suspens : [description ou 'Aucun']

### 13.5 Multi-fermes â€” Ã‰tat actuel et Feuille de Route SaaS

**Ã‰TAT ACTUEL (production) :**

AviGest gÃ¨re aujourdâ€™hui 2 fermes actives sur une architecture multi-tenant dÃ©jÃ  fonctionnelle : un seul frontend GitHub Pages, sÃ©lection de ferme via code dâ€™accÃ¨s au login (Ã©cran-code-ferme), isolation des donnÃ©es par `ferme_id` + header `x-ferme-id` + RLS Supabase.

- â†’ REVAGRO (ferme_id : e56574a9-54c1-430d-b480-b9bdd1090dd7)
- â†’ ALIRAH2026 (ferme_id : 40ee764e-d073-463e-b07b-bf95a9d7a675)

**EN COURS Dâ€™ENGAGEMENT :**

Un 3e client est actuellement en cours dâ€™intÃ©gration sur cette mÃªme architecture. DÃ©tails Ã  prÃ©ciser dans une prochaine mise Ã  jour de la Bible.

**VISION SAAS (extension future au-delÃ  des clients dÃ©jÃ  engagÃ©s) :**

La vision SaaS plus large (accueil de clients externes non encore identifiÃ©s, abonnements, dashboard central multi-fermes) reste documentÃ©e ici pour que chaque fonctionnalitÃ© v1 soit conÃ§ue de faÃ§on compatible. Ne pas commencer le chantier SaaS Ã©largi avant que les sections Fondations, Agent et GÃ©rant soient toutes Ã  statut ValidÃ©.

| PrÃ©-requis SaaS Ã©largi | Condition de dÃ©marrage |
|----|----|
| v1 stable | ZÃ©ro bug ouvert en Fondations + Agent + GÃ©rant + Stock â€” **Stock atteint ce seuil depuis la session v26.18** |
| Architecture multi-tenant | âœ… DÃ©jÃ  en place et validÃ©e en production (2 fermes actives) |
| Authentification sÃ©curisÃ©e | Remplacer PIN seul par token JWT avec expiration |
| Plans tarifaires | DÃ©finir Free (1 poulailler) vs Pro (6+ poulaillers) |
| Onboarding | Option A : Ã©cran onboarding intÃ©grÃ© â€” pas de subdomains par ferme |
| Client(s) au-delÃ  des 3 dÃ©jÃ  engagÃ©s | Cible : dÃ©but janvier 2027 |

------------------------------------------------------------------------

## 14. SÃ©curitÃ© â€” Ã‰tat et Audit (nouvelle section, session v26.18)

### 14.1 Chantiers sÃ©curitÃ© fermÃ©s (historique)

S1-S4 â€” voir version prÃ©cÃ©dente de la Bible : protection brute force PIN, hachage bcrypt, erreurs contextuelles showToast, fetch natif remplaÃ§ant sbTemp. Tous validÃ©s v26.9/v26.10.

### 14.2 Audit RLS â€” session v26.18 (via Claude Code)

Premier audit structurÃ© de sÃ©curitÃ© RLS effectuÃ© le 02/07/2026. MÃ©thode : analyse exhaustive du code JS (`index.html`) pour repÃ©rer les opÃ©rations sans filtre `ferme_id` ; accÃ¨s direct aux policies RLS rÃ©elles en base non disponible dans cette passe (nÃ©cessite Supabase Studio/psql).

**Point CRITIQUE confirmÃ© et corrigÃ© :** - `sessions_actives` â€” RLS dÃ©sactivÃ©e (choix documentÃ©) + un DELETE cross-tenant sans filtre `ferme_id` trouvÃ© ligne ~1739 (`doLogin``()`, nettoyage sessions expirÃ©es). **CorrigÃ© v26.19** : ajout de `.eq('``ferme_id``', FERME_ID)`. Commit : `"v26.19 - Fix RLS gap: DELETE ``sessions_actives`` sans filtre ``ferme_id`` (audit sÃ©curitÃ© v26.18)"`. - Limite du correctif : protÃ¨ge contre lâ€™erreur applicative cÃ´tÃ© code lÃ©gitime, mais ne remplace pas une policy RLS rÃ©elle â€” un accÃ¨s direct via devtools/clÃ© anon pourrait thÃ©oriquement encore contourner ce filtre tant que RLS reste dÃ©sactivÃ©e sur cette table.

**Points restÃ©s CONDITIONNELS (Ã©tat RLS rÃ©el non vÃ©rifiÃ©) :**

| Table | Filtre ferme_id cÃ´tÃ© code | Risque si RLS off | Exemple |
|----|----|----|----|
| bandes | Partiel â€” ~20 opÃ©rations sans ferme_id, dont des UPDATE/DELETE par id seul | ðŸ”´ Ã‰levÃ© | Soft-delete bande, changement statut, par id seul |
| batiments | Absent â€” 4 UPDATE par id seul | ðŸ”´ Ã‰levÃ© | Changement statut poulailler par id seul |
| taches | Partiel â€” ~10 opÃ©rations sans ferme_id | ðŸŸ  Moyen-Ã©levÃ© | Marquer tÃ¢che exÃ©cutÃ©e par id seul |
| lots_stock / mouvements_stock | Absent sur SELECT/UPDATE dÃ©tail | ðŸŸ  Moyen | DÃ©tail lot, historique mouvements par id seul |
| RPCs (`get_dashboard`, `imputer_stock`, `valider_imputation_gerant`) | Pas de ferme_id explicite en paramÃ¨tre | Inconnu â€” dÃ©pend de la vÃ©rification interne SQL | Ã€ lire directement en base |
| utilisateurs | Absent â€” UPDATE last_login par id seul | ðŸŸ¡ Faible | Impact mÃ©tier faible |
| partenaires_bandes | Absent â€” SELECT par utilisateur_id seul | ðŸŸ¡ Faible | Pertinent si un utilisateur multi-fermes existe un jour |

**Tables jugÃ©es saines (filtre ferme_id systÃ©matique cÃ´tÃ© code) :** journal, rapports_hebdo, composants_lot, vue_stock_actuel.

### 14.3 Session RLS dÃ©diÃ©e â€” programmÃ©e, non planifiÃ©e dans le temps

**Objectif** : lever lâ€™incertitude sur lâ€™Ã©tat RLS rÃ©el des tables listÃ©es ci-dessus. NÃ©cessite lâ€™exÃ©cution directe en base (Supabase Studio ou psql) des requÃªtes suivantes :

    SELECT schemaname, tablename, rowsecurity FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;
    SELECT schemaname, tablename, policyname, cmd, roles, qual, with_check FROM pg_policies WHERE schemaname = 'public' ORDER BY tablename, policyname;
    SELECT routine_name, routine_definition FROM information_schema.routines
    WHERE routine_schema = 'public' AND routine_name IN ('get_dashboard','imputer_stock','valider_imputation_gerant','get_ferme_id','verifier_pin');

Une fois ces rÃ©sultats obtenus, les points conditionnels du tableau 14.2 deviendront des diagnostics fermes, exploitables pour prioriser dâ€™Ã©ventuels correctifs. **Aucun correctif ne doit Ãªtre appliquÃ© avant validation explicite dâ€™Adama, patch par patch, comme pour le point sessions_actives.**

------------------------------------------------------------------------

## Points en suspens (Ã  clarifier avec Adama)

1.  **~~Collision de numÃ©rotation B1~~** â€” **RefermÃ© session v26.18.** B1 â€œscore santÃ©â€ passÃ© au statut â¹ï¸ AbandonnÃ©, dÃ©cision dÃ©finitive dâ€™Adama.
2.  **B4** â€” collision historique entre deux mentions du mÃªme numÃ©ro reste non Ã©claircie (un B4 â€œcorrigÃ© 18/06â€ dans GÃ‰RANT vs un B4 parfois citÃ© en basse prioritÃ© ailleurs), **mais sans consÃ©quence pratique** : le comportement fonctionnel est confirmÃ© rÃ©solu par Adama (session v26.18). Point purement historique, non bloquant.
3.  **Bug cosmÃ©tique score santÃ©** (balises `<``strong``>` brutes) : toujours non rÃ©solu, prioritÃ© moyenne â€” voir section 5. Le blocage technique prÃ©cÃ©dent (â€œ0 changed filesâ€ GitHub Desktop) nâ€™a pas Ã©tÃ© creusÃ© ; Ã  la reprise, vÃ©rifier dâ€™abord la sauvegarde (Ctrl+S) avant de retenter lâ€™Ã©dition.
4.  **CohÃ©rence .md/.docx** : cette version .md (v26.18) doit Ãªtre rÃ©percutÃ©e manuellement par Adama dans le `.docx`, qui reste lâ€™unique source. AprÃ¨s Ã©dition du `.docx`, il faudra confirmer avec Adama sâ€™il souhaite une rÃ©gÃ©nÃ©ration .md Ã  committer dans le repo GitHub, Ã  cÃ´tÃ© de SCHEMA.md.
5.  **Prochaine prioritÃ© de dÃ©veloppement** : Ã  redÃ©finir. Le chantier initialement annoncÃ© comme â€œprioritÃ© hauteâ€ (imputation multi-produits stock) est en rÃ©alitÃ© dÃ©jÃ  clos (voir section 6). Restent en attente : bug cosmÃ©tique score santÃ© (prioritÃ© moyenne, 5 min), session RLS dÃ©diÃ©e (section 14.3), verrou session agent non dÃ©blocable Ã  distance par le gÃ©rant (limitation connue, chantier futur), mode offline et dashboard SaaS (vision long terme).

------------------------------------------------------------------------

**15. Module ClÃ´ture de Bande (CHANTIER CLOS â€” v26.21)**

Le module clÃ´ture permet au gÃ©rant de terminer dÃ©finitivement une bande : archiver son statut, valoriser le stock restant, libÃ©rer le bÃ¢timent et gÃ©nÃ©rer un rapport final. Architecture en **6 phases**, fonction principale renderClotureBande(bandeId).

ðŸ’¡ *En clair : c'est l'Ã©tape Â« fin de cycle Â». Quand les poulets sont partis, le gÃ©rant clÃ´ture la bande â€” l'app fait le bilan, remet le poulailler Ã  disposition, et fige les chiffres.*

**15.1 Les 6 phases**

| **Phase** | **RÃ´le** | **Statut** |
|----|----|----|
| Phase 1 â€” Ã‰ligibilitÃ© | VÃ©rifie l'anciennetÃ© (14 jours minimum) et le statut clÃ´turable | âœ… ValidÃ© |
| Phase 2 â€” Effectif final | Affiche l'effectif restant, avec correction manuelle possible (colonnes effectif_final_corrige, effectif_final_note â€” migration 032) | âœ… ValidÃ© |
| Phase 3 â€” Reliquat stock | Valorise le stock restant en Ã©criture RECETTE (catÃ©gorie 'Reliquat stock') | âœ… ValidÃ© |
| Phase 4 â€” Bilan financier | 5 lignes lues depuis get_dashboard : recettes, dÃ©penses, CRU, marge nette, reliquat estimÃ© | âœ… ValidÃ© |
| Phase 5 â€” Validation PIN gÃ©rant | PavÃ© PIN dÃ©diÃ©, contrÃ´le serveur via verifier_pin (rÃ´le GERANT) | âœ… ValidÃ© |
| Phase 6 â€” Archivage + libÃ©ration | Passe la bande en 'CLOTURE' et libÃ¨re le bÃ¢timent ('LIBRE') | âœ… ValidÃ© |

**15.2 Migrations associÃ©es**

| **Migration** | **Contenu** |
|----|----|
| 032 | Colonnes effectif_final_corrige, effectif_final_note sur bandes (correction manuelle de l'effectif final) |
| 033 | RPC cloturer_phase3_reliquat â€” Ã©crit l'Ã©criture RECETTE du reliquat stock |
| 034 | RPC calculer_reliquat_stock â€” calcul en lecture seule pour l'affichage (ne modifie rien) |

**15.3 RÃ¨gle reliquat â€” hors CRU**

Le reliquat stock est enregistrÃ© comme une **RECETTE** (pas une dÃ©pense). Il reste donc automatiquement **hors CRU** (le CRU ne compte que les DEPENSE hors 'Achat stock'). Aucun filtre spÃ©cial nÃ©cessaire.

ðŸ’¡ *En clair : le stock qui reste en fin de bande a de la valeur â€” c'est de l'argent Â« rÃ©cupÃ©rÃ© Â», pas une charge. On le compte donc comme une recette, et il n'alourdit pas le coÃ»t de revient par poulet.*

**15.4 Validation PIN gÃ©rant (Piste A)**

La clÃ´ture dÃ©finitive exige le PIN du gÃ©rant. Le front appelle verifier_pin (p_role = 'GERANT') cÃ´tÃ© serveur ; si le PIN est correct, il enchaÃ®ne l'Ã©criture du reliquat (cloturer_phase3_reliquat) puis _confirmerCloture (archivage bande + libÃ©ration bÃ¢timent).

Fonctions du pavÃ© PIN : _pinClotureTap, _pinClotureDel, _updateDotsCloture, _validerCloturePin, _showClotErr. Variable globale _pinCloture. PavÃ© isolÃ© du login (classes pin-key, points dot-clot-0 Ã  dot-clot-3).

ðŸ’¡ *En clair : pour Ã©viter qu'un agent clÃ´ture une bande par erreur, seul le gÃ©rant peut valider â€” en tapant son code secret, vÃ©rifiÃ© directement par le serveur.*

**15.5 Bug B10 â€” fermÃ© (v26.21)**

Le code Ã©crivait statut = 'TERMINEE', valeur **invalide** (la contrainte bandes_statut_check n'accepte que 'PREPARATION', 'EN COURS', 'CLOTURE', 'ARCHIVE'). CorrigÃ© aux 3 endroits : l'Ã©criture rÃ©elle du statut, la dÃ©tection Â« dÃ©jÃ  clÃ´turÃ©e Â», et le texte affichÃ© (Â« CLÃ”TURÃ‰E Â»). Ajout au passage du filtre .eq('ferme_id', FERME_ID) sur l'UPDATE de clÃ´ture (sÃ©curitÃ© multi-fermes).

**15.6 Limite connue â€” clÃ´ture non atomique**

L'enchaÃ®nement archivage bande â†’ libÃ©ration bÃ¢timent se fait en deux Ã©critures sÃ©parÃ©es (via Promise.all), pas dans une transaction unique. **Risque thÃ©orique** : si la libÃ©ration du bÃ¢timent Ã©choue aprÃ¨s l'archivage rÃ©ussi (coupure rÃ©seau), la bande serait clÃ´turÃ©e mais le bÃ¢timent resterait Â« occupÃ© Â». Impact faible et rÃ©parable manuellement (remettre le bÃ¢timent en 'LIBRE'). Chantier futur si observÃ© sur le terrain : basculer vers une RPC unique tout-ou-rien.

ðŸ’¡ *En clair : dans un cas trÃ¨s rare (coupure au mauvais moment), le poulailler pourrait rester marquÃ© Â« occupÃ© Â» alors que la bande est finie. Facile Ã  corriger Ã  la main. On blindera seulement si Ã§a arrive vraiment.*

**NOUVELLE SECTION 16 â€” Module CRM Clients**

**16. Module CRM Clients (chantier en cours â€” dÃ©marrÃ© v26.21/v26.22)**

**16.1 Objectif**

Permettre au gÃ©rant de gÃ©rer ses clients, leurs commandes (prÃ©commandes puis livraisons), et le suivi des paiements/crÃ©ances. SÃ©paration comptable OHADA : **CRÃ‰ANCES** (qui me doit) distinctes de la **CAISSE** (combien j'ai rÃ©ellement).

**Seul le GÃ‰RANT saisit.** RÃ©servÃ© Ã  l'onglet GESTION.

**16.2 DÃ©coupage en 6 Ã©tapes**

| **Ã‰tape** | **Contenu**                                    | **Statut**       |
|-----------|------------------------------------------------|------------------|
| 1         | Clients + catalogue produits                   | âœ… Migration 035 |
| 2         | Livraison â†’ vente â†’ recette journal            | â—‹ Ã€ faire        |
| 3         | Suivi paiements / crÃ©ances                     | â—‹ Ã€ faire        |
| 4         | Export WhatsApp commande                       | â—‹ Ã€ faire        |
| 5         | Ã‰cran TrÃ©sorerie / Caisse                      | â—‹ Ã€ faire        |
| 6         | Mouvements hors-bande + injections partenaires | â—‹ Ã€ faire        |

**16.3 Migration 035 â€” Socle (exÃ©cutÃ©e)**

- produits_catalogue : nom, unite, prix_reference, **decremente_effectif**, actif

- clients : nom, telephone, adresse, type_client, note, actif

- 5 produits prÃ©-remplis Ã— 2 fermes : Sujet vivant (decremente=true), Poulet entier abattu (true), Foies & gÃ©siers (kg, false), Cous tÃªtes+pattes (kg, false), Sac de fientes (sac, false)

**16.4 Migration 036 â€” CÅ“ur CRM (exÃ©cutÃ©e v26.22)**

Trois tables, toutes avec ferme_id NOT NULL + RLS (ferme_id = get_ferme_id()) :

**commandes** â€” en-tÃªte du bon de commande

- client_id, date_commande, statut, date_reglement_prevue, note

- statut âˆˆ PRECOMMANDE / PLANIFIEE / LIVREE / ANNULEE

- **Pas de colonne total** â€” calculÃ© Ã  la volÃ©e depuis les lignes

**commande_lignes** â€” 1 ligne = 1 produit + 1 bande

- commande_id (CASCADE), produit_id, bande_id, quantite, prix_prevu, prix_reel

- **bande_id OPTIONNEL en base** (fientes, abats hors bande)

- **Mais OBLIGATOIRE Ã  l'Ã©cran** pour les produits avec decremente_effectif = true

- Prix **prÃ©vu** (Ã  la commande) et **rÃ©el** (Ã  la livraison) : les deux conservÃ©s

**paiements** â€” encaissements

- commande_id **NOT NULL** (chaque paiement = 1 commande prÃ©cise), client_id, montant, date_paiement, moyen, type, note

- moyen âˆˆ CASH / MOBILE_MONEY / VIREMENT / CHEQUE / AUTRE

- type âˆˆ ACOMPTE / SOLDE

- client_id est une **redondance contrÃ´lÃ©e** (accessible via commande, mais Ã©vite une jointure sur chaque calcul de crÃ©ance client)

**16.5 DÃ©cisions mÃ©tier actÃ©es (ne pas rouvrir sans demande explicite)**

1.  **Total calculÃ©, jamais stockÃ©** â€” il existe un total prÃ©vu ET un total rÃ©el ; les stocker crÃ©erait un risque de dÃ©synchronisation.

2.  **Chaque paiement rattachÃ© Ã  une commande prÃ©cise** â€” pas d'acompte flottant.

3.  **Commande multi-produits ET multi-bandes** â€” d'oÃ¹ le modÃ¨le en-tÃªte + lignes.

4.  **Abattage = module futur sÃ©parÃ©.** Le CRM enregistre la vente de produits abattus sans toucher l'effectif de la bande.

5.  **Injections partenaires** : s'appuieront sur partenaires_bandes (il n'existe PAS de table partenaires seule).

**16.6 Alerte Ã©chÃ©ance (Ã  implÃ©menter, Ã©tape 3)**

Rappel J-1 sur l'accueil gÃ©rant : Â« Facture client X Ã  rÃ©gler demain Â». Trois couleurs : ðŸŸ¡ J-1 Ã  relancer Â· ðŸ”´ Ã©chÃ©ance dÃ©passÃ©e impayÃ©e Â· âšª lointaine. Compteur Ã©galement sur la tuile Clients.

**16.7 Ã‰tat actuel (fin v26.22)**

- âœ… Tables en base (035 + 036)

- âœ… Onglet GESTION + page tuiles (Clients active, TrÃ©sorerie/Stock grisÃ©es)

- â—‹ Ã‰cran Clients (liste, ajout, modification) â€” **prochain chantier**

**â‘£ NOUVELLE SECTION 17 â€” Architecture modules sÃ©parÃ©s**

**17. Architecture modules sÃ©parÃ©s (Ã©tablie v26.22)**

**17.1 Le problÃ¨me**

index.html fait ~5900 lignes, tout le code dans un seul <script> inline. Ajouter le CRM, la trÃ©sorerie et l'abattage dedans reviendrait Ã  aggraver le spaghetti.

**DÃ©cision** : les nouveaux modules sont construits **dans des dossiers sÃ©parÃ©s**, en **vrais modules ES** (type="module"). index.html **n'est PAS redÃ©coupÃ©** â€” trop risquÃ©. On greffe proprement Ã  cÃ´tÃ© ; la migration de l'ancien code viendra plus tard.

**17.2 Structure de fichiers**

AVIGEST4/

â”œâ”€â”€ index.html â† existant, 4 lignes ajoutÃ©es seulement

â”œâ”€â”€ sw.js

â”œâ”€â”€ migrations/

â”‚

â”œâ”€â”€ css/

â”‚ â””â”€â”€ gestion.css

â”‚

â””â”€â”€ js/

â”œâ”€â”€ shared/

â”‚ â”œâ”€â”€ db.js â† accÃ¨s Supabase + contexte (guichet)

â”‚ â””â”€â”€ helpers.js â† esc, toast, zone, fcfa, dateFr

â”œâ”€â”€ gestion/

â”‚ â””â”€â”€ gestion.js â† page GESTION (tuiles)

â””â”€â”€ clients/ â† Ã  venir

**17.3 Le "guichet" avigestContext() â€” point clÃ©**

**ProblÃ¨me dÃ©couvert en v26.22** (vÃ©rifiÃ© en console) :

| **Variable** | **DÃ©clarÃ©e avec** | **Visible depuis un module ?**       |
|--------------|-------------------|--------------------------------------|
| sb           | var (ligne ~549)  | âœ… Oui â€” var global va sur window    |
| App          | const/let         | âŒ Non â€” window.App = undefined      |
| FERME_ID     | const/let         | âŒ Non â€” window.FERME_ID = undefined |

Sans FERME_ID, aucun module ne peut filtrer ses requÃªtes par ferme â†’ CRM impossible.

**Solution retenue** : index.html expose **une seule fonction**, en fin de script inline :

javascript

window.avigestContext = function () {

return {

sb: (typeof sb !== 'undefined') ? sb : null,

role: (typeof App !== 'undefined' && App) ? App.role : null,

fermeId: (typeof FERME_ID !== 'undefined') ? FERME_ID : null

};

};

C'est **l'unique frontiÃ¨re** entre l'ancien code et les nouveaux modules. Les modules **lisent** une photo de l'Ã©tat ; ils ne peuvent pas modifier les originaux.

**RÃˆGLE ABSOLUE** : ne jamais mettre sb en cache dans une variable de module. sb est **rÃ©affectÃ© au login** (index.html ~526) une fois le FERME_ID connu. Une copie gardÃ©e en mÃ©moire porterait le mauvais header x-ferme-id. Toujours appeler db() au moment de s'en servir.

**17.4 Branchement sur le Nav existant**

NAVBAR_CONFIG (ligne ~1402) est une simple liste d'objets. Le clic exÃ©cute _navTap(id, fn) qui appelle window[fn]().

Un module isolÃ© n'est pas dans window â€” il doit **s'exposer explicitement**, mais **une seule porte d'entrÃ©e** :

javascript

window.renderGestion = renderGestion; // la "sonnette" du module

Tout le reste du fichier reste privÃ© â†’ **zÃ©ro collision** avec les ~5900 lignes d'index.html.

**17.5 Serveur local obligatoire en dÃ©veloppement**

Les modules ES **ne se chargent pas** depuis un fichier ouvert en double-clic (file:///...). Le navigateur les refuse.

**Commande Ã  lancer avant chaque session de dev**, depuis le dossier du projet :

npx serve

Puis tester sur http://localhost:3000. Laisser le terminal ouvert (Ctrl+C pour arrÃªter).

**En production sur GitHub Pages : aucun problÃ¨me** â€” GitHub Pages *est* un serveur. La contrainte est purement locale.

**17.6 Greffe dans index.html (4 lignes au total)**

1.  NAVBAR_CONFIG â†’ { id:'gestion', icon:'ðŸ“‹', label:'Gestion', fn:'renderGestion' },

2.  <head> â†’ <link rel="stylesheet" href="css/gestion.css">

3.  Fin de <script> inline â†’ la fonction avigestContext()

4.  Avant </body> â†’ <script type="module" src="js/gestion/gestion.js"></script>

**â‘¤ AJOUTER â€” Points en suspens**

**Ajouter Ã  la liste des points en suspens :**

6.  **sw.js â€” STATIC_URLS incomplet** (ouvert v26.22) : la liste ne contient que /AVIGEST4/ et /AVIGEST4/index.html. Les nouveaux fichiers (css/gestion.css, js/shared/db.js, js/shared/helpers.js, js/gestion/gestion.js) n'y figurent pas. **ConsÃ©quence** : le module GESTION **ne fonctionnera pas hors ligne**. Fonctionne correctement en ligne (testÃ© en production le 11/07/2026, fenÃªtre InPrivate). Ã€ corriger dans un commit dÃ©diÃ©.

7.  **Warning Multiple GoTrueClient instances detected** (observÃ© v26.22) : deux clients Supabase coexistent dans la page â€” crÃ©ation ligne 549 puis rÃ©affectation ligne 526 d'index.html. Sans gravitÃ© constatÃ©e Ã  ce jour, mais Ã  surveiller.

8.  **Doublon de policy RLS sur clients** (observÃ© v26.22) : deux policies ALL font le mÃªme travail â€” clients_isolation et ferme_isolation (cette derniÃ¨re avec with_check NULL). Ã€ nettoyer lors de la session RLS dÃ©diÃ©e (Â§14.3).

**â‘¥ METTRE Ã€ JOUR â€” Section 2.1 (version)**

| **Version actuelle** | **APP_VERSION = 'v26.22' Â· CACHE_NAME = 'avigest-v26-22'** |

**â‘¦ METTRE Ã€ JOUR â€” Section 2.5 (migrations)**

Ajouter les deux derniÃ¨res lignes :

| 035_crm_clients_catalogue.sql | Tables clients + produits_catalogue (CRM Ã©tape 1) | | 036_crm_commandes.sql | Tables commandes, commande_lignes, paiements + suppression tables mortes ventes/paiements |

*â€” Fin de la mise Ã  jour Bible session v26.22 â€”*

*â€” Fin de la Bible AviGest v26 â€” Version .md gÃ©nÃ©rÃ©e le 13/07/2026 (session v26.22), Ã  rÃ©percuter manuellement dans le .docx â€”*

