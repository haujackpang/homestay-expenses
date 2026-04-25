import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// ── Config ──────────────────────────────────────────────────────
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") || "https://skwogboredsczcyhlqgn.supabase.co";
const SUPABASE_SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || "";
const RESERVATION_EMAIL = Deno.env.get("RESERVATION_EMAIL") || "";
const RESERVATION_PASSWORD = Deno.env.get("RESERVATION_PASSWORD") || "";
const RESERVATION_API_BASE = Deno.env.get("RESERVATION_API_BASE") || "https://nebulapi-asg.hostplatform.com/v1";

const PAGE_SIZE = 100;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

function requireSyncEnv() {
  const missing = [
    !SUPABASE_SERVICE_KEY ? "SUPABASE_SERVICE_ROLE_KEY" : "",
    !RESERVATION_EMAIL ? "RESERVATION_EMAIL" : "",
    !RESERVATION_PASSWORD ? "RESERVATION_PASSWORD" : "",
    !RESERVATION_API_BASE ? "RESERVATION_API_BASE" : "",
  ].filter(Boolean);

  if (missing.length) {
    throw new Error(`Missing required env: ${missing.join(", ")}`);
  }
}

// ── Helpers ──────────────────────────────────────────────────────

/** Extract code from parentheses, fallback to full string */
function extractCode(raw: string): string {
  if (!raw) return "";
  const m = raw.match(/\(([^)]+)\)/);
  return m ? m[1].trim() : raw.trim();
}

/** Sum all numeric values in a charges/tax/payment object */
function sumCharges(obj: Record<string, unknown> | undefined | null): number {
  if (!obj || typeof obj !== "object") return 0;
  let total = 0;
  for (const [key, val] of Object.entries(obj)) {
    if (key === "details") continue; // skip payment.details array
    if (typeof val === "number") total += val;
  }
  return Math.round(total * 100) / 100;
}

/** Calculate nights between two date strings */
function calcNights(start: string, end: string): number {
  if (!start || !end) return 0;
  const ms = new Date(end).getTime() - new Date(start).getTime();
  return Math.max(0, Math.round(ms / 86400000));
}



// ── Main ──────────────────────────────────────────────────────

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const sb = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);
  let logId: number | null = null;

  try {
    requireSyncEnv();

    // Determine sync type from body (manual vs auto)
    let syncType = "auto";
    try {
      const body = await req.json();
      if (body?.type) syncType = body.type;
    } catch { /* no body = auto */ }

    // 1. Insert sync log (running)
    const { data: logRow } = await sb.from("sync_logs").insert({
      sync_type: syncType,
      status: "running",
    }).select("id").single();
    logId = logRow?.id ?? null;

    // 2. Login to reservation API
    const loginResp = await fetch(`${RESERVATION_API_BASE}/auth/session-login`, {
      method: "POST",
      headers: { "Content-Type": "application/json;charset=UTF-8" },
      body: JSON.stringify({
        email: RESERVATION_EMAIL,
        password: RESERVATION_PASSWORD,
        deviceInfo: { userAgent: "HomestayExpenseSync/1.0" },
      }),
    });

    if (!loginResp.ok) {
      throw new Error(`Login failed: ${loginResp.status} ${await loginResp.text()}`);
    }

    const loginData = await loginResp.json();
    const token = loginData.token;
    if (!token) throw new Error("No token in login response");

    // 3. Load HP units for matching unit_raw → hp_unit_id
    const { data: hpUnits, error: hpUnitsError } = await sb
      .from("units")
      .select("hp_unit_id, name")
      .eq("source", "hostplatform");
    if (hpUnitsError) {
      throw new Error(`Failed to load HostPlatform units: ${hpUnitsError.message}`);
    }
    const unitRawToHpId: Record<string, string> = {};
    if (hpUnits) {
      for (const u of hpUnits) {
        if (u.name && u.hp_unit_id) {
          unitRawToHpId[u.name.toLowerCase()] = u.hp_unit_id;
        }
      }
    }

    // 4. Paginate through all reservations
    let currentPage = 1;
    let totalFetched = 0;
    let totalUpserted = 0;
    let totalCount = 0;

    do {
      const pagination = JSON.stringify({ limit: PAGE_SIZE, currentPage });
      const encoded = encodeURIComponent(encodeURIComponent(pagination));
      const url = `${RESERVATION_API_BASE}/reservation/paginated?pagination=${encoded}`;

      const apiResp = await fetch(url, {
        headers: {
          Authorization: token,
          Accept: "application/json, text/plain, */*",
          Referer: "https://system.hostplatform.com/",
          Origin: "https://system.hostplatform.com",
        },
      });

      if (!apiResp.ok) {
        throw new Error(`API page ${currentPage} failed: ${apiResp.status}`);
      }

      const pageData = await apiResp.json();
      totalCount = pageData.totalCount || 0;
      const reservations: Record<string, unknown>[] = pageData.reservations || [];
      totalFetched += reservations.length;

      // 5. Process & upsert each reservation
      // Group by extracted code: keep only the one with largest _id
      const byCode: Record<string, Record<string, unknown>> = {};
      for (const r of reservations) {
        const code = extractCode(r.code as string);
        if (!code) continue;
        const existing = byCode[code];
        if (!existing || (r._id as string) > (existing._id as string)) {
          byCode[code] = r;
        }
      }

      const rows = Object.values(byCode).map((r) => {
        const code = extractCode(r.code as string);
        const unitRaw = (r.unitName as string) || "";
        const charges = r.charges as Record<string, unknown> | undefined;
        const rental = typeof charges?.rental === "number" ? charges.rental : 0;
        const extraGuest = typeof charges?.extraGuest === "number" ? charges.extraGuest : 0;

        return {
          ext_id: r._id as string,
          code,
          source_id: (r.sourceId as string) || null,
          booking_type: (r.bookingType as number) ?? 3,
          platform: (r.platform as string) || "",
          booking_status: (r.bookingStatus as string) || "",
          unit_raw: unitRaw,
          unit_name: unitRaw,
          hp_unit_id: unitRawToHpId[unitRaw.toLowerCase()] || null,
          property_name: (r.propertyName as string) || "",
          guest_name: (r.guestName as string) || "",
          contact_number: (r.contactNumber as string) || "",
          start_date: (r.startDate as string) || null,
          end_date: (r.endDate as string) || null,
          nights: calcNights(r.startDate as string, r.endDate as string),
          rental: Math.round(rental * 100) / 100,
          extra_guest: Math.round(extraGuest * 100) / 100,
          total_charges: sumCharges(charges),
          charges: charges || {},
          tax: r.tax || {},
          payment: r.payment || {},
          raw_data: r,
          ext_created_at: (r.createdAt as string) || null,
          updated_at: new Date().toISOString(),
        };
      });

      if (rows.length > 0) {
        const { error } = await sb.from("reservations").upsert(rows, {
          onConflict: "code",
          ignoreDuplicates: false,
        });
        if (error) {
          console.error("Upsert error page", currentPage, error);
        } else {
          totalUpserted += rows.length;
        }
      }

      currentPage++;
    } while ((currentPage - 1) * PAGE_SIZE < totalCount);

    // 6. Update sync log (success)
    if (logId) {
      await sb.from("sync_logs").update({
        finished_at: new Date().toISOString(),
        records_fetched: totalFetched,
        records_upserted: totalUpserted,
        status: "success",
      }).eq("id", logId);
    }

    return new Response(
      JSON.stringify({ ok: true, fetched: totalFetched, upserted: totalUpserted, totalCount }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    console.error("sync-reservations error:", msg);

    // Update sync log (error)
    if (logId) {
      await sb.from("sync_logs").update({
        finished_at: new Date().toISOString(),
        status: "error",
        error_msg: msg.substring(0, 500),
      }).eq("id", logId);
    }

    // Also log to error_logs table
    try {
      await sb.from("error_logs").insert({
        level: "error",
        source: "sync-reservations",
        message: msg.substring(0, 500),
        details: {},
      });
    } catch { /* ignore */ }

    return new Response(
      JSON.stringify({ ok: false, error: msg }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
