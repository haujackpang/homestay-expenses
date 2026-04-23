import "https://deno.land/x/xhr@0.3.0/mod.ts";
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const OPENROUTER_API_KEY = Deno.env.get("OPENROUTER_API_KEY");
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") || "https://skwogboredsczcyhlqgn.supabase.co";
const SUPABASE_SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || "";

// Fallback models: try in order, skip to next on rate limit / provider error
const MODELS = [
  "nvidia/nemotron-nano-12b-v2-vl:free",  // OCR-optimized VL model, best for receipts
  "google/gemma-3-27b-it:free",
  "google/gemma-3-12b-it:free",
  "google/gemma-3-4b-it:free",
  "openrouter/free",
];

// ── Error logger ──────────────────────────────────────────────
async function logError(level: string, source: string, message: string, details?: Record<string, unknown>) {
  try {
    if (!SUPABASE_SERVICE_KEY) return;
    const sb = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);
    await sb.from("error_logs").insert({
      level,
      source,
      message,
      details: details || {},
    });
  } catch (e) {
    console.error("Failed to write error log:", e);
  }
}

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

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    if (!OPENROUTER_API_KEY) {
      return new Response(
        JSON.stringify({ error: "OPENROUTER_API_KEY not configured" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const { fileUrl, mimeType, base64Data: clientBase64 } = await req.json();
    if (!fileUrl && !clientBase64) {
      return new Response(
        JSON.stringify({ error: "fileUrl or base64Data is required" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    let base64Data: string;
    let detectedMime: string = mimeType || "image/jpeg";

    if (clientBase64) {
      // Client sent base64 directly — extract raw base64 from data URL if needed
      if (clientBase64.startsWith("data:")) {
        const parts = clientBase64.split(",");
        base64Data = parts[1] || "";
        const mimeMatch = parts[0].match(/data:([^;]+)/);
        if (mimeMatch && !mimeType) detectedMime = mimeMatch[1];
      } else {
        base64Data = clientBase64;
      }
      // Size check (~base64 is ~4/3 of original)
      if (base64Data.length > 7 * 1024 * 1024) {
        return new Response(
          JSON.stringify({ error: "Image too large. Please use a photo under 5MB." }),
          { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }
    } else {
      // Legacy: download from fileUrl
      detectedMime = mimeType ||
        (fileUrl.match(/\.(jpg|jpeg)$/i) ? "image/jpeg"
          : fileUrl.match(/\.png$/i) ? "image/png"
          : fileUrl.match(/\.gif$/i) ? "image/gif"
          : fileUrl.match(/\.webp$/i) ? "image/webp"
          : "image/jpeg");

      const fileResponse = await fetch(fileUrl);
      if (!fileResponse.ok) {
        return new Response(
          JSON.stringify({ error: "Failed to download image from storage" }),
          { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }
      const fileBuffer = await fileResponse.arrayBuffer();
      if (fileBuffer.byteLength > 5 * 1024 * 1024) {
        return new Response(
          JSON.stringify({ error: "Image too large. Please use a photo under 5MB." }),
          { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }
      const bytes = new Uint8Array(fileBuffer);
      let binary = "";
      const chunkSize = 8192;
      for (let i = 0; i < bytes.length; i += chunkSize) {
        binary += String.fromCharCode(...bytes.subarray(i, i + chunkSize));
      }
      base64Data = btoa(binary);
    }

    const categoryList = JSON.stringify(CATEGORIES);
    const prompt = `You are an expert receipt/invoice analyzer. Your PRIMARY FOCUS is to extract **every line item**, **each item's amount**, the **total amount**, and the **date** from this receipt or invoice.

YOUR #1 PRIORITY — ITEMS & AMOUNTS:
- Extract EVERY line item visible on the receipt — do NOT skip any item
- For each item, capture: the item name/description, quantity, and the RM price charged for that item
- If an item has qty > 1, "price" should be the TOTAL cost for that line (qty × unit price)
- The "total" field must be the final total amount paid (look for "Total", "Grand Total", "Amount Due", "Jumlah")
- The total should equal the sum of all item prices (if it doesn't match, trust the printed total on receipt)

DATE EXTRACTION:
- Look for transaction date, invoice date, or bill date on the receipt
- Return in YYYY-MM-DD format
- If no date is found, return empty string

IMPORTANT RULES:
- All prices/amounts are in Malaysian Ringgit (RM)
- Return ONLY valid JSON, no markdown, no code blocks, no explanation
- If you cannot read certain fields, use reasonable defaults
- For the category field, you MUST choose exactly one from this list: ${categoryList}

CRITICAL - PRICE vs USAGE/QUANTITY:
- "price" field MUST be a MONETARY VALUE in RM (e.g. 45.80, 12.50) — this is what was CHARGED/PAID
- NEVER put usage units (kWh, m3, litres, units) into the "price" field
- NEVER put meter readings into the "price" field
- For utility bills (TNB/electricity, Syabas/water, gas): look for "Amount Due", "Jumlah Perlu Dibayar", "Total Payable", or "Amaun" — that is the price
- "qty" is the quantity/number of units purchased (use 1 if unclear)

EXAMPLES of what NOT to do:
- Water bill shows "Usage: 15 m3" and "Amount: RM 8.50" → price = 8.50 (NOT 15)
- Electric bill shows "234 kWh" and "RM 98.40" → price = 98.40 (NOT 234)

REFERENCE NUMBER EXTRACTION:
- Look for invoice number, bill number, reference number, account number, receipt number on the document
- Return the best invoice/bill number in both "invoice_number" and "reference_number"
- If multiple reference numbers exist, return the most prominent one (invoice/bill number preferred)
- If no reference number is found, return empty string

MERCHANT AND UNIT:
- Extract the merchant/vendor/company name, such as TNB, Indah Water, TM/Unifi, Syabas, Shopee, supplier shop name
- If a homestay unit name/code appears, return it in "unit_hint"; otherwise return empty string
- Return confidence from 0 to 1 based on how clearly you read the document

Return this exact JSON structure:
{
  "items": [
    {"name": "item description", "qty": 1, "price": 12.50}
  ],
  "merchant_name": "vendor or merchant name",
  "invoice_number": "invoice or bill number if found",
  "category": "one of the allowed categories",
  "total": 45.80,
  "date": "YYYY-MM-DD",
  "summary": "brief 1-line summary of what this receipt is for",
  "reference_number": "invoice or bill number if found",
  "unit_hint": "unit code/name if visible",
  "confidence": 0.85,
  "is_receipt": true
}
is_receipt: set to false ONLY if you are confident this image is NOT a receipt or invoice (e.g. selfie, nature photo, ID card, blank document, screenshot with no transaction data). Default to true for any document showing payment, purchase, billing, or utility information.`;

    // ── Try each model with fallback ──
    let rawText = "";
    let lastErr = "";
    let usedModel = "";

    for (const model of MODELS) {
      try {
        console.log(`Trying model: ${model}`);
        const openRouterResponse = await fetch("https://openrouter.ai/api/v1/chat/completions", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${OPENROUTER_API_KEY}`,
            "HTTP-Referer": "https://skwogboredsczcyhlqgn.supabase.co",
            "X-Title": "Homestay Expense Tracker",
          },
          body: JSON.stringify({
            model,
            messages: [
              {
                role: "user",
                content: [
                  { type: "text", text: prompt },
                  { type: "image_url", image_url: { url: `data:${detectedMime};base64,${base64Data}` } },
                ],
              },
            ],
            temperature: 0.1,
            max_tokens: 2048,
          }),
        });

        if (!openRouterResponse.ok) {
          const errText = await openRouterResponse.text();
          let errMsg = `HTTP ${openRouterResponse.status}`;
          try { const ej = JSON.parse(errText); errMsg = ej?.error?.message || errMsg; } catch { /* */ }
          console.warn(`Model ${model} failed: ${errMsg}`);
          await logError("warn", "analyze-receipt", `Model ${model} failed: ${errMsg}`, { model, status: openRouterResponse.status });
          lastErr = errMsg;
          // If rate-limited or provider error, try next model
          if (openRouterResponse.status === 429 || openRouterResponse.status === 502 || openRouterResponse.status === 503) {
            continue;
          }
          // For other errors (400, 401, etc.) don't retry — it won't help
          break;
        }

        const responseData = await openRouterResponse.json();
        rawText = responseData?.choices?.[0]?.message?.content || "";
        if (rawText) {
          usedModel = model;
          console.log(`Success with model: ${model}`);
          break;
        }
        // Empty response — try next
        await logError("warn", "analyze-receipt", `Model ${model} returned empty response`, { model });
        lastErr = "Empty response from " + model;
      } catch (fetchErr) {
        const msg = (fetchErr as Error).message;
        console.warn(`Model ${model} fetch error: ${msg}`);
        await logError("warn", "analyze-receipt", `Model ${model} fetch error: ${msg}`, { model });
        lastErr = msg;
      }
    }

    if (!rawText) {
      await logError("error", "analyze-receipt", `All models failed. Last error: ${lastErr}`, { models: MODELS });
      return new Response(
        JSON.stringify({ error: "All AI models are temporarily unavailable. Please try again in a moment. (" + lastErr + ")" }),
        { status: 502, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    let parsed;
    try {
      const jsonStr = rawText
        .replace(/```json\s*/g, "")
        .replace(/```\s*/g, "")
        .trim();
      parsed = JSON.parse(jsonStr);
    } catch {
      console.error("Failed to parse response:", rawText);
      await logError("error", "analyze-receipt", "Failed to parse AI response as JSON", { model: usedModel, rawText: rawText.substring(0, 500) });
      return new Response(
        JSON.stringify({ error: "Could not parse receipt. Please try a clearer photo.", raw: rawText }),
        { status: 422, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const result = {
      items: Array.isArray(parsed.items)
        ? parsed.items.map((item: { name?: string; qty?: number; price?: number }) => ({
            name: String(item.name || "Unknown item"),
            qty: Number(item.qty) || 1,
            price: Number(item.price) || 0,
          }))
        : [],
      merchant_name: String(parsed.merchant_name || parsed.vendor || parsed.supplier || ""),
      invoice_number: String(parsed.invoice_number || parsed.reference_number || ""),
      category: CATEGORIES.includes(parsed.category) ? parsed.category : "Other",
      total: Number(parsed.total) || 0,
      date: /^\d{4}-\d{2}-\d{2}$/.test(parsed.date) ? parsed.date : "",
      summary: String(parsed.summary || "Receipt"),
      reference_number: String(parsed.reference_number || parsed.invoice_number || ""),
      unit_hint: String(parsed.unit_hint || ""),
      confidence: Math.max(0, Math.min(1, Number(parsed.confidence) || 0)),
      is_receipt: parsed.is_receipt !== false,
    };

    return new Response(JSON.stringify(result), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err) {
    console.error("Unexpected error:", err);
    // Best-effort error log
    try {
      if (SUPABASE_SERVICE_KEY) {
        const sb = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);
        await sb.from("error_logs").insert({
          level: "error",
          source: "analyze-receipt",
          message: "Unexpected error: " + (err as Error).message,
          details: { stack: (err as Error).stack },
        });
      }
    } catch { /* ignore */ }
    return new Response(
      JSON.stringify({ error: "Internal error: " + (err as Error).message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
