import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

interface EmailRequest {
  type: "welcome" | "article" | "event" | "live";
  email: string;
  nome?: string;
  contentTitle?: string;
  contentUrl?: string;
  contentDescription?: string;
  contentDate?: string;
}

function getWelcomeTemplate(nome: string): string {
  return `
<!doctype html>
<html lang="pt-PT">
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"></head>
<body style="margin:0;padding:0;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif;background-color:#f5f5f5;">
<table width="100%" cellpadding="0" cellspacing="0" style="background-color:#f5f5f5">
<tr><td align="center" style="padding:40px 20px">
<table width="600" cellpadding="0" cellspacing="0" style="background-color:#ffffff;border-radius:8px;box-shadow:0 2px 8px rgba(0,0,0,0.1);overflow:hidden">
<tr><td style="background:linear-gradient(135deg,#00493a 0%,#0a844f 100%);padding:40px 20px;text-align:center">
<h1 style="margin:0;color:#ffffff;font-size:28px;font-weight:700">Conheça Farmácia</h1>
<p style="margin:8px 0 0 0;color:rgba(255,255,255,0.9);font-size:14px;font-weight:300">Conhecimento que conecta. Formação que transforma.</p>
</td></tr>
<tr><td style="padding:40px 30px">
<p style="margin:0 0 20px 0;font-size:16px;color:#333333;font-weight:600">Olá <strong>${nome}</strong>,</p>
<p style="margin:0 0 24px 0;font-size:15px;color:#555555;line-height:1.6">Bem-vindo à newsletter da Conheça Farmácia! 🎉</p>
<p style="margin:0 0 24px 0;font-size:15px;color:#555555;line-height:1.6">A partir de agora, receberá as nossas atualizações sobre artigos, eventos e lives diretamente na sua caixa de entrada.</p>
<p style="margin:0 0 24px 0;font-size:15px;color:#555555;line-height:1.6">Obrigado por se juntar à nossa comunidade de profissionais de saúde dedicados à excelência.</p>
</td></tr>
<tr><td style="background-color:#f9f9f9;padding:24px 30px;border-top:1px solid #e0e0e0;text-align:center">
<p style="margin:0 0 12px 0;font-size:13px;color:#999999"><strong style="color:#333333">Conheça Farmácia</strong></p>
<p style="margin:0 0 16px 0;font-size:12px;color:#999999">Conhecimento que conecta. Formação que transforma.</p>
<p style="margin:16px 0 0 0;font-size:11px;color:#bbb">© 2026 Conheça Farmácia. Todos os direitos reservados.</p>
</td></tr>
</table>
</td></tr>
</table>
</body></html>`;
}

function getAlertTemplate(
  type: string,
  title: string,
  description: string,
  url: string,
  date?: string
): string {
  const icon = type === "article" ? "📄" : type === "event" ? "📅" : "🎥";
  const label =
    type === "article"
      ? "Novo Artigo"
      : type === "event"
      ? "Novo Evento"
      : "Nova Live";

  return `
<!doctype html>
<html lang="pt-PT">
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"></head>
<body style="margin:0;padding:0;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif;background-color:#f5f5f5;">
<table width="100%" cellpadding="0" cellspacing="0" style="background-color:#f5f5f5">
<tr><td align="center" style="padding:40px 20px">
<table width="600" cellpadding="0" cellspacing="0" style="background-color:#ffffff;border-radius:8px;box-shadow:0 2px 8px rgba(0,0,0,0.1);overflow:hidden">
<tr><td style="background:linear-gradient(135deg,#00493a 0%,#0a844f 100%);padding:40px 20px;text-align:center">
<h1 style="margin:0;color:#ffffff;font-size:28px;font-weight:700">Conheça Farmácia</h1>
<p style="margin:8px 0 0 0;color:rgba(255,255,255,0.9);font-size:14px;font-weight:300">Conhecimento que conecta. Formação que transforma.</p>
</td></tr>
<tr><td style="padding:40px 30px">
<p style="margin:0 0 20px 0;font-size:16px;color:#333333;font-weight:600">${icon} ${label}</p>
<table width="100%" cellpadding="0" cellspacing="0" style="background-color:#f9f9f9;border-left:4px solid #00493a;margin-bottom:24px">
<tr><td style="padding:20px;font-size:15px;color:#333333">
<p style="margin:0 0 12px 0;font-weight:700;color:#00493a;font-size:14px;text-transform:uppercase;letter-spacing:0.5px">${label}</p>
<p style="margin:0 0 16px 0;font-weight:600;font-size:16px;color:#333333">${title}</p>
<p style="margin:0;font-size:14px;color:#666666">${description}</p>
${date ? `<p style="margin:12px 0 0 0;font-size:14px;color:#666666">Data: <strong>${date}</strong></p>` : ""}
</td></tr>
</table>
<table width="100%" cellpadding="0" cellspacing="0" style="margin:32px 0">
<tr><td align="center">
<a href="${url}" style="display:inline-block;background-color:#00493a;color:#ffffff;padding:14px 32px;text-decoration:none;border-radius:6px;font-size:15px;font-weight:600">Ver ${label}</a>
</td></tr>
</table>
</td></tr>
<tr><td style="background-color:#f9f9f9;padding:24px 30px;border-top:1px solid #e0e0e0;text-align:center">
<p style="margin:0 0 12px 0;font-size:13px;color:#999999"><strong style="color:#333333">Conheça Farmácia</strong></p>
<p style="margin:0 0 16px 0;font-size:12px;color:#999999">Conhecimento que conecta. Formação que transforma.</p>
<p style="margin:16px 0 0 0;font-size:11px;color:#bbb">© 2026 Conheça Farmácia. Todos os direitos reservados.</p>
</td></tr>
</table>
</td></tr>
</table>
</body></html>`;
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const {
      type,
      email,
      nome,
      contentTitle,
      contentUrl,
      contentDescription,
      contentDate,
    }: EmailRequest = await req.json();

    if (!email || !type) {
      return new Response(
        JSON.stringify({ error: "Email and type are required" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Validar formato de email (SEC-SQL-04)
    const emailRegex =
      /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/;
    if (!emailRegex.test(email) || email.length > 254) {
      return new Response(
        JSON.stringify({ error: "Invalid email format" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Validar tipo de email
    const validTypes = ["welcome", "article", "event", "live"];
    if (!validTypes.includes(type)) {
      return new Response(
        JSON.stringify({ error: "Invalid email type" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    let htmlContent: string;
    let subject: string;

    if (type === "welcome") {
      htmlContent = getWelcomeTemplate(nome || "Subscritor");
      subject = "Bem-vindo à Newsletter - Conheça Farmácia";
    } else {
      htmlContent = getAlertTemplate(
        type,
        contentTitle || "Novo conteúdo",
        contentDescription || "",
        contentUrl || "https://conhecafarmacia.com",
        contentDate
      );
      const labels: Record<string, string> = {
        article: "Novo Artigo",
        event: "Novo Evento",
        live: "Nova Live",
      };
      subject = `${labels[type] || "Novo Conteúdo"} - Conheça Farmácia`;
    }

    const resendResponse = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${RESEND_API_KEY}`,
      },
      body: JSON.stringify({
        from: "Conheça Farmácia <onboarding@resend.dev>",
        to: email,
        subject,
        html: htmlContent,
        reply_to: "conhecerfarmacia@gmail.com",
      }),
    });

    if (!resendResponse.ok) {
      const error = await resendResponse.text();
      return new Response(
        JSON.stringify({ error: "Failed to send email", details: error }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const result = await resendResponse.json();

    return new Response(
      JSON.stringify({ success: true, id: result.id }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({
        error: "Internal server error",
        details: (error as Error).message,
      }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
