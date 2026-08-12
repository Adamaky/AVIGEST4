-- Migration 056 — Étendre acces_par_ferme (bandes) au rôle authenticated
-- Cause : depuis Marche 1 (JWT), l'app présente le rôle authenticated ;
-- la policy anon-seule bloquait l'écriture (erreur 42501). Débloque bandes.

DROP POLICY acces_par_ferme ON bandes;

CREATE POLICY acces_par_ferme ON bandes
  FOR ALL
  TO anon, authenticated
  USING (ferme_id = get_ferme_id())
  WITH CHECK (ferme_id = get_ferme_id());