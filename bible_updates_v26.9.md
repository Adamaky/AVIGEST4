# AviGest Bible — Mises à jour v26.9
*À intégrer dans bible_avigest_v26.docx*

---

## SECTION 13.4 — Protocole de Brief de Session (REMPLACER l'existant)

```
📋 BRIEF SESSION AVIGEST v26.X

Objectif du jour : [une phrase]
Dernière chose validée : [fonctionnalité]
Bug en suspens : [description ou 'Aucun']

CHECKLIST CLAUDE — À FAIRE AVANT TOUT CODE :
□ 1. Lire SCHEMA.md depuis GitHub avant tout SQL
□ 2. Vérifier les types exacts des colonnes (information_schema)
□ 3. Pour tout patch JS : vérifier les noms exacts avec Ctrl+Shift+F
□ 4. Mettre à jour CACHE_NAME dans sw.js à chaque déploiement
```

---

## SECTION 14 — Protocoles Anti-Régression (NOUVELLE SECTION)

### 14.1 — Avant chaque déploiement

```
□ Mettre à jour CACHE_NAME dans sw.js
  Exemple : 'avigest-v24' → 'avigest-v26-9'
  Pourquoi : force tous les navigateurs à vider leur cache
  Sans ça : les utilisateurs voient une ancienne version du code

□ Vérifier APP_VERSION dans index.html correspond à la version déployée
```

### 14.2 — Avant chaque test terrain

```
□ Ouvrir un onglet InPrivate (Ctrl+Shift+N)
□ Ctrl+Shift+R pour forcer le rechargement sans cache
□ Vérifier le numéro de version affiché en bas de l'écran d'accueil
  correspond au dernier commit pushé
□ Si la version ne correspond pas → supprimer le Service Worker :
  navigator.serviceWorker.getRegistrations().then(function(r) {
    for(let reg of r) { reg.unregister(); }
    location.reload(true);
  });
```

### 14.3 — Avant tout SQL (règle absolue)

```
□ Lire SCHEMA.md depuis GitHub
□ Vérifier les types exacts des colonnes avec :

  SELECT column_name, data_type, is_nullable
  FROM information_schema.columns
  WHERE table_schema = 'public'
    AND table_name = 'NOM_TABLE'
  ORDER BY ordinal_position;

□ Ne jamais supposer un type — toujours vérifier
□ SCHEMA.md est mis à jour après chaque migration
```

### 14.4 — Pendant les tests de sécurité (brute force)

```
□ Ajouter un bouton Reset (debug) pendant les tests S1/S2
□ Le supprimer uniquement après validation complète de tous les tests
□ Commande de reset localStorage si nécessaire :
  Object.keys(localStorage)
    .filter(k => k.startsWith('av_lockout') || k.startsWith('av_att'))
    .forEach(k => localStorage.removeItem(k));
```

---

## SECTION 13.3 — Bugs ouverts (METTRE À JOUR)

### Bugs FERMÉS cette session

S1 | Protection brute force PIN         | ✅ FERMÉ v26.8
S2 | Hash PIN bcrypt (verifier_pin RPC) | ✅ FERMÉ v26.9
   | Colonne pin clair supprimée (028)  |
   | SCHEMA.md créé sur GitHub          |

### Bugs ouverts

B7 | Journal aliment
   | Écriture créée avant validation gérant
   | → inverser flux (Étape 5)
   | 🟠 Modéré — Priorité #1 prochaine session

B8 | Stock litière
   | Règle métier à trancher avant implémentation
   | 🟡 Moyen — Suspendu

---

## SECTION 13.2 — Tableau de Suivi (METTRE À JOUR)

| Fonctionnalité | Statut | Note |
|---|---|---|
| Login PIN bcrypt | ✅ Validé | verifier_pin() RPC — hash bcrypt actif v26.9 |
| Protection brute force | ✅ Validé | Lockout par ferme — S1 v26.8 |
| SCHEMA.md | ✅ Validé | Référence schéma sur GitHub |

---

## ACQUIS TECHNIQUES v26.9 (à ajouter dans Section 4)

```
RÈGLE pgcrypto :
  pgcrypto est dans le schéma 'extensions' sur Supabase
  → Toujours appeler extensions.crypt() et non crypt()
  → SET search_path = public, extensions dans les RPCs

RÈGLE RLS dans SECURITY DEFINER :
  Les RPCs SECURITY DEFINER sont quand même soumises à RLS
  → Ajouter SET LOCAL row_security = off dans le corps de la fonction
  → Obligatoire pour toute RPC qui lit utilisateurs sans header x-ferme-id

RÈGLE Service Worker :
  Mettre à jour CACHE_NAME dans sw.js à chaque déploiement majeur
  → Format : 'avigest-vXX-Y'
  → Sans ça : les navigateurs servent une version obsolète
```
