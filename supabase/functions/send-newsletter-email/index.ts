import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

// CORS — origem dinâmica (whitelist)
const ALLOWED_ORIGINS = [
  "https://conheca-farmacia-next.vercel.app",
  "https://conhecafarmacia.com",
  "https://www.conhecafarmacia.com",
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

// SEC (vistoria o-sentinela 2026-08-11): segredo partilhado com o servidor
// Next.js. As Server Actions (lib/actions/newsletter.js) enviam este header;
// quem não o tiver (ex.: atacante com a anon key do bundle) recebe 401.
const INTERNAL_KEY = Deno.env.get("EDGE_INTERNAL_KEY");

// Defesa em profundidade — mesmo que o segredo vaze, limita o dano:
// máx. 3 emails/hora por destinatário (in-memory, por worker).
const RECIPIENT_RATE_MAX = 3;
const RECIPIENT_RATE_WINDOW_MS = 3600_000;
const recipientRate = new Map<string, { count: number; resetAt: number }>();

function checkRecipientRate(email: string): boolean {
  const now = Date.now();
  const entry = recipientRate.get(email);
  if (!entry || entry.resetAt < now) {
    recipientRate.set(email, { count: 1, resetAt: now + RECIPIENT_RATE_WINDOW_MS });
    return true;
  }
  if (entry.count >= RECIPIENT_RATE_MAX) return false;
  entry.count += 1;
  return true;
}

interface EmailRequest {
  type: "welcome" | "welcome-account" | "article" | "event" | "live";
  email: string;
  nome?: string;
  contentTitle?: string;
  contentUrl?: string;
  contentDescription?: string;
  contentDate?: string;
  contentPlatform?: string;
  contentLocation?: string;
  unsubscribeToken?: string;
}

// Logo URLs — usar URLs externas (base64 é bloqueado por Gmail/Outlook)
const LOGO_LIGHT = "https://conhecafarmacia.com/logo/3.png";
const LOGO_DARK = "https://conhecafarmacia.com/logo/3_2.png";

/**
 * Welcome — Minimalista premium
 * Fundo branco, tipografia refinada, espaço negativo generoso
 */
function getWelcomeTemplate(nome: string, unsubUrl?: string): string {
  const unsubBlock = unsubUrl
    ? `<p style="margin:0 0 16px 0;font-size:12px;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif"><a href="${unsubUrl}" style="color:#999999;text-decoration:underline">Cancelar subscrição</a></p>`
    : "";

  return `<!doctype html>
<html lang="pt-PT">
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"></head>
<body style="margin:0;padding:0;background-color:#fafafa;">
<table width="100%" cellpadding="0" cellspacing="0" style="background-color:#fafafa">
<tr><td align="center" style="padding:48px 20px">
<table width="600" cellpadding="0" cellspacing="0" style="background-color:#ffffff;border-radius:2px;overflow:hidden;border:1px solid #e8e8e8">

<tr><td style="padding:48px 40px 40px 40px;text-align:center;border-bottom:1px solid #f0f0f0">
<img src="${LOGO_LIGHT}" alt="Conheça Farmácia" style="height:52px;margin-bottom:24px;display:block;margin-left:auto;margin-right:auto">
<p style="margin:0;font-size:11px;color:#0a844f;text-transform:uppercase;letter-spacing:3px;font-weight:600;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">Bem-vindo</p>
</td></tr>

<tr><td style="padding:48px 40px">
<p style="margin:0 0 32px 0;font-size:22px;color:#1a1a1a;line-height:1.3;font-weight:300;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif;letter-spacing:-0.3px">
Olá, <strong style="font-weight:700;color:#00493a">${nome}</strong>
</p>
<p style="margin:0 0 28px 0;font-size:15px;color:#555555;line-height:1.75;font-weight:400;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">
Bem-vindo à comunidade Conheça Farmácia. A partir de agora, receberá diretamente na sua caixa de entrada conteúdo cuidadosamente selecionado para profissionais de saúde.
</p>
<p style="margin:0 0 40px 0;font-size:15px;color:#555555;line-height:1.75;font-weight:400;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">
Obrigado por fazer parte de uma comunidade dedicada à excelência no cuidado farmacêutico.
</p>

<table width="100%" cellpadding="0" cellspacing="0"><tr><td style="padding:0 0 40px 0">
<table width="60" cellpadding="0" cellspacing="0" align="center"><tr><td style="height:1px;background-color:#0a844f;font-size:1px;line-height:1px">&nbsp;</td></tr></table>
</td></tr></table>

<p style="margin:0 0 24px 0;font-size:11px;color:#0a844f;text-transform:uppercase;letter-spacing:2.5px;font-weight:600;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">O que esperar</p>

<table width="100%" cellpadding="0" cellspacing="0">
<tr><td style="padding:0 0 20px 0"><table width="100%" cellpadding="0" cellspacing="0"><tr>
<td width="40" valign="top" style="padding-top:2px"><div style="width:32px;height:32px;background-color:#f0f7f4;border-radius:50%;text-align:center;line-height:32px;font-size:14px;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">A</div></td>
<td valign="top" style="padding-left:12px"><p style="margin:0 0 4px 0;font-size:14px;color:#1a1a1a;font-weight:600;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">Artigos Científicos</p><p style="margin:0;font-size:13px;color:#888888;line-height:1.5;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">Práticas farmacêuticas atualizadas e baseadas em evidência</p></td>
</tr></table></td></tr>
<tr><td style="padding:0 0 20px 0"><table width="100%" cellpadding="0" cellspacing="0"><tr>
<td width="40" valign="top" style="padding-top:2px"><div style="width:32px;height:32px;background-color:#f0f7f4;border-radius:50%;text-align:center;line-height:32px;font-size:14px;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">E</div></td>
<td valign="top" style="padding-left:12px"><p style="margin:0 0 4px 0;font-size:14px;color:#1a1a1a;font-weight:600;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">Eventos & Formações</p><p style="margin:0;font-size:13px;color:#888888;line-height:1.5;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">Oportunidades de desenvolvimento profissional contínuo</p></td>
</tr></table></td></tr>
<tr><td style="padding:0"><table width="100%" cellpadding="0" cellspacing="0"><tr>
<td width="40" valign="top" style="padding-top:2px"><div style="width:32px;height:32px;background-color:#f0f7f4;border-radius:50%;text-align:center;line-height:32px;font-size:14px;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">L</div></td>
<td valign="top" style="padding-left:12px"><p style="margin:0 0 4px 0;font-size:14px;color:#1a1a1a;font-weight:600;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">Lives com Especialistas</p><p style="margin:0;font-size:13px;color:#888888;line-height:1.5;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">Sessões ao vivo com profissionais de referência do setor</p></td>
</tr></table></td></tr>
</table>

<table width="100%" cellpadding="0" cellspacing="0" style="margin-top:40px"><tr><td align="center">
<a href="https://conhecafarmacia.com" style="display:inline-block;background:linear-gradient(135deg,#00493a 0%,#0a844f 100%);color:#ffffff;padding:16px 40px;text-decoration:none;border-radius:8px;font-size:14px;font-weight:600;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif;letter-spacing:0.3px">Explorar Conteúdo</a>
</td></tr></table>
</td></tr>

<tr><td style="padding:32px 40px;border-top:1px solid #f0f0f0;text-align:center">
<p style="margin:0 0 8px 0;font-size:12px;color:#999999;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">Conheça Farmácia &mdash; Conhecimento que conecta.</p>
<p style="margin:0 0 20px 0;font-size:12px;color:#bbbbbb;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">
<a href="https://www.facebook.com/conhecafarmacia" style="color:#0a844f;text-decoration:none;margin:0 10px">Facebook</a>
<span style="color:#e0e0e0">&bull;</span>
<a href="https://www.instagram.com/conhecafarmacia" style="color:#0a844f;text-decoration:none;margin:0 10px">Instagram</a>
<span style="color:#e0e0e0">&bull;</span>
<a href="https://www.linkedin.com/company/conhecafarmacia" style="color:#0a844f;text-decoration:none;margin:0 10px">LinkedIn</a>
</p>
${unsubBlock}
<p style="margin:0;font-size:11px;color:#cccccc;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">&copy; 2026 Conheça Farmácia. Todos os direitos reservados.</p>
</td></tr>

</table>
</td></tr>
</table>
</body></html>`;
}

/**
 * Welcome Account — Boas-vindas ao criar conta no website
 * Lista de ferramentas com ícones Lucide SVG inline
 */
function getWelcomeAccountTemplate(nome: string): string {
  return `<!doctype html>
<html lang="pt-PT">
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"></head>
<body style="margin:0;padding:0;background-color:#fafafa;">
<table width="100%" cellpadding="0" cellspacing="0" style="background-color:#fafafa">
<tr><td align="center" style="padding:48px 20px">
<table width="600" cellpadding="0" cellspacing="0" style="background-color:#ffffff;border-radius:2px;overflow:hidden;border:1px solid #e8e8e8">

<tr><td style="padding:48px 40px 40px 40px;text-align:center;border-bottom:1px solid #f0f0f0">
<img src="${LOGO_LIGHT}" alt="Conheça Farmácia" width="180" style="display:block;margin:0 auto 20px;height:auto" />
<h1 style="margin:0 0 8px 0;font-size:28px;color:#1a1a1a;font-weight:700;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif;letter-spacing:-0.5px">
Bem-vindo, ${nome}!
</h1>
<p style="margin:0;font-size:15px;color:#888888;line-height:1.6;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">
A tua conta foi criada com sucesso.<br/>
Guarda, anota e estuda farmacologia num só sítio.
</p>
</td></tr>

<tr><td style="padding:32px 40px">
<p style="margin:0 0 16px 0;font-size:11px;color:#0a844f;text-transform:uppercase;letter-spacing:2.5px;font-weight:600;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">Novo na tua conta</p>
<table width="100%" cellpadding="0" cellspacing="0">
<tr><td style="padding:0 0 16px 0"><table width="100%" cellpadding="0" cellspacing="0" style="background-color:#f0f7f4;border-radius:8px;overflow:hidden"><tr><td width="48" valign="middle" style="padding:20px 0 20px 20px"><div style="width:36px;height:36px;background-color:#ffffff;border-radius:8px;text-align:center;line-height:36px"><svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#00493a" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:middle"><path d="m19 21-7-4-7 4V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2v16z"/></svg></div></td><td valign="middle" style="padding:20px 20px 20px 16px"><p style="margin:0 0 4px 0;font-size:15px;color:#1a1a1a;font-weight:600;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">Guardados</p><p style="margin:0;font-size:13px;color:#555555;line-height:1.5;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">Guarda medicamentos, artigos, alvos e interações para consultar depois. Acedes de qualquer dispositivo.</p></td></tr></table></td></tr>
<tr><td style="padding:0 0 16px 0"><table width="100%" cellpadding="0" cellspacing="0" style="background-color:#f0f7f4;border-radius:8px;overflow:hidden"><tr><td width="48" valign="middle" style="padding:20px 0 20px 20px"><div style="width:36px;height:36px;background-color:#ffffff;border-radius:8px;text-align:center;line-height:36px"><svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#00493a" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:middle"><path d="M17 3a2.85 2.83 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5Z"/></svg></div></td><td valign="middle" style="padding:20px 20px 20px 16px"><p style="margin:0 0 4px 0;font-size:15px;color:#1a1a1a;font-weight:600;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">Anotações</p><p style="margin:0;font-size:13px;color:#555555;line-height:1.5;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">Cria notas em qualquer página — medicamentos, alvos, artigos, interações. Uma nota contínua por item, sempre guardada.</p></td></tr></table></td></tr>
<tr><td><table width="100%" cellpadding="0" cellspacing="0" style="background-color:#f0f7f4;border-radius:8px;overflow:hidden"><tr><td width="48" valign="middle" style="padding:20px 0 20px 20px"><div style="width:36px;height:36px;background-color:#ffffff;border-radius:8px;text-align:center;line-height:36px"><svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#00493a" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:middle"><path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg></div></td><td valign="middle" style="padding:20px 20px 20px 16px"><p style="margin:0 0 4px 0;font-size:15px;color:#1a1a1a;font-weight:600;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">Perfil &amp; Progresso</p><p style="margin:0;font-size:13px;color:#555555;line-height:1.5;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">Acompanha o teu historico de quiz, guardados e anotações no teu perfil pessoal.</p></td></tr></table></td></tr>
</table>
</td></tr>

<tr><td style="padding:0 40px 32px 40px">
<p style="margin:0 0 24px 0;font-size:11px;color:#0a844f;text-transform:uppercase;letter-spacing:2.5px;font-weight:600;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">Ferramentas para explorar</p>
<table width="100%" cellpadding="0" cellspacing="0">
<tr><td style="padding:0 0 20px 0"><table width="100%" cellpadding="0" cellspacing="0"><tr><td width="40" valign="top" style="padding-top:2px"><div style="width:32px;height:32px;background-color:#e8f5f0;border-radius:50%;text-align:center;line-height:32px"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#00493a" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:middle"><path d="M20 13c0 5-3.5 7.5-7.66 8.95a1 1 0 0 1-.67-.01C7.5 20.5 4 18 4 13V6a1 1 0 0 1 1-1c2 0 4.5-1.2 6.24-2.72a1.17 1.17 0 0 1 1.52 0C14.51 3.81 17 5 19 5a1 1 0 0 1 1 1z"/><path d="M12 8v4"/><path d="M12 16h.01"/></svg></div></td><td valign="top" style="padding-left:12px"><p style="margin:0 0 4px 0;font-size:14px;color:#1a1a1a;font-weight:600;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">Interações Medicamentosas</p><p style="margin:0;font-size:13px;color:#888888;line-height:1.5;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">Verifica interações entre 300+ fármacos com gravidade, mecanismo e conduta</p></td></tr></table></td></tr>
<tr><td style="padding:0 0 20px 0"><table width="100%" cellpadding="0" cellspacing="0"><tr><td width="40" valign="top" style="padding-top:2px"><div style="width:32px;height:32px;background-color:#e8f5f0;border-radius:50%;text-align:center;line-height:32px"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#00493a" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:middle"><path d="m10.5 20.5 10-10a4.95 4.95 0 1 0-7-7l-10 10a4.95 4.95 0 1 0 7 7Z"/><path d="m8.5 8.5 7 7"/></svg></div></td><td valign="top" style="padding-left:12px"><p style="margin:0 0 4px 0;font-size:14px;color:#1a1a1a;font-weight:600;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">Medicamentos</p><p style="margin:0;font-size:13px;color:#888888;line-height:1.5;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">Fichas completas com farmacologia, interações, gravidez e fontes DailyMed/EMC</p></td></tr></table></td></tr>
<tr><td style="padding:0 0 20px 0"><table width="100%" cellpadding="0" cellspacing="0"><tr><td width="40" valign="top" style="padding-top:2px"><div style="width:32px;height:32px;background-color:#e8f5f0;border-radius:50%;text-align:center;line-height:32px"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#00493a" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:middle"><path d="M12 16a4 4 0 1 0 0-8 4 4 0 0 0 0 8Z"/><path d="M12 8V4"/><path d="M8 12H4"/><path d="M16 12h4"/><path d="M12 16v4"/><path d="M9.5 4.5 8 3"/><path d="M14.5 4.5 16 3"/><path d="M9.5 19.5 8 21"/><path d="M14.5 19.5 16 21"/></svg></div></td><td valign="top" style="padding-left:12px"><p style="margin:0 0 4px 0;font-size:14px;color:#1a1a1a;font-weight:600;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">Quiz</p><p style="margin:0;font-size:13px;color:#888888;line-height:1.5;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">Testa os teus conhecimentos com perguntas de farmacologia, interações e protocolos</p></td></tr></table></td></tr>
<tr><td style="padding:0 0 20px 0"><table width="100%" cellpadding="0" cellspacing="0"><tr><td width="40" valign="top" style="padding-top:2px"><div style="width:32px;height:32px;background-color:#e8f5f0;border-radius:50%;text-align:center;line-height:32px"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#00493a" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:middle"><path d="m12.83 2.18a2 2 0 0 0-1.66 0L2.6 6.08a1 1 0 0 0 0 1.83l8.58 3.91a2 2 0 0 0 1.66 0l8.58-3.9a1 1 0 0 0 0-1.83Z"/><path d="m22 17.65-9.17 4.16a2 2 0 0 1-1.66 0L2 17.65"/><path d="m22 12.65-9.17 4.16a2 2 0 0 1-1.66 0L2 12.65"/></svg></div></td><td valign="top" style="padding-left:12px"><p style="margin:0 0 4px 0;font-size:14px;color:#1a1a1a;font-weight:600;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">Flashcards</p><p style="margin:0;font-size:13px;color:#888888;line-height:1.5;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">Revisão espaçada inteligente com repetição por algoritmo SM-2</p></td></tr></table></td></tr>
<tr><td style="padding:0 0 20px 0"><table width="100%" cellpadding="0" cellspacing="0"><tr><td width="40" valign="top" style="padding-top:2px"><div style="width:32px;height:32px;background-color:#e8f5f0;border-radius:50%;text-align:center;line-height:32px"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#00493a" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:middle"><rect width="8" height="4" x="8" y="2" rx="1" ry="1"/><path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"/><path d="M12 11h4"/><path d="M12 16h4"/><path d="M8 11h.01"/><path d="M8 16h.01"/></svg></div></td><td valign="top" style="padding-left:12px"><p style="margin:0 0 4px 0;font-size:14px;color:#1a1a1a;font-weight:600;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">Classes Terapêuticas</p><p style="margin:0;font-size:13px;color:#888888;line-height:1.5;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">Explora classes de fármacos com descrições detalhadas e códigos ATC</p></td></tr></table></td></tr>
<tr><td style="padding:0"><table width="100%" cellpadding="0" cellspacing="0"><tr><td width="40" valign="top" style="padding-top:2px"><div style="width:32px;height:32px;background-color:#e8f5f0;border-radius:50%;text-align:center;line-height:32px"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#00493a" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:middle"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/></svg></div></td><td valign="top" style="padding-left:12px"><p style="margin:0 0 4px 0;font-size:14px;color:#1a1a1a;font-weight:600;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">Guias de Estudo</p><p style="margin:0;font-size:13px;color:#888888;line-height:1.5;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">Material de estudo organizado por temas farmacêuticos</p></td></tr></table></td></tr>
</table>
</td></tr>

<tr><td style="padding:0 40px 40px 40px">
<table width="100%" cellpadding="0" cellspacing="0">
<tr><td align="center"><a href="https://conhecafarmacia.com/pt/praticar" style="display:inline-block;background:linear-gradient(135deg,#00493a 0%,#0a844f 100%);color:#ffffff;padding:16px 40px;text-decoration:none;border-radius:8px;font-size:14px;font-weight:600;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif;letter-spacing:0.3px">Explorar Ferramentas</a></td></tr>
<tr><td align="center" style="padding-top:12px"><a href="https://conhecafarmacia.com/pt/guardados" style="display:inline-block;color:#0a844f;text-decoration:none;font-size:13px;font-weight:600;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">ou vai aos teus Guardados &rarr;</a></td></tr>
</table>
</td></tr>

<tr><td style="padding:32px 40px;border-top:1px solid #f0f0f0;text-align:center">
<p style="margin:0 0 8px 0;font-size:12px;color:#999999;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">Conheça Farmácia &mdash; Conhecimento que conecta.</p>
<p style="margin:0 0 20px 0;font-size:12px;color:#bbbbbb;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">
<a href="https://www.facebook.com/conhecafarmacia" style="color:#0a844f;text-decoration:none;margin:0 10px">Facebook</a>
<span style="color:#e0e0e0">&bull;</span>
<a href="https://www.instagram.com/conhecafarmacia" style="color:#0a844f;text-decoration:none;margin:0 10px">Instagram</a>
<span style="color:#e0e0e0">&bull;</span>
<a href="https://www.linkedin.com/company/conhecafarmacia" style="color:#0a844f;text-decoration:none;margin:0 10px">LinkedIn</a>
</p>
<p style="margin:0;font-size:11px;color:#cccccc;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">&copy; 2026 Conheça Farmácia. Todos os direitos reservados.</p>
<p style="margin:12px 0 0 0;font-size:11px;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif"><a href="https://conhecafarmacia.com/pt/unsubscribe" style="color:#999999;text-decoration:underline;">Gerir preferências de email</a></p>
</td></tr>

</table>
</td></tr>
</table>
</body></html>`;
}

/**
 * Article Alert — Editorial/Magazine
 * Tipografia marcante, layout de revista, fundo branco
 */
function getArticleTemplate(title: string, description: string, url: string, unsubUrl?: string): string {
  return `<!doctype html>
<html lang="pt-PT">
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"></head>
<body style="margin:0;padding:0;background-color:#ffffff;">
<table width="100%" cellpadding="0" cellspacing="0" style="background-color:#ffffff">
<tr><td align="center" style="padding:0">
<table width="600" cellpadding="0" cellspacing="0" style="overflow:hidden">

<tr><td style="padding:40px 40px 0 40px">
<table width="100%" cellpadding="0" cellspacing="0"><tr>
<td style="padding-bottom:24px;border-bottom:2px solid #1a1a1a;text-align:center">
<img src="${LOGO_LIGHT}" alt="Conheça Farmácia" style="height:52px;display:block;margin-left:auto;margin-right:auto">
</td>
</tr></table>
</td></tr>

<tr><td style="padding:32px 40px 0 40px">
<p style="margin:0;font-size:11px;color:#0a844f;text-transform:uppercase;letter-spacing:4px;font-weight:700;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">Novo Artigo</p>
</td></tr>

<tr><td style="padding:16px 40px 0 40px">
<p style="margin:0;font-size:28px;color:#1a1a1a;line-height:1.2;font-weight:300;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif;letter-spacing:-0.5px">${title}</p>
</td></tr>

<tr><td style="padding:24px 40px 0 40px">
<table width="40" cellpadding="0" cellspacing="0"><tr><td style="height:3px;background-color:#0a844f;font-size:1px;line-height:1px">&nbsp;</td></tr></table>
</td></tr>

<tr><td style="padding:24px 40px 0 40px">
<p style="margin:0;font-size:16px;color:#555555;line-height:1.8;font-weight:400;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">${description}</p>
</td></tr>

<tr><td style="padding:40px 40px 0 40px">
<table width="100%" cellpadding="0" cellspacing="0"><tr><td>
<a href="${url}" style="display:inline-block;background:linear-gradient(135deg,#00493a 0%,#0a844f 100%);color:#ffffff;padding:16px 36px;text-decoration:none;border-radius:8px;font-size:14px;font-weight:600;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif;letter-spacing:0.3px">Ler Artigo Completo</a>
</td></tr></table>
</td></tr>

<tr><td style="padding:40px 40px 0 40px">
<table width="100%" cellpadding="0" cellspacing="0" style="border-top:1px solid #f0f0f0"><tr><td style="padding-top:24px">
<p style="margin:0;font-size:13px;color:#999999;line-height:1.7;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif;font-style:italic">Mantenha-se atualizado com as melhores práticas farmacêuticas. Visite o nosso site para mais conteúdo.</p>
</td></tr></table>
</td></tr>

<tr><td style="padding:40px">
<table width="100%" cellpadding="0" cellspacing="0" style="border-top:1px solid #f0f0f0"><tr><td style="padding-top:24px;text-align:center">
<p style="margin:0 0 8px 0;font-size:12px;color:#999999;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">Conheça Farmácia &mdash; Conhecimento que conecta.</p>
<p style="margin:0 0 16px 0;font-size:12px;color:#bbbbbb;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">
<a href="https://www.facebook.com/conhecafarmacia" style="color:#0a844f;text-decoration:none;margin:0 10px">Facebook</a>
<span style="color:#e0e0e0">&bull;</span>
<a href="https://www.instagram.com/conhecafarmacia" style="color:#0a844f;text-decoration:none;margin:0 10px">Instagram</a>
<span style="color:#e0e0e0">&bull;</span>
<a href="https://www.linkedin.com/company/conhecafarmacia" style="color:#0a844f;text-decoration:none;margin:0 10px">LinkedIn</a>
</p>
${unsubUrl ? `<p style="margin:0 0 16px 0;font-size:12px;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif"><a href="${unsubUrl}" style="color:#999999;text-decoration:underline">Cancelar subscrição</a></p>` : ""}
<p style="margin:0;font-size:11px;color:#cccccc;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">&copy; 2026 Conheça Farmácia. Todos os direitos reservados.</p>
</td></tr></table>
</td></tr>

</table>
</td></tr>
</table>
</body></html>`;
}

/**
 * Event Alert — Dark Luxury
 * Fundo escuro verde marca, detalhes dourados, logo branco
 */
function getEventTemplate(title: string, description: string, url: string, date?: string, location?: string, unsubUrl?: string): string {
  return `<!doctype html>
<html lang="pt-PT">
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"></head>
<body style="margin:0;padding:0;background-color:#00493a;">
<table width="100%" cellpadding="0" cellspacing="0" style="background-color:#00493a">
<tr><td align="center" style="padding:48px 20px">
<table width="600" cellpadding="0" cellspacing="0" style="overflow:hidden;border-radius:2px">

<tr><td style="background-color:#003a2e;padding:48px 40px;text-align:center">
<img src="${LOGO_DARK}" alt="Conheça Farmácia" style="height:52px;margin-bottom:24px;display:block;margin-left:auto;margin-right:auto">
<table width="60" cellpadding="0" cellspacing="0" align="center"><tr><td style="height:1px;background-color:rgba(255,255,255,0.15);font-size:1px;line-height:1px">&nbsp;</td></tr></table>
</td></tr>

<tr><td style="background-color:#003a2e;padding:0 40px 48px 40px">
<p style="margin:0 0 12px 0;font-size:11px;color:#0a844f;text-transform:uppercase;letter-spacing:4px;font-weight:700;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">Novo Evento</p>
<p style="margin:0 0 28px 0;font-size:26px;color:#ffffff;line-height:1.25;font-weight:300;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif;letter-spacing:-0.3px">${title}</p>
<p style="margin:0 0 24px 0;font-size:15px;color:rgba(255,255,255,0.7);line-height:1.75;font-weight:400;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">${description}</p>

<table width="100%" cellpadding="0" cellspacing="0" style="border-top:1px solid rgba(255,255,255,0.1)">
<tr><td style="padding:24px 0 0 0">
<table width="100%" cellpadding="0" cellspacing="0"><tr>
<td width="50%" valign="top">
<p style="margin:0 0 4px 0;font-size:10px;color:rgba(255,255,255,0.4);text-transform:uppercase;letter-spacing:2px;font-weight:600;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">Data</p>
<p style="margin:0;font-size:15px;color:#ffffff;font-weight:600;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">${date || "Em breve"}</p>
</td>
<td width="50%" valign="top" style="text-align:right">
<p style="margin:0 0 4px 0;font-size:10px;color:rgba(255,255,255,0.4);text-transform:uppercase;letter-spacing:2px;font-weight:600;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">Local</p>
<p style="margin:0;font-size:15px;color:#ffffff;font-weight:600;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">${location || "Online"}</p>
</td>
</tr></table>
</td></tr>
</table>
</td></tr>

<tr><td style="padding:40px;text-align:center">
<a href="${url}" style="display:inline-block;background:linear-gradient(135deg,#00493a 0%,#0a844f 100%);color:#ffffff;padding:16px 44px;text-decoration:none;border-radius:8px;font-size:14px;font-weight:600;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif;letter-spacing:0.3px">Inscrever-se</a>
</td></tr>

<tr><td style="background-color:#003a2e;padding:32px 40px;border-top:1px solid rgba(255,255,255,0.05)">
<p style="margin:0;font-size:13px;color:rgba(255,255,255,0.4);line-height:1.7;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif;text-align:center;font-style:italic">As vagas podem ser limitadas. Garanta a sua inscrição.</p>
</td></tr>

<tr><td style="background-color:#00493a;padding:32px 40px;text-align:center">
<p style="margin:0 0 8px 0;font-size:12px;color:rgba(255,255,255,0.5);font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">Conheça Farmácia &mdash; Conhecimento que conecta.</p>
<p style="margin:0 0 16px 0;font-size:12px;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">
<a href="https://www.facebook.com/conhecafarmacia" style="color:#0a844f;text-decoration:none;margin:0 10px">Facebook</a>
<span style="color:rgba(255,255,255,0.1)">&bull;</span>
<a href="https://www.instagram.com/conhecafarmacia" style="color:#0a844f;text-decoration:none;margin:0 10px">Instagram</a>
<span style="color:rgba(255,255,255,0.1)">&bull;</span>
<a href="https://www.linkedin.com/company/conhecafarmacia" style="color:#0a844f;text-decoration:none;margin:0 10px">LinkedIn</a>
</p>
${unsubUrl ? `<p style="margin:0 0 16px 0;font-size:12px;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif"><a href="${unsubUrl}" style="color:rgba(255,255,255,0.4);text-decoration:underline">Cancelar subscrição</a></p>` : ""}
<p style="margin:0;font-size:11px;color:rgba(255,255,255,0.25);font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">&copy; 2026 Conheça Farmácia. Todos os direitos reservados.</p>
</td></tr>

</table>
</td></tr>
</table>
</body></html>`;
}

/**
 * Live Alert — Dinâmico/Energético
 * Gradiente verde a 3 cores, badge "Live", cards de info
 */
function getLiveTemplate(title: string, description: string, url: string, date?: string, platform?: string, unsubUrl?: string): string {
  return `<!doctype html>
<html lang="pt-PT">
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"></head>
<body style="margin:0;padding:0;background-color:#f0f7f4;">
<table width="100%" cellpadding="0" cellspacing="0" style="background-color:#f0f7f4">
<tr><td align="center" style="padding:48px 20px">
<table width="600" cellpadding="0" cellspacing="0" style="overflow:hidden;border-radius:4px">

<tr><td style="background:linear-gradient(135deg,#00493a 0%,#0a844f 50%,#006171 100%);padding:48px 40px;text-align:center">
<img src="${LOGO_DARK}" alt="Conheça Farmácia" style="height:52px;margin-bottom:20px;display:block;margin-left:auto;margin-right:auto">
<table width="100%" cellpadding="0" cellspacing="0"><tr><td align="center">
<span style="display:inline-block;background-color:rgba(255,255,255,0.2);color:#ffffff;padding:6px 16px;border-radius:20px;font-size:11px;font-weight:700;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif;letter-spacing:2px;text-transform:uppercase">Transmissão ao Vivo</span>
</td></tr></table>
</td></tr>

<tr><td style="background-color:#ffffff;padding:48px 40px">
<p style="margin:0 0 8px 0;font-size:11px;color:#0a844f;text-transform:uppercase;letter-spacing:3px;font-weight:700;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">Nova Live</p>
<p style="margin:0 0 28px 0;font-size:24px;color:#1a1a1a;line-height:1.3;font-weight:300;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif;letter-spacing:-0.3px">${title}</p>
<p style="margin:0 0 32px 0;font-size:15px;color:#555555;line-height:1.75;font-weight:400;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">${description}</p>

<table width="100%" cellpadding="0" cellspacing="0"><tr><td style="padding:0 0 40px 0">
<table width="100%" cellpadding="0" cellspacing="0" style="background-color:#f0f7f4;border-radius:8px"><tr>
<td width="50%" style="padding:20px;border-right:1px solid #ddeee6">
<p style="margin:0 0 4px 0;font-size:10px;color:#0a844f;text-transform:uppercase;letter-spacing:2px;font-weight:600;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">Data & Hora</p>
<p style="margin:0;font-size:15px;color:#1a1a1a;font-weight:600;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">${date || "Em breve"}</p>
</td>
<td width="50%" style="padding:20px">
<p style="margin:0 0 4px 0;font-size:10px;color:#0a844f;text-transform:uppercase;letter-spacing:2px;font-weight:600;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">Plataforma</p>
<p style="margin:0;font-size:15px;color:#1a1a1a;font-weight:600;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">${platform || "Online"}</p>
</td>
</tr></table>
</td></tr></table>

<table width="100%" cellpadding="0" cellspacing="0"><tr><td align="center">
<a href="${url}" style="display:inline-block;background:linear-gradient(135deg,#00493a 0%,#0a844f 100%);color:#ffffff;padding:16px 44px;text-decoration:none;border-radius:8px;font-size:14px;font-weight:600;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif;letter-spacing:0.3px">Acessar Live</a>
</td></tr></table>
</td></tr>

<tr><td style="background-color:#f0f7f4;padding:28px 40px;text-align:center">
<p style="margin:0;font-size:13px;color:#5a8a6e;line-height:1.6;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif;font-style:italic">Marque na sua agenda e prepare as suas perguntas. Estamos ansiosos por si!</p>
</td></tr>

<tr><td style="background-color:#ffffff;padding:32px 40px;border-top:1px solid #e8f0ec;text-align:center">
<p style="margin:0 0 8px 0;font-size:12px;color:#999999;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">Conheça Farmácia &mdash; Conhecimento que conecta.</p>
<p style="margin:0 0 16px 0;font-size:12px;color:#bbbbbb;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">
<a href="https://www.facebook.com/conhecafarmacia" style="color:#0a844f;text-decoration:none;margin:0 10px">Facebook</a>
<span style="color:#e0e0e0">&bull;</span>
<a href="https://www.instagram.com/conhecafarmacia" style="color:#0a844f;text-decoration:none;margin:0 10px">Instagram</a>
<span style="color:#e0e0e0">&bull;</span>
<a href="https://www.linkedin.com/company/conhecafarmacia" style="color:#0a844f;text-decoration:none;margin:0 10px">LinkedIn</a>
</p>
${unsubUrl ? `<p style="margin:0 0 16px 0;font-size:12px;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif"><a href="${unsubUrl}" style="color:#999999;text-decoration:underline">Cancelar subscrição</a></p>` : ""}
<p style="margin:0;font-size:11px;color:#cccccc;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif">&copy; 2026 Conheça Farmácia. Todos os direitos reservados.</p>
</td></tr>

</table>
</td></tr>
</table>
</body></html>`;
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: getCorsHeaders(req.headers.get("origin")) });
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
      contentPlatform,
      contentLocation,
      unsubscribeToken,
    }: EmailRequest = await req.json();

  // SEC: welcome-account emails are public (client-sends after OAuth),
  // rate-limited to 3/hour/recipient. Other types require internal key.
  if (type !== "welcome-account") {
    if (!INTERNAL_KEY || req.headers.get("x-internal-key") !== INTERNAL_KEY) {
      return new Response(
        JSON.stringify({ error: "Unauthorized" }),
        {
          status: 401,
          headers: { ...getCorsHeaders(req.headers.get("origin")), "Content-Type": "application/json" },
        }
      );
    }
  }

    if (!email || !type) {
      return new Response(
        JSON.stringify({ error: "Email and type are required" }),
        {
          status: 400,
          headers: { ...getCorsHeaders(req.headers.get("origin")), "Content-Type": "application/json" },
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
          headers: { ...getCorsHeaders(req.headers.get("origin")), "Content-Type": "application/json" },
        }
      );
    }

    // Validar tipo de email
    const validTypes = ["welcome", "welcome-account", "article", "event", "live"];
    if (!validTypes.includes(type)) {
      return new Response(
        JSON.stringify({ error: "Invalid email type" }),
        {
          status: 400,
          headers: { ...getCorsHeaders(req.headers.get("origin")), "Content-Type": "application/json" },
        }
      );
    }

    // Defesa em profundidade: limite por destinatário (3/hora)
    if (!checkRecipientRate(email.toLowerCase().trim())) {
      return new Response(
        JSON.stringify({ error: "Rate limit exceeded" }),
        {
          status: 429,
          headers: { ...getCorsHeaders(req.headers.get("origin")), "Content-Type": "application/json" },
        }
      );
    }

    // Validação Brevo API key (migração SES→Brevo 2026-06-18).
    if (!Deno.env.get("BREVO_API_KEY")) {
      console.error("BREVO_API_KEY não configurada");
      return new Response(
        JSON.stringify({ error: "Email service not configured" }),
        { status: 500, headers: { ...getCorsHeaders(req.headers.get("origin")), "Content-Type": "application/json" } }
      );
    }

    let htmlContent: string;
    let subject: string;

    const fallbackUrl = "https://conhecafarmacia.com";
    const unsubUrl = unsubscribeToken
      ? `https://conhecafarmacia.com/pt/unsubscribe?token=${unsubscribeToken}`
      : "https://conhecafarmacia.com/pt/unsubscribe";

    if (type === "welcome") {
      htmlContent = getWelcomeTemplate(nome || "Subscritor", unsubUrl);
      subject = "Bem-vindo à Newsletter - Conheça Farmácia";
    } else if (type === "welcome-account") {
      htmlContent = getWelcomeAccountTemplate(nome || "Utilizador");
      subject = `Bem-vindo ao Conheça Farmácia, ${nome || "Utilizador"}!`;
    } else if (type === "article") {
      htmlContent = getArticleTemplate(
        contentTitle || "Novo artigo",
        contentDescription || "",
        contentUrl || fallbackUrl,
        unsubUrl
      );
      subject = "Novo Artigo - Conheça Farmácia";
    } else if (type === "event") {
      htmlContent = getEventTemplate(
        contentTitle || "Novo evento",
        contentDescription || "",
        contentUrl || fallbackUrl,
        contentDate,
        contentLocation,
        unsubUrl
      );
      subject = "Novo Evento - Conheça Farmácia";
    } else {
      htmlContent = getLiveTemplate(
        contentTitle || "Nova live",
        contentDescription || "",
        contentUrl || fallbackUrl,
        contentDate,
        contentPlatform,
        unsubUrl
      );
      subject = "Nova Live - Conheça Farmácia";
    }

    // From / Reply-To por tipo de email (domínio conhecafarmacia.com).
    // sender.name UTF-8 hardcoded "Conheça Farmácia" no helper (decisão
    // 2026-06-18 — Brevo tolera UTF-8 no JSON; rollback ASCII via commit).
    const senderAddress =
      type === "welcome"
        ? "newsletter@conhecafarmacia.com"
        : type === "welcome-account"
        ? "info@conhecafarmacia.com"
        : "info@conhecafarmacia.com";
    const replyToAddress = "contato@conhecafarmacia.com";

    // Cabeçalhos antispam (RFC 8058 + RFC 2369)
    // List-Unsubscribe-Post: List-Unsubscribe=One-Click (mailto) para Gmail/Outlook
    const listUnsubscribeMailto = `mailto:${replyToAddress}?subject=unsubscribe&body=Por%20favor%2C%20remova-me%20da%20lista.`;
    const listUnsubscribeHeaders: Record<string, string> = {
      "List-Unsubscribe": `<${listUnsubscribeMailto}>, <${unsubUrl}>`,
      "List-Unsubscribe-Post": "List-Unsubscribe=One-Click",
    };

    // Envio via Brevo API v3 (helper partilhado em _shared/brevo.ts).
    // Erros propagam com `code` semântico mapeado para i18n no client.
    const { sendViaBrevo } = await import("../_shared/brevo.ts");
    await sendViaBrevo({
      to: { email, name: nome ?? email },
      sender: senderAddress,
      subject,
      htmlContent,
      replyTo: replyToAddress,
      headers: listUnsubscribeHeaders,
      tags: [type === "welcome-account" ? "account" : "newsletter", type],
    });

    return new Response(
      JSON.stringify({ success: true }),
      {
        status: 200,
        headers: { ...getCorsHeaders(req.headers.get("origin")), "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    const e = error as Error;
    console.error("send-newsletter-email error:", e.message, e.stack);
    return new Response(
      JSON.stringify({ error: "Erro interno do servidor" }),
      {
        status: 500,
        headers: { ...getCorsHeaders(req.headers.get("origin")), "Content-Type": "application/json" },
      }
    );
  }
});
