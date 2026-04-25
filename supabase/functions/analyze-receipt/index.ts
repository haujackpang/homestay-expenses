import "https://deno.land/x/xhr@0.3.0/mod.ts";
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const OPENROUTER_API_KEY = Deno.env.get("OPENROUTER_API_KEY") || "";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") || "";
const SUPABASE_SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || "";
const OPENROUTER_PRIMARY_MODEL = Deno.env.get("OPENROUTER_OCR_PRIMARY_MODEL") || "qwen/qwen2.5-vl-32b-instruct:free";
const OPENROUTER_FALLBACK_MODELS = (Deno.env.get("OPENROUTER_OCR_FALLBACK_MODELS") || "").trim();

const CATEGORIES = [
  "Water Bill",
  "Electricity Bill",
  "Internet Bill",
  "Rental",
  "MFSF",
  "Utilities",
  "Maintenance & Repair",
  "Housekeeping & Cleaning",
  "Laundry",
  "Daily Products",
  "Hospitality Items",
  "Electrical & Unit Setup",
  "Office Expenses",
  "Employee Welfare",
  "Outsource Cleaning Staff",
  "Unit Renovation",
  "Other",
];

const BILL_PREFIX: Record<string, string> = {
  "Water Bill": "WB",
  "Electricity Bill": "EB",
  "Internet Bill": "INT",
};

const MONTH_LABELS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

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

async function logError(level: string, source: string, message: string, details?: Record<string, unknown>) {
  try {
    if (!SUPABASE_URL || !SUPABASE_SERVICE_KEY) return;
    const sb = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);
    await sb.from("error_logs").insert({ level, source, message, details: details || {} });
  } catch (e) {
    console.error("Failed to write error log:", e);
  }
}

function normalizeDate(value: unknown) {
  const text = String(value || "").trim();
  if (/^\d{4}-\d{2}-\d{2}$/.test(text)) return text;
  const parsed = new Date(text);
  return Number.isNaN(parsed.getTime()) ? "" : parsed.toISOString().slice(0, 10);
}

function previousMonth(date: string) {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(date)) return "";
  const d = new Date(Number(date.slice(0, 4)), Number(date.slice(5, 7)) - 2, 1);
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}`;
}

function validMonth(value: unknown) {
  const text = String(value || "").trim();
  return /^\d{4}-\d{2}$/.test(text) ? text : "";
}

function expenseMonth(category: string, date: string, explicitMonth?: unknown) {
  const fixed = validMonth(explicitMonth);
  if (fixed) return fixed;
  if (BILL_PREFIX[category] && date) return previousMonth(date);
  return date ? date.slice(0, 7) : new Date().toISOString().slice(0, 7);
}

function monthLabel(month: string) {
  if (!/^\d{4}-\d{2}$/.test(month)) return "";
  const idx = Number(month.slice(5, 7)) - 1;
  if (idx < 0 || idx > 11) return "";
  return `${MONTH_LABELS[idx]} ${month.slice(2, 4)}`;
}

function billDescription(category: string, unit: string, month: string, fallback: string) {
  const prefix = BILL_PREFIX[category];
  if (!prefix) return fallback || category || "Receipt";
  const parts = [`[${prefix}]`];
  if (unit) parts.push(unit);
  const label = monthLabel(month);
  if (label) parts.push(label);
  return parts.join(" ");
}

function cleanText(value: unknown) {
  return String(value || "").replace(/\s+/g, " ").trim();
}

function itemNames(items: Array<{ name?: unknown }>) {
  const seen = new Set<string>();
  const names: string[] = [];
  for (const item of items) {
    const name = cleanText(item?.name);
    if (!name) continue;
    const key = name.toLowerCase();
    if (seen.has(key)) continue;
    seen.add(key);
    names.push(name);
    if (names.length >= 3) break;
  }
  return names;
}

function nonBillDescription(
  category: string,
  merchant: string,
  invoiceNumber: string,
  summary: string,
  items: Array<{ name?: unknown }>,
) {
  const base = cleanText(summary) || cleanText(merchant) || category || "Receipt";
  const parts = [base];
  if (invoiceNumber) parts.push(`Invoice ${invoiceNumber}`);
  const names = itemNames(items);
  if (names.length) parts.push(`Items: ${names.join(", ")}`);
  return parts.join(" | ");
}

function receiptDescription(
  category: string,
  unit: string,
  month: string,
  merchant: string,
  invoiceNumber: string,
  summary: string,
  items: Array<{ name?: unknown }>,
) {
  if (BILL_PREFIX[category]) return billDescription(category, unit, month, summary || category || "Receipt");
  return nonBillDescription(category, merchant, invoiceNumber, summary, items);
}

function parseJson(rawText: string) {
  const clean = rawText.replace(/```json\s*/gi, "").replace(/```\s*/g, "").trim();
  try {
    return JSON.parse(clean);
  } catch {
    const first = clean.indexOf("{");
    const last = clean.lastIndexOf("}");
    if (first >= 0 && last > first) return JSON.parse(clean.slice(first, last + 1));
    throw new Error("AI response was not valid JSON");
  }
}

function extractResponseText(data: any) {
  if (typeof data?.output_text === "string" && data.output_text.trim()) return data.output_text;
  const chunks: string[] = [];
  for (const item of data?.output || []) {
    for (const content of item?.content || []) {
      if (typeof content?.text === "string") chunks.push(content.text);
      if (typeof content?.output_text === "string") chunks.push(content.output_text);
    }
  }
  return chunks.join("\n").trim();
}

function buildPrompt(selectedUnit: string) {
  const unitRule = selectedUnit
    ? `Selected unit from the form is "${selectedUnit}". Use this as unit_hint unless the document clearly shows a different homestay unit.`
    : "If a homestay unit name/code appears on the document, return it in unit_hint; otherwise return an empty string.";

  return `You are an OCR and invoice extraction engine for a Malaysian homestay expense system.

Extract the invoice/receipt data from the image and return ONLY valid JSON. No markdown or explanation.

Allowed categories: ${JSON.stringify(CATEGORIES)}

Important extraction rules:
- Total must be the final amount payable/paid in RM. For utility bills, use Amount Due / Total Payable / Jumlah Perlu Dibayar / Amaun, not kWh, meter units, litres, m3, or usage.
- Date must be the invoice/bill/transaction date in YYYY-MM-DD. If unreadable, return an empty string.
- Category must be exactly one allowed category.
- Extract merchant_name whenever a vendor, shop, landlord, or bill issuer is visible.
- Extract invoice_number whenever an invoice, receipt, bill, or reference number is visible.
- Extract item lines into items[] whenever line items are readable. Do not omit obvious purchased items.
- summary must be a short readable one-line summary of the receipt in plain English.
- Utility description rules:
  - Water Bill description format is [WB] UNIT Mon YY.
  - Electricity Bill description format is [EB] UNIT Mon YY.
  - Internet Bill description format is [INT] UNIT Mon YY.
  - If the bill date is in March 2026 and there is no explicit service period, the expense/bill period is February 2026, so Mon YY is Feb 26.
  - If the document has an explicit service/billing period, use that period for expense_month.
- For non-utility receipts, include invoice_number and key purchased items in summary/description when they are visible.
- ${unitRule}

Return this exact JSON structure:
{
  "items": [{"name": "item description", "qty": 1, "price": 12.50}],
  "merchant_name": "vendor or merchant name",
  "invoice_number": "invoice or bill number if found",
  "category": "one of the allowed categories",
  "total": 45.80,
  "date": "YYYY-MM-DD",
  "expense_month": "YYYY-MM",
  "bill_period_month": "YYYY-MM",
  "description": "[WB] 150A Feb 26",
  "summary": "brief 1-line summary",
  "reference_number": "invoice or bill number if found",
  "unit_hint": "unit code/name if visible",
  "confidence": 0.85,
  "is_receipt": true
}`;
}

function openRouterModels() {
  const fallbackModels = OPENROUTER_FALLBACK_MODELS
    ? OPENROUTER_FALLBACK_MODELS.split(",").map((m) => cleanText(m)).filter(Boolean)
    : [
      "qwen/qwen2.5-vl-72b-instruct:free",
      "nvidia/nemotron-nano-12b-v2-vl:free",
    ];
  return [OPENROUTER_PRIMARY_MODEL, ...fallbackModels].filter((model, idx, arr) => model && arr.indexOf(model) === idx);
}

function shouldTryNextOpenRouterModel(status: number, errMsg: string) {
  const normalized = cleanText(errMsg).toLowerCase();
  if ([400, 404, 408, 409, 425, 429, 500, 502, 503, 504].includes(status)) return true;
  if (normalized.includes("no endpoints found")) return true;
  if (normalized.includes("provider returned error")) return true;
  if (normalized.includes("temporarily unavailable")) return true;
  return false;
}

async function analyzeWithOpenRouter(prompt: string, dataUrl: string) {
  let rawText = "";
  let lastErr = "";
  let usedModel = "";

  for (const model of openRouterModels()) {
    try {
      const response = await fetch("https://openrouter.ai/api/v1/chat/completions", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${OPENROUTER_API_KEY}`,
          "HTTP-Referer": SUPABASE_URL || "https://supabase.co",
          "X-Title": "Homestay Expense System",
        },
        body: JSON.stringify({
          model,
          messages: [
            {
              role: "user",
              content: [
                { type: "text", text: prompt },
                { type: "image_url", image_url: { url: dataUrl } },
              ],
            },
          ],
          response_format: { type: "json_object" },
          temperature: 0.1,
          max_tokens: 2048,
        }),
      });

      if (!response.ok) {
        const errText = await response.text();
        let errMsg = `HTTP ${response.status}`;
        try {
          const parsed = JSON.parse(errText);
          errMsg = parsed?.error?.message || errMsg;
        } catch { /* keep HTTP status */ }
        await logError("warn", "analyze-receipt", `OpenRouter model ${model} failed: ${errMsg}`, { model, status: response.status });
        lastErr = errMsg;
        if (shouldTryNextOpenRouterModel(response.status, errMsg)) continue;
        break;
      }

      const data = await response.json();
      rawText = data?.choices?.[0]?.message?.content || "";
      if (rawText) {
        usedModel = model;
        break;
      }
      lastErr = "Empty response from " + model;
      await logError("warn", "analyze-receipt", `OpenRouter model ${model} returned empty response`, { model });
    } catch (e) {
      lastErr = e instanceof Error ? e.message : String(e);
      await logError("warn", "analyze-receipt", `OpenRouter model ${model} fetch error: ${lastErr}`, { model });
    }
  }

  if (!rawText) throw new Error("All OpenRouter models failed. Last error: " + lastErr);
  await logError("info", "analyze-receipt", "AI OCR used OpenRouter", { model: usedModel });
  return { rawText, usedModel };
}

function normalizeResult(parsed: any, selectedUnit: string, provider: string, model: string) {
  const category = CATEGORIES.includes(parsed?.category) ? parsed.category : "Other";
  const date = normalizeDate(parsed?.date);
  const unit = String(selectedUnit || parsed?.unit_hint || "").trim();
  const month = expenseMonth(category, date, parsed?.expense_month || parsed?.bill_period_month);
  const normalizedItems = Array.isArray(parsed?.items)
    ? parsed.items.map((item: { name?: string; qty?: number; price?: number }) => ({
        name: String(item.name || "Unknown item"),
        qty: Number(item.qty) || 1,
        price: Number(item.price) || 0,
      }))
    : [];
  const merchantName = cleanText(parsed?.merchant_name || parsed?.vendor || parsed?.supplier || "");
  const invoiceNumber = cleanText(parsed?.invoice_number || parsed?.reference_number || "");
  const fallbackSummary = cleanText(parsed?.summary || parsed?.description || merchantName || category || "Receipt");
  const description = receiptDescription(category, unit, month, merchantName, invoiceNumber, fallbackSummary, normalizedItems);

  return {
    items: normalizedItems,
    merchant_name: merchantName,
    invoice_number: invoiceNumber,
    category,
    total: Number(parsed?.total) || 0,
    date,
    expense_month: month,
    bill_period_month: validMonth(parsed?.bill_period_month) || month,
    description,
    summary: fallbackSummary,
    reference_number: cleanText(parsed?.reference_number || parsed?.invoice_number || ""),
    unit_hint: unit,
    confidence: Math.max(0, Math.min(1, Number(parsed?.confidence) || 0)),
    is_receipt: parsed?.is_receipt !== false,
    ai_provider: provider,
    ai_model: model,
  };
}

serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "POST required" }, 405);

  try {
    const { fileUrl, mimeType, base64Data: clientBase64, unit } = await req.json();
    if (!fileUrl && !clientBase64) return json({ error: "fileUrl or base64Data is required" }, 400);

    let base64Data = "";
    let detectedMime = mimeType || "image/jpeg";

    if (clientBase64) {
      if (String(clientBase64).startsWith("data:")) {
        const parts = String(clientBase64).split(",");
        base64Data = parts[1] || "";
        const mimeMatch = parts[0].match(/data:([^;]+)/);
        if (mimeMatch && !mimeType) detectedMime = mimeMatch[1];
      } else {
        base64Data = String(clientBase64);
      }
      if (base64Data.length > 7 * 1024 * 1024) return json({ error: "Image too large. Please use a photo under 5MB." }, 400);
    } else {
      detectedMime = mimeType ||
        (String(fileUrl).match(/\.(jpg|jpeg)$/i) ? "image/jpeg"
          : String(fileUrl).match(/\.png$/i) ? "image/png"
          : String(fileUrl).match(/\.gif$/i) ? "image/gif"
          : String(fileUrl).match(/\.webp$/i) ? "image/webp"
          : "image/jpeg");
      const fileResponse = await fetch(fileUrl);
      if (!fileResponse.ok) return json({ error: "Failed to download image from storage" }, 400);
      const fileBuffer = await fileResponse.arrayBuffer();
      if (fileBuffer.byteLength > 5 * 1024 * 1024) return json({ error: "Image too large. Please use a photo under 5MB." }, 400);
      const bytes = new Uint8Array(fileBuffer);
      let binary = "";
      for (let i = 0; i < bytes.length; i += 8192) binary += String.fromCharCode(...bytes.subarray(i, i + 8192));
      base64Data = btoa(binary);
    }

    const selectedUnit = String(unit || "").trim();
    const prompt = buildPrompt(selectedUnit);
    const dataUrl = `data:${detectedMime};base64,${base64Data}`;

    let rawText = "";
    let provider = "openrouter";
    let model = "";

    if (OPENROUTER_API_KEY) {
      const result = await analyzeWithOpenRouter(prompt, dataUrl);
      rawText = result.rawText;
      model = result.usedModel;
    }

    if (!rawText) {
      return json({ error: "AI OCR is not configured. Add OPENROUTER_API_KEY to Supabase secrets." }, 500);
    }

    let parsed;
    try {
      parsed = parseJson(rawText);
    } catch (e) {
      await logError("error", "analyze-receipt", "Failed to parse AI response as JSON", {
        provider,
        model,
        rawText: rawText.slice(0, 500),
      });
      return json({ error: "Could not parse receipt. Please try a clearer photo.", raw: rawText }, 422);
    }

    return json(normalizeResult(parsed, selectedUnit, provider, model));
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    await logError("error", "analyze-receipt", "Unexpected error: " + message, {
      stack: err instanceof Error ? err.stack : undefined,
    });
    return json({ error: "Internal error: " + message }, 500);
  }
});
