-- Migration 057 — Étendre les policies anon au rôle authenticated (début Marche 2)
-- Cause : depuis Marche 1 (JWT), l'app présente le rôle authenticated.
-- Les 8 policies ci-dessous n'acceptaient que anon → écritures bloquées (42501).
-- On conserve strictement la règle ferme_id = get_ferme_id(). On ajoute juste authenticated.

-- journal
DROP POLICY acces_par_ferme ON journal;
CREATE POLICY acces_par_ferme ON journal FOR ALL TO anon, authenticated
  USING (ferme_id = get_ferme_id()) WITH CHECK (ferme_id = get_ferme_id());

-- lots_stock
DROP POLICY acces_par_ferme ON lots_stock;
CREATE POLICY acces_par_ferme ON lots_stock FOR ALL TO anon, authenticated
  USING (ferme_id = get_ferme_id()) WITH CHECK (ferme_id = get_ferme_id());

-- mouvements_stock
DROP POLICY acces_par_ferme ON mouvements_stock;
CREATE POLICY acces_par_ferme ON mouvements_stock FOR ALL TO anon, authenticated
  USING (ferme_id = get_ferme_id()) WITH CHECK (ferme_id = get_ferme_id());

-- rapports_hebdo
DROP POLICY acces_par_ferme ON rapports_hebdo;
CREATE POLICY acces_par_ferme ON rapports_hebdo FOR ALL TO anon, authenticated
  USING (ferme_id = get_ferme_id()) WITH CHECK (ferme_id = get_ferme_id());

-- saisies_techniques
DROP POLICY acces_par_ferme ON saisies_techniques;
CREATE POLICY acces_par_ferme ON saisies_techniques FOR ALL TO anon, authenticated
  USING (ferme_id = get_ferme_id()) WITH CHECK (ferme_id = get_ferme_id());

-- taches
DROP POLICY acces_par_ferme ON taches;
CREATE POLICY acces_par_ferme ON taches FOR ALL TO anon, authenticated
  USING (ferme_id = get_ferme_id()) WITH CHECK (ferme_id = get_ferme_id());

-- caisse_ajustements
DROP POLICY caisse_ajustements_isolation ON caisse_ajustements;
CREATE POLICY caisse_ajustements_isolation ON caisse_ajustements FOR ALL TO anon, authenticated
  USING (ferme_id = get_ferme_id()) WITH CHECK (ferme_id = get_ferme_id());

-- penalites
DROP POLICY penalites_isolation ON penalites;
CREATE POLICY penalites_isolation ON penalites FOR ALL TO anon, authenticated
  USING (ferme_id = get_ferme_id()) WITH CHECK (ferme_id = get_ferme_id());