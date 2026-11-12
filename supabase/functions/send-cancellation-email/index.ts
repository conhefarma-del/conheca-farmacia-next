import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { sendViaBrevo } from "../_shared/brevo.ts";

const SITE_URL = "https://conhecafarmacia.com";
const INTERNAL_KEY = Deno.env.get("EDGE_INTERNAL_KEY");

function corsHeaders(origin: string | null) {
  return {
    "Access-Control-Allow-Origin": origin || SITE_URL,
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type, x-internal-key",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
  };
}

const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

function escapeHtml(value: unknown) {
  return String(value ?? "")
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

function template(nome: string, evento: string, data: string, lang: string) {
  const isEN = lang === "en";
  return `<!DOCTYPE html>
<html lang="${isEN ? "en" : "pt-PT"}">
<body style="margin:0;padding:0;background:#f5f5f5;font-family:'Segoe UI',Roboto,Arial,sans-serif;">
<table width="100%" cellpadding="0" cellspacing="0" style="background:#f5f5f5;">
<tr><td align="center" style="padding:40px 20px;">
<table width="600" cellpadding="0" cellspacing="0" style="background:#fff;border-radius:8px;overflow:hidden;">
<tr><td style="background:linear-gradient(135deg,#00493a 0%,#0a844f 100%);padding:36px 20px;text-align:center;">
<h1 style="margin:0;color:#fff;font-size:26px;">Conheça Farmácia</h1>
</td></tr>
<tr><td style="padding:36px 30px;color:#333;font-size:15px;line-height:1.6;">
<p>${isEN ? "Hello" : "Olá"} <strong>${escapeHtml(nome)}</strong>,</p>
<p>${isEN
    ? "Your registration has been cancelled and your place released."
    : "A sua inscrição foi cancelada e a vaga foi libertada."}</p>
<table width="100%" style="background:#f9f9f9;border-left:4px solid #00493a;margin:20px 0;">
<tr><td style="padding:18px;">
<p style="margin:0 0 8px;font-weight:700;color:#00493a;">${escapeHtml(evento)}</p>
<p style="margin:0;color:#666;">${escapeHtml(data)}</p>
</td></tr>
</table>
<p>${isEN
    ? "If this was not you, contact us immediately."
    : "Se não foi você, contacte-nos imediatamente."}</p>
<p style="margin-top:28px;">
<a href="${SITE_URL}/${isEN ? "en" : "pt"}/eventos" style="color:#00493a;font-weight:600;">${isEN ? "See other events" : "Ver outros eventos"}</a>
</p>
</td></tr>
<tr><td style="background:#f9f9f9;padding:20px;text-align:center;color:#999;font-size:12px;">
© 2026 Conheça Farmácia
</td></tr>
</table>
</td></tr>
</table>
</body></html>`;
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders(req.headers.get("origin")) });
  }

  const headers = { "Content-Type": "application/json", ...corsHeaders(req.headers.get("origin")) };

  try {
    if (!INTERNAL_KEY || req.headers.get("x-internal-key") !== INTERNAL_KEY) {
      return new Response(JSON.stringify({ error: "unauthorized" }), { status: 401, headers });
    }

    const body = await req.json().catch(() => ({}));
    const inscriptionId = String(body.inscription_id || "");
    const lang = body.lang === "en" ? "en" : "pt";

    if (!/^\d{1,18}$/.test(inscriptionId)) {
      return new Response(JSON.stringify({ error: "invalid_input" }), { status: 400, headers });
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const { data: row, error } = await supabase
      .from("inscricoes")
      .select("nome, email, status, created_at, evento:events(title, date)")
      .eq("id", inscriptionId)
      .maybeSingle();

    if (error || !row) {
      return new Response(JSON.stringify({ error: "not_found" }), { status: 404, headers });
    }
    if (!EMAIL_REGEX.test(row.email) || row.email.length > 254) {
      return new Response(JSON.stringify({ error: "invalid_email" }), { status: 400, headers });
    }

    const dataEvento = row.evento?.date
      ? new Date(`${row.evento.date}T00:00:00`).toLocaleDateString(lang === "en" ? "en-GB" : "pt-PT", {
          day: "numeric", month: "long", year: "numeric",
        })
      : "";

    await sendViaBrevo({
      to: { email: row.email, name: row.nome },
      sender: "inscricao@conhecafarmacia.com",
      subject: lang === "en"
        ? "Registration cancelled - Conheça Farmácia"
        : "Inscrição cancelada - Conheça Farmácia",
      htmlContent: template(row.nome, row.evento?.title || "", dataEvento, lang),
      replyTo: "contato@conhecafarmacia.com",
      tags: ["cancellation", lang],
    });

    return new Response(JSON.stringify({ success: true }), { status: 200, headers });
  } catch (error) {
    console.error("send-cancellation-email error:", (error as Error).message);
    return new Response(JSON.stringify({ error: "internal_error" }), { status: 500, headers });
  }
});
