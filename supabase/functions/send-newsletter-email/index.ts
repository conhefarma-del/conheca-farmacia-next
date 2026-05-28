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
  contentPlatform?: string;
  contentLocation?: string;
  unsubscribeToken?: string;
}

// Logo URLs — usar URLs externas (base64 é bloqueado por Gmail/Outlook)
const LOGO_LIGHT = "https://conheca-farmacia-next.vercel.app/logo/3.png";
const LOGO_DARK = "https://conheca-farmacia-next.vercel.app/logo/3_2.png";

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
<img src="${LOGO_LIGHT}" alt="Conheça Farmácia" style="height:52px;margin-bottom:24px">
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
<a href="https://conheca-farmacia-next.vercel.app" style="display:inline-block;background:linear-gradient(135deg,#00493a 0%,#0a844f 100%);color:#ffffff;padding:16px 40px;text-decoration:none;border-radius:8px;font-size:14px;font-weight:600;font-family:'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif;letter-spacing:0.3px">Explorar Conteúdo</a>
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
<td style="padding-bottom:24px;border-bottom:2px solid #1a1a1a">
<img src="${LOGO_LIGHT}" alt="Conheça Farmácia" style="height:36px">
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
<img src="${LOGO_DARK}" alt="Conheça Farmácia" style="height:52px;margin-bottom:24px">
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
<img src="${LOGO_DARK}" alt="Conheça Farmácia" style="height:48px;margin-bottom:20px">
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
      contentPlatform,
      contentLocation,
      unsubscribeToken,
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

    const fallbackUrl = "https://conheca-farmacia-next.vercel.app";
    const unsubUrl = unsubscribeToken
      ? `https://conheca-farmacia-next.vercel.app/pt/unsubscribe?token=${unsubscribeToken}`
      : "";

    if (type === "welcome") {
      htmlContent = getWelcomeTemplate(nome || "Subscritor", unsubUrl);
      subject = "Bem-vindo à Newsletter - Conheça Farmácia";
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
