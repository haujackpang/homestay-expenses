import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") || "";
const SUPABASE_SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || "";
const IMPORT_API_TOKEN = Deno.env.get("IMPORT_API_TOKEN") || "";

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

function normalizeDate(value: unknown) {
  const s = String(value || "");
  return /^\d{4}-\d{2}-\d{2}$/.test(s) ? s : new Date().toISOString().slice(0, 10);
}

serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "POST required" }, 405);

  try {
    const token = (req.headers.get("Authorization") || "").replace(/^Bearer\s+/i, "");
    if (IMPORT_API_TOKEN && token !== IMPORT_API_TOKEN) return json({ error: "Unauthorized" }, 401);

    const admin = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);
    const body = await req.json();
    const invoices = Array.isArray(body.invoices) ? body.invoices : [body];
    const results = [];

    for (const inv of invoices) {
      const externalId = String(inv.external_id || inv.invoice_number || "").trim();
      const externalSource = String(inv.external_source || inv.source || "external-api").trim();
      const amount = Number(inv.amount || inv.total || 0);
      const date = normalizeDate(inv.date || inv.invoice_date);
      const expenseMonth = String(inv.expense_month || date.slice(0, 7));
      const unitInput = String(inv.unit || inv.unit_code || "").trim();

      if (!externalId || !amount) {
        results.push({ ok: false, external_id: externalId, error: "external_id and amount are required" });
        continue;
      }

      const { data: existing } = await admin
        .from("claims")
        .select("claim_id")
        .eq("external_source", externalSource)
        .eq("external_id", externalId)
        .maybeSingle();
      if (existing) {
        results.push({ ok: true, external_id: externalId, skipped: true, claim_id: existing.claim_id });
        continue;
      }

      let unit = unitInput;
      let hpUnitId = inv.hp_unit_id || null;
      if (unitInput) {
        const { data: units } = await admin
          .from("units")
          .select("name, property_short, hp_unit_id")
          .eq("active", true);
        const match = (units || []).find((u) => {
          const display = `${u.property_short ? `${u.property_short} ` : ""}${u.name}`;
          return display.toLowerCase() === unitInput.toLowerCase()
            || String(u.name || "").toLowerCase() === unitInput.toLowerCase()
            || String(u.hp_unit_id || "").toLowerCase() === unitInput.toLowerCase();
        });
        if (match) {
          unit = `${match.property_short ? `${match.property_short} ` : ""}${match.name}`;
          hpUnitId = match.hp_unit_id;
        }
      }

      const year = new Date().getFullYear();
      const { data: seq } = await admin
        .from("claim_sequences")
        .select("last_number")
        .eq("year", year)
        .maybeSingle();
      const next = (seq?.last_number || 0) + 1;
      await admin
        .from("claim_sequences")
        .upsert({ year, last_number: next }, { onConflict: "year" });
      const claimId = `API-${expenseMonth}-${String(next).padStart(5, "0")}`;

      const row = {
        claim_id: claimId,
        emp: String(inv.employee_name || inv.emp || ""),
        unit,
        hp_unit_id: hpUnitId,
        category: String(inv.category || "Other"),
        description: String(inv.description || inv.summary || inv.invoice_number || externalId),
        amount,
        date,
        expense_month: expenseMonth,
        status: String(inv.status || "Submitted"),
        reject_reason: "",
        slip_ref: String(inv.file_url || inv.attachment_url || ""),
        pay_type: String(inv.pay_type || "employee"),
        submitted_by: String(inv.submitted_by || "manager"),
        charged_to: String(inv.charged_to || ""),
        invoice_number: String(inv.invoice_number || externalId),
        merchant_name: String(inv.merchant_name || ""),
        ai_raw: inv,
        ai_confidence: Number(inv.confidence || 1),
        source_type: "api_import",
        external_id: externalId,
        external_source: externalSource,
      };

      const { error } = await admin.from("claims").insert(row);
      if (error) results.push({ ok: false, external_id: externalId, error: error.message });
      else results.push({ ok: true, external_id: externalId, claim_id: claimId });
    }

    return json({ ok: true, results });
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    return json({ ok: false, error: msg }, 500);
  }
});
