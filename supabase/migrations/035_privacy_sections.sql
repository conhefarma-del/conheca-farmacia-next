-- 035: Privacy policy sections (hierarchical, up to level 2)
CREATE TABLE IF NOT EXISTS public.privacy_sections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  parent_id UUID REFERENCES public.privacy_sections(id) ON DELETE CASCADE,
  anchor_slug TEXT UNIQUE NOT NULL,
  title_pt TEXT NOT NULL,
  title_en TEXT NOT NULL,
  content_pt TEXT NOT NULL DEFAULT '',
  content_en TEXT NOT NULL DEFAULT '',
  level INT NOT NULL DEFAULT 1 CHECK (level IN (1, 2)),
  pending BOOLEAN NOT NULL DEFAULT false,
  sort_order INT NOT NULL DEFAULT 0,
  is_archived BOOLEAN NOT NULL DEFAULT false,
  archived_at TIMESTAMPTZ,
  archived_by UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- RLS
ALTER TABLE public.privacy_sections ENABLE ROW LEVEL SECURITY;

CREATE POLICY "admin_all_privacy_sections" ON public.privacy_sections
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()));

CREATE POLICY "anon_read_privacy_sections" ON public.privacy_sections
  FOR SELECT TO anon, authenticated
  USING (is_archived = false);

CREATE TRIGGER set_privacy_sections_updated_at
  BEFORE UPDATE ON public.privacy_sections
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Seed privacy sections from policiesfc/CF-Politica-Privacidade-Cookies.md
-- First insert level-1 sections (those without parent)
INSERT INTO public.privacy_sections (anchor_slug, title_pt, title_en, content_pt, content_en, level, pending, sort_order) VALUES
  ('quem-somos', '1. Quem somos', '1. Who we are',
   'A Conheça Farmácia (NIF: 5001925989) é uma organização angolana dedicada à educação e promoção da saúde. Esta política explica como recolhemos, usamos, armazenamos e protegemos os dados pessoais de quem utiliza o nosso website, se inscreve em eventos, ou interage com os nossos formulários.\n\nPara qualquer questão sobre esta política ou sobre os seus dados pessoais, pode contactar-nos através de: **geral@conhecafarmacia.com**.',
   'Conheça Farmácia (Tax ID: 5001925989) is an Angolan organization dedicated to health education and promotion. This policy explains how we collect, use, store and protect the personal data of those who use our website, register for events, or interact with our forms.\n\nFor any questions about this policy or your personal data, you can contact us at: **geral@conhecafarmacia.com**.',
   1, false, 1),
  ('que-dados', '2. Que dados recolhemos', '2. What data we collect',
   'Recolhemos os seguintes dados através dos formulários do website (nomeadamente inscrição em eventos):\n\n- Nome completo\n- Profissão\n- Endereço de email\n- Número de telefone\n\nNão recolhemos número de identificação fiscal (NIF), dados de saúde, nem qualquer dado sensível dos participantes.',
   'We collect the following data through website forms (namely event registration):\n\n- Full name\n- Profession\n- Email address\n- Phone number\n\nWe do not collect tax identification numbers, health data, or any sensitive participant data.',
   1, false, 2),
  ('finalidade', '3. Finalidade do tratamento', '3. Purpose of processing',
   'Os dados recolhidos são utilizados para:\n\n- Processar inscrições em eventos e formações;\n- Emitir certificados de participação;\n- Comunicar informações relevantes sobre o evento em que a pessoa se inscreveu;\n- Manter um histórico de participação, incluindo para efeitos de verificação de autenticidade de certificados emitidos.\n\nNão utilizamos os dados recolhidos para fins de marketing não solicitado, nem os vendemos ou cedemos a terceiros para fins comerciais.',
   'The collected data is used for:\n\n- Processing event and training registrations;\n- Issuing participation certificates;\n- Communicating relevant information about the event the person registered for;\n- Maintaining a participation history, including for authenticity verification of issued certificates.\n\nWe do not use collected data for unsolicited marketing purposes, nor do we sell or transfer it to third parties for commercial purposes.',
   1, false, 3),
  ('partilha', '4. Partilha de dados com terceiros', '4. Data sharing with third parties',
   'Os dados recolhidos são, na sua maioria, de uso exclusivamente interno da Conheça Farmácia.\n\nEm situações específicas — nomeadamente quando um evento envolve co-certificação ou co-organização com uma Ordem profissional — os dados de participação (nome, e eventualmente profissão) podem ser partilhados com essa entidade, exclusivamente para os fins relacionados com essa colaboração.',
   'The collected data is, for the most part, for the exclusive internal use of Conheça Farmácia.\n\nIn specific situations — particularly when an event involves co-certification or co-organization with a professional Order — participation data (name, and possibly profession) may be shared with that entity, exclusively for purposes related to that collaboration.',
   1, false, 4),
  ('armazenamento', '5. Armazenamento e segurança', '5. Storage and security',
   'Os dados pessoais recolhidos são armazenados na plataforma Supabase, alojada em servidores localizados em **[região do servidor Supabase — a confirmar: ex. EUA, União Europeia]**.\n\nNos casos em que os dados são armazenados fora do território angolano, a Conheça Farmácia compromete-se a assegurar que essa transferência respeita as exigências da Lei n.º 22/11, de 17 de junho (Lei da Proteção de Dados Pessoais), nomeadamente através da adoção de medidas de segurança técnicas e organizativas adequadas junto do prestador de serviço.',
   'The collected personal data is stored on the Supabase platform, hosted on servers located in **[Supabase server region — to be confirmed: e.g. USA, European Union]**.\n\nIn cases where data is stored outside Angolan territory, Conheça Farmácia undertakes to ensure that this transfer complies with the requirements of Law No. 22/11 of June 17 (Personal Data Protection Law), namely through the adoption of appropriate technical and organizational security measures with the service provider.',
   1, true, 5),
  ('conservacao', '6. Prazo de conservação dos dados', '6. Data retention period',
   'Os dados pessoais são conservados enquanto for necessário para cumprir as finalidades descritas na secção 3 — nomeadamente para manter um histórico de participação que permita a emissão e verificação de certificados em edições futuras dos mesmos eventos ou formações.\n\nO titular dos dados pode, a qualquer momento, solicitar a eliminação dos seus dados, nos termos da secção 7.',
   'Personal data is retained for as long as necessary to fulfill the purposes described in section 3 — namely to maintain a participation history that allows for the issuance and verification of certificates in future editions of the same events or training.\n\nThe data subject may, at any time, request the deletion of their data, as per section 7.',
   1, false, 6),
  ('direitos', '7. Direitos do titular dos dados', '7. Data subject rights',
   'Nos termos da Lei n.º 22/11, tem o direito de, em qualquer momento:\n\n- Aceder aos dados pessoais que temos sobre si;\n- Solicitar a rectificação de dados incorretos ou incompletos;\n- Solicitar a eliminação dos seus dados;\n- Opor-se ao tratamento dos seus dados, nos termos permitidos por lei.\n\nPara exercer qualquer um destes direitos, contacte-nos através de **geral@conhecafarmacia.com**.',
   'Under Law No. 22/11, you have the right at any time to:\n\n- Access the personal data we hold about you;\n- Request rectification of incorrect or incomplete data;\n- Request deletion of your data;\n- Object to the processing of your data, as permitted by law.\n\nTo exercise any of these rights, contact us at **geral@conhecafarmacia.com**.',
   1, false, 7),
  ('cookies', '8. Cookies', '8. Cookies',
   'O nosso website utiliza cookies para o seu funcionamento e, no futuro, para fins de análise de audiência.',
   'Our website uses cookies for its operation and, in the future, for audience analysis purposes.',
   1, false, 8),
  ('natureza', '9. Sobre a natureza da Conheça Farmácia', '9. About the nature of Conheça Farmácia',
   'Para evitar confusões: a Conheça Farmácia **não é uma farmácia comercial** e não vende medicamentos ou produtos farmacêuticos. Somos uma organização de educação e promoção da saúde.',
   'To avoid confusion: Conheça Farmácia **is not a commercial pharmacy** and does not sell medicines or pharmaceutical products. We are a health education and promotion organization.',
   1, false, 9),
  ('alteracoes', '10. Alterações a esta política', '10. Changes to this policy',
   'Esta política pode ser atualizada periodicamente, nomeadamente para refletir novas funcionalidades do website (ex.: introdução de um agente de IA via WhatsApp, ativação do Google Analytics). A data da última atualização será sempre indicada no topo desta página.\n\n**Última atualização:** [DD/MM/AAAA]',
   'This policy may be updated periodically, namely to reflect new website features (e.g., introduction of an AI agent via WhatsApp, activation of Google Analytics). The date of the last update will always be indicated at the top of this page.\n\n**Last updated:** [DD/MM/AAAA]',
   1, false, 10);

-- Now insert level-2 sections using the parent anchor_slug to find parent id
DO $$
DECLARE
  que_dados_id UUID;
  cookies_id UUID;
BEGIN
  SELECT id INTO que_dados_id FROM public.privacy_sections WHERE anchor_slug = 'que-dados';
  SELECT id INTO cookies_id FROM public.privacy_sections WHERE anchor_slug = 'cookies';

  -- Children of 'que-dados'
  INSERT INTO public.privacy_sections (parent_id, anchor_slug, title_pt, title_en, content_pt, content_en, level, pending, sort_order) VALUES
  (que_dados_id, 'menores', '2.1 Dados de menores de idade', '2.1 Minors data',
   'Alguns dos nossos eventos aceitam a inscrição de estudantes menores de idade. Nestes casos, **é necessário o consentimento do responsável legal (pai, mãe ou tutor)** para o tratamento dos dados do menor. Este consentimento é obtido no momento da inscrição, através de declaração específica no formulário, a ser prestada pelo responsável legal.',
   'Some of our events accept registrations from underage students. In these cases, **consent from the legal guardian (parent or tutor) is required** for processing the minor''s data. This consent is obtained at the time of registration through a specific declaration in the form, to be provided by the legal guardian.',
   2, false, 1);

  -- Children of 'cookies'
  INSERT INTO public.privacy_sections (parent_id, anchor_slug, title_pt, title_en, content_pt, content_en, level, pending, sort_order) VALUES
  (cookies_id, 'cookies-necessarios', '8.1 Cookies estritamente necessários', '8.1 Strictly necessary cookies',
   'Cookies essenciais ao funcionamento do website (ex.: manter a sessão de inscrição ativa). Estes não podem ser desativados.',
   'Cookies essential for the website''s operation (e.g., keeping the registration session active). These cannot be disabled.',
   2, false, 1),
  (cookies_id, 'cookies-analise', '8.2 Cookies de análise (Google Analytics)', '8.2 Analytics cookies (Google Analytics)',
   '*[a implementar]* Quando ativado, o Google Analytics recolhe dados anónimos sobre a utilização do website, para nos ajudar a compreender como os visitantes o utilizam. Estes cookies só são ativados após consentimento explícito do utilizador.',
   '*[to be implemented]* When activated, Google Analytics collects anonymous data about website usage to help us understand how visitors use it. These cookies are only activated after explicit user consent.',
   2, true, 2),
  (cookies_id, 'cookies-youtube', '8.3 Cookies de conteúdo incorporado (YouTube)', '8.3 Embedded content cookies (YouTube)',
   '*[a implementar]* Quando publicarmos vídeos do YouTube incorporados no website (ex.: entrevistas), a reprodução desses vídeos pode definir cookies próprios do YouTube/Google.',
   '*[to be implemented]* When we publish embedded YouTube videos on the website (e.g., interviews), playing those videos may set YouTube/Google cookies.',
   2, true, 3),
  (cookies_id, 'cookies-gestao', '8.4 Gestão de preferências de cookies', '8.4 Cookie preference management',
   '*[Nota de implementação: quando o Google Analytics for adicionado, implementar um banner de consentimento de cookies com opção de aceitar/rejeitar cookies não-essenciais, para além dos estritamente necessários.]*',
   '*[Implementation note: when Google Analytics is added, implement a cookie consent banner with the option to accept/reject non-essential cookies, in addition to strictly necessary ones.]*',
   2, true, 4);
END $$;
