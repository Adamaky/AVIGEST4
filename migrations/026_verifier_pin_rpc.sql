-- Migration 026 — RPC verifier_pin() avec bcrypt (pgcrypto)
-- S2 — Hash PIN côté serveur
-- Accessible à anon pour le flux de login

DROP FUNCTION IF EXISTS verifier_pin(TEXT, TEXT, TEXT);

CREATE OR REPLACE FUNCTION verifier_pin(
  p_ferme_id TEXT,
  p_role     TEXT,
  p_pin      TEXT
)
RETURNS TABLE (
  id       UUID,
  nom      TEXT,
  role     TEXT,
  ferme_id UUID
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT
    u.id,
    u.nom,
    u.role,
    u.ferme_id
  FROM utilisateurs u
  WHERE u.ferme_id = p_ferme_id::UUID
    AND u.role     = p_role
    AND u.pin_hash IS NOT NULL
    AND crypt(p_pin, u.pin_hash) = u.pin_hash;
END;
$$;

-- Accès public pour le login anon
GRANT EXECUTE ON FUNCTION verifier_pin(TEXT, TEXT, TEXT) TO anon;
GRANT EXECUTE ON FUNCTION verifier_pin(TEXT, TEXT, TEXT) TO authenticated;
