BEGIN;

-- 1. Jouer la migration (colle le contenu du fichier 049 ici)
-- ... CREATE TABLE ... etc ...

-- 2. Vérifier la structure
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema='public' AND table_name='penalites'
ORDER BY ordinal_position;

-- 3. Vérifier la RLS active + la policy
SELECT tablename, rowsecurity FROM pg_tables WHERE tablename='penalites';
SELECT policyname, cmd, roles, qual, with_check
FROM pg_policies WHERE tablename='penalites';

-- 4. Test isolation en rôle anon : insertion croisée refusée, légitime acceptée
--    (même méthode que §14.4 — à faire seulement si tu veux confirmer la RLS)

ROLLBACK;   -- rien n'est gardé