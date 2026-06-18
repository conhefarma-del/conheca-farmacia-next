import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SITE_URL = "https://conhecafarmacia.com";

type Lang = 'pt' | 'en';
function isLang(x: unknown): x is Lang { return x === 'pt' || x === 'en' }

function getInscriptionEmailTemplate(
  nomeParticipante: string,
  nomeEvento: string,
  dataInscricao: string,
  eventoSlug: string,
  unsubscribeUrl: string
): string {
  const dataObj = new Date(dataInscricao);
  const dataFormatada = dataObj.toLocaleDateString("pt-PT", {
    year: "numeric",
    month: "long",
    day: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });

  const eventoUrl = `${SITE_URL}/pt/eventos/${eventoSlug}`;

  return `<!DOCTYPE html>
<html lang="pt-PT">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Confirmação de Inscrição - Conheça Farmácia</title>
</head>
<body style="margin: 0; padding: 0; font-family: 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; background-color: #f5f5f5;">

<table width="100%" cellpadding="0" cellspacing="0" style="background-color: #f5f5f5;">
    <tr>
        <td align="center" style="padding: 40px 20px;">
            <table width="600" cellpadding="0" cellspacing="0" style="background-color: #ffffff; border-radius: 8px; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1); overflow: hidden;">
                <tr>
                    <td style="background: linear-gradient(135deg, #00493a 0%, #0a844f 100%); padding: 40px 20px; text-align: center;">
                        <h1 style="margin: 0; color: #ffffff; font-size: 28px; font-weight: 700; letter-spacing: -0.5px;">Conheça Farmácia</h1>
                        <p style="margin: 8px 0 0 0; color: rgba(255, 255, 255, 0.9); font-size: 14px; font-weight: 300;">Excelência no Cuidado Farmacêutico</p>
                    </td>
                </tr>
                <tr>
                    <td style="padding: 40px 30px;">
                        <p style="margin: 0 0 20px 0; font-size: 16px; color: #333333; font-weight: 600;">Olá <strong>${nomeParticipante}</strong>,</p>
                        <p style="margin: 0 0 24px 0; font-size: 15px; color: #555555; line-height: 1.6;">Recebemos a sua candidatura com sucesso!</p>
                        <p style="margin: 0 0 24px 0; font-size: 15px; color: #555555; line-height: 1.6;">Confirma-se o seu registo para o evento:</p>
                        <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #f9f9f9; border-left: 4px solid #00493a; margin-bottom: 24px;">
                            <tr>
                                <td style="padding: 20px; font-size: 15px; color: #333333;">
                                    <p style="margin: 0 0 12px 0; font-weight: 700; color: #00493a; font-size: 14px; text-transform: uppercase; letter-spacing: 0.5px;">Evento</p>
                                    <p style="margin: 0 0 16px 0; font-weight: 600; font-size: 16px; color: #333333;">${nomeEvento}</p>
                                    <p style="margin: 0; font-size: 14px; color: #666666;">Data de Inscrição: <strong>${dataFormatada}</strong></p>
                                </td>
                            </tr>
                        </table>
                        <p style="margin: 0 0 24px 0; font-size: 15px; color: #555555; line-height: 1.6;">A sua participação é fundamental para o fortalecimento do papel clínico do farmacêutico. Estamos entusiasmados em tê-lo connosco.</p>
                        <h3 style="margin: 32px 0 16px 0; font-size: 16px; color: #00493a; font-weight: 700;">Próximos Passos</h3>
                        <table width="100%" cellpadding="0" cellspacing="0" style="margin-bottom: 24px;">
                            <tr>
                                <td style="vertical-align: top; padding: 12px 0; font-size: 14px;">
                                    <span style="display: inline-block; width: 24px; height: 24px; background-color: #0a844f; color: white; border-radius: 50%; text-align: center; line-height: 24px; font-weight: bold; margin-right: 12px; font-size: 13px;">1</span>
                                </td>
                                <td style="vertical-align: top; font-size: 14px; color: #555555; padding: 12px 0;">
                                    <strong style="color: #333333;">Fique atento ao seu e-mail</strong> para receber o link de acesso ou detalhes do local do evento.
                                </td>
                            </tr>
                            <tr>
                                <td style="vertical-align: top; padding: 12px 0; font-size: 14px;">
                                    <span style="display: inline-block; width: 24px; height: 24px; background-color: #0a844f; color: white; border-radius: 50%; text-align: center; line-height: 24px; font-weight: bold; margin-right: 12px; font-size: 13px;">2</span>
                                </td>
                                <td style="vertical-align: top; font-size: 14px; color: #555555; padding: 12px 0;">
                                    <strong style="color: #333333;">Confirme sua presença</strong> caso seja necessário mediante o link que enviaremos.
                                </td>
                            </tr>
                            <tr>
                                <td style="vertical-align: top; padding: 12px 0; font-size: 14px;">
                                    <span style="display: inline-block; width: 24px; height: 24px; background-color: #0a844f; color: white; border-radius: 50%; text-align: center; line-height: 24px; font-weight: bold; margin-right: 12px; font-size: 13px;">3</span>
                                </td>
                                <td style="vertical-align: top; font-size: 14px; color: #555555; padding: 12px 0;">
                                    <strong style="color: #333333;">Partilhe com colegas</strong> interessados em desenvolver-se profissionalmente.
                                </td>
                            </tr>
                        </table>
                        <table width="100%" cellpadding="0" cellspacing="0" style="margin: 32px 0;">
                            <tr>
                                <td align="center">
                                    <a href="${eventoUrl}" style="display: inline-block; background-color: #00493a; color: #ffffff; padding: 14px 32px; text-decoration: none; border-radius: 6px; font-size: 15px; font-weight: 600;">Ver Evento</a>
                                </td>
                            </tr>
                        </table>
                        <p style="margin: 32px 0 0 0; font-size: 14px; color: #666666; line-height: 1.6; border-top: 1px solid #e0e0e0; padding-top: 24px;">
                            Se tiver dúvidas ou precisar de ajuda, entre em contacto connosco através de
                            <a href="mailto:contato@conhecafarmacia.com" style="color: #00493a; text-decoration: none; font-weight: 600;">contato@conhecafarmacia.com</a>
                            ou
                            <a href="https://wa.me/244925696002" style="color: #00493a; text-decoration: none; font-weight: 600;">+244 925 696 002</a>.
                        </p>
                    </td>
                </tr>
                <tr>
                    <td style="background-color: #f9f9f9; padding: 24px 30px; border-top: 1px solid #e0e0e0; text-align: center;">
                        <p style="margin: 0 0 12px 0; font-size: 13px; color: #999999;"><strong style="color: #333333;">Conheça Farmácia</strong></p>
                        <p style="margin: 0 0 16px 0; font-size: 12px; color: #999999;">Conhecimento que conecta. Formação que transforma. Saúde que evolui.</p>
                        <table width="100%" cellpadding="0" cellspacing="0">
                            <tr>
                                <td align="center" style="font-size: 12px;">
                                    <a href="https://www.facebook.com/conhecafarmacia" style="color: #0a844f; text-decoration: none; margin: 0 12px;">Facebook</a>
                                    <span style="color: #ddd;">•</span>
                                    <a href="https://www.instagram.com/conhecafarmacia" style="color: #0a844f; text-decoration: none; margin: 0 12px;">Instagram</a>
                                    <span style="color: #ddd;">•</span>
                                    <a href="https://www.linkedin.com/company/conhecafarmacia" style="color: #0a844f; text-decoration: none; margin: 0 12px;">LinkedIn</a>
                                </td>
                            </tr>
                        </table>
                        <p style="margin: 16px 0 0 0; font-size: 11px; color: #bbb;">
                            <a href="${unsubscribeUrl}" style="color: #999; text-decoration: underline;">Cancelar subscrição da newsletter</a>
                        </p>
                        <p style="margin: 8px 0 0 0; font-size: 11px; color: #bbb;">© 2026 Conheça Farmácia. Todos os direitos reservados.</p>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>
</body>
</html>`;
}

function getInscriptionEmailTemplateEN(
  nomeParticipante: string,
  nomeEvento: string,
  dataInscricao: string,
  eventoSlug: string,
  unsubscribeUrl: string,
): string {
  const dataObj = new Date(dataInscricao);
  const dataFormatada = dataObj.toLocaleDateString("en-GB", {
    year: "numeric",
    month: "long",
    day: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
  const eventoUrl = `${SITE_URL}/en/events/${eventoSlug}`;
  return `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registration Confirmation - Conheça Farmácia</title>
</head>
<body style="margin: 0; padding: 0; font-family: 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; background-color: #f5f5f5;">
<table width="100%" cellpadding="0" cellspacing="0" style="background-color: #f5f5f5;">
    <tr>
        <td align="center" style="padding: 40px 20px;">
            <table width="600" cellpadding="0" cellspacing="0" style="background-color: #ffffff; border-radius: 8px; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1); overflow: hidden;">
                <tr>
                    <td style="background: linear-gradient(135deg, #00493a 0%, #0a844f 100%); padding: 40px 20px; text-align: center;">
                        <h1 style="margin: 0; color: #ffffff; font-size: 28px; font-weight: 700; letter-spacing: -0.5px;">Conheça Farmácia</h1>
                        <p style="margin: 8px 0 0 0; color: rgba(255, 255, 255, 0.9); font-size: 14px; font-weight: 300;">Excellence in Pharmaceutical Care</p>
                    </td>
                </tr>
                <tr>
                    <td style="padding: 40px 30px;">
                        <h2 style="margin: 0 0 20px 0; color: #00493a; font-size: 22px;">Hello, ${escapeHtml(nomeParticipante)}!</h2>
                        <p style="margin: 0 0 16px 0; color: #333; font-size: 16px; line-height: 1.6;">
                            We've received your registration for <strong>${escapeHtml(nomeEvento)}</strong>.
                        </p>
                        <p style="margin: 0 0 16px 0; color: #333; font-size: 16px; line-height: 1.6;">
                            <strong>Registration date:</strong> ${dataFormatada}
                        </p>
                        <p style="margin: 0 0 24px 0; color: #333; font-size: 16px; line-height: 1.6;">
                            Check your email and the event page for further details. See you there!
                        </p>
                        <table width="100%" cellpadding="0" cellspacing="0" style="margin: 24px 0;">
                            <tr>
                                <td align="center">
                                    <a href="${eventoUrl}" style="display: inline-block; padding: 14px 32px; background: linear-gradient(135deg, #00493a 0%, #0a844f 100%); color: #ffffff; text-decoration: none; border-radius: 6px; font-weight: 600; font-size: 16px;">View Event</a>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td style="background-color: #f8f8f8; padding: 20px 30px; text-align: center; color: #888; font-size: 12px; line-height: 1.5;">
                        <p style="margin: 0 0 8px 0;">You're receiving this email because you registered for an event at Conheça Farmácia.</p>
                        <p style="margin: 0;"><a href="${unsubscribeUrl}" style="color: #00493a; text-decoration: underline;">Unsubscribe</a></p>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>
</body>
</html>`;
}

function escapeHtml(s: string): string {
  if (!s) return '';
  return String(s)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

const ALLOWED_ORIGINS = [
  "https://conheca-farmacia-next.vercel.app",
  "https://conhecafarmacia.com",
  "http://localhost:3000",
];

function getCorsHeaders(requestOrigin: string | null): Record<string, string> {
  const origin = ALLOWED_ORIGINS.includes(requestOrigin || "")
    ? requestOrigin!
    : ALLOWED_ORIGINS[0];
  return {
    "Access-Control-Allow-Origin": origin,
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
  };
}

serve(async (req: Request) => {
  const corsHeaders = getCorsHeaders(req.headers.get("origin"));

  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { "Content-Type": "application/json", ...corsHeaders },
    });
  }

  try {
    const { email, nome, evento_slug, lang: rawLang } = await req.json();
    const lang: Lang = isLang(rawLang) ? rawLang : 'pt';

    if (!email || !nome || !evento_slug) {
      return new Response(
        JSON.stringify({ error: "Campos obrigatórios: email, nome, evento_slug" }),
        { status: 400, headers: { "Content-Type": "application/json", ...corsHeaders } }
      );
    }

    // Validação de input
    const EMAIL_REGEX = /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/;
    const SLUG_REGEX = /^[a-zA-Z0-9\-_]+$/;

    if (typeof nome !== "string" || nome.length < 3 || nome.length > 255) {
      return new Response(JSON.stringify({ error: "Nome inválido" }), { status: 400, headers: { "Content-Type": "application/json", ...corsHeaders } });
    }
    if (typeof email !== "string" || !EMAIL_REGEX.test(email) || email.length > 254) {
      return new Response(JSON.stringify({ error: "Email inválido" }), { status: 400, headers: { "Content-Type": "application/json", ...corsHeaders } });
    }
    if (typeof evento_slug !== "string" || !SLUG_REGEX.test(evento_slug)) {
      return new Response(JSON.stringify({ error: "Slug inválido" }), { status: 400, headers: { "Content-Type": "application/json", ...corsHeaders } });
    }

    // Look up event name from BD
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    const { data: event } = await supabase
      .from("events")
      .select("title")
      .eq("slug", evento_slug)
      .single();

    const nomeEvento = event?.title || evento_slug;

    // Look up subscriber unsubscribe token
    const { data: subscriber } = await supabase
      .from("newsletter")
      .select("unsubscribe_token")
      .eq("email", email.toLowerCase().trim())
      .eq("status", "active")
      .single();

    const unsubscribeUrl = subscriber?.unsubscribe_token
      ? `${SITE_URL}/${lang}/unsubscribe?token=${subscriber.unsubscribe_token}`
      : `${SITE_URL}/${lang}/unsubscribe`;

    // Template bilingue: PT (default) / EN conforme `lang` recebido no body.
    const htmlContent = lang === 'en'
      ? getInscriptionEmailTemplateEN(
          nome,
          nomeEvento,
          new Date().toISOString(),
          evento_slug,
          unsubscribeUrl,
        )
      : getInscriptionEmailTemplate(
          nome,
          nomeEvento,
          new Date().toISOString(),
          evento_slug,
          unsubscribeUrl,
        );

    // Subject com acentos: Brevo trata UTF-8 nos headers sem os codificar
    // como "=?utf-8?Q?..." (ao contrário do antigo stack denomailer/Amazon
    // SES, que produzia headers raw visíveis em Zoho). Helper envia subject
    // tal-qual em JSON; o gateway SMTP da Brevo aplica o encoding MIME
    // (RFC 2047) correctamente.
    const subject = lang === 'en'
      ? 'Registration Confirmation - Conheça Farmácia'
      : 'Confirmação de Inscrição - Conheça Farmácia';

    // Cabeçalhos antispam (RFC 8058) — Brevo propaga-os no payload JSON
    // e o gateway SMTP da Brevo adiciona-os ao header MIME final.
    const listUnsubscribeMailto = `mailto:contato@conhecafarmacia.com?subject=unsubscribe&body=Por%20favor%2C%20remova-me%20da%20lista.`;
    const listUnsubscribeHeaders: Record<string, string> = {
      "List-Unsubscribe": `<${listUnsubscribeMailto}>, <${unsubscribeUrl}>`,
      "List-Unsubscribe-Post": "List-Unsubscribe=One-Click",
    };

    // Envio via Brevo API v3 (helper partilhado em _shared/brevo.ts).
    // Erros propagam com `code` semântico mapeado para i18n no client.
    const { sendViaBrevo } = await import("../_shared/brevo.ts");
    await sendViaBrevo({
      to: { email, name: nome },
      sender: "inscricao@conhecafarmacia.com",
      subject,
      htmlContent,
      replyTo: "contato@conhecafarmacia.com",
      headers: listUnsubscribeHeaders,
      tags: ["inscription", lang],
    });

    return new Response(
      JSON.stringify({ success: true }),
      { status: 200, headers: { "Content-Type": "application/json", ...corsHeaders } }
    );
  } catch (error) {
    const e = error as Error;
    console.error("send-inscription-email error:", e.message, e.stack);
    return new Response(
      JSON.stringify({ error: "Erro interno do servidor", debug: e.message }),
      { status: 500, headers: { "Content-Type": "application/json", ...corsHeaders } }
    );
  }
});
