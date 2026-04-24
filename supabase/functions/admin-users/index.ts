import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") || "";
const SUPABASE_SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || "";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

function json(body: Record<string, unknown>, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

async function listLoginUsers(admin: ReturnType<typeof createClient>) {
  const perPage = 200;
  const authUsers: Array<Record<string, unknown>> = [];

  for (let page = 1; page <= 20; page++) {
    const { data, error } = await admin.auth.admin.listUsers({ page, perPage });
    if (error) throw error;
    const rows = (data?.users || []) as Array<Record<string, unknown>>;
    if (!rows.length) break;
    authUsers.push(...rows);
    if (rows.length < perPage) break;
  }

  const { data: profiles, error: profilesError } = await admin
    .from("profiles")
    .select("id, email, full_name, role, active");
  if (profilesError) throw profilesError;

  const profileById: Record<string, Record<string, unknown>> = {};
  (profiles || []).forEach((p) => {
    const id = String(p.id || "");
    if (id) profileById[id] = p as Record<string, unknown>;
  });

  const users = authUsers
    .filter((u) => {
      const email = String(u.email || "").toLowerCase();
      const aud = String(u.aud || "");
      const isAnonymous = u.is_anonymous === true;
      return !!email && aud === "authenticated" && !isAnonymous;
    })
    .map((u) => {
      const id = String(u.id || "");
      const p = profileById[id] || null;
      const email = String(u.email || (p?.email as string) || "").toLowerCase();
      const meta = (u.user_metadata || {}) as Record<string, unknown>;
      const fullName = String(
        (p?.full_name as string) ||
        (meta.full_name as string) ||
        (meta.name as string) ||
        email.split("@")[0] ||
        "User",
      ).trim();
      const role = String((p?.role as string) || (email === "admin@homestay.app" ? "admin" : "employee"));
      const active = p ? p.active !== false : true;

      return {
        id,
        email,
        full_name: fullName,
        role,
        active,
        has_profile: !!p,
        last_sign_in_at: (u.last_sign_in_at as string) || null,
      };
    })
    .sort((a, b) => {
      const aRole = a.role === "admin" ? 0 : a.role === "manager" ? 1 : 2;
      const bRole = b.role === "admin" ? 0 : b.role === "manager" ? 1 : 2;
      if (aRole !== bRole) return aRole - bRole;
      return a.full_name.localeCompare(b.full_name);
    });

  return users;
}

async function requireAdmin(req: Request) {
  const authHeader = req.headers.get("Authorization") || "";
  const userClient = createClient(SUPABASE_URL, Deno.env.get("SUPABASE_ANON_KEY") || SUPABASE_SERVICE_KEY, {
    global: { headers: { Authorization: authHeader } },
  });
  const { data: userData, error: userError } = await userClient.auth.getUser();
  if (userError || !userData.user) throw new Error("Unauthorized");

  const admin = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);
  const { data: profile, error } = await admin
    .from("profiles")
    .select("id, role, active")
    .eq("id", userData.user.id)
    .single();
  if (error || !profile || profile.role !== "admin" || profile.active === false) {
    throw new Error("Only system admin can manage users");
  }
  return admin;
}

serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "POST required" }, 405);

  try {
    if (!SUPABASE_URL || !SUPABASE_SERVICE_KEY) return json({ error: "Supabase env not configured" }, 500);
    const admin = await requireAdmin(req);
    const body = await req.json();
    const action = String(body.action || "");

    if (action === "list") {
      const users = await listLoginUsers(admin);
      return json({ ok: true, users });
    }

    if (action === "create") {
      const username = String(body.username || "").trim().toLowerCase();
      const password = String(body.password || "");
      const fullName = String(body.full_name || "").trim();
      const role = String(body.role || "employee");
      if (!username || !password || !fullName) return json({ error: "Username, password and full name are required" }, 400);
      if (password.length < 6) return json({ error: "Password must be at least 6 characters" }, 400);
      if (!["employee", "manager"].includes(role)) return json({ error: "Role must be employee or manager" }, 400);

      const email = `${username}@homestay.app`;
      const { data: created, error: createError } = await admin.auth.admin.createUser({
        email,
        password,
        email_confirm: true,
        user_metadata: { full_name: fullName },
      });
      if (createError || !created.user) throw createError || new Error("Failed to create user");

      const { error: profileError } = await admin.from("profiles").insert({
        id: created.user.id,
        email,
        full_name: fullName,
        role,
        active: true,
      });
      if (profileError) throw profileError;

      if (role === "employee") {
        await admin.from("bank_info").upsert({ employee_name: fullName }, { onConflict: "employee_name" });
      }
      return json({ ok: true, user: { id: created.user.id, email, full_name: fullName, role, active: true } });
    }

    if (action === "reset-password") {
      const userId = String(body.user_id || "");
      const password = String(body.password || "");
      if (!userId) return json({ error: "User id is required" }, 400);
      if (!password || password.length < 6) return json({ error: "Password must be at least 6 characters" }, 400);

      const { error } = await admin.auth.admin.updateUserById(userId, { password });
      if (error) throw error;
      return json({ ok: true });
    }

    if (action === "update") {
      const userId = String(body.user_id || "");
      const fullName = String(body.full_name || "").trim();
      const oldName = String(body.old_name || "").trim();
      const role = String(body.role || "employee");
      const password = body.password ? String(body.password) : "";
      if (!userId || !fullName) return json({ error: "User id and full name are required" }, 400);
      if (password && password.length < 6) return json({ error: "Password must be at least 6 characters" }, 400);

      const { error: profileError } = await admin
        .from("profiles")
        .update({ full_name: fullName, role })
        .eq("id", userId);
      if (profileError) throw profileError;

      if (oldName && oldName !== fullName) {
        await admin.from("bank_info").update({ employee_name: fullName }).eq("employee_name", oldName);
      }
      if (password) {
        const { error } = await admin.auth.admin.updateUserById(userId, { password });
        if (error) throw error;
      }
      return json({ ok: true });
    }

    if (action === "set-active") {
      const userId = String(body.user_id || "");
      const active = body.active === true;
      if (!userId) return json({ error: "User id is required" }, 400);
      const { error } = await admin.from("profiles").update({ active }).eq("id", userId);
      if (error) throw error;
      return json({ ok: true });
    }

    return json({ error: "Unknown action" }, 400);
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    return json({ ok: false, error: msg }, msg === "Unauthorized" ? 401 : 500);
  }
});
