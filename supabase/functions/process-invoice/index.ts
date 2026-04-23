import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") || "";
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY") || "";
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

function expenseMonth(date: string) {
  return /^\d{4}-\d{2}-\d{2}$/.test(date) ? date.slice(0, 7) : new Date().toISOString().slice(0, 7);
}

serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "POST required" }, 405);

  try {
    const authHeader = req.headers.get("Authorization") || "";
    const userClient = createClient(SUPABASE_URL, SUPABASE_ANON_KEY || SUPABASE_SERVICE_KEY, {
      global: { headers: { Authorization: authHeader } },
    });
    const { data: userData, error: userError } = await userClient.auth.getUser();
    if (userError || !userData.user) return json({ error: "Unauthorized" }, 401);

    const admin = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);
    const { data: profile } = await admin
      .from("profiles")
      .select("full_name, role, active")
      .eq("id", userData.user.id)
      .single();
    if (!profile || profile.active === false) return json({ error: "Profile not active" }, 403);

    const body = await req.json();
    const analyzeResp = await fetch(`${SUPABASE_URL}/functions/v1/analyze-receipt`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: authHeader,
        apikey: SUPABASE_ANON_KEY || SUPABASE_SERVICE_KEY,
      },
      body: JSON.stringify({
        base64Data: body.base64Data,
        fileUrl: body.fileUrl,
        mimeType: body.mimeType,
      }),
    });

    const ai = await analyzeResp.json();
    if (!analyzeResp.ok) return json(ai, analyzeResp.status);

    const month = expenseMonth(ai.date || "");
    const { data: duplicates } = await admin.rpc("find_possible_duplicate_claims", {
      p_invoice_number: ai.invoice_number || ai.reference_number || "",
      p_merchant_name: ai.merchant_name || "",
      p_amount: Number(ai.total) || 0,
      p_expense_month: month,
      p_emp: profile.full_name || "",
      p_unit: String(body.unit || ""),
    });

    let unitMatch = null;
    const hint = String(body.unit || ai.unit_hint || "").trim().toLowerCase();
    if (hint) {
      const { data: units } = await admin
        .from("units")
        .select("id, name, hp_unit_id, property_short, property_name")
        .eq("active", true);
      unitMatch = (units || []).find((u) => {
        const display = `${u.property_short ? `${u.property_short} ` : ""}${u.name}`.toLowerCase();
        return display === hint || String(u.name || "").toLowerCase() === hint || String(u.hp_unit_id || "").toLowerCase() === hint;
      }) || null;
    }

    return json({
      ok: true,
      ai,
      duplicate_claims: duplicates || [],
      suggested: {
        expense_month: month,
        unit: unitMatch
          ? `${unitMatch.property_short ? `${unitMatch.property_short} ` : ""}${unitMatch.name}`
          : "",
        hp_unit_id: unitMatch?.hp_unit_id || null,
        source_type: "ai_scan",
      },
    });
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    return json({ ok: false, error: msg }, 500);
  }
});
