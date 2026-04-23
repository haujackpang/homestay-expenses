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
      const { data, error } = await admin.from("profiles").select("*").order("created_at");
      if (error) throw error;
      return json({ ok: true, users: data || [] });
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
