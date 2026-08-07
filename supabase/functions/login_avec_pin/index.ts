// login_avec_pin — CRAN 3+4 : compte miroir + ouverture de session
// Chaîne complète : code_ferme -> ferme_id -> PIN -> utilisateur
//   -> auth_user_id -> email -> signInWithPassword -> tokens
// Objectif final de la Brique 1.2 : renvoyer un vrai access_token.

import { createClient } from "jsr:@supabase/supabase-js@2";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
      },
    });
  }

  const cors = {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
  };

  try {
    const { code_ferme, role, pin } = await req.json();

    // Clés + URL
    const url = Deno.env.get("SUPABASE_URL")!;
    const cleSecrete = JSON.parse(Deno.env.get("SUPABASE_SECRET_KEYS")!)["default"];
    const clePublishable = JSON.parse(Deno.env.get("SUPABASE_PUBLISHABLE_KEYS")!)["default"];
    const motDePasseTechnique = Deno.env.get("MOT_DE_PASSE_TECHNIQUE")!;

    // Client ADMIN (pleins pouvoirs) : pour les RPC et getUserById.
    const admin = createClient(url, cleSecrete);

    // === CRAN 1 : code ferme -> ferme_id ===
    const { data: dataFerme, error: errFerme } = await admin.rpc("valider_code_ferme", {
      code: code_ferme,
    });
    if (errFerme) {
      return new Response(JSON.stringify({ ok: false, etape: "valider_code_ferme", erreur: errFerme.message }), { status: 400, headers: cors });
    }
    const ferme = Array.isArray(dataFerme) ? dataFerme[0] : dataFerme;
    if (!ferme || !ferme.ferme_id) {
      return new Response(JSON.stringify({ ok: false, erreur: "Code ferme invalide" }), { status: 401, headers: cors });
    }

    // === CRAN 2 : PIN -> utilisateur ===
    const { data: dataPin, error: errPin } = await admin.rpc("verifier_pin", {
      p_ferme_id: String(ferme.ferme_id),
      p_role: role,
      p_pin: pin,
    });
    if (errPin) {
      return new Response(JSON.stringify({ ok: false, etape: "verifier_pin", erreur: errPin.message }), { status: 400, headers: cors });
    }
    const utilisateur = Array.isArray(dataPin) ? dataPin[0] : dataPin;
    if (!utilisateur || !utilisateur.id) {
      return new Response(JSON.stringify({ ok: false, erreur: "PIN incorrect" }), { status: 401, headers: cors });
    }

    // === CRAN 3 : utilisateur -> auth_user_id -> email ===
    // Lire l'auth_user_id dans la table utilisateurs.
    const { data: ligneUtil, error: errUtil } = await admin
      .from("utilisateurs")
      .select("auth_user_id")
      .eq("id", utilisateur.id)
      .single();
    if (errUtil || !ligneUtil || !ligneUtil.auth_user_id) {
      return new Response(JSON.stringify({ ok: false, etape: "lecture_auth_user_id", erreur: "Compte Auth non relié" }), { status: 500, headers: cors });
    }

    // Récupérer l'email réel du compte miroir (Piste A : getUserById).
    const { data: dataAuthUser, error: errAuthUser } = await admin.auth.admin.getUserById(
      String(ligneUtil.auth_user_id),
    );
    if (errAuthUser || !dataAuthUser || !dataAuthUser.user || !dataAuthUser.user.email) {
      return new Response(JSON.stringify({ ok: false, etape: "getUserById", erreur: "Compte Auth introuvable" }), { status: 500, headers: cors });
    }
    const email = dataAuthUser.user.email;

    // === CRAN 4 : ouvrir la session ===
    // Client SÉPARÉ avec la clé publishable, sans persistance (serveur).
    const clientLogin = createClient(url, clePublishable, {
      auth: { autoRefreshToken: false, persistSession: false },
    });
    const { data: dataSession, error: errSession } = await clientLogin.auth.signInWithPassword({
      email: email,
      password: motDePasseTechnique,
    });
    if (errSession || !dataSession || !dataSession.session) {
      return new Response(JSON.stringify({ ok: false, etape: "signInWithPassword", erreur: errSession ? errSession.message : "Session non créée" }), { status: 500, headers: cors });
    }

    // === Succès : on renvoie les tokens + l'identité ===
    return new Response(
      JSON.stringify({
        ok: true,
        etape: "cran4_session_ouverte",
        access_token: dataSession.session.access_token,
        refresh_token: dataSession.session.refresh_token,
        utilisateur: {
          id: utilisateur.id,
          nom: utilisateur.nom,
          role: utilisateur.role,
          ferme_id: ferme.ferme_id,
          ferme_nom: ferme.nom,
        },
      }),
      { status: 200, headers: cors },
    );
  } catch (e) {
    return new Response(JSON.stringify({ ok: false, erreur: String(e) }), { status: 500, headers: cors });
  }
});