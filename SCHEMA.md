# AviGest — Schéma de Référence Base de Données
*Mis à jour : session v26.9 — 28 juin 2026*
*⚠️ Ce fichier est la source de vérité. Claude le lit en début de session avant tout SQL.*

---

## RÈGLE ABSOLUE POUR CLAUDE

Avant toute RPC ou INSERT touchant une table, exécuter dans Supabase SQL Editor :
```sql
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'NOM_TABLE'
ORDER BY ordinal_position;
```
**Ne jamais supposer un type. Toujours vérifier.**

---

## Tables

### `bandes`
| Colonne | Type | Nullable |
|---|---|---|
| id | uuid | NO |
| ferme_id | uuid | NO |
| batiment_id | uuid | NO |
| id_bande | text | NO |
| date_arrivee | date | NO |
| effectif_initial | integer | NO |
| race | text | YES |
| statut | text | YES |
| commentaire | text | YES |
| created_at | timestamptz | YES |
| updated_at | timestamptz | YES |
| is_deleted | boolean | YES |
| prep_terminee | boolean | YES |
| abattage_demarre | boolean | YES |
| fournisseur_poussins | text | YES |
| effectif_vendu | integer | YES |
| date_cloture | date | YES |

### `batiments`
| Colonne | Type | Nullable |
|---|---|---|
| id | uuid | NO |
| ferme_id | uuid | NO |
| numero | integer | NO |
| nom | text | YES |
| capacite_max | integer | YES |
| statut | text | YES |
| created_at | timestamptz | YES |

### `clients`
| Colonne | Type | Nullable |
|---|---|---|
| id | uuid | NO |
| ferme_id | uuid | NO |
| nom | text | NO |
| telephone | text | YES |
| adresse | text | YES |
| type_client | text | YES |
| note | text | YES |
| actif | boolean | YES |
| created_at | timestamptz | YES |

### `clotures`
| Colonne | Type | Nullable |
|---|---|---|
| id | uuid | NO |
| ferme_id | uuid | NO |
| bande_id | uuid | NO |
| phase | text | NO |
| date_prevue | date | YES |
| date_reelle | date | YES |
| statut | text | YES |
| note | text | YES |
| valide_par | uuid | YES |
| created_at | timestamptz | YES |

### `composants_lot`
| Colonne | Type | Nullable |
|---|---|---|
| id | uuid | NO |
| ferme_id | uuid | NO |
| lot_id | uuid | NO |
| nom | text | NO |
| unite | text | NO |
| quantite | numeric | NO |
| prix_unitaire | numeric | NO |

### `fermes`
*(à compléter lors d'une prochaine session)*

### `journal`
*(à compléter — colonnes connues : id, ferme_id, bande_id, date_ecriture, type_ecriture, categorie, montant, note, statut)*

### `lots_stock`
*(à compléter — colonnes connues : id, ferme_id, bande_id, produit, reference, quantite_initiale, quantite_restante, cout_unitaire GÉNÉRÉ, seuil_alerte, date_fabrication, impute_journal)*

### `mouvements_stock`
*(à compléter — colonnes connues : id, ferme_id, lot_id, type_mouvement ENTREE/SORTIE, quantite, session, cout_impute, note)*

### `saisies_techniques`
*(à compléter)*

### `sessions_actives`
*(RLS désactivée — colonnes connues : id, ferme_id, user_pin, device_id, connected_at, last_seen_at)*

### `taches`
*(à compléter — statuts : PLANIFIEE, ENVOYEE, EXECUTEE, VALIDEE, REJETEE)*

### `utilisateurs`
| Colonne | Type | Nullable |
|---|---|---|
| id | uuid | NO |
| ferme_id | uuid | NO |
| nom | text | NO |
| role | text | NO |
| pin | text | YES |
| pin_hash | text | YES |
| actif | boolean | YES |
| last_login | timestamptz | YES |
| id_partenaire | uuid | YES |

---

## Fonctions RPC

| Fonction | Arguments |
|---|---|
| fn_decrementer_stock | — |
| fn_purger_sessions_expirees | — |
| fn_update_timestamp | — |
| get_dashboard | p_bande_id uuid |
| get_ferme_id | — |
| get_stock_dashboard | p_ferme_id uuid |
| get_user_role | — |
| imputer_aliment | p_bande_id uuid, p_session text, p_quantite numeric, p_note text |
| imputer_stock | p_bande_id uuid, p_produit_like text, p_quantite numeric, p_session text, … |
| imputer_stock | p_lot_id uuid, p_bande_id uuid, p_quantite numeric, p_libelle text, … |
| imputer_stock_type_b | p_bande_id uuid, p_type_produit text, p_quantite numeric, p_session text, … |
| login_par_pin | p_ferme_id uuid, p_pin text |
| set_ferme_id | p_ferme_id uuid |
| sync_batiment_statut | — |
| update_updated_at | — |
| valider_code_ferme | code text |
| valider_imputation_gerant | p_journal_id uuid, p_action text, p_note_rejet text |
| verifier_pin | p_ferme_id text, p_role text, p_pin text |

---

## Politiques RLS actives

| Table | Policy | Cmd | Condition |
|---|---|---|---|
| utilisateurs | ferme_isolation | ALL | ferme_id = get_ferme_id() |
| bandes | ferme_isolation | ALL | ferme_id = get_ferme_id() |
| journal | ferme_isolation | ALL | ferme_id = get_ferme_id() |
| lots_stock | ferme_isolation | ALL | ferme_id = get_ferme_id() |
| mouvements_stock | ferme_isolation | ALL | ferme_id = get_ferme_id() |
| sessions_actives | RLS désactivée | — | — |

---

## Contraintes CHECK importantes

| Table | Colonne | Valeurs acceptées |
|---|---|---|
| mouvements_stock | type_mouvement | 'ENTREE', 'SORTIE' |
| journal | type_ecriture | 'DEPENSE', 'RECETTE' |
| utilisateurs | role | 'GERANT', 'AGENT', 'PARTENAIRE' |

---

## Notes critiques

- `cout_unitaire` dans `lots_stock` est une **colonne GÉNÉRÉE** — ne jamais l'inclure dans un INSERT
- `get_ferme_id()` lit le header HTTP `x-ferme-id` — retourne NULL si absent
- RPCs avec `SECURITY DEFINER` + `SET search_path = public, extensions` pour accéder à pgcrypto
- `verifier_pin()` utilise `SET LOCAL row_security = off` pour bypasser RLS sur `utilisateurs`
- Supabase pgcrypto est dans le schéma `extensions` — appeler `extensions.crypt()` et non `crypt()`
