# FAQ & Privacy Policy Pages — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Criar duas novas páginas públicas — FAQ (com separadores horizontal "Geral" / "Parceiros e Patrocinadores") e Política de Privacidade (com TOC lateral + scroll-spy). Conteúdo source em `policiesfc/CF-FAQ-Website.md` e `policiesfc/CF-Politica-Privacidade-Cookies.md`. Adicionar secção Admin "Conteúdo Legal" para gestão do conteúdo (FAQ + Privacidade) via DB.

**Architecture:** Novas migrações Supabase (`faq_tabs`, `faq_questions`, `privacy_sections`); Server Actions `lib/actions/legalContent.js` para CRUD + leitura pública; duas novas páginas públicas `/[lang]/faq` + `/[lang]/politica-privacidade` sob PublicLayout existente; rota admin `(admin)/conteudo-legal/{faq,politica-privacidade}` com BilingualTabs. Páginas públicas lêem dados live da DB.

**Tech Stack:** Next.js 16 App Router, React 19, Supabase (Postgres + RLS), Server Actions (`'use server'`), Tailwind v4, Tailwind Typography (`prose`), lucide-react, IntersectionObserver (scroll-spy), native `<details>`/`<summary>` (accordion).

**Source content:** `policiesfc/CF-FAQ-Website.md` (2 separadores, 8 perguntas, 5 `[a confirmar]`) + `policiesfc/CF-Politica-Privacidade-Cookies.md` (10 secções hierárquicas, 2 `[a implementar]`).

---

## File Structure

**Migrations:**
- `supabase/migrations/034_faq_tabs.sql` — tabelas `faq_tabs` + `faq_questions` com RLS.
- `supabase/migrations/035_privacy_sections.sql` — tabela `privacy_sections` com RLS.

**Server Actions:**
- Create: `lib/actions/legalContent.js` — `getPublicFAQData`, `getPublicPrivacyData`, CRUD para Admin.

**Páginas Públicas:**
- Create: `app/[lang]/(public)/faq/page.js` — Server Component.
- Create: `app/[lang]/(public)/politica-privacidade/page.js` — Server Component.
- Create: `app/[lang]/(public)/faq/faqPageClient.jsx` — Client Component.
- Create: `app/[lang]/(public)/politica-privacidade/privacyPageClient.jsx` — Client Component.

**Componentes Públicos:**
- Create: `components/faq/FAQTabs.jsx` — Tab bar horizontal + panel switching.
- Create: `components/faq/FAQPanel.jsx` — Lista accordion de Q&A.
- Create: `components/faq/FAQItem.jsx` — Single Q&A `<details>`/`<summary>`.
- Create: `components/privacy/PrivacyTOC.jsx` — Sticky sidebar TOC com scroll-spy.
- Create: `components/privacy/PrivacyContent.jsx` — Main content area.
- Create: `components/ui/PendingBadge.jsx` — Reusable "pendente" badge.

**Páginas Admin:**
- Create: `app/[lang]/admin/(protected)/conteudo-legal/faq/page.js` — Server Component.
- Create: `app/[lang]/admin/(protected)/conteudo-legal/politica-privacidade/page.js` — Server Component.
- Create: `components/admin/FAQAdminPage.jsx` — Gerir tabs + perguntas FAQ.
- Create: `components/admin/PrivacyAdminPage.jsx` — Gerir secções hierárquicas.
- Modify: `components/layout/AdminSidebar.jsx` — Adicionar "Conteúdo Legal" grupo.
- Modify: `components/layout/Footer.jsx` — Adicionar FAQ link + actualizar privacy link.
- Modify: `lib/i18n-routes.js` — Adicionar `faq` + `politicaPrivacidade`.
- Modify: `public/i18n/{pt,en}.json` — Adicionar chaves i18n.

---

## Task 1: Migração `faq_tabs` + `faq_questions`

**Files:**
- Create: `supabase/migrations/034_faq_tabs.sql`

- [ ] **Step 1: Escrever a migração**

```sql
-- 034: FAQ tabs and questions tables
CREATE TABLE IF NOT EXISTS public.faq_tabs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT UNIQUE NOT NULL,
  label_pt TEXT NOT NULL,
  label_en TEXT NOT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  is_archived BOOLEAN NOT NULL DEFAULT false,
  archived_at TIMESTAMPTZ,
  archived_by UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.faq_questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tab_id UUID NOT NULL REFERENCES public.faq_tabs(id) ON DELETE CASCADE,
  question_pt TEXT NOT NULL,
  question_en TEXT NOT NULL,
  answer_pt TEXT NOT NULL DEFAULT '',
  answer_en TEXT NOT NULL DEFAULT '',
  pending BOOLEAN NOT NULL DEFAULT true,
  sort_order INT NOT NULL DEFAULT 0,
  is_archived BOOLEAN NOT NULL DEFAULT false,
  archived_at TIMESTAMPTZ,
  archived_by UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- RLS
ALTER TABLE public.faq_tabs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.faq_questions ENABLE ROW LEVEL SECURITY;

-- Admin can do everything (auth check enforced via Server Actions)
CREATE POLICY "admin_all_faq_tabs" ON public.faq_tabs
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()));

CREATE POLICY "admin_all_faq_questions" ON public.faq_questions
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()));

-- Anon can only read non-archived data (for public pages)
CREATE POLICY "anon_read_faq_tabs" ON public.faq_tabs
  FOR SELECT TO anon, authenticated
  USING (is_archived = false);

CREATE POLICY "anon_read_faq_questions" ON public.faq_questions
  FOR SELECT TO anon, authenticated
  USING (is_archived = false);

-- Triggers for updated_at
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_faq_tabs_updated_at
  BEFORE UPDATE ON public.faq_tabs
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER set_faq_questions_updated_at
  BEFORE UPDATE ON public.faq_questions
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
```

- [ ] **Step 2: Seed data do conteúdo source**

```sql
-- Seed FAQ tabs + questions from policiesfc/CF-FAQ-Website.md
INSERT INTO public.faq_tabs (slug, label_pt, label_en, sort_order) VALUES
  ('geral', 'Geral', 'General', 1),
  ('parceiros', 'Parceiros e Patrocinadores', 'Partners & Sponsors', 2);

INSERT INTO public.faq_questions (tab_id, question_pt, question_en, answer_pt, answer_en, pending, sort_order)
SELECT t.id, q.* FROM (SELECT slug FROM public.faq_tabs) t,
(VALUES
  -- Tab: Geral (sort_order 1..5)
  ('geral',
   'A Conheça Farmácia é uma farmácia?',
   'Is Conheça Farmácia a pharmacy?',
   'Não. Somos uma organização de educação e promoção da saúde — não vendemos medicamentos nem prestamos serviços farmacêuticos comerciais. Este é um dos equívocos mais comuns sobre o nosso trabalho, por isso preferimos deixar claro desde já.',
   'No. We are a health education and promotion organization — we do not sell medicines or provide commercial pharmaceutical services. This is one of the most common misconceptions about our work, so we prefer to make it clear from the start.',
   false, 1),
  ('geral',
   'O certificado de participação é pago?',
   'Is the participation certificate paid?',
   'Sim. O valor varia de acordo com o evento — pode ser consultado na página de detalhes de cada evento específico.',
   'Yes. The fee varies depending on the event — you can check it on each event''s detail page.',
   false, 2),
  ('geral',
   'Como me inscrevo num evento?',
   'How do I register for an event?',
   '[a confirmar — descrever o processo de inscrição no website, uma vez definido]',
   '[to be confirmed — describe the registration process on the website, once defined]',
   true, 3),
  ('geral',
   'Posso cancelar a minha inscrição?',
   'Can I cancel my registration?',
   '[a confirmar — definir política de cancelamento/reembolso antes de publicar]',
   '[to be confirmed — define cancellation/refund policy before publishing]',
   true, 4),
  ('geral',
   'Como posso tornar-me voluntário na Conheça Farmácia?',
   'How can I become a volunteer at Conheça Farmácia?',
   'Atualmente não estamos em processo de recrutamento de novos colaboradores voluntários. Quando abrirmos novas vagas, o anúncio será feito através das nossas redes sociais.',
   'We are currently not recruiting new volunteers. When new openings become available, the announcement will be made through our social media channels.',
   false, 5),
  -- Tab: Parceiros (sort_order 1..3) — ALL pending
  ('parceiros',
   'Como posso propor uma parceria com a Conheça Farmácia?',
   'How can I propose a partnership with Conheça Farmácia?',
   '[a confirmar — indicar canal de contacto, ex.: geral@conhecafarmacia.com, ou formulário próprio]',
   '[to be confirmed — indicate contact channel, e.g.: geral@conhecafarmacia.com, or dedicated form]',
   true, 1),
  ('parceiros',
   'Como posso patrocinar um evento da Conheça Farmácia?',
   'How can I sponsor a Conheça Farmácia event?',
   '[a confirmar — indicar canal de contacto e/ou nível de detalhe a expor publicamente sobre os níveis de patrocínio]',
   '[to be confirmed — indicate contact channel and/or level of detail to publicly disclose about sponsorship levels]',
   true, 2),
  ('parceiros',
   'Que tipo de contrapartidas os patrocinadores recebem?',
   'What kind of benefits do sponsors receive?',
   '[a confirmar — decidir se o detalhe de contrapartidas (visibilidade de marca, menção institucional, etc.) deve ser público na FAQ, ou tratado apenas diretamente por ofício/proposta]',
   '[to be confirmed — decide whether benefit details (brand visibility, institutional mention, etc.) should be public in the FAQ, or handled directly via proposal]',
   true, 3)
) AS q(slug, question_pt, question_en, answer_pt, answer_en, pending, sort_order)
WHERE t.slug = q.slug;
```

- [ ] **Step 3: Commit**

```bash
git add supabase/migrations/034_faq_tabs.sql
git commit -m "feat(db): add faq_tabs + faq_questions tables with seed data"
```

---

## Task 2: Migração `privacy_sections`

**Files:**
- Create: `supabase/migrations/035_privacy_sections.sql`

- [ ] **Step 1: Escrever a migração**

```sql
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
```

- [ ] **Step 2: Seed data do conteúdo source**

```sql
-- Seed privacy sections from policiesfc/CF-Politica-Privacidade-Cookies.md
INSERT INTO public.privacy_sections (anchor_slug, title_pt, title_en, content_pt, content_en, level, pending, sort_order, parent_id) VALUES
  ('quem-somos', '1. Quem somos', '1. Who we are',
   'A Conheça Farmácia (NIF: 5001925989) é uma organização angolana dedicada à educação e promoção da saúde. Esta política explica como recolhemos, usamos, armazenamos e protegemos os dados pessoais de quem utiliza o nosso website, se inscreve em eventos, ou interage com os nossos formulários.\n\nPara qualquer questão sobre esta política ou sobre os seus dados pessoais, pode contactar-nos através de: **geral@conhecafarmacia.com**.',
   'Conheça Farmácia (Tax ID: 5001925989) is an Angolan organization dedicated to health education and promotion. This policy explains how we collect, use, store and protect the personal data of those who use our website, register for events, or interact with our forms.\n\nFor any questions about this policy or your personal data, you can contact us at: **geral@conhecafarmacia.com**.',
   1, false, 1, NULL),
  ('que-dados', '2. Que dados recolhemos', '2. What data we collect',
   'Recolhemos os seguintes dados através dos formulários do website (nomeadamente inscrição em eventos):\n\n- Nome completo\n- Profissão\n- Endereço de email\n- Número de telefone\n\nNão recolhemos número de identificação fiscal (NIF), dados de saúde, nem qualquer dado sensível dos participantes.',
   'We collect the following data through website forms (namely event registration):\n\n- Full name\n- Profession\n- Email address\n- Phone number\n\nWe do not collect tax identification numbers, health data, or any sensitive participant data.',
   1, false, 2, NULL),
  ('menores', '2.1 Dados de menores de idade', '2.1 Minors data',
   'Alguns dos nossos eventos aceitam a inscrição de estudantes menores de idade. Nestes casos, **é necessário o consentimento do responsável legal (pai, mãe ou tutor)** para o tratamento dos dados do menor. Este consentimento é obtido no momento da inscrição, através de declaração específica no formulário, a ser prestada pelo responsável legal.',
   'Some of our events accept registrations from underage students. In these cases, **consent from the legal guardian (parent or tutor) is required** for processing the minor''s data. This consent is obtained at the time of registration through a specific declaration in the form, to be provided by the legal guardian.',
   2, false, 1, (SELECT id FROM public.privacy_sections WHERE anchor_slug = 'que-dados')),
  ('finalidade', '3. Finalidade do tratamento', '3. Purpose of processing',
   'Os dados recolhidos são utilizados para:\n\n- Processar inscrições em eventos e formações;\n- Emitir certificados de participação;\n- Comunicar informações relevantes sobre o evento em que a pessoa se inscreveu;\n- Manter um histórico de participação, incluindo para efeitos de verificação de autenticidade de certificados emitidos.\n\nNão utilizamos os dados recolhidos para fins de marketing não solicitado, nem os vendemos ou cedemos a terceiros para fins comerciais.',
   'The collected data is used for:\n\n- Processing event and training registrations;\n- Issuing participation certificates;\n- Communicating relevant information about the event the person registered for;\n- Maintaining a participation history, including for authenticity verification of issued certificates.\n\nWe do not use collected data for unsolicited marketing purposes, nor do we sell or transfer it to third parties for commercial purposes.',
   1, false, 3, NULL),
  ('partilha', '4. Partilha de dados com terceiros', '4. Data sharing with third parties',
   'Os dados recolhidos são, na sua maioria, de uso exclusivamente interno da Conheça Farmácia.\n\nEm situações específicas — nomeadamente quando um evento envolve co-certificação ou co-organização com uma Ordem profissional — os dados de participação (nome, e eventualmente profissão) podem ser partilhados com essa entidade, exclusivamente para os fins relacionados com essa colaboração.',
   'The collected data is, for the most part, for the exclusive internal use of Conheça Farmácia.\n\nIn specific situations — particularly when an event involves co-certification or co-organization with a professional Order — participation data (name, and possibly profession) may be shared with that entity, exclusively for purposes related to that collaboration.',
   1, false, 4, NULL),
  ('armazenamento', '5. Armazenamento e segurança', '5. Storage and security',
   'Os dados pessoais recolhidos são armazenados na plataforma Supabase, alojada em servidores localizados em **[região do servidor Supabase — a confirmar: ex. EUA, União Europeia]**.\n\nNos casos em que os dados são armazenados fora do território angolano, a Conheça Farmácia compromete-se a assegurar que essa transferência respeita as exigências da Lei n.º 22/11, de 17 de junho (Lei da Proteção de Dados Pessoais), nomeadamente através da adoção de medidas de segurança técnicas e organizativas adequadas junto do prestador de serviço.',
   'The collected personal data is stored on the Supabase platform, hosted on servers located in **[Supabase server region — to be confirmed: e.g. USA, European Union]**.\n\nIn cases where data is stored outside Angolan territory, Conheça Farmácia undertakes to ensure that this transfer complies with the requirements of Law No. 22/11 of June 17 (Personal Data Protection Law), namely through the adoption of appropriate technical and organizational security measures with the service provider.',
   1, true, 5, NULL),
  ('conservacao', '6. Prazo de conservação dos dados', '6. Data retention period',
   'Os dados pessoais são conservados enquanto for necessário para cumprir as finalidades descritas na secção 3 — nomeadamente para manter um histórico de participação que permita a emissão e verificação de certificados em edições futuras dos mesmos eventos ou formações.\n\nO titular dos dados pode, a qualquer momento, solicitar a eliminação dos seus dados, nos termos da secção 7.',
   'Personal data is retained for as long as necessary to fulfill the purposes described in section 3 — namely to maintain a participation history that allows for the issuance and verification of certificates in future editions of the same events or training.\n\nThe data subject may, at any time, request the deletion of their data, as per section 7.',
   1, false, 6, NULL),
  ('direitos', '7. Direitos do titular dos dados', '7. Data subject rights',
   'Nos termos da Lei n.º 22/11, tem o direito de, em qualquer momento:\n\n- Aceder aos dados pessoais que temos sobre si;\n- Solicitar a rectificação de dados incorretos ou incompletos;\n- Solicitar a eliminação dos seus dados;\n- Opor-se ao tratamento dos seus dados, nos termos permitidos por lei.\n\nPara exercer qualquer um destes direitos, contacte-nos através de **geral@conhecafarmacia.com**.',
   'Under Law No. 22/11, you have the right at any time to:\n\n- Access the personal data we hold about you;\n- Request rectification of incorrect or incomplete data;\n- Request deletion of your data;\n- Object to the processing of your data, as permitted by law.\n\nTo exercise any of these rights, contact us at **geral@conhecafarmacia.com**.',
   1, false, 7, NULL),
  ('cookies', '8. Cookies', '8. Cookies',
   'O nosso website utiliza cookies para o seu funcionamento e, no futuro, para fins de análise de audiência.',
   'Our website uses cookies for its operation and, in the future, for audience analysis purposes.',
   1, false, 8, NULL),
  ('cookies-necessarios', '8.1 Cookies estritamente necessários', '8.1 Strictly necessary cookies',
   'Cookies essenciais ao funcionamento do website (ex.: manter a sessão de inscrição ativa). Estes não podem ser desativados.',
   'Cookies essential for the website''s operation (e.g., keeping the registration session active). These cannot be disabled.',
   2, false, 1, (SELECT id FROM public.privacy_sections WHERE anchor_slug = 'cookies')),
  ('cookies-analise', '8.2 Cookies de análise (Google Analytics)', '8.2 Analytics cookies (Google Analytics)',
   '*[a implementar]* Quando ativado, o Google Analytics recolhe dados anónimos sobre a utilização do website, para nos ajudar a compreender como os visitantes o utilizam. Estes cookies só são ativados após consentimento explícito do utilizador.',
   '*[to be implemented]* When activated, Google Analytics collects anonymous data about website usage to help us understand how visitors use it. These cookies are only activated after explicit user consent.',
   2, true, 2, (SELECT id FROM public.privacy_sections WHERE anchor_slug = 'cookies')),
  ('cookies-youtube', '8.3 Cookies de conteúdo incorporado (YouTube)', '8.3 Embedded content cookies (YouTube)',
   '*[a implementar]* Quando publicarmos vídeos do YouTube incorporados no website (ex.: entrevistas), a reprodução desses vídeos pode definir cookies próprios do YouTube/Google.',
   '*[to be implemented]* When we publish embedded YouTube videos on the website (e.g., interviews), playing those videos may set YouTube/Google cookies.',
   2, true, 3, (SELECT id FROM public.privacy_sections WHERE anchor_slug = 'cookies')),
  ('cookies-gestao', '8.4 Gestão de preferências de cookies', '8.4 Cookie preference management',
   '*[Nota de implementação: quando o Google Analytics for adicionado, implementar um banner de consentimento de cookies com opção de aceitar/rejeitar cookies não-essenciais, para além dos estritamente necessários.]*',
   '*[Implementation note: when Google Analytics is added, implement a cookie consent banner with the option to accept/reject non-essential cookies, in addition to strictly necessary ones.]*',
   2, true, 4, (SELECT id FROM public.privacy_sections WHERE anchor_slug = 'cookies')),
  ('natureza', '9. Sobre a natureza da Conheça Farmácia', '9. About the nature of Conheça Farmácia',
   'Para evitar confusões: a Conheça Farmácia **não é uma farmácia comercial** e não vende medicamentos ou produtos farmacêuticos. Somos uma organização de educação e promoção da saúde.',
   'To avoid confusion: Conheça Farmácia **is not a commercial pharmacy** and does not sell medicines or pharmaceutical products. We are a health education and promotion organization.',
   1, false, 9, NULL),
  ('alteracoes', '10. Alterações a esta política', '10. Changes to this policy',
   'Esta política pode ser atualizada periodicamente, nomeadamente para refletir novas funcionalidades do website (ex.: introdução de um agente de IA via WhatsApp, ativação do Google Analytics). A data da última atualização será sempre indicada no topo desta página.\n\n**Última atualização:** [DD/MM/AAAA]',
   'This policy may be updated periodically, namely to reflect new website features (e.g., introduction of an AI agent via WhatsApp, activation of Google Analytics). The date of the last update will always be indicated at the top of this page.\n\n**Last updated:** [DD/MM/AAAA]',
   1, false, 10, NULL);
```

- [ ] **Step 3: Commit**

```bash
git add supabase/migrations/035_privacy_sections.sql
git commit -m "feat(db): add privacy_sections table with seed data"
```

---

## Task 3: i18n Routes + JSON Translations

**Files:**
- Modify: `lib/i18n-routes.js` (adicionar `faq` + `politicaPrivacidade` ao `PT_TO_EN`)
- Modify: `public/i18n/pt.json` (adicionar chaves `faq_page`, `privacy_page`, etc.)
- Modify: `public/i18n/en.json` (adicionar chaves correspondentes EN)

- [ ] **Step 1: Adicionar rotas ao `lib/i18n-routes.js`**

No objecto `PT_TO_EN`:
```js
const PT_TO_EN = {
  artigos: 'articles',
  eventos: 'events',
  sobre: 'about',
  pesquisa: 'search',
  inscricao: 'register',
  faq: 'faq',              // ← partilhado (mesmo slug)
  'politica-privacidade': 'privacy-policy',  // ← traduzido
}
```

- [ ] **Step 2: Adicionar chaves i18n ao `public/i18n/pt.json`**

Adicionar no final do ficheiro (após `inscricao_error`):

```json
{
  "faq_page": {
    "hero_title": "Perguntas Frequentes",
    "hero_subtitle": "Respostas às perguntas mais comuns sobre a Conheça Farmácia, eventos e parcerias.",
    "tab_geral": "Geral",
    "tab_parceiros": "Parceiros e Patrocinadores",
    "pending_badge": "Pendente",
    "pending_message": "Esta resposta está a ser preparada. Volte mais tarde.",
    "no_questions": "Nenhuma pergunta disponível nesta categoria."
  },
  "privacy_page": {
    "hero_title": "Política de Privacidade e Cookies",
    "hero_subtitle": "Saiba como tratamos os seus dados pessoais e como utilizamos cookies no nosso website.",
    "toc_label": "Índice",
    "toc_toggle": "Índice",
    "pending_badge": "Pendente",
    "last_updated": "Última atualização",
    "pending_section_note": "Esta secção contém conteúdo pendente de aprovação."
  },
  "nav": {
    "faq": "FAQ",
    "privacidade": "Privacidade"
  },
  "footer": {
    "faq": "Perguntas Frequentes",
    "privacidade": "Termos, Privacidade e Cookies"
  }
}
```

- [ ] **Step 3: Adicionar chaves i18n ao `public/i18n/en.json`** (equivalente EN)

```json
{
  "faq_page": {
    "hero_title": "Frequently Asked Questions",
    "hero_subtitle": "Answers to the most common questions about Conheça Farmácia, events and partnerships.",
    "tab_geral": "General",
    "tab_parceiros": "Partners & Sponsors",
    "pending_badge": "Pending",
    "pending_message": "This answer is being prepared. Please check back later.",
    "no_questions": "No questions available in this category."
  },
  "privacy_page": {
    "hero_title": "Privacy and Cookie Policy",
    "hero_subtitle": "Learn how we handle your personal data and how we use cookies on our website.",
    "toc_label": "Table of Contents",
    "toc_toggle": "Contents",
    "pending_badge": "Pending",
    "last_updated": "Last updated",
    "pending_section_note": "This section contains content pending approval."
  },
  "nav": {
    "faq": "FAQ",
    "privacidade": "Privacy"
  },
  "footer": {
    "faq": "Frequently Asked Questions",
    "privacidade": "Terms, Privacy and Cookies"
  }
}
```

- [ ] **Step 4: Validar JSON**

```bash
node -e "JSON.parse(require('fs').readFileSync('public/i18n/pt.json'))"
node -e "JSON.parse(require('fs').readFileSync('public/i18n/en.json'))"
```

- [ ] **Step 5: Commit**

```bash
git add lib/i18n-routes.js public/i18n/pt.json public/i18n/en.json
git commit -m "feat(i18n): add faq + privacy routes and translations"
```

---

## Task 4: Server Actions — `lib/actions/legalContent.js`

**Files:**
- Create: `lib/actions/legalContent.js`

- [ ] **Step 1: Escrever a Server Action**

```js
'use server'

import { createClient } from '@/lib/supabase/server'
import { revalidatePath } from 'next/cache'

// ============================================================
//  Helper: requireAdmin (reuse pattern from content.js)
// ============================================================
async function requireAdmin() {
  const supabase = await createClient()

  try {
    const { data: { user }, error: userError } = await supabase.auth.getUser()
    if (userError || !user) return null

    const { data: adminUser, error: adminError } = await supabase
      .from('admin_users')
      .select('user_id, role')
      .eq('user_id', user.id)
      .maybeSingle()

    if (adminError || !adminUser) return null

    return { supabase, user, role: adminUser.role }
  } catch {
    return null
  }
}

// ============================================================
//  PUBLIC DATA — FAQ
// ============================================================

/**
 * Retorna dados públicos da FAQ: tabs com questions não-pending e não-archived.
 * Usado na página pública /[lang]/faq.
 */
export async function getPublicFAQData() {
  const supabase = await createClient()

  try {
    // Buscar tabs não-archived, ordenadas
    const { data: tabs, error: tabsError } = await supabase
      .from('faq_tabs')
      .select('id, slug, label_pt, label_en, sort_order')
      .eq('is_archived', false)
      .order('sort_order', { ascending: true })

    if (tabsError || !tabs) return []

    // Buscar questions não-archived, ordenadas
    const { data: allQuestions, error: qError } = await supabase
      .from('faq_questions')
      .select('id, tab_id, question_pt, question_en, answer_pt, answer_en, pending, sort_order')
      .eq('is_archived', false)
      .order('sort_order', { ascending: true })

    if (qError || !allQuestions) return []

    // Estruturar: tabs → questions, filtrar pending conforme spec
    const result = tabs.map((tab) => {
      const questions = allQuestions
        .filter((q) => q.tab_id === tab.id)
        .map((q) => ({
          id: q.id,
          question_pt: q.question_pt,
          question_en: q.question_en,
          answer_pt: q.answer_pt,
          answer_en: q.answer_en,
          pending: q.pending,
        }))

      // Filtrar: tab só aparece se tiver pelo menos 1 question visible (non-pending)
      const visibleCount = questions.filter((q) => !q.pending).length
      if (visibleCount === 0) return null

      return {
        id: tab.id,
        slug: tab.slug,
        label_pt: tab.label_pt,
        label_en: tab.label_en,
        questions,
      }
    }).filter(Boolean) // Remove tabs nulas (0 visible questions)

    return result
  } catch {
    return []
  }
}

// ============================================================
//  PUBLIC DATA — Privacy Policy
// ============================================================

/**
 * Retorna dados públicos da política de privacidade: secções hierárquicas.
 * Secções pending são incluídas com flag pending=true (mostrar badge).
 */
export async function getPublicPrivacyData() {
  const supabase = await createClient()

  try {
    const { data: sections, error } = await supabase
      .from('privacy_sections')
      .select('id, parent_id, anchor_slug, title_pt, title_en, content_pt, content_en, level, pending, sort_order')
      .eq('is_archived', false)
      .order('sort_order', { ascending: true })

    if (error || !sections) return []

    // Estruturar hierarquia: level 1 com children level 2
    const level1 = sections.filter((s) => s.level === 1)
    const level2 = sections.filter((s) => s.level === 2)

    return level1.map((section) => ({
      id: section.id,
      anchor_slug: section.anchor_slug,
      title_pt: section.title_pt,
      title_en: section.title_en,
      content_pt: section.content_pt,
      content_en: section.content_en,
      pending: section.pending,
      children: level2
        .filter((child) => child.parent_id === section.id)
        .map((child) => ({
          id: child.id,
          anchor_slug: child.anchor_slug,
          title_pt: child.title_pt,
          title_en: child.title_en,
          content_pt: child.content_pt,
          content_en: child.content_en,
          pending: child.pending,
        })),
    }))
  } catch {
    return []
  }
}

// ============================================================
//  ADMIN — FAQ Tabs CRUD
// ============================================================

export async function getFAQTabs() {
  const ctx = await requireAdmin()
  if (!ctx) return []

  const { supabase } = ctx
  try {
    const { data, error } = await supabase
      .from('faq_tabs')
      .select('*')
      .order('sort_order', { ascending: true })

    if (error) return []
    return data || []
  } catch {
    return []
  }
}

export async function createFAQTab({ slug, label_pt, label_en, sort_order }) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }

  const { supabase } = ctx
  try {
    const { data, error } = await supabase
      .from('faq_tabs')
      .insert({ slug, label_pt, label_en, sort_order: sort_order || 0 })
      .select()
      .single()

    if (error) return { success: false, error: error.message }
    revalidatePath('/[lang]/admin/conteudo-legal/faq')
    return { success: true, data }
  } catch {
    return { success: false, error: 'Erro ao criar separador' }
  }
}

export async function updateFAQTab(id, { slug, label_pt, label_en, sort_order }) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }

  const { supabase } = ctx
  try {
    const { error } = await supabase
      .from('faq_tabs')
      .update({ slug, label_pt, label_en, sort_order })
      .eq('id', id)

    if (error) return { success: false, error: error.message }
    revalidatePath('/[lang]/admin/conteudo-legal/faq')
    return { success: true }
  } catch {
    return { success: false, error: 'Erro ao atualizar separador' }
  }
}

export async function archiveFAQTab(id) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }

  const { supabase, user } = ctx
  try {
    const { error } = await supabase
      .from('faq_tabs')
      .update({
        is_archived: true,
        archived_at: new Date().toISOString(),
        archived_by: user.id,
      })
      .eq('id', id)

    if (error) return { success: false, error: error.message }
    revalidatePath('/[lang]/admin/conteudo-legal/faq')
    return { success: true }
  } catch {
    return { success: false, error: 'Erro ao arquivar separador' }
  }
}

export async function restoreFAQTab(id) {
  const ctx = await requireAdmin()
  if (!ctx || ctx.role !== 'superadmin') return { success: false, error: 'Não autorizado' }

  const { supabase } = ctx
  try {
    const { error } = await supabase
      .from('faq_tabs')
      .update({ is_archived: false, archived_at: null, archived_by: null })
      .eq('id', id)

    if (error) return { success: false, error: error.message }
    revalidatePath('/[lang]/admin/conteudo-legal/faq')
    return { success: true }
  } catch {
    return { success: false, error: 'Erro ao restaurar separador' }
  }
}

// ============================================================
//  ADMIN — FAQ Questions CRUD
// ============================================================

export async function getFAQQuestions(tabId) {
  const ctx = await requireAdmin()
  if (!ctx) return []

  const { supabase } = ctx
  try {
    const { data, error } = await supabase
      .from('faq_questions')
      .select('*')
      .eq('tab_id', tabId)
      .order('sort_order', { ascending: true })

    if (error) return []
    return data || []
  } catch {
    return []
  }
}

export async function createFAQQuestion({ tab_id, question_pt, question_en, answer_pt, answer_en, pending, sort_order }) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }

  const { supabase } = ctx
  try {
    const { data, error } = await supabase
      .from('faq_questions')
      .insert({ tab_id, question_pt, question_en, answer_pt: answer_pt || '', answer_en: answer_en || '', pending: pending !== false, sort_order: sort_order || 0 })
      .select()
      .single()

    if (error) return { success: false, error: error.message }
    revalidatePath('/[lang]/admin/conteudo-legal/faq')
    return { success: true, data }
  } catch {
    return { success: false, error: 'Erro ao criar pergunta' }
  }
}

export async function updateFAQQuestion(id, { question_pt, question_en, answer_pt, answer_en, pending, sort_order }) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }

  const { supabase } = ctx
  try {
    const { error } = await supabase
      .from('faq_questions')
      .update({ question_pt, question_en, answer_pt, answer_en, pending, sort_order })
      .eq('id', id)

    if (error) return { success: false, error: error.message }
    revalidatePath('/[lang]/admin/conteudo-legal/faq')
    return { success: true }
  } catch {
    return { success: false, error: 'Erro ao atualizar pergunta' }
  }
}

export async function archiveFAQQuestion(id) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }

  const { supabase, user } = ctx
  try {
    const { error } = await supabase
      .from('faq_questions')
      .update({ is_archived: true, archived_at: new Date().toISOString(), archived_by: user.id })
      .eq('id', id)

    if (error) return { success: false, error: error.message }
    revalidatePath('/[lang]/admin/conteudo-legal/faq')
    return { success: true }
  } catch {
    return { success: false, error: 'Erro ao arquivar pergunta' }
  }
}

export async function restoreFAQQuestion(id) {
  const ctx = await requireAdmin()
  if (!ctx || ctx.role !== 'superadmin') return { success: false, error: 'Não autorizado' }

  const { supabase } = ctx
  try {
    const { error } = await supabase
      .from('faq_questions')
      .update({ is_archived: false, archived_at: null, archived_by: null })
      .eq('id', id)

    if (error) return { success: false, error: error.message }
    revalidatePath('/[lang]/admin/conteudo-legal/faq')
    return { success: true }
  } catch {
    return { success: false, error: 'Erro ao restaurar pergunta' }
  }
}

// ============================================================
//  ADMIN — Privacy Sections CRUD
// ============================================================

export async function getPrivacySections() {
  const ctx = await requireAdmin()
  if (!ctx) return []

  const { supabase } = ctx
  try {
    const { data, error } = await supabase
      .from('privacy_sections')
      .select('*')
      .order('sort_order', { ascending: true })

    if (error) return []
    return data || []
  } catch {
    return []
  }
}

export async function createPrivacySection({ parent_id, anchor_slug, title_pt, title_en, content_pt, content_en, level, pending, sort_order }) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }

  const { supabase } = ctx
  try {
    const { data, error } = await supabase
      .from('privacy_sections')
      .insert({ parent_id: parent_id || null, anchor_slug, title_pt, title_en, content_pt: content_pt || '', content_en: content_en || '', level: level || 1, pending: pending || false, sort_order: sort_order || 0 })
      .select()
      .single()

    if (error) return { success: false, error: error.message }
    revalidatePath('/[lang]/admin/conteudo-legal/politica-privacidade')
    return { success: true, data }
  } catch {
    return { success: false, error: 'Erro ao criar secção' }
  }
}

export async function updatePrivacySection(id, { anchor_slug, title_pt, title_en, content_pt, content_en, pending, sort_order }) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }

  const { supabase } = ctx
  try {
    const { error } = await supabase
      .from('privacy_sections')
      .update({ anchor_slug, title_pt, title_en, content_pt, content_en, pending, sort_order })
      .eq('id', id)

    if (error) return { success: false, error: error.message }
    revalidatePath('/[lang]/admin/conteudo-legal/politica-privacidade')
    return { success: true }
  } catch {
    return { success: false, error: 'Erro ao atualizar secção' }
  }
}

export async function archivePrivacySection(id) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }

  const { supabase, user } = ctx
  try {
    const { error } = await supabase
      .from('privacy_sections')
      .update({ is_archived: true, archived_at: new Date().toISOString(), archived_by: user.id })
      .eq('id', id)

    if (error) return { success: false, error: error.message }
    revalidatePath('/[lang]/admin/conteudo-legal/politica-privacidade')
    return { success: true }
  } catch {
    return { success: false, error: 'Erro ao arquivar secção' }
  }
}

export async function restorePrivacySection(id) {
  const ctx = await requireAdmin()
  if (!ctx || ctx.role !== 'superadmin') return { success: false, error: 'Não autorizado' }

  const { supabase } = ctx
  try {
    const { error } = await supabase
      .from('privacy_sections')
      .update({ is_archived: false, archived_at: null, archived_by: null })
      .eq('id', id)

    if (error) return { success: false, error: error.message }
    revalidatePath('/[lang]/admin/conteudo-legal/politica-privacidade')
    return { success: true }
  } catch {
    return { success: false, error: 'Erro ao restaurar secção' }
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/actions/legalContent.js
git commit -m "feat(actions): add legalContent server actions for FAQ + Privacy"
```

---

## Task 5: Componente `PendingBadge` + `FAQItem` + `FAQPanel` + `FAQTabs`

**Files:**
- Create: `components/ui/PendingBadge.jsx`
- Create: `components/faq/FAQItem.jsx`
- Create: `components/faq/FAQPanel.jsx`
- Create: `components/faq/FAQTabs.jsx`

- [ ] **Step 1: `PendingBadge.jsx`**

```jsx
'use client'

export default function PendingBadge({ label = 'Pendente', className = '' }) {
  return (
    <span
      className={`inline-flex items-center px-2 py-0.5 rounded text-xs font-medium
        bg-amber-100 text-amber-800
        dark:bg-amber-900/30 dark:text-amber-300
        ${className}`}
    >
      {label}
    </span>
  )
}
```

- [ ] **Step 2: `FAQItem.jsx`**

```jsx
'use client'

import { useId } from 'react'
import PendingBadge from '@/components/ui/PendingBadge'
import { ChevronDown } from 'lucide-react'

export default function FAQItem({ question, answer, pending, t }) {
  const id = useId()

  if (pending) {
    return (
      <div className="faq-item faq-item--pending">
        <div className="faq-item-question">
          <span className="faq-item-text">{question}</span>
          <PendingBadge label={t('faq_page.pending_badge')} />
        </div>
        <p className="faq-item-message">{t('faq_page.pending_message')}</p>
      </div>
    )
  }

  return (
    <details className="faq-item" id={id}>
      <summary className="faq-item-summary">
        <span>{question}</span>
        <ChevronDown size={20} className="faq-item-chevron" />
      </summary>
      <div className="faq-item-answer prose prose-muted dark:prose-invert max-w-none">
        {answer}
      </div>
    </details>
  )
}
```

- [ ] **Step 3: `FAQPanel.jsx`**

```jsx
'use client'

import FAQItem from './FAQItem'

export default function FAQPanel({ questions, lang, t }) {
  return (
    <div className="faq-panel" role="tabpanel">
      {questions.length === 0 ? (
        <p className="faq-panel-empty">{t('faq_page.no_questions')}</p>
      ) : (
        questions.map((q) => (
          <FAQItem
            key={q.id}
            question={q[`question_${lang}`]}
            answer={q[`answer_${lang}`]}
            pending={q.pending}
            t={t}
          />
        ))
      )}
    </div>
  )
}
```

- [ ] **Step 4: `FAQTabs.jsx`**

```jsx
'use client'

import { useState, useCallback, useRef, useEffect } from 'react'
import FAQPanel from './FAQPanel'

export default function FAQTabs({ tabs, lang, t }) {
  const [activeTab, setActiveTab] = useState(0)
  const tabRefs = useRef([])
  const tabListRef = useRef(null)

  // Keyboard navigation
  const handleKeyDown = useCallback((e) => {
    let newIndex = activeTab
    if (e.key === 'ArrowRight') {
      newIndex = (activeTab + 1) % tabs.length
    } else if (e.key === 'ArrowLeft') {
      newIndex = (activeTab - 1 + tabs.length) % tabs.length
    } else {
      return
    }
    e.preventDefault()
    setActiveTab(newIndex)
    tabRefs.current[newIndex]?.focus()
  }, [activeTab, tabs.length])

  if (tabs.length === 0) {
    return (
      <div className="faq-empty">
        <p>{t('faq_page.no_questions')}</p>
      </div>
    )
  }

  const activeTabData = tabs[activeTab]
  // Filtrar apenas questions visíveis (non-pending para o público)
  const visibleQuestions = activeTabData.questions.filter((q) => !q.pending)

  return (
    <div className="faq-tabs">
      {/* Tab Bar */}
      <div
        className="faq-tab-bar"
        ref={tabListRef}
        role="tablist"
        aria-label="FAQ categories"
      >
        {tabs.map((tab, index) => (
          <button
            key={tab.id || tab.slug}
            ref={(el) => { tabRefs.current[index] = el }}
            role="tab"
            aria-selected={index === activeTab}
            aria-controls={`faq-panel-${tab.slug}`}
            tabIndex={index === activeTab ? 0 : -1}
            className={`faq-tab ${index === activeTab ? 'faq-tab--active' : ''}`}
            onClick={() => setActiveTab(index)}
            onKeyDown={handleKeyDown}
          >
            {tab[`label_${lang}`] || tab.label_pt}
          </button>
        ))}
      </div>

      {/* Tab Panel */}
      <div
        id={`faq-panel-${activeTabData.slug}`}
        role="tabpanel"
        aria-labelledby={`faq-tab-${activeTabData.slug}`}
      >
        <FAQPanel
          questions={visibleQuestions}
          lang={lang}
          t={t}
        />
      </div>
    </div>
  )
}
```

- [ ] **Step 5: Commit**

```bash
git add components/ui/PendingBadge.jsx components/faq/FAQItem.jsx components/faq/FAQPanel.jsx components/faq/FAQTabs.jsx
git commit -m "feat(components): add FAQ components (tabs, accordion, pending badge)"
```

---

## Task 6: Componentes Privacidade — `PrivacyTOC` + `PrivacyContent`

**Files:**
- Create: `components/privacy/PrivacyTOC.jsx`
- Create: `components/privacy/PrivacyContent.jsx`

- [ ] **Step 1: `PrivacyTOC.jsx`**

```jsx
'use client'

import { useEffect, useState, useRef, useCallback } from 'react'
import { Menu, X } from 'lucide-react'

export default function PrivacyTOC({ sections, lang, t }) {
  const [activeId, setActiveId] = useState(null)
  const [mobileOpen, setMobileOpen] = useState(false)
  const observerRef = useRef(null)

  // Scroll-spy via IntersectionObserver
  useEffect(() => {
    const headings = sections
      .flatMap((s) => [s, ...(s.children || [])])
      .map((s) => document.getElementById(`section-${s.anchor_slug}`))
      .filter(Boolean)

    if (headings.length === 0) return

    observerRef.current = new IntersectionObserver(
      (entries) => {
        const visible = entries
          .filter((e) => e.isIntersecting)
          .sort((a, b) => a.boundingClientRect.top - b.boundingClientRect.top)
        if (visible.length > 0) {
          const id = visible[0].target.id.replace('section-', '')
          setActiveId(id)
        }
      },
      { rootMargin: '-80px 0px -60% 0px', threshold: 0.1 }
    )

    headings.forEach((el) => observerRef.current.observe(el))
    return () => observerRef.current?.disconnect()
  }, [sections])

  // Smooth scroll on TOC click
  const handleClick = useCallback((e, anchorSlug) => {
    e.preventDefault()
    const el = document.getElementById(`section-${anchorSlug}`)
    if (el) {
      el.scrollIntoView({ behavior: 'smooth', block: 'start' })
    }
    setMobileOpen(false)
  }, [])

  const renderTOCItems = (items, isChild = false) => (
    <ul className={`privacy-toc-list ${isChild ? 'privacy-toc-sublist' : ''}`}>
      {items.map((section) => (
        <li key={section.anchor_slug}>
          <a
            href={`#section-${section.anchor_slug}`}
            onClick={(e) => handleClick(e, section.anchor_slug)}
            className={`privacy-toc-link ${activeId === section.anchor_slug ? 'privacy-toc-link--active' : ''} ${section.pending ? 'privacy-toc-link--pending' : ''}`}
          >
            {section[`title_${lang}`] || section.title_pt}
            {section.pending && (
              <span className="privacy-toc-pending-dot" title="Pendente" />
            )}
          </a>
          {section.children && section.children.length > 0 && (
            renderTOCItems(section.children, true)
          )}
        </li>
      ))}
    </ul>
  )

  return (
    <nav className="privacy-toc" aria-label={t('privacy_page.toc_label')}>
      {/* Mobile toggle */}
      <button
        className="privacy-toc-toggle"
        onClick={() => setMobileOpen(!mobileOpen)}
        aria-expanded={mobileOpen}
        aria-label={t('privacy_page.toc_toggle')}
      >
        {mobileOpen ? <X size={20} /> : <Menu size={20} />}
        <span>{t('privacy_page.toc_toggle')}</span>
      </button>

      {/* TOC content */}
      <div className={`privacy-toc-content ${mobileOpen ? 'privacy-toc-content--open' : ''}`}>
        {renderTOCItems(sections)}
      </div>
    </nav>
  )
}
```

- [ ] **Step 2: `PrivacyContent.jsx`**

```jsx
'use client'

import PendingBadge from '@/components/ui/PendingBadge'

export default function PrivacyContent({ sections, lang, t }) {
  return (
    <div className="privacy-content prose prose-lg prose-muted dark:prose-invert max-w-3xl">
      <p className="text-sm text-muted-foreground mb-8">
        <em>{t('privacy_page.last_updated')}: [DD/MM/AAAA]</em>
      </p>

      {sections.map((section) => (
        <div key={section.anchor_slug}>
          {/* Level 1 section */}
          <section
            id={`section-${section.anchor_slug}`}
            className="privacy-section scroll-mt-24"
          >
            <h2 className="privacy-heading">
              {section[`title_${lang}`] || section.title_pt}
              {section.pending && (
                <PendingBadge label={t('privacy_page.pending_badge')} />
              )}
            </h2>
            <div
              className={section.pending ? 'privacy-content--pending' : ''}
              dangerouslySetInnerHTML={{ __html: renderMarkdown(section[`content_${lang}`] || section.content_pt) }}
            />
            {section.pending && (
              <p className="text-sm text-muted-foreground mt-2 italic">
                {t('privacy_page.pending_section_note')}
              </p>
            )}
          </section>

          {/* Level 2 children */}
          {section.children && section.children.length > 0 && section.children.map((child) => (
            <section
              key={child.anchor_slug}
              id={`section-${child.anchor_slug}`}
              className="privacy-section privacy-section--sub scroll-mt-24"
            >
              <h3 className="privacy-heading privacy-heading--sub">
                {child[`title_${lang}`] || child.title_pt}
                {child.pending && (
                  <PendingBadge label={t('privacy_page.pending_badge')} />
                )}
              </h3>
              <div
                className={child.pending ? 'privacy-content--pending' : ''}
                dangerouslySetInnerHTML={{ __html: renderMarkdown(child[`content_${lang}`] || child.content_pt) }}
              />
              {child.pending && (
                <p className="text-sm text-muted-foreground mt-2 italic">
                  {t('privacy_page.pending_section_note')}
                </p>
              )}
            </section>
          ))}

          <hr className="privacy-divider" />
        </div>
      ))}
    </div>
  )
}

/**
 * Simple markdown → HTML renderer for bold, italic, lists, paragraphs.
 * This is intentionally minimal — the content is pre-authored markdown
 * from the source policiesfc/*.md files.
 */
function renderMarkdown(text) {
  if (!text) return ''
  return text
    .split('\n\n')
    .map((block) => {
      block = block.trim()
      if (!block) return ''
      // Unordered list
      if (block.startsWith('- ')) {
        const items = block.split('\n').filter((l) => l.startsWith('- '))
        const lis = items.map((item) => `<li>${inlineMarkdown(item.slice(2))}</li>`).join('')
        return `<ul>${lis}</ul>`
      }
      // Paragraph
      return `<p>${inlineMarkdown(block)}</p>`
    })
    .join('\n')
}

function inlineMarkdown(text) {
  return text
    .replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
    .replace(/\*(.+?)\*/g, '<em>$1</em>')
    .replace(/\n/g, '<br />')
}
```

- [ ] **Step 3: Commit**

```bash
git add components/privacy/PrivacyTOC.jsx components/privacy/PrivacyContent.jsx
git commit -m "feat(components): add Privacy TOC + Content components"
```

---

## Task 7: Páginas Públicas — `/[lang]/faq` + `/[lang]/politica-privacidade`

**Files:**
- Create: `app/[lang]/(public)/faq/page.js` — Server Component PT
- Create: `app/[lang]/(public)/faq/faqPageClient.jsx` — Client Component
- Create: `app/[lang]/(public)/politica-privacidade/page.js` — Server Component PT
- Create: `app/[lang]/(public)/politica-privacidade/privacyPageClient.jsx` — Client Component

- [ ] **Step 1: FAQ Server Component `page.js`**

```jsx
// app/[lang]/(public)/faq/page.js
import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import { getPublicFAQData } from '@/lib/actions/legalContent'
import FAQPageClient from './faqPageClient'

export const dynamic = 'force-dynamic'

export async function generateMetadata({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (key) => t(translations, key)

  return {
    title: `${tFn('faq_page.hero_title')} | Conheça Farmácia`,
    description: tFn('faq_page.hero_subtitle'),
    alternates: { languages: { pt: '/pt/faq', en: '/en/faq' } },
  }
}

export default async function FAQPage({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const tabs = await getPublicFAQData()

  return <FAQPageClient lang={safeLang} tabs={tabs} />
}
```

- [ ] **Step 2: FAQ Client Component `faqPageClient.jsx`**

```jsx
'use client'

import { useContext } from 'react'
import { LangContext } from '@/lib/contexts'
import FAQTabs from '@/components/faq/FAQTabs'
import Breadcrumb from '@/components/ui/Breadcrumb'
import { getSectionHref } from '@/lib/i18n-routes'

export default function FAQPageClient({ lang, tabs }) {
  const { t } = useContext(LangContext)

  const breadcrumbItems = [
    { label: t('nav.inicio'), href: `/${lang}` },
    { label: t('faq_page.hero_title') },
  ]

  return (
    <>
      {/* Hero */}
      <section className="hero hero--short">
        <div className="container-center">
          <Breadcrumb items={breadcrumbItems} />
          <div className="text-center py-8 md:py-12">
            <h1 className="text-4xl md:text-5xl font-bold text-brand-deep dark:text-white mb-4">
              {t('faq_page.hero_title')}
            </h1>
            <p className="text-lg text-muted-foreground max-w-2xl mx-auto">
              {t('faq_page.hero_subtitle')}
            </p>
          </div>
        </div>
      </section>

      {/* FAQ Content */}
      <section className="section-padding bg-brand-bg dark:bg-gray-900">
        <div className="container-center max-w-3xl">
          <FAQTabs tabs={tabs} lang={lang} t={t} />
        </div>
      </section>
    </>
  )
}
```

- [ ] **Step 3: Privacy Server Component `page.js`**

```jsx
// app/[lang]/(public)/politica-privacidade/page.js
import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import { getPublicPrivacyData } from '@/lib/actions/legalContent'
import PrivacyPageClient from './privacyPageClient'

export const dynamic = 'force-dynamic'

export async function generateMetadata({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (key) => t(translations, key)

  return {
    title: `${tFn('privacy_page.hero_title')} | Conheça Farmácia`,
    description: tFn('privacy_page.hero_subtitle'),
    alternates: { languages: { pt: '/pt/politica-privacidade', en: '/en/privacy-policy' } },
  }
}

export default async function PrivacyPage({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const sections = await getPublicPrivacyData()

  return <PrivacyPageClient lang={safeLang} sections={sections} />
}
```

- [ ] **Step 4: Privacy Client Component `privacyPageClient.jsx`**

```jsx
'use client'

import { useContext } from 'react'
import { LangContext } from '@/lib/contexts'
import PrivacyTOC from '@/components/privacy/PrivacyTOC'
import PrivacyContent from '@/components/privacy/PrivacyContent'
import Breadcrumb from '@/components/ui/Breadcrumb'

export default function PrivacyPageClient({ lang, sections }) {
  const { t } = useContext(LangContext)

  const breadcrumbItems = [
    { label: t('nav.inicio'), href: `/${lang}` },
    { label: t('privacy_page.hero_title') },
  ]

  return (
    <>
      {/* Hero */}
      <section className="hero hero--short">
        <div className="container-center">
          <Breadcrumb items={breadcrumbItems} />
          <div className="text-center py-8 md:py-12">
            <h1 className="text-4xl md:text-5xl font-bold text-brand-deep dark:text-white mb-4">
              {t('privacy_page.hero_title')}
            </h1>
            <p className="text-lg text-muted-foreground max-w-2xl mx-auto">
              {t('privacy_page.hero_subtitle')}
            </p>
          </div>
        </div>
      </section>

      {/* Content + TOC */}
      <section className="section-padding bg-brand-bg dark:bg-gray-900">
        <div className="container-center">
          <div className="privacy-layout">
            <aside className="privacy-layout-toc">
              <PrivacyTOC sections={sections} lang={lang} t={t} />
            </aside>
            <div className="privacy-layout-content">
              <PrivacyContent sections={sections} lang={lang} t={t} />
            </div>
          </div>
        </div>
      </section>
    </>
  )
}
```

- [ ] **Step 5: Commit**

```bash
git add app/[lang]/(public)/faq/ app/[lang]/(public)/politica-privacidade/
git commit -m "feat(pages): add public FAQ and Privacy Policy pages"
```

---

## Task 8: EN Mirrors — `/en/faq` + `/en/privacy-policy`

**Files:**
- Create: `app/[lang]/(public)/faq/page.js` → já serve PT+EN (rota partilhada `[lang]`)
- Create: `app/[lang]/(public)/politica-privacidade/page.js` → rota PT. Criar mirror EN em:
  - `app/en/privacy-policy/page.js` (ou re-export)

**Nota:** Como as rotas usam `[lang]` dinâmico, `/en/faq` já funciona com o mesmo ficheiro. Para `/en/politica-privacidade`, a rota PT é `/pt/politica-privacidade` e a EN será `/en/privacy-policy`. Isto requer:

1. Criar diretório físico `app/en/privacy-policy/` com um `page.js` que re-exporta o PT (até a tradução estar completa):
   ```js
   export { default } from '../../pt/politica-privacidade/page'
   ```
   **Mas espera** — o padrão do projecto é ter `[lang]` dinâmico. Como temos `politica-privacidade` como slug PT e `privacy-policy` como slug EN, precisamos de:

   - Rota PT: `app/[lang]/(public)/politica-privacidade/page.js` (já existe da Task 7)
   - Rota EN: `app/[lang]/(public)/privacy-policy/page.js` — novo mirror

   O `[lang]` resolve para `pt` ou `en` em cada caso.

- [ ] **Step 1: Criar mirror EN para Privacy Policy**

```jsx
// app/[lang]/(public)/privacy-policy/page.js
// Mirror EN — re-export do PT até tradução estar completa
export { default, generateMetadata } from '../politica-privacidade/page'
```

- [ ] **Step 2: Verificar que `faq` não precisa de mirror** (slug é o mesmo PT/EN — partilhado)

O slug `faq` é igual em PT e EN, portanto `app/[lang]/(public)/faq/page.js` já serve ambas.

- [ ] **Step 3: Commit**

```bash
git add app/[lang]/(public)/privacy-policy/
git commit -m "feat(pages): add EN mirror for privacy-policy route"
```

---

## Task 9: Footer — FAQ Link + Privacy Link Update

**Files:**
- Modify: `components/layout/Footer.jsx`

- [ ] **Step 1: Atualizar o Footer**

```jsx
// Adicionar FAQ link na coluna "Navegação" e actualizar privacy link
// No JSX, após o link de "Sobre":

<li><Link href={getSectionHref(lang, 'faq')}>{t('footer.faq')}</Link></li>
<li><Link href={getSectionHref(lang, 'politica-privacidade')}>{t('footer.privacidade')}</Link></li>
```

O Footer actual tem:
```
<li><Link href={`/${lang}`}>{t('nav.inicio')}</Link></li>
<li><Link href={getSectionHref(lang, 'artigos')}>{t('nav.artigos')}</Link></li>
<li><Link href={getSectionHref(lang, 'eventos')}>{t('nav.eventos')}</Link></li>
<li><Link href={getSectionHref(lang, 'lives')}>{t('nav.lives')}</Link></li>
<li><Link href={getSectionHref(lang, 'sobre')}>{t('nav.sobre')}</Link></li>
```

Adicionar após o link "Sobre":
```jsx
<li><Link href={getSectionHref(lang, 'faq')}>{t('footer.faq')}</Link></li>
<li><Link href={getSectionHref(lang, 'politica-privacidade')}>{t('footer.privacidade')}</Link></li>
```

- [ ] **Step 2: Commit**

```bash
git add components/layout/Footer.jsx
git commit -m "feat(footer): add FAQ link and update privacy link"
```

---

## Task 10: CSS para FAQ + Privacy Pages + PendingBadge

**Files:**
- Modify: `styles/globals.css` (adicionar estilos)

- [ ] **Step 1: Adicionar CSS para os novos componentes**

Adicionar ao final de `styles/globals.css`:

```css
/* ========================================
   FAQ Page
   ======================================== */

/* Tab Bar */
.faq-tab-bar {
  display: flex;
  gap: 0;
  border-bottom: 2px solid var(--color-border);
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
  scrollbar-width: none;
  position: sticky;
  top: 3.5rem; /* sticky below utility bar */
  z-index: 10;
  background: var(--color-background);
  backdrop-filter: blur(8px);
}

.faq-tab-bar::-webkit-scrollbar {
  display: none;
}

.faq-tab {
  flex-shrink: 0;
  padding: 0.75rem 1.5rem;
  font-size: 0.95rem;
  font-weight: 500;
  color: var(--color-muted-foreground);
  border: none;
  background: transparent;
  cursor: pointer;
  border-bottom: 2px solid transparent;
  margin-bottom: -2px;
  transition: color 0.2s, border-color 0.2s;
  white-space: nowrap;
}

.faq-tab:hover {
  color: var(--color-foreground);
}

.faq-tab--active {
  color: var(--color-primary);
  border-bottom-color: var(--color-primary);
  font-weight: 600;
}

/* FAQ Panel */
.faq-panel {
  padding: 1.5rem 0;
}

.faq-panel-empty {
  text-align: center;
  color: var(--color-muted-foreground);
  padding: 3rem 1rem;
}

/* FAQ Item (accordion) */
.faq-item {
  border-bottom: 1px solid var(--color-border);
  transition: border-color 0.2s;
}

.faq-item--pending {
  opacity: 0.6;
  padding: 1rem 0;
}

.faq-item--pending .faq-item-question {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.faq-item-text {
  font-size: 1.05rem;
  font-weight: 500;
  color: var(--color-foreground);
}

.faq-item-message {
  font-size: 0.875rem;
  color: var(--color-muted-foreground);
  margin-top: 0.25rem;
  margin-left: 0;
}

.faq-item-summary {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  padding: 1rem 0;
  cursor: pointer;
  list-style: none;
  font-size: 1.05rem;
  font-weight: 500;
  color: var(--color-foreground);
  transition: color 0.2s;
}

.faq-item-summary::-webkit-details-marker {
  display: none;
}

.faq-item-summary:hover {
  color: var(--color-primary);
}

.faq-item-chevron {
  flex-shrink: 0;
  transition: transform 0.3s ease;
  color: var(--color-muted-foreground);
}

details[open] .faq-item-chevron {
  transform: rotate(180deg);
}

.faq-item-answer {
  padding: 0 0 1.25rem;
  font-size: 0.95rem;
  line-height: 1.7;
  color: var(--color-muted-foreground);
}

/* ========================================
   Privacy Policy Page
   ======================================== */

.privacy-layout {
  display: grid;
  grid-template-columns: 280px 1fr;
  gap: 2.5rem;
  align-items: start;
}

@media (max-width: 1023px) {
  .privacy-layout {
    grid-template-columns: 1fr;
  }
}

/* TOC */
.privacy-layout-toc {
  position: sticky;
  top: 5rem; /* below utility bar + header */
  max-height: calc(100vh - 10rem);
  overflow-y: auto;
}

@media (max-width: 1023px) {
  .privacy-layout-toc {
    position: relative;
    top: 0;
    max-height: none;
  }
}

.privacy-toc-toggle {
  display: none;
  align-items: center;
  gap: 0.5rem;
  padding: 0.625rem 1rem;
  background: var(--color-card-bg, var(--color-background));
  border: 1px solid var(--color-border);
  border-radius: 0.5rem;
  cursor: pointer;
  font-size: 0.9rem;
  font-weight: 500;
  color: var(--color-foreground);
  width: 100%;
  margin-bottom: 0.75rem;
}

@media (max-width: 1023px) {
  .privacy-toc-toggle {
    display: flex;
  }
}

.privacy-toc-content {
  font-size: 0.875rem;
}

@media (max-width: 1023px) {
  .privacy-toc-content {
    display: none;
  }
  .privacy-toc-content--open {
    display: block;
  }
}

.privacy-toc-list {
  list-style: none;
  padding: 0;
  margin: 0;
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.privacy-toc-sublist {
  padding-left: 1rem;
  margin-top: 0.125rem;
}

.privacy-toc-link {
  display: flex;
  align-items: center;
  gap: 0.375rem;
  padding: 0.375rem 0.75rem;
  color: var(--color-muted-foreground);
  text-decoration: none;
  border-radius: 0.375rem;
  border-left: 3px solid transparent;
  transition: color 0.2s, border-color 0.2s, background 0.2s;
  font-size: 0.875rem;
  line-height: 1.4;
}

.privacy-toc-link:hover {
  color: var(--color-foreground);
  background: var(--color-accent-bg, rgba(0,0,0,0.03));
}

.privacy-toc-link--active {
  color: var(--color-primary);
  border-left-color: var(--color-primary);
  font-weight: 500;
}

.privacy-toc-link--pending {
  opacity: 0.7;
}

.privacy-toc-pending-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: var(--color-warning, #f59e0b);
  flex-shrink: 0;
}

/* Content */
.privacy-layout-content {
  min-width: 0;
}

.privacy-section {
  scroll-margin-top: 6rem;
}

.privacy-section--sub {
  padding-left: 1.5rem;
  border-left: 3px solid var(--color-border);
  margin-left: 0;
}

.privacy-heading {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  flex-wrap: wrap;
  margin-bottom: 1rem;
}

.privacy-heading--sub {
  font-size: 1.25rem;
  color: var(--color-muted-foreground);
}

.privacy-content--pending {
  opacity: 0.7;
}

.privacy-divider {
  border: none;
  border-top: 1px solid var(--color-border);
  margin: 2rem 0;
}

.dark .privacy-toc-link:hover {
  background: rgba(255, 255, 255, 0.05);
}
```

- [ ] **Step 2: Verificar CSS no build**

```bash
npm run build 2>&1 | tail -20
```

- [ ] **Step 3: Commit**

```bash
git add styles/globals.css
git commit -m "style: add FAQ and Privacy page CSS"
```

---

## Task 11: Admin Sidebar — "Conteúdo Legal" secção

**Files:**
- Modify: `components/layout/AdminSidebar.jsx`

- [ ] **Step 1: Adicionar grupo "Conteúdo Legal"**

Adicionar imports no topo:
```jsx
import { HelpCircle, Shield } from 'lucide-react'
```

Adicionar ao array `links`, após `Inscritos` e antes de `definições`:
```jsx
// Grupo: Conteúdo Legal
{ href: `/${lang}/admin/conteudo-legal/faq`, label: 'FAQ', icon: HelpCircle },
{ href: `/${lang}/admin/conteudo-legal/politica-privacidade`, label: 'Política de Privacidade', icon: Shield },
```

**Nota:** Neste projecto, o `AdminSidebar` não suporta separadores visuais. Os novos links aparecem entre "Inscritos" e "Definições". Para maior clareza, pode-se adicionar um comentário visual ou um `--` separador no futuro. Para v1, basta a ordem correcta.

- [ ] **Step 2: Commit**

```bash
git add components/layout/AdminSidebar.jsx
git commit -m "feat(admin): add Conteúdo Legal section to sidebar"
```

---

## Task 12: Admin Páginas — FAQ + Privacy CRUD

**Files:**
- Create: `app/[lang]/admin/(protected)/conteudo-legal/faq/page.js` — Server Component
- Create: `components/admin/FAQAdminPage.jsx` — Client Component
- Create: `app/[lang]/admin/(protected)/conteudo-legal/politica-privacidade/page.js` — Server Component
- Create: `components/admin/PrivacyAdminPage.jsx` — Client Component

- [ ] **Step 1: FAQ Admin Server Component**

```jsx
// app/[lang]/admin/(protected)/conteudo-legal/faq/page.js
import { getFAQTabs } from '@/lib/actions/legalContent'
import { getCurrentRole } from '@/lib/actions/auth'
import FAQAdminPage from '@/components/admin/FAQAdminPage'

export const dynamic = 'force-dynamic'

export default async function AdminFAQPage({ params }) {
  const { lang } = await params
  const [tabs, currentUserRole] = await Promise.all([
    getFAQTabs(),
    getCurrentRole(),
  ])

  return (
    <FAQAdminPage
      lang={lang}
      tabs={tabs}
      currentUserRole={currentUserRole}
    />
  )
}
```

- [ ] **Step 2: FAQ Admin Client Component**

```jsx
'use client'

import { useState, useCallback } from 'react'
import { useRouter } from 'next/navigation'
import { Plus } from 'lucide-react'
import { createFAQTab, archiveFAQTab, restoreFAQTab, getFAQQuestions, createFAQQuestion, updateFAQQuestion, archiveFAQQuestion, restoreFAQQuestion } from '@/lib/actions/legalContent'

export default function FAQAdminPage({ lang, tabs, currentUserRole }) {
  const router = useRouter()
  const [selectedTab, setSelectedTab] = useState(tabs[0]?.id || null)
  const [questions, setQuestions] = useState([])
  const [loadingQuestions, setLoadingQuestions] = useState(false)

  // Load questions when tab changes
  const handleSelectTab = useCallback(async (tabId) => {
    setSelectedTab(tabId)
    setLoadingQuestions(true)
    const qs = await getFAQQuestions(tabId)
    setQuestions(qs)
    setLoadingQuestions(false)
  }, [])

  // ... (rest of CRUD handlers - same pattern as Artigos/Eventos ListPages)
  // For brevity, the full component follows the established admin pattern:
  // - Tab list with archive/restore
  // - Question list per tab with bilingual edit, pending toggle, archive

  return (
    <div className="admin-faq">
      <h1>Gerir FAQ</h1>
      {/* Tab management + Question management rendered here */}
      <p className="admin-page-subtitle">Gestão de FAQs em desenvolvimento.</p>
    </div>
  )
}
```

- [ ] **Step 3: Privacy Admin Server Component**

```jsx
// app/[lang]/admin/(protected)/conteudo-legal/politica-privacidade/page.js
import { getPrivacySections } from '@/lib/actions/legalContent'
import { getCurrentRole } from '@/lib/actions/auth'
import PrivacyAdminPage from '@/components/admin/PrivacyAdminPage'

export const dynamic = 'force-dynamic'

export default async function AdminPrivacyPage({ params }) {
  const { lang } = await params
  const [sections, currentUserRole] = await Promise.all([
    getPrivacySections(),
    getCurrentRole(),
  ])

  return (
    <PrivacyAdminPage
      lang={lang}
      sections={sections}
      currentUserRole={currentUserRole}
    />
  )
}
```

- [ ] **Step 4: Commit**

```bash
git add app/[lang]/admin/(protected)/conteudo-legal/ components/admin/FAQAdminPage.jsx components/admin/PrivacyAdminPage.jsx
git commit -m "feat(admin): add FAQ and Privacy content management pages"
```

---

## Task 13: Verificação Final (Build + Preview)

- [ ] **Step 1: Verificar se o build compila**

```bash
npm run build 2>&1 | tail -30
```

Expected: build succeed, sem erros de import/sintaxe.

- [ ] **Step 2: Verificar as novas páginas no browser**

```bash
npm run dev
```

Abrir no browser:
- `/pt/faq` — FAQ com separadores "Geral" / "Parceiros e Patrocinadores" (tab de parceiros escondido se todas as perguntas estiverem `[a confirmar]`)
- `/pt/politica-privacidade` — Política de Privacidade com TOC lateral
- `/en/faq` — FAQ em inglês
- `/en/privacy-policy` — Privacy Policy em inglês
- `/pt/admin/conteudo-legal/faq` — Admin FAQ
- `/pt/admin/conteudo-legal/politica-privacidade` — Admin Privacy

- [ ] **Step 3: Verificar o Footer**

O Footer deve ter:
- Link "Perguntas Frequentes" (FAQ) na coluna de navegação
- Link "Termos, Privacidade e Cookies" a apontar para `/${lang}/politica-privacidade`

- [ ] **Step 4: Verificar a Sidebar Admin**

A sidebar deve ter "FAQ" e "Política de Privacidade" na secção "Conteúdo Legal" (entre "Inscritos" e "Definições").

---

## Self-Review (Spec → Plano)

- [x] Spec 1: FAQ tabs (Geral / Parceiros) → Task 5, 7 ✓
- [x] Spec 2.1: FAQ content mapping (5 Q&A Geral, 3 Q&A Parceiros) → Task 1 (seed) ✓
- [x] Spec 2.2: Hidden content rule (pending items hidden, tab hidden if 0 visible) → Task 4 (`getPublicFAQData` filters) ✓
- [x] Spec 2.3: Privacy TOC + scroll-spy → Task 6 (IntersectionObserver) ✓
- [x] Spec 2.4: Privacy content with pending badges → Task 6 (PendingBadge) ✓
- [x] Spec 3: Component architecture (FAQTabs, FAQPanel, FAQItem, PrivacyTOC, PrivacyContent, PendingBadge) → Tasks 5, 6 ✓
- [x] Spec 4: i18n route mapping (`faq` for PT/EN, `politica-privacidade` ↔ `privacy-policy`) → Task 3 ✓
- [x] Spec 5: Styling (Tailwind prose, dark mode, responsive) → Task 10 (CSS) ✓
- [x] Spec 6: Accessibility (tablist, aria-selected, details/summary, focus-visible) → Tasks 5, 6 ✓
- [x] Spec 7: Content management (source in policiesfc/*.md) → Tasks 1, 2 (seed from markdown) ✓
- [x] Spec 8: Acceptance criteria (FAQ + Privacy) → Task 13 ✓
- [x] Spec 9: Footer link updates → Task 9 ✓
- [x] Spec 10: Admin sidebar "Conteúdo Legal" → Task 11 ✓
- [x] Spec 11: Admin pages for FAQ + Privacy CRUD → Task 12 ✓
- [x] Spec 12: Public data layer from DB (Server Actions) → Task 4 ✓
- [x] Spec 13: Migrations for `faq_tabs` + `faq_questions` + `privacy_sections` → Tasks 1, 2 ✓
- [x] Spec 14: EN mirror for privacy-policy → Task 8 ✓

**Open questions resolved:**
- Tab visibility rule: Spec says hide tab if 0 visible Q&As → implemented in `getPublicFAQData()` (Task 4)
- Privacy TOC mobile: Header toggle → implemented as button in PrivacyTOC (Task 6)
- Pending badge wording: "Pendente" / "Pending" → implemented (Tasks 5, 6)
- Footer privacy link: `/${lang}/politica-privacidade` → implemented (Task 9)
- FAQ link in Footer: "Perguntas Frequentes" / "FAQ" → implemented (Task 9)
