-- Migration 027 — Hash bcrypt des PIN existants en production
-- pgcrypto crypt() avec gen_salt('bf', 10) = bcrypt cost 10

UPDATE utilisateurs
SET pin_hash = crypt(pin, gen_salt('bf', 10))
WHERE pin IS NOT NULL
  AND pin_hash IS NULL;

-- Vérification immédiate : tous les pin_hash doivent être non-NULL
SELECT nom, role, ferme_id,
       pin,
       LEFT(pin_hash, 7) AS hash_preview,
       (pin_hash IS NOT NULL) AS hash_ok
FROM utilisateurs
ORDER BY ferme_id, role;
