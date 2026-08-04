# 🐔 AviGest v26

## Bible du Projet --- Document de Référence Permanent

*Version 26 --- Adama Désiré --- Ouagadougou, Burkina Faso*

> **Synchronisation** : cette version `.md` est générée à partir de
> `bible_avigest_v26.docx` --- dernière synchronisation le **22/07/2026
> (session v26.30).**. Le `.docx` reste la référence unique pour toute
> modification manuelle ; ce fichier `.md` est une copie dérivée
> destinée à être lue par Claude Code depuis le repo GitHub, à côté de
> `SCHEMA.md`. Ne jamais éditer ce `.md` comme source --- toujours
> régénérer depuis le `.docx` à jour.

## 1. Contexte et Objectif

AviGest est une Progressive Web App (PWA) de gestion avicole à
Ouagadougou. Elle gère un élevage de poulets de chair sur plusieurs
poulaillers, avec trois rôles : gérant, agent, partenaires
investisseurs.

**Contraintes clés :**

-   Connexion variable --- mode hors ligne prévu (non encore implémenté)
-   Agent peu familier avec le numérique --- interface pavé numérique,
    un champ à la fois
-   Backend : Supabase PostgreSQL + Realtime · Frontend : GitHub Pages ·
    SDK local supabase.js

## 2. Architecture Technique

### 2.1 URLs et Identifiants

  -----------------------------------------------------------------------
  Élément               Valeur
  --------------------- -------------------------------------------------
  URL Frontend          https://adamaky.github.io/AVIGEST4/

  GitHub Repo           https://github.com/Adamaky/AVIGEST4

  Supabase URL          https://jzlmnpxcnrcajludtkpt.supabase.co

  Supabase Project ID   jzlmnpxcnrcajludtkpt

  Ferme ID (REVAGRO)    e56574a9-54c1-430d-b480-b9bdd1090dd7

  Ferme ID (ALIRAH2026) 40ee764e-d073-463e-b07b-bf95a9d7a675

  Client Supabase       sb (toujours sb, jamais supabase)

  SDK local             supabase.js ligne 17 (téléchargé depuis
                        unpkg.com)

  Session               12 heures · Avertissement 1h avant expiration

  Fichier de travail    C:.html

  **Version actuelle**  **APP_VERSION = 'v26.40' · CACHE_NAME =
                        'avigest-v26-40'**
  -----------------------------------------------------------------------

### 2.2 Terminologie --- Deux niveaux

  -----------------------------------------------------------------------
  Terme visible         Terme technique       Explication
  (interface)           (code)                
  --------------------- --------------------- ---------------------------
  Poulailler 1, 2...    Batiment-1,           Salle d'élevage physique
                        Batiment-2...         

  Bande                 bande / bande_id      Lot de poulets dans un
                                              poulailler

  Agent                 AGENT / role          Responsable terrain

  Partenaire            PARTENAIRE / role     Investisseur

  Gérant                GERANT / role         Gestionnaire principal
  -----------------------------------------------------------------------

### 2.3 Format ID Bande

Format : `Bande-YYYY-NNN` (ex : `Bande-2026-001`)

-   Regex de validation : `/^Bande-\d{4}-\d{3}$/`
-   Auto-génération avec possibilité de saisie manuelle
-   Soft-delete : toujours ajouter `.eq('is_deleted', false)` sur les
    requêtes bandes

### 2.4 Architecture Supabase --- Tables principales

### 2.4 Architecture Supabase --- Tables

### Liste exhaustive vérifiée en base le 11/07/2026 (session v26.22) --- 18 tables. Toute nouvelle table doit être ajoutée ici. Toute création de table doit être précédée d\'une vérification en base (voir règle 4.1).

+---------------+------------------------------------------------------+
| ### Table     | ### Rôle                                             |
+===============+======================================================+
| ### bandes    | ### Lots de poulets --- id, ferme_id, nom, race      |
|               | , effectif_initial, date_arrivee, statut, is_deleted |
+---------------+------------------------------------------------------+
| ### batiments | ### Poulaillers physiques                            |
+---------------+------------------------------------------------------+
| ### clients   | ### CRM --- nom, telephon                            |
|               | e, adresse, type_client, note, actif (Migration 035) |
+---------------+------------------------------------------------------+
| ### clotures  | ### Clôtures de bande (module v26.21)                |
+---------------+------------------------------------------------------+
| ### co        | ### CRM --- détail comm                              |
| mmande_lignes | ande : 1 ligne = 1 produit + 1 bande (Migration 036) |
+---------------+------------------------------------------------------+
| ### commandes | ### CRM --- en-tête bon de commande (Migration 036)  |
+---------------+------------------------------------------------------+
| ### c         | ### Composition des lots d\'aliment fabriqué         |
| omposants_lot |                                                      |
+---------------+------------------------------------------------------+
| ### config    | ### Paramètres applicatifs                           |
+---------------+------------------------------------------------------+
| ### croiss    | ### Courbes de référence zootechniques (Cobb 500)    |
| ance_standard |                                                      |
+---------------+------------------------------------------------------+
| ### fermes    | ### Tenants --- une ligne par fer                    |
|               | me cliente. 14 colonnes, schéma détaillé en §2.4 bis |
+---------------+------------------------------------------------------+
| ### journal   | ### Écritures comptables --- DEPENSE / RECETTE       |
+---------------+------------------------------------------------------+
| #             | ### Lots de stock ---                                |
| ## lots_stock |  cout_unitaire GÉNÉRÉ, categorie_cru, impute_journal |
+---------------+------------------------------------------------------+
| ### mou       | ### ENTREE / SORTIE de stock                         |
| vements_stock |                                                      |
+---------------+------------------------------------------------------+
| ### paiements | ### CRM --- en                                       |
|               | caissements rattachés à une commande (Migration 036) |
+---------------+------------------------------------------------------+
| ### parte     | ###                                                  |
| naires_bandes | Quotes-parts des partenaires investisseurs par bande |
+---------------+------------------------------------------------------+
| ### produ     | ### CRM --- produits vendables (Migration 035)       |
| its_catalogue |                                                      |
+---------------+------------------------------------------------------+
| ### r         | ### Rapports hebdomadaires agent/gérant              |
| apports_hebdo |                                                      |
+---------------+------------------------------------------------------+
| ### saisi     | ### Sai                                              |
| es_techniques | sies agent (température, hygrométrie, mortalité\...) |
+---------------+------------------------------------------------------+
| ### ses       | ### Verrouillage multi-appareils --                  |
| sions_actives | - RLS ACTIVE (vérifié en base le 22/07/2026, §14.4 ; |
|               |  la Bible indiquait à tort qu'elle était désactivée) |
+---------------+------------------------------------------------------+
| ### taches    | ### Tâches planifiées                                |
+---------------+------------------------------------------------------+
| ###           | ### Comptes --- PIN bcrypt via verifier_pin()        |
|  utilisateurs |                                                      |
+---------------+------------------------------------------------------+

### ⚠️ Tables supprimées en v26.22 : ventes et paiements (ancienne version) existaient en base sans être documentées. Vides (0 ligne), aucune occurrence dans index.html. Modèle incompatible (1 vente = 1 seul produit). Supprimées par la Migration 036, remplacées par commandes + commande_lignes + paiements (nouveau modèle).

### 2.4 bis --- Schéma détaillé de la table fermes

Vérifié en base le 23/07/2026 (session v26.35) via
information_schema.columns. 14 colonnes. Cette table n'avait jamais été
documentée au-delà de son rôle --- or elle porte trois colonnes
structurantes que la Bible ignorait : plan, nb_batiments et code_acces.

  ------------------------------------------------------------------------
  **Colonne**         **Type**           **Rôle / remarque**
  ------------------- ------------------ ---------------------------------
  id                  uuid NOT NULL      Clé primaire, default
                                         uuid_generate_v4(). C'est la
                                         valeur portée par le header
                                         x-ferme-id.

  nom                 text NOT NULL      Nom technique du tenant (REVAGRO,
                                         ALIRAH2026).

  proprietaire        text NOT NULL      Nom du propriétaire de la ferme.

  ville               text               Default 'Ouagadougou'.

  pays                text               Default 'Burkina Faso'.

  telephone           text               Utilisé sur les reçus de paiement
                                         (§19).

  email               text               Nullable, non utilisé à ce jour.

  plan                text               Default 'FREE'. ⚠️ Socle du
                                         modèle tarifaire SaaS --- la
                                         colonne existe mais n'est
                                         exploitée par aucun écran.

  nb_batiments        integer            Default 6. Nombre de poulaillers
                                         alloués au tenant. Même remarque
                                         que plan.

  actif               boolean            Default true.

  created_at          timestamptz        Default now().

  updated_at          timestamptz        Default now().

  code_acces          text               ⚠️ Colonne du login par code
                                         ferme (écran-code-ferme). C'est
                                         elle que protège la policy
                                         lecture_publique_code_acces
                                         (SELECT, qual=true, rôles
                                         anon+authenticated) documentée en
                                         §14.4 --- policy volontaire, à
                                         conserver.

  nom_commercial      text               Ajoutée par la Migration 047
                                         (v26.34). Nom affiché en tête des
                                         reçus de paiement, distinct du
                                         nom technique. Ex. REVAGRO → «
                                         Kalycoq ». Saisi via l'écran
                                         Paramètres (§20).
  ------------------------------------------------------------------------

💡 En clair : cette table, c'est le registre des clients d'AviGest ---
une ligne par ferme. On y a découvert deux cases déjà prévues pour la
vente d'abonnements (plan et nombre de poulaillers autorisés) qui ne
servent encore à rien : le terrain est déjà préparé pour le passage en
SaaS, il reste à construire dessus.

### 2.5 Migrations SQL --- GitHub

  -------------------------------------------------------------------------------
  Fichier                          Contenu
  -------------------------------- ----------------------------------------------
  001_schema_initial.sql           Tables de base : bandes, saisies_techniques,
                                   taches, journal

  002_stock_tables.sql             Tables lots_stock et mouvements_stock

  003_rls_policies.sql             Politiques RLS sur les 14 tables

  004_get_ferme_id_fix.sql         Correction SECURITY DEFINER + cast JSON sur
                                   get_ferme_id()

  005_imputer_aliment_rpc.sql      RPC imputer_aliment() --- imputation atomique
                                   stock depuis sessions agent

  006_stock_dashboard_rpc.sql      RPC pour vue stock dashboard gérant

  ...                              (migrations suivantes numérotées jusqu'à 030
                                   --- voir dossier migrations/ du repo)

  049_penalites.sql                Table penalites (16 colonnes) --- pénalités de
                                   retard : carnet à souches PEN-{annee}-{seq},
                                   RLS penalites_isolation, CHECK montant\>0 et
                                   taux_pct\>0

  050_encaisser_penalite.sql       RPC encaisser_penalite(p_penalite_id, p_moyen)
                                   --- encaissement atomique : RECETTE au
                                   journal + bascule paye=true, avec repli tracé
                                   sur bande active

  051_get_alertes_echeance.sql     RPC get_alertes_echeance() --- lecture des
                                   commandes livrées non soldées avec échéance,
                                   catégorie couleur (ROUGE/JAUNE/BLANC), source
                                   unique de l\'alerte §23

  053_get_rentabilite_bandes.sql : RPC get_rentabilite_bandes() --- lit
                                   vue_dashboard_bande, renvoie une ligne par
                                   bande EN COURS (CRU unitaire calculé côté
                                   serveur via total_depenses_cru / effectif,
                                   protégé par NULLIF). Filtrée get_ferme_id(),
                                   fail-closed. Dernière migration : 053.
  -------------------------------------------------------------------------------

## Dernière migration : 051.

## ⚠️ Dette de fichiers migrations --- ✅ SOLDÉE (v26.37). Quatre migrations avaient été jouées en base sans que leur fichier .sql soit committé : 047 (ALTER fermes ADD nom_commercial), 048 (paramètre p_date_reglement sur livrer_commande), 050 (encaisser_penalite) et 051 (get_alertes_echeance). Toutes recréées a posteriori en v26.37 depuis l\'état réel en base (pg_get_functiondef pour les fonctions, vérification information_schema pour l\'ALTER) --- jamais depuis la Bible seule, conformément à la règle absolue n°1. Le dossier migrations/ est désormais complet et continu jusqu\'à 051. Confirmé au passage : 045 (045_imputer_stock_type_b.sql) existe bien.

## 

## 3. Utilisateurs et Rôles

  ----------------------------------------------------------------------------
  Rôle         Limite     PIN actuel     Accès
  ------------ ---------- -------------- -------------------------------------
  GERANT       Max 2      0000 (Adama)   Tout --- supervision, planif, compta,
                                         poulaillers, stock, rapports

  AGENT        Max 2      1111 (Agent    Terrain --- sessions, saisies, taches
                          Ferme)         

  PARTENAIRE   Illimité   PIN individuel Ses bandes --- résultats, état lot,
                                         créances
  ----------------------------------------------------------------------------

> PIN stocké en bcrypt via RPC `verifier_pin()` (colonne PIN en clair
> supprimée --- Migration 028).

## 4. Règles Techniques Critiques

### 4.1 Règles Supabase

-   Client toujours nommé `sb` --- jamais `supabase`
-   Header `x-ferme-id` injecté globalement à la création du client
    (ligne 427)
-   RLS active sur toutes les tables, y compris `sessions_actives`
    (vérifié en base le 22/07/2026, session v26.30 --- la Bible
    indiquait à tort que sessions_actives était sans RLS)
-   `get_ferme_id()` avec SECURITY DEFINER --- retourne l'ID ferme
    depuis le header
-   Statelessness REST : `set_config` ne persiste pas entre requêtes ---
    utiliser le header global
-   Avant tout INSERT : vérifier colonnes NOT NULL, defaults, et
    colonnes générées
-   `cout_unitaire` dans `lots_stock` est une colonne GÉNÉRÉE --- ne
    jamais l'inclure dans un INSERT
-   `lots_stock.produit` : noms complets (ex : 'Aliment de démarrage')
    --- chercher avec `LOWER(produit) LIKE`
-   `mouvements_stock.type_mouvement` : uniquement 'ENTREE' ou 'SORTIE'
-   `SET LOCAL row_security = off` dans les RPCs SECURITY DEFINER qui
    interrogent `utilisateurs`, pour bypasser RLS
-   Appeler `extensions.crypt()` et non `crypt()` --- pgcrypto est dans
    le schéma extensions
-   **Toute opération DELETE/UPDATE sur une table sans RLS (ex:**
    `sessions_actives`**) doit systématiquement filtrer par** `ferme_id`
    **côté client --- leçon de l'audit sécurité v26.18 (voir section
    14)**

> Avant toute création de table : vérifier qu\'elle n\'existe pas déjà
> en base.
>
> SELECT tablename FROM pg_tables WHERE schemaname = \'public\' ORDER BY
> tablename;
>
> Leçon session v26.22 : les tables ventes et paiements existaient en
> base sans figurer dans la Bible. La Migration 036 a échoué sur
> relation \"paiements\" already exists. La documentation ne suffit pas
> --- **la base est la seule vérité**. Corollaire du principe «
> diagnostic avant de coder ».

-   **Une migration SQL est transactionnelle** : si une instruction
    échoue, TOUT est annulé, y compris les instructions déjà passées.
    Aucun état intermédiaire n\'est possible.

### 4.2 Règles JavaScript

-   Apostrophes dans les chaînes JS : toujours échapper avec `\'` ou
    utiliser des guillemets doubles
-   Ne jamais imbriquer des template literals dans `.map()` --- utiliser
    la concaténation
-   `&quot;` au lieu d'apostrophes dans les attributs onclick inline
-   `node --check` échoue sur les fichiers `.html` --- utiliser la
    commande PowerShell d'extraction JS
-   jsDelivr CDN inaccessible depuis le Burkina Faso --- utiliser
    unpkg.com ou le fichier local

### 4.3 Règles de travail

-   Fichier unique :
    `C:\Users\kyada\Documents\GitHub\AVIGEST4\index.html`
-   Workflow : VS Code → Claude Code → vérification syntaxe PowerShell →
    GitHub Desktop → Push
-   Chaque modification SQL = un nouveau fichier de migration numéroté
    dans `migrations/`
-   `APP_VERSION` (ligne \~463 index.html) mis à jour EN MÊME TEMPS que
    `CACHE_NAME` (ligne 9 sw.js) à chaque session --- format `'v26.XX'`
-   Sélectionner 'Yes, allow all edits this session' dans Claude Code
    pour les sessions multi-patches
-   Vérification après patch : commandes `Ctrl+Shift+F` avec nombre
    d'occurrences attendu
-   **Un seul changement par patch** --- ne jamais mixer des
    modifications non liées dans un même commit (leçon B6/isolation
    stricte)
-   **Séquence de vérification stricte (confirmée v26.18)** : édition →
    `node --check` (confirmation explicite du résultat, ne jamais
    supposer que c'est fait) → diff GitHub Desktop complet → incrément
    version si dernier changement de la session → commit avec message
    combiné (version + description)

**RÈGLE STOCK --- Deux types de lots**

Avant tout INSERT `lots_stock`, vérifier le flag `impute_journal`
(BOOLEAN) : - `true` : RPC déclenche écriture journal - `false` : RPC
décrémente stock uniquement, pas d'écriture journal

**RÈGLE CRU --- Filtre catégories charges consommées (définitive, ne pas
modifier)**

    CRU = SUM(montant) WHERE type_ecriture = 'DEPENSE' 
                        AND categorie != 'Achat stock'
          / effectif_vivants

Filtre par **exclusion**, pas par liste fermée. La litière (comme tout
produit avec `impute_journal = true`) entre correctement dans le CRU via
ce filtre --- ne jamais ajouter de catégorie spécifique au filtre,
l'exclusion `!= 'Achat stock'` suffit et gère tout automatiquement.

**RÈGLE JOURNAL --- Catégories prédéfinies (v2)**

Charges consommées (CRU) : - Alimentation (auto RPC) - Vaccin \[type +
unité + qté + PU\] - Médicament \[type + unité + qté + PU\] - Litière
\[type + unité + qté + PU\] --- traitée comme l'aliment (Type A)

Charges exploitation (hors CRU par exclusion, mais toujours DEPENSE) : -
Salaire \[forfait ou qté×PU\] - Prestation de service \[forfait ou
qté×PU\] - Transport \[forfait ou qté×PU\] - Glace \[forfait ou
qté×PU\] - Autre \[texte libre + montant\]

Hors charges (mouvement stock, jamais dans le CRU) : - Achat stock \[lié
à lots_stock\]

**4.4 Cadre de design**

Cadre de design boutons (figé v26.25) : couleur = sens, jamais
décoration. Bleu (\--blue) = action « avance » (Nouvelle, Planifier) ·
Vert (\--green) = confirmation d\'argent/effectif réel (Livrer), texte
sombre · Rouge (\--red) = danger/annulation · Gris (\--bg3) = action
secondaire (Retour). Classe de base .gestion-pastille (pastille ≥44px,
cible tactile). Une seule action vive par écran. Toute action engageant
argent/effectif passe par un écran de confirmation, jamais un clic
direct.

## 5. Score Santé --- Règle de Calcul

Validé session 18 juin 2026 --- Cobb 500, Ouagadougou, J14+

  ------------------------------------------------------------------------
  Paramètre              Bon 🟢         Passable 🟡      Mauvais 🔴
  ---------------------- -------------- ---------------- -----------------
  Température (°C)       26--32°C       33--35°C         \<26 ou \>35°C

  Hygrométrie (%)        50--70%        71--80%          \<50 ou \>80%

  Mortalité/jour         0--2 morts     3--5 morts       \>5 morts
  ------------------------------------------------------------------------

**Règle de calcul : Score final = le PIRE des 3 scores individuels**

Surcharge manuelle : l'agent peut modifier le score calculé + saisir une
note explicative

> **Bug cosmétique (v26.17) --- ✅ FERMÉ v26.30** : écran de
> confirmation agent affiche le score santé avec balises HTML brutes
> (`<strong>BON</strong>` au lieu de **BON** en gras). Cause : la
> fonction `esc()` échappe les balises `<strong>` volontairement
> insérées dans `_renderSessionResume()`. Correctif appliqué en v26.30
> (retrait de `<strong>`/`</strong>`, le CSS
> `.rapport-ligne span:last-child` gère déjà le gras). ⚠️ Leçon : DEUX
> balises étaient en cause, pas une seule --- le premier correctif
> partiel n'avait donc rien changé à l'écran. Toujours compter les
> occurrences avant de conclure qu'un correctif est complet.

## 6. Module Stock --- Architecture complète (CHANTIER CLOS --- v26.18)

**TYPE DE LOT STOCK**

**Type A --- Avec imputation journal (charge)** - → Aliment, Vaccin,
Médicament, Litière - → Décrémente stock + écriture journal auto - →
Entre dans le CRU (sauf catégorie "Achat stock")

**Type B --- Sans imputation journal** - → Produits créés par le gérant
avec `impute_journal = false` - → Décrémente stock uniquement - →
N'entre PAS dans le CRU

**FLAG sur lots_stock (implémenté) :**

    impute_journal BOOLEAN DEFAULT false
    categorie_cru TEXT (v26.16) — catégorie comptable du lot,
      lue en priorité par imputer_stock(), avec repli sur
      l'ancien CASE (nom produit) si NULL

**RPC imputer_stock_type_b --- sortie de stock sans écriture comptable**

Documentée en v26.35. Cette RPC existait en base depuis plusieurs
sessions sans figurer dans la Bible. Schéma relevé directement via
pg_get_functiondef() le 23/07/2026.

    imputer_stock_type_b(
      p_bande_id     uuid,
      p_type_produit text,
      p_quantite,
      p_session,
      p_note
    ) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER

⚠️ Correction d'une erreur de brief : un brief de reprise antérieur
annonçait la signature (p_lot_id, p_bande_id, p_quantite, p_session,
p_note). C'est FAUX. Le premier paramètre est p_bande_id et le second
p_type_produit --- il n'existe aucun p_lot_id. Application directe de la
règle absolue n°1 : diagnostiquer en base avant de coder.

**Paramètres :**

  -----------------------------------------------------------------------
  **Paramètre**            **Rôle**
  ------------------------ ----------------------------------------------
  p_bande_id uuid          Bande concernée par la sortie de stock.

  p_type_produit text      ⚠️ Ce n'est PAS un identifiant de lot. C'est
                           un fragment du nom du produit. La RPC cherche
                           elle-même le lot avec LOWER(produit) LIKE
                           '%...%'.

  p_quantite               Quantité sortie. La valeur 0 est autorisée
                           (aucune décrémentation, mais le mouvement est
                           tout de même tracé).

  p_session                Session agent à l'origine du mouvement (Matin
                           / Midi / PM / Nuit).

  p_note                   Note libre. Si NULL, générée automatiquement :
                           « {type_produit} utilisé --- Session {session}
                           ».
  -----------------------------------------------------------------------

**Sélection du lot :**

La RPC lit ferme_id depuis
current_setting('request.headers')::json-\>\>'x-ferme-id', puis cherche
dans lots_stock le lot correspondant à la ferme ET à la bande, dont le
nom de produit contient p_type_produit, avec statut = 'EN STOCK' et
impute_journal = false (ou NULL). Elle retient le plus récent (ORDER BY
created_at DESC LIMIT 1).

**Comportement :**

1\) Si aucun lot ne correspond → retour jsonb {success:false,
error:'Aucun lot actif trouvé pour...'}. 2) Si p_quantite \> 0 et stock
insuffisant → {success:false, error:'Stock insuffisant...'}. 3) Sinon :
décrémentation de lots_stock.quantite_restante, puis INSERT dans
mouvements_stock (type_mouvement = 'SORTIE', cout_impute = 0). 4) Retour
{success:true, produit, quantite, session}.

**Point clé --- aucune écriture au journal. cout_impute vaut 0 et aucune
ligne n'est créée dans journal. C'est exactement la définition du Type B
ci-dessus : le produit sort du stock sans jamais entrer dans le CRU. À
ne pas confondre avec imputer_stock(), qui elle écrit la charge.**

⚠️ La RPC ne lève pas d'exception en cas d'échec --- elle renvoie un
jsonb avec success:false. Le code appelant doit donc tester ce champ :
un appel « réussi » côté Supabase ne signifie pas que l'imputation a eu
lieu.

💡 En clair : c'est la sortie de stock « silencieuse ». On retire un
produit du magasin et on le note dans le registre des mouvements, mais
on n'inscrit aucune dépense dans les comptes --- donc ça n'alourdit pas
le coût de revient du poulet. Et on lui donne le nom du produit, pas le
numéro du sac : elle retrouve le bon sac toute seule, en prenant le plus
récent.

**⚠️ Surcharge des RPC d'imputation --- relevé en base le 23/07/2026**

PostgreSQL autorise plusieurs fonctions de même nom si leurs signatures
diffèrent. Trois fonctions d'imputation coexistent aujourd'hui. Relevé
via pg_get_function_identity_arguments :

  ------------------------------------------------------------------------
  **oid**   **Signature**                      **Retour**
  --------- ---------------------------------- ---------------------------
  18919     imputer_stock(p_bande_id uuid,     jsonb
            p_produit_like text, p_quantite    
            numeric, p_session...)             

  18918     imputer_stock(p_lot_id uuid,       json
            p_bande_id uuid, p_quantite        
            numeric, p_libelle text...)        

  18741     imputer_stock_type_b(p_bande_id    jsonb
            uuid, p_type_produit text,         
            p_quantite numeric, p_session...)  
  ------------------------------------------------------------------------

Conséquence : imputer_stock existe en DEUX versions (18918 et 18919),
l'une prenant un p_lot_id, l'autre un p_produit_like. Le choix de la
version appelée dépend entièrement des paramètres transmis par le JS.
Avant toute modification d'un appel à imputer_stock, vérifier laquelle
des deux est réellement visée. À nettoyer dans une future migration.

**⚠️ ÉCART ENTRE LE FICHIER DE MIGRATION ET LA BASE ---
imputer_stock_type_b**

Le fichier migrations/015 décrit une fonction
imputer_stock_type_b(p_lot_id, p_bande_id, p_quantite, p_session,
p_note) RETURNS json, qui refuse explicitement les lots Type A et
surtout insère le mouvement avec statut = 'EN_ATTENTE' (validation
gérant requise via valider_imputation_gerant). Cette fonction N'EST PAS
en base. La seule imputer_stock_type_b existante est l'oid 18741, de
signature différente, qui n'écrit AUCUN statut EN_ATTENTE.

**Point de contrôle à trancher : un mouvement créé par la fonction
réellement en base est donc définitif immédiatement, sans passer par la
validation du gérant. Soit c'est un choix assumé --- et il faut le
documenter comme tel --- soit c'est une régression du circuit de
validation, et il faut rétablir le statut EN_ATTENTE. À arbitrer par
Adama avant tout développement touchant aux sorties de stock Type B.**

💡 En clair : le plan écrit dans le dossier migrations dit que l'agent
sort un produit du stock et que ça reste « en attente » jusqu'à ce que
le gérant valide. La machine réellement installée ne fait pas cette
pause : elle enregistre directement. Ce n'est pas forcément grave, mais
c'est un contrôle du gérant qui saute sans que personne l'ait décidé. À
trancher.

Leçon de méthode : un fichier dans migrations/ prouve qu'une migration a
été écrite, jamais qu'elle est l'état actuel de la base. Une migration
ultérieure a pu la remplacer. Corollaire de la règle absolue n°1 : la
base est la seule vérité.

**Imputation générique multi-produits depuis sessions agent (confirmé
v26.18) :** L'étape `stock_autres` (« Autres produits utilisés ») est
présente dans les 4 sessions agent (Matin/Midi/PM/Nuit), pas seulement
Matin. Elle liste tout lot dont le produit n'est pas l'aliment
(`.not('produit', 'ilike', '%aliment%')`) et impute chaque quantité
saisie via `imputer_stock()` --- mécanisme générique, non câblé
spécifiquement pour un produit donné. Testé en conditions réelles avec
deux produits distincts, flux complet jusqu'à validation gérant
(EN_ATTENTE → CONFIRME) confirmé pour les deux : - **Litière** --- B8,
testé 01/07/2026 - **Médicament** --- testé, session v26.18 (02/07/2026)

Le vaccin n'a pas fait l'objet d'un test terrain distinct, mais utilise
exactement le même mécanisme générique que la litière et le médicament
--- risque de comportement différent jugé très faible.

### ÉTAPES MODULE STOCK

  -----------------------------------------------------------------------
  Étape                           Statut
  ------------------------------- ---------------------------------------
  Étape 1 --- Schéma SQL          ✅ Validé

  Étape 2 --- Interface création  ✅ Validé
  lot                             

  Étape 3 --- Imputation auto     ✅ Validé
  sessions agent                  

  Étape 4 --- Vue stock dashboard ✅ Validé
  gérant                          

  Étape 5 --- Validation gérant   ✅ Validé --- mécanisme EN_ATTENTE +
  alimentation                    écran validation gérant opérationnel

  Étape 6 --- RPC litière (Type   ✅ Validé --- Migration 029, testé en
  A, alignée aliment)             conditions réelles 01/07/2026

  Étape 7 --- Formulaire dépense  ✅ Validé --- confirmé session v26.18,
  enrichi                         `renderNouvelleEcriture()` avec
                                  `<optgroup>` Charges CRU / Mouvement
                                  stock, mode Qté×PU

  Étape 8 --- CRU filtré charges  ✅ Validé --- confirmé session v26.18,
  consommées                      filtre `categorie !== 'Achat stock'`
                                  présent et cohérent à 3 endroits du
                                  code

  Imputation multi-produits       ✅ Validé --- confirmé session v26.18,
  (litière/vaccin/médicament)     voir détail ci-dessus
  depuis sessions agent           
  -----------------------------------------------------------------------

**Le module Stock est désormais entièrement clos --- zéro item ouvert.**

## 13. Tableau de Suivi --- Outil Permanent du Non-Codeur

Cette section est la mémoire vivante du projet. Claude la lit à chaque
session pour savoir où en est le projet sans qu'Adama ait besoin de tout
réexpliquer.

### 13.1 Légende des Statuts

  ------------------------------------------------------------------------
  Statut      Signification         Action suivante
  ----------- --------------------- --------------------------------------
  ✅ Validé   Testé sur l'app et    Passer à la prochaine fonctionnalité
              confirmé fonctionnel  

  ⏳ En cours Code produit mais pas Tester sur
              encore testé          https://adamaky.github.io/AVIGEST4/

  🐛 Bug      Testé ---             Décrire le bug précis à Claude
              comportement          
              incorrect observé     

  ○ À faire   Pas encore commencé   Briefer Claude quand c'est la priorité

  ☁️ SaaS     Fonctionnalité prévue À planifier après stabilisation v1
              multi-fermes          

  ⏹️          Décision définitive   Aucune --- ne jamais rouvrir sans
  Abandonné   de ne pas traiter     demande explicite d'Adama
  ------------------------------------------------------------------------

### 13.2 Tableau de Suivi des Fonctionnalités

**FONDATIONS**

  --------------------------------------------------------------------------
  Fonctionnalité               Statut     Note / Bug connu
  ---------------------------- ---------- ----------------------------------
  Login PIN + session 12h      ✅ Validé  Testé PIN 0000 → OK

  Verrouillage multi-appareils ✅ Validé  Table sessions_actives + device
                                          fingerprint

  Écran blocage session        ✅ Validé  Ex-B2 --- écran dédié
  concurrente                             screen-blocage (au lieu
                                          d'injection dans app-main caché)

  Bouton Forcer déconnexion    ✅ Validé  Ex-B9 --- role passé en paramètre,
                                          corrige dépendance circulaire
                                          localStorage

  Système de navigation Nav    ✅ Validé  Bug pavé PIN corrigé

  **Correctif RLS ---          **✅       **v26.19 --- filtre**
  sessions_actives DELETE      Validé**   `.eq('ferme_id', FERME_ID)`
  cross-tenant**                          **ajouté, voir section 14**

  Mode hors ligne + sync auto  ○ À faire  Queue localStorage à implémenter

  Notifications OneSignal      ○ À faire  Géré en arrière-plan
  --------------------------------------------------------------------------

**AGENT**

  -------------------------------------------------------------------------
  Fonctionnalité   Statut      Note / Bug connu
  ---------------- ----------- --------------------------------------------
  Tuiles sessions  ✅ Validé   4 sessions : Matin/Midi/PM/Nuit
  dans onglet                  
  Tâches                       

  Session Matin    ✅ Validé   Pavé numérique fonctionnel
  --- 6 étapes                 

  Session Midi --- ✅ Validé   Testé 18/06/2026
  3 étapes                     

  Session PM --- 3 ✅ Validé   Testé 18/06/2026
  étapes                       

  Session Nuit --- ✅ Validé   Testé 18/06/2026
  4 étapes                     

  Score santé ---  ⏹️          Ex-B1 : "Score undefined" --- décision
  calcul auto      Abandonné   définitive d'Adama (session v26.18) de ne
                               pas traiter, non prioritaire. Distinct du
                               bug cosmétique `<strong>` (voir section 5),
                               toujours actif celui-là

  Score santé ---  ○ À faire   Prévu : bouton Bon/Passable/Mauvais + note
  surcharge                    agent
  manuelle                     

  Blocage sessions ✅ Validé   Ex-B3 --- confirmé implémenté dans
  hors plage                   `renderSession()` : plages par session
  horaire                      (Matin 5h-10h, Midi 10h-14h, PM 14h-19h,
                               Nuit 19h-5h), double protection (bouton
                               désactivé + re-vérification fonction)

  Écran abattage   ○ À faire   Calcul poids moyen auto
  --- 3 étapes                 
  -------------------------------------------------------------------------

**GÉRANT**

  ------------------------------------------------------------------------
  Fonctionnalité   Statut   Note / Bug connu
  ---------------- -------- ----------------------------------------------
  Accueil gérant   ✅       ACCUEIL · BANDES · ANALYSES
  --- navigation   Validé   

  Onglet Tâches    ✅       Ex-B4 --- confirmé résolu (termineesHTML
  gérant           Validé   déclarée) ; collision historique de
                            numérotation avec un autre B4 cité ailleurs
                            restée non éclaircie mais sans impact pratique
                            --- voir Points en suspens

  Planifier tâches ✅       3 types : Quotidienne · Hebdomadaire ·
  agent            Validé   Abattage

  Journal          ✅       Dépenses + Recettes + CRU/sujet
  comptable        Validé   

  Analyses ---     ✅       Ex-B5 : Poids moyen et IC --- confirmé résolu
  zootechnie       Validé   par Adama (testé/observé récemment, session
                            v26.18)

  Analyses ---     ✅       Marge nette · Dépenses · Recettes
  finance          Validé   

  Planifier        ✅       Formulaire Date + Nb sujets + Client cible
  abattage         Validé   

  Rapports         ⏳ En    À tester prochaine session
  hebdomadaires    cours    

  Rapport fin de   ✅       Export texte structuré (fermé v26.9)
  bande + WhatsApp Validé   

  Gestion          ○ À      Créer / activer / désactiver
  utilisateurs     faire    
  ------------------------------------------------------------------------

**STOCK**

Voir section 6 --- module entièrement clos (8 étapes + imputation
multi-produits, toutes ✅ Validé).

**PARTENAIRE**

  ------------------------------------------------------------------------
  Fonctionnalité                     Statut      Note / Bug connu
  ---------------------------------- ----------- -------------------------
  Interface partenaire --- 3 tuiles  ○ À faire   Filtré par idPartenaire

  Assignation quotes-parts           ○ À faire   Total ≤ 100%
  ------------------------------------------------------------------------

**PROCESSUS**

  ------------------------------------------------------------------------
  Fonctionnalité                    Statut     Note / Bug connu
  --------------------------------- ---------- ---------------------------
  Clôture bande --- 6 phases        ○ À faire  14 jours minimum

  Fabrication aliment               ○ À faire  Lignes dynamiques

  Alertes automatiques in-app       ○ À faire  7 KPI configurés

  Abattage progressif --- 6 étapes  ○ À faire  Plan → Exec → Validation
  ------------------------------------------------------------------------

**VISION SAAS**

  ---------------------------------------------------------------------------
  Fonctionnalité     Statut   Note / Bug connu                         SaaS
  ------------------ -------- ---------------------------------------- ------
  Multi-fermes       ✅       2 fermes actives (REVAGRO, ALIRAH2026),  ☁️
  (multi-tenant)     Validé   3e client en cours d'intégration ---     
                              chaque ferme = espace isolé              

  Authentification   ○ À      PIN → tokens JWT ou équivalent           ☁️
  sécurisée SaaS     faire                                             

  Plans tarifaires   ○ À      Gestion abonnements                      ☁️
  (Free / Pro)       faire                                             

  Dashboard gérant   ○ À      Vue de toutes les fermes                 ☁️
  SaaS               faire                                             

  Onboarding         ○ À      Option A : intégré (pas subdomain)       ☁️
  nouvelle ferme     faire                                             
  ---------------------------------------------------------------------------

### 13.3 Registre des bugs (créé session v26.18)

Registre centralisé transversal, source unique de numérotation des bugs.
Les tableaux de section (AGENT, GÉRANT, etc.) ci-dessus restent la
référence de lecture rapide, mais tout nouveau bug détecté à partir de
maintenant doit être numéroté ici en premier.

**Règles établies (session v26.18) :** - Numérotation strictement
croissante, jamais réutilisée, identique dans tous les documents
(Bible + mémoire de session) - Sync Bible déclenchée proactivement par
Claude dès qu'une ligne passe à ✅ Validé (granularité fine, pas
d'attente de fin de chantier) --

*« B10 fermé en v26.21. Prochain numéro disponible : B11. »*

  -------------------------------------------------------------------------------------------
  **Numéro**   **Titre court**         **Domaine**   **Statut**   **Session     **Session
                                                                  ouverture**   fermeture**
  ------------ ----------------------- ------------- ------------ ------------- -------------
  B10          Statut \'TERMINEE\'     Clôture       ✅ Fermé     v26.18        v26.21
               invalide (→                                                      
               \'CLOTURE\')                                                     

  -------------------------------------------------------------------------------------------

### 13.4 Protocole de Brief de Session

Avant chaque session avec Claude, Adama colle ce bloc en début de
message :

    📋 BRIEF SESSION AVIGEST v26

    Objectif du jour : [une phrase]
    Dernière chose validée : [fonctionnalité]
    Bug en suspens : [description ou 'Aucun']

### 13.5 Multi-fermes --- État actuel et Feuille de Route SaaS

**ÉTAT ACTUEL (production) :**

AviGest gère aujourd'hui 2 fermes actives sur une architecture
multi-tenant déjà fonctionnelle : un seul frontend GitHub Pages,
sélection de ferme via code d'accès au login (écran-code-ferme),
isolation des données par `ferme_id` + header `x-ferme-id` + RLS
Supabase.

-   → REVAGRO (ferme_id : e56574a9-54c1-430d-b480-b9bdd1090dd7)
-   → ALIRAH2026 (ferme_id : 40ee764e-d073-463e-b07b-bf95a9d7a675)

**EN COURS D'ENGAGEMENT :**

Un 3e client est actuellement en cours d'intégration sur cette même
architecture. Détails à préciser dans une prochaine mise à jour de la
Bible.

**VISION SAAS (extension future au-delà des clients déjà engagés) :**

La vision SaaS plus large (accueil de clients externes non encore
identifiés, abonnements, dashboard central multi-fermes) reste
documentée ici pour que chaque fonctionnalité v1 soit conçue de façon
compatible. Ne pas commencer le chantier SaaS élargi avant que les
sections Fondations, Agent et Gérant soient toutes à statut Validé.

  -----------------------------------------------------------------------
  Pré-requis SaaS       Condition de démarrage
  élargi                
  --------------------- -------------------------------------------------
  v1 stable             Zéro bug ouvert en Fondations + Agent + Gérant +
                        Stock --- **Stock atteint ce seuil depuis la
                        session v26.18**

  Architecture          ✅ Déjà en place et validée en production (2
  multi-tenant          fermes actives)

  Authentification      Remplacer PIN seul par token JWT avec expiration
  sécurisée             

  Plans tarifaires      Définir Free (1 poulailler) vs Pro (6+
                        poulaillers)

  Onboarding            Option A : écran onboarding intégré --- pas de
                        subdomains par ferme

  Client(s) au-delà des Cible : début janvier 2027
  3 déjà engagés        
  -----------------------------------------------------------------------

## 14. Sécurité --- État et Audit (nouvelle section, session v26.18)

### 14.1 Chantiers sécurité fermés (historique)

S1-S4 --- voir version précédente de la Bible : protection brute force
PIN, hachage bcrypt, erreurs contextuelles showToast, fetch natif
remplaçant sbTemp. Tous validés v26.9/v26.10.

### 14.2 Audit RLS --- session v26.18 (via Claude Code)

\[MISE À JOUR v26.30 : cet audit ne lisait que le code JS ; ses points «
conditionnels » ont été confirmés OU corrigés en base le 22/07/2026 ---
voir §14.4 pour les diagnostics fermes. Notamment, le risque « écriture
» était surestimé, PostgreSQL appliquant USING comme WITH CHECK par
défaut.\] Premier audit structuré de sécurité RLS effectué le
02/07/2026. Méthode : analyse exhaustive du code JS (`index.html`) pour
repérer les opérations sans filtre `ferme_id` ; accès direct aux
policies RLS réelles en base non disponible dans cette passe (nécessite
Supabase Studio/psql).

**Point CRITIQUE confirmé et corrigé :** - `sessions_actives` --- RLS
désactivée (choix documenté) + un DELETE cross-tenant sans filtre
`ferme_id` trouvé ligne \~1739 (`doLogin()`, nettoyage sessions
expirées). **Corrigé v26.19** : ajout de `.eq('ferme_id', FERME_ID)`.
Commit :
`"v26.19 - Fix RLS gap: DELETE sessions_actives sans filtre ferme_id (audit sécurité v26.18)"`. -
Limite du correctif : protège contre l'erreur applicative côté code
légitime, mais ne remplace pas une policy RLS réelle --- un accès direct
via devtools/clé anon pourrait théoriquement encore contourner ce filtre
tant que RLS reste désactivée sur cette table.

**Points restés CONDITIONNELS (état RLS réel non vérifié) :**

  -------------------------------------------------------------------------------
  Table                          Filtre ferme_id    Risque si RLS  Exemple
                                 côté code          off            
  ------------------------------ ------------------ -------------- --------------
  bandes                         Partiel --- \~20   🔴 Élevé       Soft-delete
                                 opérations sans                   bande,
                                 ferme_id, dont des                changement
                                 UPDATE/DELETE par                 statut, par id
                                 id seul                           seul

  batiments                      Absent --- 4       🔴 Élevé       Changement
                                 UPDATE par id seul                statut
                                                                   poulailler par
                                                                   id seul

  taches                         Partiel --- \~10   🟠 Moyen-élevé Marquer tâche
                                 opérations sans                   exécutée par
                                 ferme_id                          id seul

  lots_stock / mouvements_stock  Absent sur         🟠 Moyen       Détail lot,
                                 SELECT/UPDATE                     historique
                                 détail                            mouvements par
                                                                   id seul

  RPCs (`get_dashboard`,         Pas de ferme_id    Inconnu ---    À lire
  `imputer_stock`,               explicite en       dépend de la   directement en
  `valider_imputation_gerant`)   paramètre          vérification   base
                                                    interne SQL    

  utilisateurs                   Absent --- UPDATE  🟡 Faible      Impact métier
                                 last_login par id                 faible
                                 seul                              

  partenaires_bandes             Absent --- SELECT  🟡 Faible      Pertinent si
                                 par utilisateur_id                un utilisateur
                                 seul                              multi-fermes
                                                                   existe un jour
  -------------------------------------------------------------------------------

**Tables jugées saines (filtre ferme_id systématique côté code) :**
journal, rapports_hebdo, composants_lot, vue_stock_actuel.

### 14.3 Session RLS dédiée --- programmée, non planifiée dans le temps

**Objectif** : lever l'incertitude sur l'état RLS réel des tables
listées ci-dessus. Nécessite l'exécution directe en base (Supabase
Studio ou psql) des requêtes suivantes :

    SELECT schemaname, tablename, rowsecurity FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;
    SELECT schemaname, tablename, policyname, cmd, roles, qual, with_check FROM pg_policies WHERE schemaname = 'public' ORDER BY tablename, policyname;
    SELECT routine_name, routine_definition FROM information_schema.routines
    WHERE routine_schema = 'public' AND routine_name IN ('get_dashboard','imputer_stock','valider_imputation_gerant','get_ferme_id','verifier_pin');

Une fois ces résultats obtenus, les points conditionnels du tableau 14.2
deviendront des diagnostics fermes, exploitables pour prioriser
d'éventuels correctifs. **Aucun correctif ne doit être appliqué avant
validation explicite d'Adama, patch par patch, comme pour le point
sessions_actives.**

**14.4 Session RLS dédiée --- RÉALISÉE (session v26.30, 22/07/2026)**

Les trois requêtes de diagnostic du §14.3 ont été exécutées en base (SQL
Editor Supabase). Les points « CONDITIONNELS » du tableau 14.2 sont
désormais des diagnostics fermes. Résultat global : l'isolation
multi-tenant est réellement appliquée au niveau serveur, pas seulement
dans le code JS.

**Diagnostic 1a (RLS on/off) :** RLS activée sur TOUTES les tables du
schéma public, y compris sessions_actives (que la Bible croyait sans
RLS). Le risque « si RLS off » du tableau 14.2 tombe donc entièrement
--- la condition n'est jamais remplie.

**Diagnostic 1b (policies réelles) :** chaque table possède au moins une
policy filtrant (ferme_id = get_ferme_id()). Les tables classées «
risque élevé » (bandes, batiments) et « moyen » (taches, lots_stock,
mouvements_stock) sont en fait protégées. Cas particulier fermes :
policy lecture_publique_code_acces (SELECT, qual=true, rôles
anon+authenticated) volontaire, nécessaire au login par code ferme --- à
conserver.

**Diagnostic 1c (RPCs sensibles) :** les 5 RPCs filtrent correctement.
get_ferme_id() lit le header et cast en uuid ; get_dashboard,
imputer_stock (2 versions coexistent --- voir note),
valider_imputation_gerant et verifier_pin dérivent toutes ferme_id via
get_ferme_id() ou le header, avec fail-closed sur NULL.
valider_imputation_gerant vérifie en plus le rôle GERANT par PIN. Le
point « Inconnu » du tableau 14.2 passe donc au vert.

**Découverte technique importante (rectifie 14.2) :** l'audit 14.2
surestimait le risque « écriture ». En PostgreSQL, une policy
ALL/INSERT/UPDATE sans clause WITH CHECK explicite utilise
automatiquement sa clause USING comme WITH CHECK. Les policies
acces_par_ferme (USING renseigné, with_check NULL) protégeaient donc
DÉJÀ l'écriture croisée, avant tout correctif. Prouvé par test en rôle
anon : insertion croisée refusée (ERROR 42501), insertion légitime
acceptée.

**Migration 041 --- ABANDONNÉE (no-op) :** rédigée pour ajouter un WITH
CHECK explicite, elle ciblait un nom de policy inexistant («
acces_par_terme » au lieu de « acces_par_ferme »). Elle n'a donc rien
créé ni cassé. Non commitée, supprimée avant push. Aucune trace en base.
Numéro 041 laissé vacant.

**Migration 042 --- FAITE et poussée (v26.30) :** nettoyage du doublon
de policy sur clients --- suppression de ferme_isolation (redondante,
with_check hérité) ; clients_isolation (qual + with_check explicites)
conservée. Testé : isolation inchangée (croisé refusé, légitime accepté
en rôle anon). Résout le point en suspens n°8.

**Doublons de policies RLS --- NETTOYAGE FAIT (migrations 043 + 044,
v26.30) :** le même doublon acces_par_ferme (anon) + ferme_isolation
(public) qui subsistait sur bandes, journal, mouvements_stock,
saisies_techniques et taches a été traité par les migrations 043 et 044,
même recette que la 042 (on garde la policy du rôle anon, celui
réellement utilisé par l'app). Il subsiste un doublon de même nature sur
la table fermes (observé v26.34) : ferme_isolation (ALL) fait double
emploi avec fermes_select (SELECT) et fermes_update (UPDATE), toutes sur
id = get_ferme_id(). Sans danger, rangement pur --- à traiter dans une
future migration.

**Limite de fond NON couverte (à traiter au niveau authentification) :**
le header x-ferme-id est posé côté navigateur (depuis localStorage) et
repose sur la clé anon publique, unique pour tous les rôles. Un
utilisateur de l'app peut donc modifier son header et se faire passer
pour une autre ferme : dans ce cas header et ferme_id concordent, la RLS
laisse passer. Aucune policy ne corrige cela --- c'est le rôle du futur
chantier authentification (PIN → token JWT, vision SaaS). Point de
sécurité prioritaire suivant.

**À clarifier --- numérotation des migrations :** le dossier migrations/
présente des numéros intermédiaires manquants (017, 020--025, 029,
033--034 --- vraisemblablement des migrations fusionnées, renommées ou
jamais créées ; le 041 est volontairement vacant, migration abandonnée).
La 040 (040_date_livraison_commandes.sql) existe bien et était la
dernière migration appliquée avant la 042. Depuis, les migrations 042 à
047 ont été appliquées (voir §2.5) --- dernière migration à ce jour :
047. Trou de numérotation sans conséquence, à documenter au besoin.

## Points en suspens (à clarifier avec Adama)

1.  **~~Collision de numérotation B1~~** --- **Refermé session v26.18.**
    B1 "score santé" passé au statut ⏹️ Abandonné, décision définitive
    d'Adama.
2.  **B4** --- collision historique entre deux mentions du même numéro
    reste non éclaircie (un B4 "corrigé 18/06" dans GÉRANT vs un B4
    parfois cité en basse priorité ailleurs), **mais sans conséquence
    pratique** : le comportement fonctionnel est confirmé résolu par
    Adama (session v26.18). Point purement historique, non bloquant.
3.  **Bug cosmétique score santé** (balises `<strong>` brutes) : ✅
    RÉSOLU en v26.30 --- voir section 5. Deux balises étaient en cause,
    pas une seule, ce qui explique l'échec du premier correctif.
4.  **Cohérence .md/.docx** : cette version .md (v26.18) doit être
    répercutée manuellement par Adama dans le `.docx`, qui reste
    l'unique source. Après édition du `.docx`, il faudra confirmer avec
    Adama s'il souhaite une régénération .md à committer dans le repo
    GitHub, à côté de SCHEMA.md.
5.  **Prochaine priorité de développement** (mis à jour v26.34) : le bug
    cosmétique score santé est fermé (v26.30) et la session RLS dédiée
    est réalisée (§14.4). Restent en attente, par ordre : alerte
    échéance (§16.6, dernier morceau de l'étape 3 CRM), étapes 4 à 6 du
    §16.2 (export WhatsApp, écran Trésorerie/Caisse, mouvements
    hors-bande), authentification JWT (LA faille de fond, prérequis SaaS
    --- voir §14.4), bouton « Forcer la déconnexion » qui ne libère pas
    le verrou, sw.js STATIC_URLS incomplet, mode offline et dashboard
    SaaS (vision long terme).

**15. Module Clôture de Bande (CHANTIER CLOS --- v26.21)**

Le module clôture permet au gérant de terminer définitivement une bande
: archiver son statut, valoriser le stock restant, libérer le bâtiment
et générer un rapport final. Architecture en **6 phases**, fonction
principale renderClotureBande(bandeId).

💡 *En clair : c\'est l\'étape « fin de cycle ». Quand les poulets sont
partis, le gérant clôture la bande --- l\'app fait le bilan, remet le
poulailler à disposition, et fige les chiffres.*

**15.1 Les 6 phases**

  -----------------------------------------------------------------------------
  **Phase**       **Rôle**                                         **Statut**
  --------------- ------------------------------------------------ ------------
  Phase 1 ---     Vérifie l\'ancienneté (14 jours minimum) et le   ✅ Validé
  Éligibilité     statut clôturable                                

  Phase 2 ---     Affiche l\'effectif restant, avec correction     ✅ Validé
  Effectif final  manuelle possible (colonnes                      
                  effectif_final_corrige, effectif_final_note ---  
                  migration 032)                                   

  Phase 3 ---     Valorise le stock restant en écriture RECETTE    ✅ Validé
  Reliquat stock  (catégorie \'Reliquat stock\')                   

  Phase 4 ---     5 lignes lues depuis get_dashboard : recettes,   ✅ Validé
  Bilan financier dépenses, CRU, marge nette, reliquat estimé      

  Phase 5 ---     Pavé PIN dédié, contrôle serveur via             ✅ Validé
  Validation PIN  verifier_pin (rôle GERANT)                       
  gérant                                                           

  Phase 6 ---     Passe la bande en \'CLOTURE\' et libère le       ✅ Validé
  Archivage +     bâtiment (\'LIBRE\')                             
  libération                                                       
  -----------------------------------------------------------------------------

**15.2 Migrations associées**

  ------------------------------------------------------------------------------
  **Migration**   **Contenu**
  --------------- --------------------------------------------------------------
  032             Colonnes effectif_final_corrige, effectif_final_note sur
                  bandes (correction manuelle de l\'effectif final)

  033             RPC cloturer_phase3_reliquat --- écrit l\'écriture RECETTE du
                  reliquat stock

  034             RPC calculer_reliquat_stock --- calcul en lecture seule pour
                  l\'affichage (ne modifie rien)
  ------------------------------------------------------------------------------

**15.3 Règle reliquat --- hors CRU**

Le reliquat stock est enregistré comme une **RECETTE** (pas une
dépense). Il reste donc automatiquement **hors CRU** (le CRU ne compte
que les DEPENSE hors \'Achat stock\'). Aucun filtre spécial nécessaire.

💡 *En clair : le stock qui reste en fin de bande a de la valeur ---
c\'est de l\'argent « récupéré », pas une charge. On le compte donc
comme une recette, et il n\'alourdit pas le coût de revient par poulet.*

**15.4 Validation PIN gérant (Piste A)**

La clôture définitive exige le PIN du gérant. Le front appelle
verifier_pin (p_role = \'GERANT\') côté serveur ; si le PIN est correct,
il enchaîne l\'écriture du reliquat (cloturer_phase3_reliquat) puis
\_confirmerCloture (archivage bande + libération bâtiment).

Fonctions du pavé PIN : \_pinClotureTap, \_pinClotureDel,
\_updateDotsCloture, \_validerCloturePin, \_showClotErr. Variable
globale \_pinCloture. Pavé isolé du login (classes pin-key, points
dot-clot-0 à dot-clot-3).

💡 *En clair : pour éviter qu\'un agent clôture une bande par erreur,
seul le gérant peut valider --- en tapant son code secret, vérifié
directement par le serveur.*

**15.5 Bug B10 --- fermé (v26.21)**

Le code écrivait statut = \'TERMINEE\', valeur **invalide** (la
contrainte bandes_statut_check n\'accepte que \'PREPARATION\', \'EN
COURS\', \'CLOTURE\', \'ARCHIVE\'). Corrigé aux 3 endroits : l\'écriture
réelle du statut, la détection « déjà clôturée », et le texte affiché («
CLÔTURÉE »). Ajout au passage du filtre .eq(\'ferme_id\', FERME_ID) sur
l\'UPDATE de clôture (sécurité multi-fermes).

**15.6 Limite connue --- clôture non atomique**

L\'enchaînement archivage bande → libération bâtiment se fait en deux
écritures séparées (via Promise.all), pas dans une transaction unique.
**Risque théorique** : si la libération du bâtiment échoue après
l\'archivage réussi (coupure réseau), la bande serait clôturée mais le
bâtiment resterait « occupé ». Impact faible et réparable manuellement
(remettre le bâtiment en \'LIBRE\'). Chantier futur si observé sur le
terrain : basculer vers une RPC unique tout-ou-rien.

💡 *En clair : dans un cas très rare (coupure au mauvais moment), le
poulailler pourrait rester marqué « occupé » alors que la bande est
finie. Facile à corriger à la main. On blindera seulement si ça arrive
vraiment.*

**NOUVELLE SECTION 16 --- Module CRM Clients**

**16. Module CRM Clients (chantier en cours --- démarré v26.21/v26.22)**

**16.1 Objectif**

Permettre au gérant de gérer ses clients, leurs commandes (précommandes
puis livraisons), et le suivi des paiements/créances. Séparation
comptable OHADA : **CRÉANCES** (qui me doit) distinctes de la **CAISSE**
(combien j\'ai réellement).

**Seul le GÉRANT saisit.** Réservé à l\'onglet GESTION.

**16.2 Découpage en 6 étapes**

  ----------------------------------------------------------------------------
  **Étape**   **Contenu**                                   **Statut**
  ----------- --------------------------------------------- ------------------
  1           Clients + catalogue produits                  ✅ Migration 035

  2           Livraison → vente → recette journal           ○ À faire

  3           Suivi paiements / créances                    ✅ Validé (v26.34)

  4           Export WhatsApp commande                      ○ À faire

  5           Écran Trésorerie / Caisse                     ○ Validé v26.39

  6           Mouvements hors-bande + injections            ○ À faire
              partenaires                                   
  ----------------------------------------------------------------------------

**16.3 Migration 035 --- Socle (exécutée)**

-   produits_catalogue : nom, unite, prix_reference,
    **decremente_effectif**, actif

-   clients : nom, telephone, adresse, type_client, note, actif

-   5 produits pré-remplis × 2 fermes : Sujet vivant (decremente=true),
    Poulet entier abattu (true), Foies & gésiers (kg, false), Cous
    têtes+pattes (kg, false), Sac de fientes (sac, false)

**16.4 Migration 036 --- Cœur CRM (exécutée v26.22)**

Trois tables, toutes avec ferme_id NOT NULL + RLS (ferme_id =
get_ferme_id()) :

**commandes** --- en-tête du bon de commande

-   client_id, date_commande, statut, date_reglement_prevue, note

-   statut ∈ PRECOMMANDE / PLANIFIEE / LIVREE / ANNULEE

-   **Pas de colonne total** --- calculé à la volée depuis les lignes

**commande_lignes** --- 1 ligne = 1 produit + 1 bande

-   commande_id (CASCADE), produit_id, bande_id, quantite, prix_prevu,
    prix_reel

-   **bande_id OPTIONNEL en base** (fientes, abats hors bande)

-   **Mais OBLIGATOIRE à l\'écran** pour les produits avec
    decremente_effectif = true

-   Prix **prévu** (à la commande) et **réel** (à la livraison) : les
    deux conservés

**paiements** --- encaissements

-   commande_id **NOT NULL** (chaque paiement = 1 commande précise),
    client_id, montant, date_paiement, moyen, type, note

-   moyen ∈ CASH / MOBILE_MONEY / VIREMENT / CHEQUE / AUTRE

-   type ∈ ACOMPTE / SOLDE

-   client_id est une **redondance contrôlée** (accessible via commande,
    mais évite une jointure sur chaque calcul de créance client)

**16.5 Décisions métier actées (ne pas rouvrir sans demande explicite)**

1.  **Total calculé, jamais stocké** --- il existe un total prévu ET un
    total réel ; les stocker créerait un risque de désynchronisation.

2.  **Chaque paiement rattaché à une commande précise** --- pas
    d\'acompte flottant.

3.  **Commande multi-produits ET multi-bandes** --- d\'où le modèle
    en-tête + lignes.

4.  **Abattage = module futur séparé.** Le CRM enregistre la vente de
    produits abattus sans toucher l\'effectif de la bande.

5.  **Injections partenaires** : s\'appuieront sur partenaires_bandes
    (il n\'existe PAS de table partenaires seule).

**16.6 Alerte échéance --- ✅ RÉALISÉE (v26.37)**

Rappel sur l\'accueil gérant des commandes livrées non soldées dont
l\'échéance de règlement approche ou est dépassée. Trois couleurs : 🔴
échéance dépassée ou due ce jour · 🟡 J-1 à relancer (demain, strict) ·
⚪ lointaine. Compteur sur la tuile Clients : non encore implémenté
(voir §23.5).

Le prérequis qui bloquait ce chantier est levé : la saisie de
date_reglement_prevue existe désormais, réalisée à la livraison (feature
v26.37, §18.9). Diagnostic confirmé en base le 29/07/2026 : la colonne
se remplit bien via cette saisie.

**Réalisation complète documentée en §23** : RPC serveur
get_alertes_echeance() (source unique, filtrée get_ferme_id()), bannière
cliquable sur l\'accueil gérant (renderGerant dans index.html, §17 pour
la frontière avec les modules ES), trois seuils de couleur.

💡 En clair : la sonnette qui prévient « ce client doit payer » est
désormais installée et fonctionnelle. On a d\'abord construit l\'endroit
où poser la date d\'échéance (à la livraison), puis la sonnette qui la
lit.

**16.7 État actuel (fin v26.22)**

-   ✅ Tables en base (035 + 036)

-   ✅ Onglet GESTION + page tuiles (Clients active, Trésorerie/Stock
    grisées)

-   ○ Écran Clients (liste, ajout, modification) --- **prochain
    chantier**

**④ NOUVELLE SECTION 17 --- Architecture modules séparés**

**17. Architecture modules séparés (établie v26.22)**

**17.1 Le problème**

index.html fait \~5900 lignes, tout le code dans un seul \<script\>
inline. Ajouter le CRM, la trésorerie et l\'abattage dedans reviendrait
à aggraver le spaghetti.

**Décision** : les nouveaux modules sont construits **dans des dossiers
séparés**, en **vrais modules ES** (type=\"module\"). index.html
**n\'est PAS redécoupé** --- trop risqué. On greffe proprement à côté ;
la migration de l\'ancien code viendra plus tard.

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

├── clients/ ← écran Clients (CRM §16)

├── commandes/ ← CRM Commandes + Paiements (§18, §19)

└── parametres/ ← écran Paramètres (§20)

Arborescence à jour au 23/07/2026 (v26.35). Chaque nouveau module suit
la même règle : un dossier dédié, un vrai module ES, une seule porte
d'entrée exposée sur window (§17.4).

**17.3 Le \"guichet\" avigestContext() --- point clé**

**Problème découvert en v26.22** (vérifié en console) :

  --------------------------------------------------------------------------
  **Variable**   **Déclarée       **Visible depuis un module ?**
                 avec**           
  -------------- ---------------- ------------------------------------------
  sb             var (ligne       ✅ Oui --- var global va sur window
                 \~549)           

  App            const/let        ❌ Non --- window.App = undefined

  FERME_ID       const/let        ❌ Non --- window.FERME_ID = undefined
  --------------------------------------------------------------------------

Sans FERME_ID, aucun module ne peut filtrer ses requêtes par ferme → CRM
impossible.

**Solution retenue** : index.html expose **une seule fonction**, en fin
de script inline :

javascript

window.avigestContext = function () {

return {

sb: (typeof sb !== \'undefined\') ? sb : null,

role: (typeof App !== \'undefined\' && App) ? App.role : null,

fermeId: (typeof FERME_ID !== \'undefined\') ? FERME_ID : null

};

};

C\'est **l\'unique frontière** entre l\'ancien code et les nouveaux
modules. Les modules **lisent** une photo de l\'état ; ils ne peuvent
pas modifier les originaux.

**RÈGLE ABSOLUE** : ne jamais mettre sb en cache dans une variable de
module. sb est **réaffecté au login** (index.html \~526) une fois le
FERME_ID connu. Une copie gardée en mémoire porterait le mauvais header
x-ferme-id. Toujours appeler db() au moment de s\'en servir.

**17.4 Branchement sur le Nav existant**

NAVBAR_CONFIG (ligne \~1402) est une simple liste d\'objets. Le clic
exécute \_navTap(id, fn) qui appelle window\[fn\]().

Un module isolé n\'est pas dans window --- il doit **s\'exposer
explicitement**, mais **une seule porte d\'entrée** :

javascript

window.renderGestion = renderGestion; // la \"sonnette\" du module

Tout le reste du fichier reste privé → **zéro collision** avec les
\~5900 lignes d\'index.html.

**17.5 Serveur local obligatoire en développement**

Les modules ES **ne se chargent pas** depuis un fichier ouvert en
double-clic (file:///\...). Le navigateur les refuse.

**Commande à lancer avant chaque session de dev**, depuis le dossier du
projet :

npx serve

Puis tester sur http://localhost:3000. Laisser le terminal ouvert
(Ctrl+C pour arrêter).

**En production sur GitHub Pages : aucun problème** --- GitHub Pages
*est* un serveur. La contrainte est purement locale.

**17.6 Greffe dans index.html (4 lignes au total)**

1.  NAVBAR_CONFIG → { id:\'gestion\', icon:\'📋\', label:\'Gestion\',
    fn:\'renderGestion\' },

2.  \<head\> → \<link rel=\"stylesheet\" href=\"css/gestion.css\"\>

3.  Fin de \<script\> inline → la fonction avigestContext()

4.  Avant \</body\> → \<script type=\"module\"
    src=\"js/gestion/gestion.js\"\>\</script\>

**⑤ AJOUTER --- Points en suspens**

**Ajouter à la liste des points en suspens :**

6.  **sw.js --- STATIC_URLS incomplet --- ✅ RÉSOLU v26.35** (ouvert
    v26.22, fermé v26.35). La liste ne contenait que /AVIGEST4/ et
    /AVIGEST4/index.html --- elle compte désormais 9 entrées, tous les
    modules ES inclus. Voir §21 pour le détail du correctif.

7.  **Warning Multiple GoTrueClient instances detected** (observé
    v26.22) : deux clients Supabase coexistent dans la page --- création
    ligne 549 puis réaffectation ligne 526 d\'index.html. Sans gravité
    constatée à ce jour, mais à surveiller. --- À ajouter également : la
    règle \~\$\* dans .gitignore, pour ignorer les fichiers temporaires
    Word (\~\$ble_avigest_v26.docx remonte à chaque commit).

8.  **Doublon de policy RLS sur clients** (observé v26.22) --- RÉSOLU en
    v26.30 (Migration 042) : la policy redondante ferme_isolation a été
    supprimée, clients_isolation conservée. Le même doublon a ensuite
    été nettoyé sur taches (Migration 043) puis sur bandes, journal,
    mouvements_stock et saisies_techniques (Migration 044). ⚠️ Il
    subsiste sur la table fermes : ferme_isolation (ALL) fait double
    emploi avec fermes_select (SELECT) et fermes_update (UPDATE), toutes
    sur id = get_ferme_id() (observé v26.34). Sans danger, rangement pur
    --- à traiter dans une future migration.

**⑥ METTRE À JOUR --- Section 2.1 (version)**

\| **Version actuelle** \| **APP_VERSION = \'v26.22\' · CACHE_NAME =
\'avigest-v26-22\'** \|

**⑦ METTRE À JOUR --- Section 2.5 (migrations)**

Ajouter les deux dernières lignes :

\| 035_crm_clients_catalogue.sql \| Tables clients + produits_catalogue
(CRM étape 1) \| \| 036_crm_commandes.sql \| Tables commandes,
commande_lignes, paiements + suppression tables mortes ventes/paiements
\|

*--- Fin de la mise à jour Bible session v26.22 ---*

**18. Module CRM Commandes (CHANTIER CLOS --- v26.25)**

**18.1 Objectif et périmètre**

Le CRM Commandes est le **chemin de vente officiel** d\'AviGest depuis
v26.26. Il remplace intégralement l\'ancien circuit « Vente » (voir
§18.6). Le gérant crée un bon de commande multi-produits / multi-bandes,
le fait passer de précommande à planifiée, puis le livre --- la
livraison étant le seul moment où l\'effectif de la bande et la recette
au journal sont réellement impactés.

**Seul le GÉRANT saisit.** Réservé à l\'onglet GESTION, module
js/commandes/commandes.js.

**18.2 Les 4 morceaux (tous validés)**

  --------------------------------------------------------------------------
  **Morceau**   **Contenu**                                **Statut**
  ------------- ------------------------------------------ -----------------
  1 --- Détail  Écran détail de commande en lecture seule  ✅ v26.23

  2 ---         Transition Précommande → Planifiée (avec   ✅ v26.24 /
  Workflow      date livraison obligatoire)                v26.27

  3 ---         Écran Livraison → RPC livrer_commande      ✅ v26.25
  Livraison     (atomique)                                 

  4 ---         Passage d\'une commande au statut ANNULEE  ✅ v26.25
  Annulation                                               
  --------------------------------------------------------------------------

**18.3 Le RPC livrer_commande (Migration 039)**

Signature : **livrer_commande(p_commande_id uuid, p_lignes jsonb,
p_date_reglement date DEFAULT NULL)**. Le 3e paramètre, ajouté par la
Migration 048 (v26.37), est optionnel : il porte l'échéance de règlement
saisie à la livraison (voir §18.9).

Opération **atomique** : elle lit get_ferme_id() (isolation
multi-tenant), enregistre les prix réels ligne par ligne, décrémente
l\'effectif de la bande pour les produits marqués decremente_effectif =
true, écrit la recette au journal, et fait passer la commande au statut
LIVREE. Tout réussit ensemble ou rien --- pas de demi-livraison
possible.

Test en base : SET LOCAL request.headers =
\'{\"x-ferme-id\":\"e56574a9\...\"}\' dans le SQL Editor avant l\'appel.

**18.4 Les deux dates d\'une commande (ne pas confondre)**

Une commande porte **deux dates distinctes**, chacune dans sa propre
colonne :

  -------------------------------------------------------------------------
  **Colonne**             **Sens**                             **Depuis**
  ----------------------- ------------------------------------ ------------
  date_reglement_prevue   Date à laquelle le client doit       Migration
                          régler (échéance de paiement)        036

  date_livraison_prevue   Date à laquelle la commande doit     Migration
                          être livrée physiquement             040 (v26.27)
  -------------------------------------------------------------------------

Règle de saisie : la **date de livraison prévue est OBLIGATOIRE** au
moment de la planification (garde dans \_validerPlanification, écran
\_dessinerPlanification). Elle s\'affiche ensuite dans la liste des
commandes (« 📅 Livraison prévue : ... », ligne conditionnelle).

**18.5 Design figé (v26.25)**

Classes CSS dédiées, respectant le cadre couleur = sens :
.gestion-livr-\* (écran de livraison), .gestion-annul-\* (écran
d\'annulation). Une seule action vive par écran, confirmation avant tout
impact argent/effectif --- conformément au cadre de design boutons figé
v26.25.

**18.6 Amputation de l\'ancien chemin « Vente » (v26.26 --- anti
double-comptage)**

Une fois le CRM devenu le chemin de vente officiel, l\'ancien écran de
vente devait cesser de produire des effets comptables, sinon chaque
vente serait comptée deux fois. **Deux effets ont été débranchés :**

6.  **Recette** --- fonction \_enregistrerJournalVente (index.html) :
    l\'ancien écran n\'écrit plus de recette au journal. Il marque juste
    la tâche COMPTABILISEE, affiche un toast « Les ventes se gèrent
    maintenant dans les Commandes » et redirige. Ajout de
    .eq(\'ferme_id\', FERME_ID) sur l\'UPDATE tâche (isolation, absente
    avant).

7.  **Effectif vendu** --- fonction \_soumettreAbattageAgent
    (index.html) : l\'agent ne touche plus au compteur effectif_vendu de
    la bande. Il saisit toujours nb_sujets_reels (suivi terrain), mais
    l\'effectif est désormais géré uniquement par la livraison CRM via
    livrer_commande.

Testé de bout en bout : ancien chemin = 0 recette, CRM = 1 recette avec
bénéficiaire rattaché à la bande. Confirmé.

**18.7 Renommage onglet « Vente » → « Abattage » (v26.28)**

Fonction renderCycleVie (index.html) : le label de l\'onglet
id:\'abattage\' passe de « Vente » à « Abattage » (un seul mot changé).
**Décision de périmètre :** on n\'a PAS touché la tuile « Vente » ni les
écrans renderPlanVente / \_renderTabAbattage --- ils appartiennent au
circuit en voie d\'extinction (remplacé par le CRM), inutile de les
renommer.

**18.8 Données de test CRM (référence)**

Vrai client des commandes : **67a139ea-9108-4f2e-b86b-0c7c07abbbcb** (⚠️
PAS 6b78a4a9 --- ancien id erroné d\'un vieux brief).

Produit test : Poulet entier abattu 96dec36b-19f0-4cb2-961d-682169b126b0
(unité kg, decremente_effectif = true).

Bande test : Bande-2026-999 33631a47-93c4-49d9-8771-45f8ee2d4278
(REVAGRO). Après tests d\'abattage : restaurer effectif_vendu = 0 et
supprimer les tâches ABATTAGE de test.

**Note de mise à jour --- Section 16.2 (découpage CRM)**

L\'étape 2 du découpage CRM (« Livraison → vente → recette journal »)
est désormais **✅ Validé** --- réalisée par le module CRM Commandes
(voir §18, RPC livrer_commande). Les étapes 3 à 6 (suivi
paiements/créances, export WhatsApp, écran Trésorerie/Caisse, mouvements
hors-bande) restent ○ À faire.

**Mise à jour --- Section 2.1 (version) et 2.5 (migrations)**

**Version actuelle : APP_VERSION = 'v26.37' · CACHE_NAME =
'avigest-v26-37'**.

Migrations ajoutées depuis v26.22 (à jour au 23/07/2026) :

  ---------------------------------------------------------------------------
  **Fichier**                        **Contenu**
  ---------------------------------- ----------------------------------------
  039_livrer_commande.sql            RPC livrer_commande --- livraison
                                     atomique CRM (effectif + recette +
                                     statut LIVREE)

  040_date_livraison_commandes.sql   ALTER TABLE commandes ADD COLUMN
                                     date_livraison_prevue date

  041 --- VACANT                     Migration abandonnée avant exécution
                                     (ciblait un nom de policy inexistant).
                                     Aucune trace en base --- numéro laissé
                                     volontairement vide.

  042_clients_policy_doublon.sql     Nettoyage du doublon de policy RLS sur
                                     clients --- suppression de
                                     ferme_isolation, conservation de
                                     clients_isolation (v26.30).

  043_menage_policy_taches.sql       DROP POLICY ferme_isolation ON taches
                                     --- doublon avec acces_par_ferme (rôle
                                     anon), cette dernière conservée
                                     (v26.30).

  044_menage_policies_suite.sql      Même ménage sur journal,
                                     mouvements_stock, saisies_techniques et
                                     bandes. ⚠️ La policy
                                     partenaire_ses_bandes sur bandes est une
                                     policy MÉTIER (accès partenaire à ses
                                     seules bandes) --- volontairement NON
                                     supprimée. Ne jamais la confondre avec
                                     un doublon.

  045                                ⚠️ Numéro non documenté --- fichier à
                                     retrouver dans migrations/ et à décrire
                                     ici.

  046_paiements_numerotation.sql     Sur paiements : annee (int NOT NULL,
                                     default année courante), numero_seq (int
                                     NOT NULL, sans default --- calculé côté
                                     JS), annule (bool NOT NULL default
                                     false), contrainte UNIQUE (ferme_id,
                                     annee, numero_seq) « carnet à souches »,
                                     CHECK (montant \> 0), index sur
                                     commande_id.

  047_fermes_nom_commercial.sql      Sur fermes : ajout de nom_commercial
                                     (text, nullable). Les colonnes nom,
                                     proprietaire, telephone, ville, pays,
                                     email existaient déjà. Policy
                                     fermes_update déjà présente --- aucun
                                     ajout RLS.

  048_livrer_commande_echeance.sql   Ajoute le paramètre p_date_reglement
                                     date DEFAULT NULL au RPC
                                     livrer_commande, pour saisir l'échéance
                                     de règlement au moment de la livraison.
                                     ⚠️ Le DEFAULT NULL n'empêche PAS la
                                     surcharge : PostgreSQL a créé une 2e
                                     fonction (oid 19628) à côté de
                                     l'ancienne (19433). L'ancienne a dû être
                                     supprimée --- voir §18.3.
  ---------------------------------------------------------------------------

Dernière migration : **048**.

**18.9 Saisie de l'échéance de règlement à la livraison (v26.37)**

Diagnostic fondateur (24/07/2026) : sur 7 commandes en base, ZERO
portait une date_reglement_prevue. La colonne existait depuis la
Migration 036 mais aucun écran ne la remplissait. L'alerte échéance
(§16.6) était donc impossible --- une sonnette sans personne pour poser
la date. Ce chantier construit la saisie ; l'alerte viendra après.

**Choix de conception (actés par Adama) :**

• Échéance OPTIONNELLE --- un client qui paie comptant ne génère pas de
créance, la date reste NULL. • Saisie À LA LIVRAISON --- c'est le moment
où la créance naît réellement et où le gérant connaît le délai accordé.
• Intégrée au RPC plutôt qu'un UPDATE séparé, pour préserver l'atomicité
de livrer_commande (§18.3).

**Interface (module js/commandes/commandes.js, écran de livraison) :**

Un bloc « Échéance de règlement » ajouté avant le bouton Confirmer.
Quatre pastilles de raccourci --- Comptant, +7 jours, +15 jours, +30
jours --- plus un champ date pour une saisie libre. Une ligne
d'affichage confirme la date choisie (« Échéance : 11/08/2026 ») ou
l'absence d'échéance (« Paiement comptant »). Design conforme au cadre
§4.4 : les pastilles en contour gris, le bouton Confirmer en vert reste
la seule action vive.

**La variable de module \_livrEcheance porte trois états :**

  -----------------------------------------------------------------------
  **Valeur**           **Signification**
  -------------------- --------------------------------------------------
  undefined            Rien choisi --- transmis comme null au RPC
                       (COALESCE garde l'existant).

  null                 « Comptant » cliqué --- pas de créance.

  'AAAA-MM-JJ'         Une date posée --- transmise telle quelle.
  -----------------------------------------------------------------------

⚠️ \_livrEcheance est réinitialisée à undefined au début de
\_dessinerLivraison(), sinon l'échéance d'une commande resterait collée
à la livraison suivante --- piege classique d'une variable de module.

Fonctions ajoutées : \_setEcheance(jours), \_setEcheanceDate(val),
\_majEcheanceUI() (les deux premières exposées sur window pour les
onclick inline, §17.4). L'appel RPC reçoit p_date_reglement:
\_livrEcheance ?? null.

**⚠️ Leçon confirmée en conditions réelles --- surcharge malgré le
DEFAULT**

La Migration 048 utilisait CREATE OR REPLACE FUNCTION avec le nouveau
paramètre p_date_reglement \... DEFAULT NULL. On croyait que le DEFAULT
suffirait à remplacer l'ancienne fonction. FAUX : PostgreSQL a créé une
SECONDE fonction (oid 19628) à côté de l'ancienne (oid 19433), car la
signature diffère. Le DEFAULT ne sert qu'à rendre les appels à 2
arguments valides sur la nouvelle version ; il n'efface jamais
l'ancienne. Conséquence : un appel à 2 arguments devenait ambigu.
Corrigé par DROP FUNCTION public.livrer_commande(uuid, jsonb). C'est
exactement le piège de surcharge déjà documenté en §6 pour imputer_stock
--- reproduit puis corrigé. Toujours relancer le diagnostic
pg_get_function_identity_arguments après un changement de signature.

**Validation (v26.37) :**

Test en base (transaction annulée) : livrer_commande avec +15 jours pose
bien date_reglement_prevue, une seule fonction en base après le DROP.
Test à l'écran : pastilles fonctionnelles, Comptant → null, +Nj → date
calculée et affichée. Livraison réelle de bout en bout confirmée (chemin
JS → RPC → journal → effectif). Données de test nettoyées (recette 22
000 F supprimée du journal).

💡 En clair : jusqu'ici, quand tu livrais, tu ne notais nulle part quand
le client devait payer. Maintenant, au moment de livrer, tu tapes « dans
15 jours » ou « comptant », et l'app retient la date. C'est la pièce qui
manquait pour, plus tard, faire sonner un rappel « ce client doit payer
demain ».

## 19. Module Paiements / Créances (CHANTIER CLOS --- v26.34)

### 19.1 Objectif et périmètre

Ce module met en œuvre l'étape 3 du découpage CRM (§16.2) : le suivi des
encaissements et des créances. Il permet au gérant d'enregistrer les
règlements reçus sur une commande, de connaître à tout moment le reste à
payer, de produire un reçu numéroté pour le client, et d'annuler un
paiement saisi par erreur sans jamais l'effacer.

Il applique la séparation comptable OHADA posée en §16.1 : une commande
livrée crée une CRÉANCE (le client me doit) ; un paiement enregistré
alimente la CAISSE (ce que j'ai réellement encaissé). Les deux ne se
confondent jamais.

**Seul le GÉRANT saisit. Réservé à l'onglet GESTION, module
js/commandes/commandes.js (bloc Règlement du détail commande).**

💡 En clair : une commande livrée, ce n'est pas de l'argent en poche ---
c'est une promesse de paiement. Ce module suit qui a payé quoi, combien
il reste à encaisser, et donne au client un reçu numéroté comme un
carnet à souches.

### 19.2 Les 6 morceaux (tous validés)

  ---------------------------------------------------------------------------
  **Morceau**   **Contenu**                                  **Version**
  ------------- -------------------------------------------- ----------------
  1             Migration 046 --- numérotation et annulation ✅ v26.30
                des paiements                                

  2             Bloc Règlement dans l'écran détail commande  ✅ v26.31

  3             Saisie du montant + écran de confirmation +  ✅ v26.32
                enregistrement                               

  4             Reçu à copier (texte formaté vers le         ✅ v26.33
                presse-papier)                               

  5             Annulation d'un paiement avec motif          ✅ v26.34
                obligatoire                                  

  6             Migration 047 + écran Paramètres +           ✅ v26.34
                branchement de l'identité ferme sur le reçu  
  ---------------------------------------------------------------------------

### 19.3 Migration 046 --- numérotation et annulation

Fichier : 046_paiements_numerotation.sql. Modifications sur la table
paiements (créée par la Migration 036, voir §16.4) :

  -----------------------------------------------------------------------
  **Élément**        **Rôle**
  ------------------ ----------------------------------------------------
  annee (int NOT     Année du reçu. Default : année courante.
  NULL)              

  numero_seq (int    Numéro d'ordre dans l'année. ⚠️ SANS default ---
  NOT NULL)          calculé côté JS (voir §19.5).

  annule (bool NOT   Default false. Un paiement annulé n'est jamais
  NULL)              supprimé, il est marqué.

  UNIQUE (ferme_id,  Le « carnet à souches » : impossible d'avoir deux
  annee, numero_seq) reçus portant le même numéro dans une même ferme et
                     une même année.

  CHECK (montant \>  Faille comblée : la table acceptait auparavant un
  0)                 montant nul ou négatif.

  Index sur          Performance --- le calcul du total payé interroge
  commande_id        les paiements d'une commande.
  -----------------------------------------------------------------------

### 19.4 Les 8 règles métier (actées --- ne pas rouvrir sans demande explicite d'Adama)

  --------------------------------------------------------------------------
  **N°**   **Règle**                  **Justification / détail**
  -------- -------------------------- --------------------------------------
  1        Paiement possible dès le   Jamais sur une PRECOMMANDE (rien n'est
           statut PLANIFIEE           encore engagé) ni sur une commande
                                      ANNULEE.

  2        Bouton présent uniquement  Une commande soldée n'affiche plus
           si reste à payer \> 0      d'action de paiement --- pas de
                                      sur-encaissement possible.

  3        Le type ACOMPTE / SOLDE    Si le montant égale le reste à payer →
           est déduit, jamais saisi   SOLDE, sinon ACOMPTE. Une saisie
                                      humaine créerait des incohérences.

  4        Montant refusé si ≤ 0 ou   Double garde : côté JS pour le message
           \> reste à payer           d'erreur, côté base par le CHECK
                                      (montant \> 0).

  5        Numérotation               Compteur par ferme ET par an. Ex.
           REC-{annee}-{seq sur 4     REC-2026-0007. Voir §19.5.
           chiffres}                  

  6        Jamais de suppression d'un Annulation uniquement : annule =
           paiement                   true + motif obligatoire préfixé dans
                                      note, au format \[ANNULÉ le JJ/MM/AAAA
                                      : motif\]. Traçabilité comptable.

  7        Un paiement annulé :       Il reste visible --- le carnet à
           barré, sans bouton 📋 ni   souches garde la souche annulée ---
           ✕, exclu du total payé     mais ne compte plus.

  8        Reçu = texte copié dans le Pas de lien wa.me, pas besoin du
           presse-papier              téléphone du client. Le gérant colle
                                      où il veut (WhatsApp, SMS, e-mail).
  --------------------------------------------------------------------------

### 19.5 Numérotation des reçus --- option A assumée

Format : REC-{annee}-{numero_seq sur 4 chiffres}. Le compteur est propre
à chaque ferme et redémarre à 1 chaque année.

    REC-2026-0001
    REC-2026-0002
    …
    REC-2027-0001   (remise à zéro au changement d’année)

Choix technique (option A, assumé) : le numéro suivant est calculé côté
JS --- lecture du plus grand numero_seq de la ferme pour l'année en
cours, puis +1. Ce n'est pas une séquence PostgreSQL.

**⚠️ Limite connue et acceptée : deux saisies rigoureusement simultanées
pourraient calculer le même numéro. La contrainte UNIQUE (ferme_id,
annee, numero_seq) sert de garde-fou : la seconde insertion est alors
refusée par la base plutôt que de créer un doublon. Risque jugé
négligeable --- un seul gérant saisit, et les paiements sont rares. Si
un jour plusieurs gérants saisissent en parallèle, basculer vers une
séquence côté base (option B).**

💡 En clair : c'est un carnet à souches. Chaque reçu porte un numéro qui
se suit, remis à zéro chaque 1er janvier, et propre à chaque ferme.
L'app regarde le dernier numéro utilisé et prend le suivant. Si par un
hasard extrême deux reçus tombaient sur le même numéro, la base refuse
le second au lieu de laisser passer deux souches identiques.

### 19.6 Annulation d'un paiement

Un paiement n'est jamais supprimé. L'annulation pose annule = true et
préfixe le champ note avec le motif, au format imposé :

    [ANNULÉ le 23/07/2026 : erreur de montant] note précédente…

Le motif est obligatoire --- aucune annulation « muette ». À l'écran, la
ligne apparaît barrée, perd ses boutons 📋 (copier le reçu) et ✕
(annuler), et son montant sort du total payé. Le reste à payer remonte
donc automatiquement.

### 19.7 Le reçu

Le reçu est un texte formaté, copié dans le presse-papier par le bouton
📋. Il porte l'identité commerciale de la ferme, lue dans la table
fermes (voir §2.4 bis et §20) : nom_commercial en tête, telephone et
ville en pied. Si nom_commercial est vide, le nom technique sert de
repli.

⚠️ Dépendance à connaître : le contenu du reçu dépend de l'écran
Paramètres (§20). Une ferme dont le nom commercial et le téléphone ne
sont pas renseignés produira un reçu incomplet, sans erreur visible.

### 19.8 Fonctions et variables ajoutées à commandes.js

Fonctions :

    _blocReglement            _texteRecu
    _numeroRecu               _copierRecu
    _totalPaye                _chargerIdentiteFerme
    _nouveauPaiement          _annulerPaiement
    _dessinerPaiement         _dessinerAnnulPaiement
    _solderPaiement           _confirmerAnnulPaiement
    _verifierPaiement
    _dessinerConfirmationPaiement
    _confirmerPaiement

Variables de module :

    _detailCmd    _payCmd    _payReste    _paySaisie    _annulPay    _identiteFerme

Rappel §17.3 : ces fonctions vivent dans un module ES. Toute fonction
appelée en onclick inline doit être exposée sur window. Et l'accès
Supabase passe toujours par avigestContext() au moment de s'en servir
--- jamais par une copie de sb mise en cache.

### 19.9 Données de test en base

⚠️ La commande « Boucherie » porte au moins un paiement annulé et un
paiement soldé, créés pour tester l'affichage. Utiles pour vérifier le
rendu (ligne barrée, exclusion du total), à nettoyer avant toute mise en
service réelle.

### 19.10 Reste à faire --- alerte échéance

Le dernier morceau de l'étape 3 CRM n'est pas commencé : l'alerte
d'échéance décrite en §16.6 (rappel J-1 sur l'accueil gérant, trois
couleurs, compteur sur la tuile Clients).

**⚠️ Deux points à diagnostiquer AVANT de coder : (1) l'alerte s'appuie
sur commandes.date_reglement_prevue, à ne pas confondre avec
date_livraison_prevue (§18.4) ; (2) il n'est pas certain qu'un écran
permette aujourd'hui de SAISIR date_reglement_prevue --- si la colonne
reste vide, l'alerte n'aura rien à afficher. Vérifier en base et dans le
code avant tout développement.**

⚠️ Terrain différent : l'accueil gérant vit dans index.html (\~5900
lignes), pas dans les modules ES. Voir §17 pour la frontière entre les
deux mondes.

## 20. Écran Paramètres --- identité commerciale de la ferme (v26.34)

### 20.1 Objectif

Premier écran de configuration d'AviGest. Il permet au gérant de
renseigner l'identité commerciale de sa ferme --- celle qui apparaît sur
les documents remis aux clients, à commencer par les reçus de paiement
(§19.7).

Né d'un besoin concret : le reçu devait porter un nom lisible par le
client (« Kalycoq ») plutôt que le nom technique du tenant (« REVAGRO
»), sans avoir à modifier la base à la main.

**Seul le GÉRANT y accède. Onglet GESTION, tuile ⚙️. Module
js/parametres/parametres.js.**

💡 En clair : c'est la page « en-tête de papier à lettres ». Tu y écris
une fois le nom commercial et le téléphone de ta ferme, et ça s'imprime
tout seul en haut de chaque reçu remis à un client.

### 20.2 Migration 047

Fichier : 047_fermes_nom_commercial.sql. Une seule colonne ajoutée à la
table fermes :

    ALTER TABLE fermes ADD COLUMN nom_commercial text;   -- nullable

**⚠️ Leçon de diagnostic : la table contenait DÉJÀ nom, proprietaire,
telephone, ville, pays et email. Aucune autre colonne n'était
nécessaire. La policy fermes_update existait également déjà --- aucun
ajout RLS. Sans la vérification préalable en base (règle absolue n°1),
la migration aurait tenté de recréer des colonnes existantes et échoué
en bloc, une migration étant transactionnelle (§4.1).**

Schéma complet de la table fermes : voir §2.4 bis.

### 20.3 Les trois champs modifiables

  ------------------------------------------------------------------------
  **Champ**        **Colonne**             **Usage**
  ---------------- ----------------------- -------------------------------
  Nom commercial   fermes.nom_commercial   Tête du reçu de paiement. Repli
                                           sur fermes.nom si vide.

  Téléphone        fermes.telephone        Pied du reçu de paiement.

  Ville            fermes.ville            Pied du reçu. Default en base :
                                           'Ouagadougou'.
  ------------------------------------------------------------------------

⚠️ Les autres colonnes de fermes (nom technique, proprietaire, pays,
email, plan, nb_batiments, code_acces, actif) ne sont PAS modifiables
depuis cet écran. code_acces en particulier commande le login par code
ferme : le rendre éditable exposerait au risque de verrouiller une ferme
entière hors de l'application.

### 20.4 Branchement dans l'onglet GESTION

Une tuile ⚙️ a été ajoutée dans js/gestion/gestion.js, aux côtés des
tuiles existantes (Clients, Commandes...). Le module suit exactement les
conventions du §17 :

• vrai module ES dans son propre dossier js/parametres/ ; • accès
Supabase via avigestContext() appelé au moment de s'en servir, jamais
mis en cache ; • une seule porte d'entrée exposée sur window ; • toute
fonction appelée en onclick inline exposée sur window.

### 20.5 Point de vigilance --- relecture des valeurs enregistrées

**⚠️ Constat non tranché à la clôture de la v26.34 : sur une capture
d'écran de vérification, le champ « Nom commercial » paraissait vide
(placeholder gris) alors que le reçu affichait bien « Kalycoq », et le
champ Téléphone vide alors que le reçu portait le numéro.**

Deux hypothèses : soit la capture a été prise avant l'enregistrement,
soit la fonction de rendu de l'écran ne relit pas correctement la ligne
fermes au chargement. L'écriture fonctionne --- c'est prouvé par le
reçu, qui lit les mêmes colonnes. Le doute ne porte que sur la
relecture.

Test de contrôle : GESTION → ⚙️ Paramètres. Les trois champs doivent
afficher les valeurs enregistrées en texte plein, pas en gris de
placeholder. Si les champs sont gris alors que le reçu est correct, le
défaut est dans la relecture.

💡 En clair : l'information est bien écrite dans la base --- la preuve,
elle sort sur les reçus. Le doute, c'est de savoir si l'écran de réglage
sait la relire quand on y revient. Sinon le gérant croit ses réglages
perdus et les ressaisit inutilement.

### 20.6 Perspective

Cet écran est le point d'entrée naturel des futurs réglages de ferme.
Deux colonnes déjà présentes en base l'attendent : plan (default 'FREE')
et nb_batiments (default 6), toutes deux inexploitées à ce jour. Elles
constituent le socle du modèle tarifaire SaaS (§13.5) --- à exposer ici
le moment venu, en lecture seule pour le gérant.

## 21. Service Worker et cache hors ligne (v26.35)

### 21.1 Ce qui a été corrigé

Le point en suspens n°6, ouvert depuis la v26.22 et aggravé à chaque
nouveau module, est fermé. Quatre corrections dans sw.js, en un seul
commit dédié :

1\) CACHE_NAME porté à avigest-v26-37, en même temps qu'APP_VERSION dans
index.html (règle §4.3). 2) STATIC_URLS passé de 2 à 9 entrées :
css/gestion.css, js/shared/db.js, js/shared/helpers.js,
js/gestion/gestion.js, js/clients/clients.js, js/commandes/commandes.js,
js/parametres/parametres.js. 3) Installation rendue tolérante (voir
§21.2). 4) Mise en cache conditionnée à resp.ok, et repli explicite si
le cache est vide (voir §21.3).

### 21.2 cache.addAll → Promise.allSettled --- le point important

**L'ancienne installation utilisait cache.addAll(STATIC_URLS). Cette
méthode est tout-ou-rien : si UNE seule URL de la liste est introuvable,
la promesse est rejetée et AUCUN fichier n'est mis en cache --- le
service worker ne s'installe pas du tout. Avec une liste de 2 entrées le
risque était faible ; avec 9, une faute de frappe suffisait à faire
perdre tout le cache, y compris ce qui fonctionnait avant.**

    caches.open(CACHE_NAME)
      .then(cache => Promise.allSettled(STATIC_URLS.map(u => cache.add(u))))
      .then(() => self.skipWaiting());

Chaque fichier est désormais tenté séparément. Un chemin faux échoue
seul, sans empêcher les autres d'être mis en cache. Conséquence pratique
: ajouter un module à STATIC_URLS n'est plus une opération risquée.

💡 En clair : avant, si un seul produit manquait à la livraison, le
magasinier refusait de ranger toute la palette. Maintenant il range ce
qu'il a et met de côté ce qui manque.

### 21.3 Stratégie fetch --- ce qui était déjà bon, ce qui ne l'était pas

Découverte du diagnostic : la stratégie était déjà « réseau d'abord,
puis mise en cache de la réponse ». Tous les modules étaient donc déjà
cachés automatiquement dès la première visite en ligne. STATIC_URLS ne
sert qu'au PRÉ-chargement à l'installation --- il couvre le cas où
l'utilisateur perd le réseau avant d'avoir ouvert l'écran concerné.

Deux défauts réels ont été corrigés au passage :

• Toutes les réponses étaient mises en cache, y compris les 404 --- une
erreur pouvait donc être resservie indéfiniment. Un test resp.ok a été
ajouté. • En cas d'échec réseau ET de cache vide, caches.match()
renvoyait undefined, et respondWith(undefined) provoquait une erreur
brute. Une réponse 503 explicite est désormais renvoyée.

### 21.4 ⚠️ Règle de test --- NE PAS tester le cache en InPrivate

**Leçon de la session v26.35, à retenir absolument. Le premier test hors
ligne a échoué (ERR_INTERNET_DISCONNECTED, service worker sans réponse)
et a fait croire à un correctif raté. La cause n'était pas le code : en
navigation InPrivate, le stockage du service worker est éphémère et le
cache ne persiste pas. C'est le principe même de la navigation privée.**

Conséquence sur les protocoles de test de la Bible : InPrivate reste
recommandé pour vérifier qu'une NOUVELLE VERSION est bien déployée (il
contourne le cache). Mais il est inadapté pour tester le cache lui-même.
Les deux usages sont opposés --- ne pas les confondre.

**Protocole de test du cache (fenêtre NORMALE obligatoire) :**

1\) Fenêtre Edge ordinaire, charger l'app et laisser le chargement se
terminer. 2) F12 → Application → Service Workers : vérifier « activated
and running ». 3) F12 → Application → Cache Storage → avigest-v26-XX :
compter les entrées. 4) Network → Offline → F5 : l'app doit s'afficher.

Contrôle rapide en console, plus fiable que la navigation dans les
panneaux :

    (await (await caches.open('avigest-v26-37')).keys()).length

⚠️ Un nouveau service worker peut demander DEUX chargements avant de
prendre le relais (le premier installe, le second active), même avec
skipWaiting().

### 21.5 Résultat mesuré en production (23/07/2026)

Cache avigest-v26-37 : 10 entrées. Les 9 de STATIC_URLS, plus une entrée
ajoutée automatiquement par la stratégie fetch (ressource chargée au
démarrage). Les 7 modules se chargent tous en statut 200, aucun 404. App
testée hors ligne en fenêtre normale : l'écran d'accueil s'affiche.

**⚠️ Ce qui NE fonctionne toujours pas hors ligne, et c'est normal : les
DONNÉES. Tous les appels Supabase échouent sans réseau. Ce chantier rend
l'INTERFACE disponible hors ligne, pas les données. Le vrai mode offline
(file d'attente localStorage + synchronisation) reste à faire --- voir
§13.2, ligne « Mode hors ligne + sync auto ».**

💡 En clair : l'agent qui perd le réseau voit maintenant son écran au
lieu d'une page blanche. Mais il ne voit pas ses chiffres --- ceux-là
viennent du serveur. Rendre les chiffres disponibles hors ligne, c'est
un autre chantier, plus gros.

**Chantiers ouverts à la reprise (session v26.29)**

**🐛 Bouton « Forcer la déconnexion » ne libère pas le verrou** ---
fonction \_forcerDeconnexion (index.html). Elle fait un DELETE sur
sessions_actives WHERE user_pin = window.\_pinSaisi. Or
window.\_pinSaisi n\'est renseigné qu\'APRÈS un login réussi --- donc
quand on est bloqué à la porte (avant login), il vaut undefined et le
DELETE ne cible rien. Le verrou ne se lève jamais. Contournement actuel
: DELETE manuel en base. Piste : ne pas dépendre de window.\_pinSaisi
avant login (cibler par device_id, ou repenser le flux).

**✅ Bug cosmétique score santé (balises \<strong\> brutes) --- FERMÉ
v26.30** --- corrigé en v26.30. Les balises \<strong\>/\</strong\> ont
été retirées de \_renderSessionResume() (le CSS .rapport-ligne
span:last-child gère déjà le gras). ⚠️ Leçon : DEUX balises étaient en
cause, pas une --- toujours compter les occurrences avant de conclure
qu'un correctif est complet.

**🔒 Session RLS dédiée (§14.3)** --- lever l\'incertitude sur l\'état
RLS réel de plusieurs tables (bandes, batiments, taches, lots_stock...).
Nécessite l\'exécution en base des requêtes pg_policies / pg_tables.
Aucun correctif sans validation explicite d\'Adama, patch par patch.

**🔒 Doublon de policy RLS sur la table clients** --- à traiter dans la
session RLS (déjà noté en point en suspens n°8).

**22. Module Pénalités de retard (CHANTIER CLOS --- v26.37)**

**22.1 Objectif et périmètre**

Le module pénalités permet au gérant d\'appliquer une pénalité de retard
sur une commande dont le client tarde à régler. La pénalité est un
**enregistrement séparé** --- ni un paiement, ni un gonflement de la
commande. Elle est signalée au client sur la facture, mais n\'entre en
comptabilité (RECETTE au journal) **que le jour où il la paie
réellement**.

**Seul le GÉRANT saisit. Réservé à l\'onglet GESTION, module
js/commandes/commandes.js (bloc Règlement du détail commande).**

💡 En clair : quand un client traîne à payer, le gérant peut ajouter une
pénalité. Elle apparaît sur la facture pour le prévenir, mais ne compte
comme une vraie recette que lorsqu\'il la règle. Tant qu\'il ne paie
pas, c\'est une créance annoncée, pas de l\'argent encaissé.

**22.2 Les 6 décisions métier (actées avec Adama --- ne pas rouvrir sans
demande explicite)**

1.  **Enregistrement séparé** --- table penalites dédiée. Une pénalité
    ne modifie ni le statut, ni les lignes, ni le total de la commande.

2.  **Signalée dès la facture** --- affichée sur la facture numérique
    remise au client, en bloc distinct de la marchandise.

3.  **Entre au journal seulement au paiement** --- une pénalité impayée
    n\'a aucun effet comptable. La RECETTE n\'est écrite qu\'à
    l\'encaissement.

4.  **Cumul possible** --- plusieurs pénalités par commande sont
    permises.

5.  **Montant figé en FCFA** --- calculé comme un % du reste à payer au
    moment de la saisie, mais **gelé** en francs. Le taux et la base
    sont conservés pour traçabilité, mais c\'est le montant gelé qui
    fait foi. Ne jamais recalculer dynamiquement.

6.  **Encaissement sur écran séparé** --- ne pas fusionner avec le
    paiement de commande, pour ne pas casser la déduction ACOMPTE/SOLDE
    du module Paiements (§19).

**22.3 La table penalites (Migration 049)**

Vérifiée en base le 29/07/2026 --- **16 colonnes** (et non 17 comme
annoncé dans un brief antérieur ; la base fait foi, règle absolue n°1).

  --------------------------------------------------------------------------
  **Colonne**     **Type**              **Rôle**
  --------------- --------------------- ------------------------------------
  id              uuid NOT NULL         Clé primaire, default
                                        gen_random_uuid()

  ferme_id        uuid NOT NULL         Tenant

  commande_id     uuid NOT NULL         FK commandes, ON DELETE CASCADE

  client_id       uuid NOT NULL         Client concerné

  taux_pct        numeric NOT NULL      Taux appliqué. CHECK \> 0

  base_calcul     numeric NOT NULL      Reste à payer au moment de la saisie

  montant         numeric NOT NULL      Montant gelé en FCFA. CHECK \> 0

  date_penalite   date NOT NULL         Default CURRENT_DATE

  paye            boolean NOT NULL      Default false

  date_paiement   date                  Renseignée à l\'encaissement

  moyen           text                  Renseigné à l\'encaissement

  note            text                  Note libre / motif d\'annulation

  annule          boolean NOT NULL      Default false

  annee           integer NOT NULL      Default année courante

  numero_seq      integer NOT NULL      SANS default --- calculé côté JS

  created_at      timestamptz NOT NULL  Default now()
  --------------------------------------------------------------------------

Contrainte carnet à souches : **UNIQUE (ferme_id, annee, numero_seq)** →
numérotation PEN-{annee}-{seq}. RLS : policy penalites_isolation, FOR
ALL TO anon, USING + WITH CHECK = (ferme_id = get_ferme_id()).

**22.4 Saisie : % ou montant fixe --- reconstitution du taux**

Le gérant choisit entre deux modes de saisie :

-   **Pourcentage** : il saisit un taux, l\'app calcule montant =
    round(reste × taux / 100).

-   **Montant fixe** : il saisit directement un montant en FCFA. Comme
    taux_pct est NOT NULL avec CHECK \> 0 en base, **le taux réel est
    reconstitué** : taux = round(montant / reste × 100, 2). La souche
    reste ainsi cohérente : on sait toujours quel pourcentage le montant
    représentait sur le reste à payer de l\'instant.

Dans les deux cas, le montant est **gelé** à l\'INSERT (décision 5). Le
reste à payer est lu au moment de la saisie, comme dans le module
Paiements (\_penReste).

⚠️ **Choix documenté** : en mode montant fixe, taux_pct porte donc une
valeur reconstituée, pas un taux saisi par le gérant. C\'est volontaire
--- elle sert uniquement de trace, jamais de base à un recalcul.

**22.5 Encaissement --- RPC encaisser_penalite (Migration 050)**

Signature : **encaisser_penalite(p_penalite_id uuid, p_moyen text)** ---
vérifiée en base (oid 19735, une seule fonction, pas de surcharge).
SECURITY DEFINER, atomique. Elle enchaîne, dans l\'ordre :

-   fail-closed si get_ferme_id() est NULL ;

-   charge la pénalité, refuse si annulée / déjà payée / mauvaise ferme
    ;

-   trouve la bande à imputer : 1re bande des commande_lignes (ORDER BY
    created_at), avec **repli sur la bande active la plus récente**
    (statut \'EN COURS\', is_deleted false) si la commande n\'a pas de
    bande. Ce repli est **tracé** dans le libellé (« \[rattachement
    bande active, commande sans bande\] »), jamais silencieux ;

-   écrit une RECETTE au journal, format calqué sur livrer_commande :
    categorie = \'Penalite de retard\', reference = PEN-{annee}-{seq},
    beneficiaire = nom client, statut = \'CONFIRME\' ;

-   bascule paye = true + date_paiement + moyen ;

-   retourne jsonb { ok, reference, montant, bande_id, repli_bande }.

**Règle journal confirmée** : bande_id est NOT NULL dans journal → toute
écriture DOIT porter une bande, d\'où le repli. Une pénalité étant une
RECETTE, elle est **automatiquement hors CRU** (le CRU ne compte que les
DEPENSE hors \'Achat stock\', §4.4). Rien à filtrer.

**22.6 La facture commande**

Nouveau support généré par le module (\_texteFacture / \_copierFacture)
: un texte formaté copié dans le presse-papier, à coller dans WhatsApp.
Il porte l\'identité commerciale de la ferme (§20), et sépare
**marchandise** et **pénalités de retard** en deux blocs distincts,
jamais fondus (décision 2). Seules les **pénalités impayées** (hors
payées, hors annulées) y figurent. Le bouton « 📄 Facture » apparaît sur
le détail commande dès que le reste à payer \> 0 OU qu\'une pénalité
impayée existe (statuts PLANIFIEE ou LIVREE). Total général affiché :
reste marchandise + pénalités impayées.

**22.7 Leçon de méthode --- SQL Editor Supabase auto-commit**

Le SQL Editor Supabase est **auto-commit**, et chaque exécution est une
**session isolée**. Un bloc BEGIN...ROLLBACK ne tient pas d\'une
exécution à l\'autre, et un CREATE FUNCTION se commit même à
l\'intérieur d\'un BEGIN. Pour tester une RPC de façon isolée : tout
mettre dans **un seul DO \$\$...\$\$** (header via set_config(\...,
true) + insert + appel), puis nettoyer manuellement par identifiant. Ne
plus s\'appuyer sur ROLLBACK dans le SQL Editor.

**23. Alerte échéance de règlement (CHANTIER CLOS --- v26.37)**

**23.1 Objectif**

Rappel visuel sur l\'accueil gérant : signaler les commandes livrées non
soldées dont l\'échéance de règlement approche ou est dépassée. Répond
au besoin §16.6, annoncé depuis la Migration 036 mais impossible à
réaliser tant qu\'aucune commande ne portait de date_reglement_prevue
--- colonne désormais remplie par la feature de saisie d\'échéance à la
livraison (§18.9, v26.37).

💡 En clair : c\'est la sonnette qui prévient le gérant « ce client
devait payer, relance-le ». Elle ne pouvait sonner que depuis qu\'on a
construit l\'endroit où poser la date d\'échéance (à la livraison).

**23.2 Architecture --- RPC serveur, source unique**

Décision actée : le calcul se fait **côté serveur**, via la RPC
get_alertes_echeance() (Migration 051), et non dupliqué en JS dans
index.html. Raison : le calcul du reste à payer (total des lignes −
paiements non annulés) existe déjà dans le module ES ; le refaire dans
index.html créerait deux copies divergentes de la même logique. La RPC
centralise ce calcul une fois, filtrée par get_ferme_id(), cohérente
avec l\'isolation multi-tenant (§14.4). L\'accueil gérant et le futur
compteur de la tuile Clients liront la même source.

**23.3 La RPC get_alertes_echeance() (Migration 051)**

Signature : get_alertes_echeance() RETURNS TABLE (commande_id uuid,
client_nom text, date_echeance date, jours_restants integer,
reste_a_payer numeric, couleur text). SECURITY DEFINER, SET search_path
= public, fail-closed si get_ferme_id() NULL.

Elle ne renvoie que les commandes **LIVREE**, ayant une
date_reglement_prevue non NULL, et **non soldées** (reste_a_payer \> 0).
Une commande livrée avec échéance mais déjà payée n\'apparaît pas --- il
n\'y a plus rien à relancer.

Les trois seuils de couleur (CASE) :

  ----------------------------------------------------------------------------
  **Couleur**   **Condition**                   **Sens**
  ------------- ------------------------------- ------------------------------
  🔴 ROUGE      date_echeance \<= CURRENT_DATE  Dépassée, ou due aujourd\'hui
                                                même

  🟡 JAUNE      date_echeance = CURRENT_DATE +  Demain (J-1 strict)
                1                               

  ⚪ BLANC      au-delà                         Lointaine
  ----------------------------------------------------------------------------

⚠️ **Choix documenté** : le rouge inclut l\'échéance du jour même (\<=
aujourd\'hui, pas \< aujourd\'hui). Sinon une facture due aujourd\'hui
passerait entre les mailles --- ni dans le rouge (pas encore dépassée),
ni dans le jaune (défini strictement à demain).

**23.4 Affichage sur l\'accueil gérant**

L\'accueil gérant vit dans **index.html** (fonction renderGerant), pas
dans les modules ES --- terrain différent (§17). L\'alerte y est greffée
sous forme d\'une bannière cliquable, sur le modèle des bannières de
tâches existantes, insérée juste après la bannière de validation des
tâches.

Fonctions ajoutées à index.html : \_getAlertesEcheance() (appel
sb.rpc(\'get_alertes_echeance\')) et \_construireAlerteEcheance(alertes)
(rendu HTML). La bannière compte les alertes par couleur et affiche «
Règlements clients : 🔴 X en retard · 🟡 Y à relancer demain · ⚪ Z à
venir ». Un clic renvoie vers renderCommandes (liste des commandes).

⚠️ **Choix documenté** : la bannière ne s\'affiche **que s\'il y a du
rouge ou du jaune** (quelque chose à relancer). Une échéance uniquement
lointaine (⚪ seul) n\'affiche rien --- sinon le gérant aurait une
alerte permanente sans action à prendre. La bordure de la bannière suit
l\'urgence : rouge s\'il y a du retard, orange sinon (cadre couleur =
sens, §4.4).

**23.5 Reste à faire --- compteur tuile Clients**

Le §16.6 prévoyait aussi un compteur sur la tuile Clients. Non encore
implémenté à la clôture v26.37 --- chantier léger, lira la même RPC. À
traiter séparément une fois localisé (tuile Clients dans index.html ou
dans les modules ES ?).

═══════════════════════════════════════════════════════════════════ MISE
À JOUR BIBLE --- sessions v26.38 + v26.39 À reporter dans
bible_avigest_v26.docx (source unique)
═══════════════════════════════════════════════════════════════════

┌─────────────────────────────────────────────────────────────────┐ │
BLOC 1 --- Version (§2.1, remplacer la ligne « Version actuelle ») │
└─────────────────────────────────────────────────────────────────┘

Version actuelle : APP_VERSION = \'v26.39\' · CACHE_NAME =
\'avigest-v26-39\'

┌─────────────────────────────────────────────────────────────────┐ │
BLOC 2 --- §23.5 (compteur tuile Clients, passer à réalisé) │ │
Remplacer le paragraphe « Reste à faire --- compteur tuile Clients »│
└─────────────────────────────────────────────────────────────────┘

23.5 Compteur tuile Clients --- ✅ RÉALISÉ (v26.38)

Le badge « N à relancer » sur la tuile Clients est en place. Il lit la
même source unique que la bannière d\'accueil : la RPC
get_alertes_echeance() (§23.3). Il compte les alertes ROUGE + JAUNE
(créances à relancer), affiche le total, et prend une bordure rouge
s\'il y a du retard, orange sinon (cadre couleur = sens, §4.4).

Terrain : module ES js/gestion/gestion.js, fonction
\_chargerBadgeClients, appelée en arrière-plan après l\'affichage des
tuiles (non bloquante --- les tuiles s\'affichent sans attendre la RPC).

┌─────────────────────────────────────────────────────────────────┐ │
BLOC 3 --- §2.4 (liste des tables, AJOUTER une ligne) │ │ Ajouter dans
le tableau des tables : │
└─────────────────────────────────────────────────────────────────┘

caisse_ajustements : Carnet des modifications du solde initial de caisse
--- traçabilité (ancienne/nouvelle valeur, motif, date). RLS
caisse_ajustements_isolation (Migration 052).

⚠️ Le nombre total de tables passe donc à 21 (était 20).

┌─────────────────────────────────────────────────────────────────┐ │
BLOC 4 --- §2.4 bis (schéma table fermes, AJOUTER 2 lignes) │ │ Ajouter
dans le tableau des colonnes de fermes : │
└─────────────────────────────────────────────────────────────────┘

solde_caisse_initial : numeric NOT NULL, default 0. Montant présent en
caisse au démarrage du suivi de trésorerie (§24). Accepte 0 et les
valeurs négatives (caisse à découvert au départ). Migration 052.

date_debut_caisse : date, nullable. Date à partir de laquelle les
mouvements sont comptés dans le solde de caisse (jour J inclus). Si
NULL, tous les mouvements depuis l\'origine sont comptés. Migration 052.

⚠️ La table fermes passe donc à 16 colonnes (était 14).

┌─────────────────────────────────────────────────────────────────┐ │
BLOC 5 --- §2.5 (liste des migrations, AJOUTER une ligne) │
└─────────────────────────────────────────────────────────────────┘

052_tresorerie_caisse.sql : Module Trésorerie (§24). Ajoute sur fermes
les colonnes solde_caisse_initial + date_debut_caisse ; crée la table
caisse_ajustements (+ RLS) ; crée 3 RPC : get_solde_caisse(),
get_historique_caisse() (LIMIT 50), modifier_solde_initial() (traçable).

Dernière migration : 052.

┌─────────────────────────────────────────────────────────────────┐ │
BLOC 6 --- §16.2 (découpage CRM, mettre à jour l\'étape 5) │
└─────────────────────────────────────────────────────────────────┘

L\'étape 5 du découpage CRM (« Écran Trésorerie / Caisse ») est
désormais ✅ Validé (v26.39) --- voir §24. Restent ○ À faire : étape 4
(export WhatsApp commande) et étape 6 (mouvements hors-bande

-   injections partenaires).

┌═════════════════════════════════════════════════════════════════┐ │
BLOC 7 --- NOUVELLE SECTION 24 (à insérer après la §23) │
└═════════════════════════════════════════════════════════════════┘

24. Module Trésorerie / Caisse (CHANTIER CLOS --- v26.39)

24.1 Objectif et périmètre

L\'écran Trésorerie donne au gérant une vue « caisse réelle » de sa
ferme : combien d\'argent est physiquement disponible, d\'où il vient,
et l\'historique des mouvements. Il met en œuvre l\'étape 5 du découpage
CRM (§16.2).

Il applique la séparation comptable OHADA (§16.1) : la CAISSE (argent
réellement encaissé/décaissé) ne se confond jamais avec les CRÉANCES (ce
qu\'on me doit). Une vente livrée mais non payée n\'apparaît PAS dans la
caisse.

Seul le GÉRANT y accède. Onglet GESTION, tuile 💰. Module
js/tresorerie/tresorerie.js.

💡 En clair : c\'est le relevé du tiroir-caisse de la ferme. Le gros
chiffre en haut = ce que tu as maintenant. En dessous, la liste de tout
ce qui est entré et sorti.

24.2 La caisse est GLOBALE par ferme (décision de fond)

Une caisse est un tiroir physique : un seul par ferme. L\'argent y est
fongible (interchangeable) --- on ne peut pas dire « tant en caisse pour
la bande A, tant pour la bande B ». La trésorerie additionne donc tous
les mouvements de la ferme, toutes bandes confondues.

⚠️ À NE PAS CONFONDRE avec la rentabilité par bande (« la bande A
a-t-elle été rentable ? »), qui est une analyse distincte, par bande,
s\'appuyant sur journal.bande_id. C\'est un chantier futur séparé (voir
§24.7). Ne jamais fusionner caisse et rentabilité : deux questions
différentes, deux écrans différents.

24.3 Sources et formule du solde

Diagnostic fondateur (base réelle, session du jour) :

-   La table paiements = encaissements de commandes uniquement. Elle
    n\'écrit JAMAIS dans journal (vérifié : 59 000 F de paiements ≠ 181
    500 F de ventes au journal).

-   Les catégories \'Vente \...\' du journal = la vente enregistrée à la
    LIVRAISON = une créance, PAS un encaissement → exclues de la caisse.

-   La catégorie \'Penalite de retard\' du journal = écrite au moment de
    l\'encaissement réel (§22.5) = vrai mouvement de caisse → incluse
    (vérifié : 0 paiement ne référence une pénalité, pas de doublon).

-   Toutes les DEPENSE du journal = sorties de caisse réelles.

Formule : Solde = solde_caisse_initial + SUM(paiements non annulés) +
SUM(journal RECETTE catégorie \'Penalite de retard\') − SUM(journal
DEPENSE) ... en ne comptant que les mouvements dont la date \>=
date_debut_caisse.

24.4 ⚠️ Différence assumée CRU vs Caisse sur « Achat stock »

Point de vigilance comptable à retenir absolument :

-   Le CRU EXCLUT la catégorie \'Achat stock\' (ce n\'est pas une charge
    consommée, l\'argent est transformé en stock --- §4.1).

-   La CAISSE INCLUT \'Achat stock\' : quand on achète un sac
    d\'aliment, l\'argent quitte physiquement le tiroir, même si on
    reçoit du stock en échange. C\'est un décaissement réel.

Ces deux règles coexistent volontairement --- elles répondent à deux
questions différentes (coût de revient du poulet vs argent en tiroir).
NE JAMAIS « aligner » la caisse sur le CRU en croyant corriger une
incohérence : ce n\'en est pas une.

24.5 Solde initial et date de début de suivi

La base ne connaissait pas le montant en caisse au démarrage. On l\'a
ajouté au niveau ferme (solde_caisse_initial), avec une date de début de
suivi (date_debut_caisse). On ne compte que les mouvements dont la date
\>= cette date (jour J inclus).

Le solde initial = montant présent en caisse AU TOUT DÉBUT de la date de
début, avant tout mouvement de ce jour. Les mouvements du jour J sont
comptés EN PLUS du solde initial. Si un mouvement du jour J existait
déjà avant la saisie, il s\'ajoute --- le gérant doit en tenir compte
dans le montant qu\'il déclare.

Le solde initial accepte 0 et les valeurs négatives (caisse à découvert
au départ). L\'écran affiche un avertissement visuel si le montant saisi
est négatif, sans l\'interdire.

💡 En clair : tu dis « au 1er juillet, j\'avais X en caisse ». L\'app ne
recompte pas ce qui s\'est passé avant --- c\'est déjà dans ton X. Elle
compte seulement à partir du 1er juillet.

24.6 Modification traçable du solde initial (option B)

Principe comptable d\'intangibilité : on ne « gomme » jamais un solde
initial, on trace chaque changement. Toute modification passe par la RPC
modifier_solde_initial(), atomique : elle met à jour fermes ET insère
une ligne dans caisse_ajustements (ancienne valeur, nouvelle valeur,
dates, motif).

Règle du motif : OBLIGATOIRE pour une modification (un ajustement existe
déjà), FACULTATIF pour la toute première saisie. La règle est appliquée
côté serveur (la RPC refuse avec ok:false si le motif manque) ET
rappelée côté client (message + champ motif affiché seulement en
modification).

24.7 Les 3 RPC (Migration 052)

get_solde_caisse() RETURNS TABLE(solde_initial, date_debut,
total_encaisse, total_penalites, total_depenses, solde) --- 1 ligne,
appel léger. SECURITY DEFINER, fail-closed si get_ferme_id() NULL.

get_historique_caisse() RETURNS TABLE(source, date_mvt, libelle,
montant, reference) --- liste unifiée paiements + pénalités + dépenses,
tri date décroissante, LIMIT 50. montant positif = entrée, négatif =
sortie. Aucune ligne \'Vente \...\'. Le sous-SELECT enveloppant est
requis pour appliquer ORDER BY + LIMIT à l\'ensemble de l\'UNION.

modifier_solde_initial(p_nouveau_montant, p_nouvelle_date, p_motif)
RETURNS jsonb --- atomique, traçable (voir §24.6).

24.8 Frontend

Module js/tresorerie/tresorerie.js, une seule porte d\'entrée exposée :
window.renderTresorerie (§17.4). Suit le gabarit de parametres.js. Écran
principal : gros solde (vert si \>=0, rouge sinon) + sous-titre « Suivi
depuis le ... » + 4 mini-cartes (solde initial, encaissé, pénalités,
dépenses) + historique + bouton « Régler le solde initial ». Écran de
réglage : montant + date de début + motif (si modification).

Branchement : tuile 💰 dans js/gestion/gestion.js (dispo: true) ; import
\'../tresorerie/tresorerie.js\' dans gestion.js (chargé via la chaîne
d\'imports, PAS de balise \<script\> séparée dans index.html ---
index.html ne charge que gestion.js). CSS : classes gestion-treso-\*
ajoutées à css/gestion.css. Service worker : tresorerie.js ajouté à
STATIC_URLS (sw.js), CACHE_NAME porté à avigest-v26-39.

24.9 Module Rentabilité par bande (CHANTIER CLOS --- v26.40)

Résultat économique de chaque bande EN COURS : coût de revient par sujet
(CRU), dépenses, recettes, marge. Distinct de la Trésorerie (§24.2) : la
caisse est GLOBALE par ferme, la rentabilité est PAR BANDE.

**Source unique --- RPC get_rentabilite_bandes() (Migration 053).** Elle
lit vue_dashboard_bande (la même vue que get_dashboard, §14.2), zéro
formule dupliquée. Diagnostic fondateur : get_dashboard ne calcule rien
lui-même, elle emballe la vue ; c\'est donc la vue qui porte le CRU
(§4.1, filtre DEPENSE hors \'Achat stock\' confirmé en base). La RPC
ajoute le seul calcul manquant --- le CRU unitaire = total_depenses_cru
/ effectif_actuel, protégé contre la division par zéro (NULLIF) --- et
filtre statut = \'EN COURS\' + get_ferme_id().

**Frontend :** module js/rentabilite/rentabilite.js, une porte
window.renderRentabilite (§17.4), gabarit tresorerie.js. Écran de
lecture seule : une carte par bande (CRU en avant, âge + effectif en
contexte, marge grise « Recettes à venir » si la bande n\'a pas encore
vendu, verte/rouge sinon). Pas de seuil CRU codé en dur --- le gérant
juge selon l\'objectif de la bande. Tuile 📈 dans gestion.js. CSS
gestion-renta-\*. Service worker : rentabilite.js ajouté à STATIC_URLS,
CACHE_NAME avigest-v26-40.

💡 En clair : la caisse dit combien d\'argent il y a dans le tiroir ; la
rentabilité dit, bande par bande, combien coûte un poulet à élever et où
en est la marge. Deux questions, deux écrans.

Écriture de test à supprimer : RECETTE \'Remboursement\' 102 583 000 F
sur Bande-2026-002 (22/06/2026, sans bénéficiaire ni référence),
confirmée donnée de test. À supprimer avec les 6 écritures du 22/06 lors
d\'un nettoyage journal dédié. Tant qu\'elle est là, elle gonfle la
marge de Bande-002 sur l\'écran Rentabilité.

--- Fin de la mise à jour Bible session v26.40 ---

*--- Fin de la Bible AviGest v26 --- Version .md générée le 04/07/2026
(session v26.40), à répercuter manuellement dans le .docx ---*
