import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SITE_URL = "https://conheca-farmacia-next.vercel.app";

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
                            <a href="mailto:conhecerfarmacia@gmail.com" style="color: #00493a; text-decoration: none; font-weight: 600;">conhecerfarmacia@gmail.com</a>
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

serve(async (req: Request) => {
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { "Content-Type": "application/json" },
    });
  }

  try {
    const { email, nome, evento_slug } = await req.json();

    if (!email || !nome || !evento_slug) {
      return new Response(
        JSON.stringify({ error: "Campos obrigatórios: email, nome, evento_slug" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
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
      ? `${SITE_URL}/pt/unsubscribe?token=${subscriber.unsubscribe_token}`
      : `${SITE_URL}/pt/unsubscribe`;

    // Generate template
    const htmlContent = getInscriptionEmailTemplate(
      nome,
      nomeEvento,
      new Date().toISOString(),
      evento_slug,
      unsubscribeUrl
    );

    // Send via Resend
    const resendApiKey = Deno.env.get("RESEND_API_KEY");
    if (!resendApiKey) {
      throw new Error("RESEND_API_KEY não configurada");
    }

    const resendResponse = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${resendApiKey}`,
      },
      body: JSON.stringify({
        from: "Conheça Farmácia <onboarding@resend.dev>",
        to: email,
        subject: "Confirmação de Inscrição - Conheça Farmácia",
        html: htmlContent,
        reply_to: "conhecerfarmacia@gmail.com",
      }),
    });

    if (!resendResponse.ok) {
      const errorData = await resendResponse.json();
      throw new Error(`Resend Error: ${JSON.stringify(errorData)}`);
    }

    const resendData = await resendResponse.json();

    return new Response(
      JSON.stringify({ success: true, resend_id: resendData.id }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("send-inscription-email error:", error);
    return new Response(
      JSON.stringify({ error: error instanceof Error ? error.message : "Erro desconhecido" }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});
