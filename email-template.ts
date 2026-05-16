/**
 * Template de Email para Confirmação de Inscrição
 * Usar placeholders: {{NOME_PARTICIPANTE}}, {{NOME_EVENTO}}, {{DATA_INSCRICAO}}
 */

export function getInscriptionEmailTemplate(
  nomeParticipante: string,
  nomeEvento: string,
  dataInscricao: string
): string {
  const dataFormatada = new Date(dataInscricao).toLocaleDateString("pt-PT", {
    year: "numeric",
    month: "long",
    day: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });

  return `<!DOCTYPE html>
<html lang="pt-PT">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Confirmação de Inscrição - Conheça Farmácia</title>
</head>
<body style="margin: 0; padding: 0; font-family: 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; background-color: #f5f5f5;">

<!-- Container Principal -->
<table width="100%" cellpadding="0" cellspacing="0" style="background-color: #f5f5f5;">
    <tr>
        <td align="center" style="padding: 40px 20px;">

            <!-- Email Wrapper -->
            <table width="600" cellpadding="0" cellspacing="0" style="background-color: #ffffff; border-radius: 8px; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1); overflow: hidden;">

                <!-- HEADER com Logo -->
                <tr>
                    <td style="background: linear-gradient(135deg, #00493a 0%, #0a844f 100%); padding: 40px 20px; text-align: center;">
                        <h1 style="margin: 0; color: #ffffff; font-size: 28px; font-weight: 700; letter-spacing: -0.5px;">
                            Conheça Farmácia
                        </h1>
                        <p style="margin: 8px 0 0 0; color: rgba(255, 255, 255, 0.9); font-size: 14px; font-weight: 300;">
                            Excelência no Cuidado Farmacêutico
                        </p>
                    </td>
                </tr>

                <!-- CONTEÚDO PRINCIPAL -->
                <tr>
                    <td style="padding: 40px 30px;">

                        <!-- Saudação -->
                        <p style="margin: 0 0 20px 0; font-size: 16px; color: #333333; font-weight: 600;">
                            Olá <strong>${nomeParticipante}</strong>,
                        </p>

                        <!-- Mensagem Principal -->
                        <p style="margin: 0 0 24px 0; font-size: 15px; color: #555555; line-height: 1.6; font-weight: 400;">
                            Recebemos a sua candidatura com sucesso! 🎉
                        </p>

                        <p style="margin: 0 0 24px 0; font-size: 15px; color: #555555; line-height: 1.6; font-weight: 400;">
                            Confirma-se o seu registo para o evento:
                        </p>

                        <!-- Card do Evento -->
                        <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #f9f9f9; border-left: 4px solid #00493a; margin-bottom: 24px;">
                            <tr>
                                <td style="padding: 20px; font-size: 15px; color: #333333;">
                                    <p style="margin: 0 0 12px 0; font-weight: 700; color: #00493a; font-size: 14px; text-transform: uppercase; letter-spacing: 0.5px;">
                                        📅 Evento
                                    </p>
                                    <p style="margin: 0 0 16px 0; font-weight: 600; font-size: 16px; color: #333333;">
                                        ${nomeEvento}
                                    </p>
                                    <p style="margin: 0; font-size: 14px; color: #666666;">
                                        Data de Inscrição: <strong>${dataFormatada}</strong>
                                    </p>
                                </td>
                            </tr>
                        </table>

                        <!-- Mensagem de Valor -->
                        <p style="margin: 0 0 24px 0; font-size: 15px; color: #555555; line-height: 1.6; font-weight: 400;">
                            A sua participação é fundamental para o fortalecimento do papel clínico do farmacêutico. Estamos entusiasmados em tê-lo connosco neste evento que reúne profissionais dedicados à excelência no cuidado farmacêutico.
                        </p>

                        <!-- Secção Próximos Passos -->
                        <h3 style="margin: 32px 0 16px 0; font-size: 16px; color: #00493a; font-weight: 700;">
                            📋 Próximos Passos
                        </h3>

                        <table width="100%" cellpadding="0" cellspacing="0" style="margin-bottom: 24px;">
                            <tr>
                                <td style="vertical-align: top; padding: 12px 0; font-size: 14px;">
                                    <span style="display: inline-block; width: 24px; height: 24px; background-color: #0a844f; color: white; border-radius: 50%; text-align: center; line-height: 24px; font-weight: bold; margin-right: 12px; font-size: 13px;">
                                        1
                                    </span>
                                </td>
                                <td style="vertical-align: top; font-size: 14px; color: #555555; padding: 12px 0;">
                                    <strong style="color: #333333;">Fique atento ao seu e-mail</strong> para receber o link de acesso ou detalhes do local do evento.
                                </td>
                            </tr>
                            <tr>
                                <td style="vertical-align: top; padding: 12px 0; font-size: 14px;">
                                    <span style="display: inline-block; width: 24px; height: 24px; background-color: #0a844f; color: white; border-radius: 50%; text-align: center; line-height: 24px; font-weight: bold; margin-right: 12px; font-size: 13px;">
                                        2
                                    </span>
                                </td>
                                <td style="vertical-align: top; font-size: 14px; color: #555555; padding: 12px 0;">
                                    <strong style="color: #333333;">Confirme sua presença</strong> caso seja necessário mediante o link que enviaremos.
                                </td>
                            </tr>
                            <tr>
                                <td style="vertical-align: top; padding: 12px 0; font-size: 14px;">
                                    <span style="display: inline-block; width: 24px; height: 24px; background-color: #0a844f; color: white; border-radius: 50%; text-align: center; line-height: 24px; font-weight: bold; margin-right: 12px; font-size: 13px;">
                                        3
                                    </span>
                                </td>
                                <td style="vertical-align: top; font-size: 14px; color: #555555; padding: 12px 0;">
                                    <strong style="color: #333333;">Partilhe com colegas</strong> interessados em desenvolver-se profissionalmente.
                                </td>
                            </tr>
                        </table>

                        <!-- CTA Button -->
                        <table width="100%" cellpadding="0" cellspacing="0" style="margin: 32px 0;">
                            <tr>
                                <td align="center">
                                    <a href="https://conhecafarmacia.com" style="display: inline-block; background-color: #00493a; color: #ffffff; padding: 14px 32px; text-decoration: none; border-radius: 6px; font-size: 15px; font-weight: 600; transition: background-color 0.3s ease;">
                                        Saber Mais
                                    </a>
                                </td>
                            </tr>
                        </table>

                        <!-- Mensagem de Encerramento -->
                        <p style="margin: 32px 0 0 0; font-size: 14px; color: #666666; line-height: 1.6; border-top: 1px solid #e0e0e0; padding-top: 24px;">
                            Se tiver dúvidas ou precisar de ajuda, entre em contacto connosco através de
                            <a href="mailto:conhecerfarmacia@gmail.com" style="color: #00493a; text-decoration: none; font-weight: 600;">
                                conhecerfarmacia@gmail.com
                            </a>
                            ou
                            <a href="https://wa.me/244925696002" style="color: #00493a; text-decoration: none; font-weight: 600;">
                                +244 925 696 002
                            </a>.
                        </p>

                    </td>
                </tr>

                <!-- FOOTER -->
                <tr>
                    <td style="background-color: #f9f9f9; padding: 24px 30px; border-top: 1px solid #e0e0e0; text-align: center;">
                        <p style="margin: 0 0 12px 0; font-size: 13px; color: #999999;">
                            <strong style="color: #333333;">Conheça Farmácia</strong>
                        </p>
                        <p style="margin: 0 0 16px 0; font-size: 12px; color: #999999;">
                            Conhecimento que conecta. Formação que transforma. Saúde que evolui.
                        </p>

                        <!-- Social Links -->
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
                            © 2026 Conheça Farmácia. Todos os direitos reservados.
                        </p>
                    </td>
                </tr>

            </table>

        </td>
    </tr>
</table>

</body>
</html>`;
}
