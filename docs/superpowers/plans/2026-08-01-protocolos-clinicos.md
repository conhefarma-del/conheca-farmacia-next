# Protocolos Clínicos — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Criar a secção pública "Protocolos Clínicos" — lista com filtros por categoria + pesquisa e página de detalhe passo-a-passo (resumo rápido, sinais de alarme, passos interativos com badges de evidência e chips de fármacos com dose, notas de segurança, proveniência, referências e PDF) — pensada para farmacêuticos comunitários e estudantes de farmácia (18-30 anos), bilíngue PT/EN, gerida via Supabase + Admin CMS. Design inspirado nos demos `_temp/design-demos/protocolos-{lista,detalhe,mobile}.html` e melhorado com boas práticas de NICE/DGS/WHO (estrutura) e AMBOSS/Epocrates/BMJ (engagement para público jovem).

**Architecture:** Migração Supabase `039` com 5 tabelas (`clinical_protocol_categories`, `clinical_protocols`, `clinical_protocol_steps`, `clinical_protocol_references`, `clinical_protocol_quizzes`) com FK RESTRICT (categoria) + CASCADE (filhos) + RLS; Server Actions `lib/actions/protocolos.js` para leitura pública e CRUD admin; páginas públicas `/[lang]/protocolos` (índice) + `/[lang]/protocolos/[slug]` (detalhe) sob PublicLayout; rota admin `(protected)/protocolos` com gestão de categorias, protocolos e conteúdo (passos + referências + quiz) via painéis slide-in. Páginas públicas lêem dados live da DB (publicado + não-arquivo). Mobile: mesmos campos com CSS responsivo (sem conteúdo extra). Iconografia 100% `lucide-react` (zero emojis).

**Tech Stack:** Next.js 16 App Router, React 19, Supabase (Postgres + RLS), Server Actions (`'use server'`), Zod, Tailwind v4 + CSS variables, `lucide-react`, metadata API (SEO), `Breadcrumb` existente.

**Source content:** Demos estáticos `_temp/design-demos/protocolos-lista.html` (6 cards), `protocolos-detalhe.html` (Hipertensão Arterial Resistente — conteúdo completo) e `protocolos-mobile.html` (variante mobile da mesma ficha). Pesquisa web (NICE NG136, ESC 2024, WHO, DGS Norma 001/2026, Infarmed, Ordem dos Farmacêuticos, BMJ Best Practice, AMBOSS, Epocrates) para estrutura canónica e engagement jovem. Conteúdo editorial é introduzido como seed de amostra na migração e completado via Admin CMS.

---

## File Structure

**Migrations:**
- Create: `supabase/migrations/039_clinical_protocols.sql` — 5 tabelas + RLS + triggers + seed de amostra.

**Server Actions:**
- Create: `lib/actions/protocolos.js` — `getPublicProtocolCategories`, `getPublicProtocols`, `getPublicProtocolBySlug`, CRUD admin (categorias, protocolos, passos, referências, quizzes) com Zod.

**Páginas Públicas:**
- Create: `app/[lang]/(public)/protocolos/page.js` — Server Component (índice).
- Create: `app/[lang]/(public)/protocolos/protocolosPageClient.jsx` — Client Component (filtros + pesquisa + grid).
- Create: `app/[lang]/(public)/protocolos/[slug]/page.js` — Server Component (detalhe).
- Create: `app/[lang]/(public)/protocolos/[slug]/protocoloDetailClient.jsx` — Client Component (resumo, red flags, passos interativos, quiz, partilha, barra mobile).

**Componentes Públicos:**
- Create: `components/protocolos/ProtocolCard.jsx` — Card de protocolo (índice).
- Create: `components/protocolos/ProtocolStep.jsx` — Passo numerado com checkbox, badges de evidência e chips de fármacos (toque-expande dose).
- Create: `components/protocolos/ProtocolSidebar.jsx` — Sidebar sticky (TOC, fármacos mencionados, referências, PDF).
- Create: `components/protocolos/ProtocolQuiz.jsx` — Quiz "Testa-te" (3-5 perguntas, pontuação efémera).

**Páginas Admin:**
- Create: `app/[lang]/admin/(protected)/protocolos/page.js` — Server Component.
- Create: `components/admin/ProtocolsAdminPage.jsx` — Gestão de categorias + protocolos (tabelas + painéis slide-in).
- Create: `components/admin/ProtocolCategoryForm.jsx` — Form de categoria.
- Create: `components/admin/ProtocolForm.jsx` — Form base do protocolo (inclui resumo, red flags, proveniência, dificuldade, PDF).
- Create: `components/admin/ProtocolContentForm.jsx` — Form de conteúdo (passos + referências + quiz).
- Modify: `components/layout/AdminSidebar.jsx` — Adicionar "Protocolos Clínicos".

**Navegação Pública:**
- Modify: `components/layout/Header.jsx` — Link "Protocolos" na nav desktop.
- Modify: `components/layout/MobileDrawer.jsx` — Link no drawer mobile.
- Modify: `components/layout/Footer.jsx` — Link na coluna "Navegação".

**i18n:**
- Modify: `lib/i18n-routes.js` — Adicionar `protocolos: 'protocols'` ao `PT_TO_EN`.
- Modify: `public/i18n/{pt,en}.json` — Chaves `nav.protocolos`, `footer.protocolos`, `protocolos_page.*`, `protocolos_detalhe.*`.

**Estilos:**
- Modify: `styles/globals.css` — Estilos `.protocol-*` (lista + detalhe + quiz + barra mobile, dark mode, responsivo).

---

## Task 1: Migração `039_clinical_protocols.sql`

**Files:**
- Create: `supabase/migrations/039_clinical_protocols.sql`

- [ ] **Step 1: Escrever a migração (5 tabelas + RLS + triggers)**

```sql
-- 039: Clinical protocols — categories, protocols, steps, references, quizzes
-- Bilíngue (PT/EN), soft-delete via is_archived, gate público via status='published'.

CREATE TABLE IF NOT EXISTS public.clinical_protocol_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT UNIQUE NOT NULL,
  name_pt TEXT NOT NULL,
  name_en TEXT NOT NULL,
  color TEXT NOT NULL DEFAULT '#0a844f',        -- fita do card / accent da categoria
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
  sort_order INT NOT NULL DEFAULT 0,
  is_archived BOOLEAN NOT NULL DEFAULT false,
  archived_at TIMESTAMPTZ,
  archived_by UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.clinical_protocols (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT UNIQUE NOT NULL,
  category_id UUID NOT NULL REFERENCES public.clinical_protocol_categories(id) ON DELETE RESTRICT,
  title_pt TEXT NOT NULL,
  title_en TEXT NOT NULL,
  description_pt TEXT NOT NULL DEFAULT '',       -- descrição do card
  description_en TEXT NOT NULL DEFAULT '',
  summary_pt TEXT NOT NULL DEFAULT '',           -- resumo rápido ("Em 60 segundos")
  summary_en TEXT NOT NULL DEFAULT '',
  safety_notes_pt TEXT NOT NULL DEFAULT '',      -- notas de segurança
  safety_notes_en TEXT NOT NULL DEFAULT '',
  red_flags_pt TEXT NOT NULL DEFAULT '',         -- sinais de alarme
  red_flags_en TEXT NOT NULL DEFAULT '',
  source_pt TEXT NOT NULL DEFAULT '',            -- proveniência ("O que diz a Norma")
  source_en TEXT NOT NULL DEFAULT '',
  source_url TEXT,                               -- link para o documento oficial
  difficulty TEXT CHECK (difficulty IN ('iniciante', 'intermedio', 'avancado')),
  pdf_url TEXT,                                  -- opcional; botão só aparece se preenchido
  is_updated BOOLEAN NOT NULL DEFAULT false,     -- chip "Actualizado" no card
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
  sort_order INT NOT NULL DEFAULT 0,
  is_archived BOOLEAN NOT NULL DEFAULT false,
  archived_at TIMESTAMPTZ,
  archived_by UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.clinical_protocol_steps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  protocol_id UUID NOT NULL REFERENCES public.clinical_protocols(id) ON DELETE CASCADE,
  label_pt TEXT NOT NULL DEFAULT '',             -- rótulo verde uppercase (ex.: "Confirmar")
  label_en TEXT NOT NULL DEFAULT '',
  title_pt TEXT NOT NULL,
  title_en TEXT NOT NULL,
  body_pt TEXT NOT NULL DEFAULT '',
  body_en TEXT NOT NULL DEFAULT '',
  recommendation TEXT CHECK (recommendation IN ('strong', 'conditional')),  -- badge GRADE simplificado (NULL oculta)
  evidence TEXT CHECK (evidence IN ('high', 'moderate', 'low')),            -- badge semáforo (NULL oculta)
  -- [{label_pt, label_en, dose}] — fármacos/tests mencionados; dose opcional
  drugs JSONB NOT NULL DEFAULT '[]',
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
  sort_order INT NOT NULL DEFAULT 0,
  is_archived BOOLEAN NOT NULL DEFAULT false,
  archived_at TIMESTAMPTZ,
  archived_by UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.clinical_protocol_references (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  protocol_id UUID NOT NULL REFERENCES public.clinical_protocols(id) ON DELETE CASCADE,
  title_pt TEXT NOT NULL,
  title_en TEXT NOT NULL,
  url TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
  sort_order INT NOT NULL DEFAULT 0,
  is_archived BOOLEAN NOT NULL DEFAULT false,
  archived_at TIMESTAMPTZ,
  archived_by UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.clinical_protocol_quizzes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  protocol_id UUID NOT NULL REFERENCES public.clinical_protocols(id) ON DELETE CASCADE,
  question_pt TEXT NOT NULL,
  question_en TEXT NOT NULL,
  option_a_pt TEXT NOT NULL DEFAULT '',
  option_a_en TEXT NOT NULL DEFAULT '',
  option_b_pt TEXT NOT NULL DEFAULT '',
  option_b_en TEXT NOT NULL DEFAULT '',
  option_c_pt TEXT NOT NULL DEFAULT '',
  option_c_en TEXT NOT NULL DEFAULT '',
  option_d_pt TEXT NOT NULL DEFAULT '',
  option_d_en TEXT NOT NULL DEFAULT '',
  correct_index INT NOT NULL DEFAULT 0 CHECK (correct_index BETWEEN 0 AND 3),
  explanation_pt TEXT NOT NULL DEFAULT '',
  explanation_en TEXT NOT NULL DEFAULT '',
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
  sort_order INT NOT NULL DEFAULT 0,
  is_archived BOOLEAN NOT NULL DEFAULT false,
  archived_at TIMESTAMPTZ,
  archived_by UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- RLS
ALTER TABLE public.clinical_protocol_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.clinical_protocols ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.clinical_protocol_steps ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.clinical_protocol_references ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.clinical_protocol_quizzes ENABLE ROW LEVEL SECURITY;

-- Admin can do everything (auth check enforced via Server Actions)
CREATE POLICY "admin_all_clinical_protocol_categories" ON public.clinical_protocol_categories
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()));

CREATE POLICY "admin_all_clinical_protocols" ON public.clinical_protocols
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()));

CREATE POLICY "admin_all_clinical_protocol_steps" ON public.clinical_protocol_steps
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()));

CREATE POLICY "admin_all_clinical_protocol_references" ON public.clinical_protocol_references
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()));

CREATE POLICY "admin_all_clinical_protocol_quizzes" ON public.clinical_protocol_quizzes
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()));

-- Anon can only read published, non-archived data (public pages)
CREATE POLICY "anon_read_clinical_protocol_categories" ON public.clinical_protocol_categories
  FOR SELECT TO anon, authenticated
  USING (status = 'published' AND is_archived = false);

CREATE POLICY "anon_read_clinical_protocols" ON public.clinical_protocols
  FOR SELECT TO anon, authenticated
  USING (status = 'published' AND is_archived = false);

CREATE POLICY "anon_read_clinical_protocol_steps" ON public.clinical_protocol_steps
  FOR SELECT TO anon, authenticated
  USING (status = 'published' AND is_archived = false);

CREATE POLICY "anon_read_clinical_protocol_references" ON public.clinical_protocol_references
  FOR SELECT TO anon, authenticated
  USING (status = 'published' AND is_archived = false);

CREATE POLICY "anon_read_clinical_protocol_quizzes" ON public.clinical_protocol_quizzes
  FOR SELECT TO anon, authenticated
  USING (status = 'published' AND is_archived = false);

-- Triggers for updated_at (função já existe — migração 034)
CREATE TRIGGER set_clinical_protocol_categories_updated_at
  BEFORE UPDATE ON public.clinical_protocol_categories
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER set_clinical_protocols_updated_at
  BEFORE UPDATE ON public.clinical_protocols
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER set_clinical_protocol_steps_updated_at
  BEFORE UPDATE ON public.clinical_protocol_steps
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER set_clinical_protocol_references_updated_at
  BEFORE UPDATE ON public.clinical_protocol_references
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER set_clinical_protocol_quizzes_updated_at
  BEFORE UPDATE ON public.clinical_protocol_quizzes
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
```

- [ ] **Step 2: Seed de amostra (6 categorias + 6 protocolos + detalhe completo de Hipertensão Arterial Resistente)**

```sql
-- Seed: conteúdo dos demos. Detalhe completo apenas para "Hipertensão Arterial
-- Resistente"; os restantes entram como cards (passos/referências via Admin CMS).
-- recommendation/evidence ficam NULL na seed (não se inventam níveis de evidência).

INSERT INTO public.clinical_protocol_categories (slug, name_pt, name_en, color, status, sort_order) VALUES
  ('cardiologia', 'Cardiologia', 'Cardiology', '#0a844f', 'published', 1),
  ('infecciologia', 'Infecciologia', 'Infectious Diseases', '#0a844f', 'published', 2),
  ('endocrinologia', 'Endocrinologia', 'Endocrinology', '#0a844f', 'published', 3),
  ('pediatria', 'Pediatria', 'Paediatrics', '#0a844f', 'published', 4),
  ('saude-mental', 'Saúde Mental', 'Mental Health', '#0a844f', 'published', 5),
  ('farmacovigilancia', 'Farmacovigilância', 'Pharmacovigilance', '#0a844f', 'published', 6);

DO $$
DECLARE
  cardio_id UUID;
  hiper_id UUID;
BEGIN
  SELECT id INTO cardio_id FROM public.clinical_protocol_categories WHERE slug = 'cardiologia';

  -- Hipertensão Arterial Resistente — o único protocolo com conteúdo detalhado no demo
  INSERT INTO public.clinical_protocols
    (slug, category_id, title_pt, title_en, description_pt, description_en, summary_pt, summary_en,
     safety_notes_pt, safety_notes_en, red_flags_pt, red_flags_en,
     source_pt, source_en, source_url, difficulty, is_updated, status, sort_order, updated_at)
  VALUES
    ('hipertensao-arterial-resistente', cardio_id,
     'Hipertensão Arterial Resistente', 'Resistant Hypertension',
     'Abordagem terapêutica passo a passo para doentes que não atingem alvo pressórico com triple terapia.',
     'Step-by-step therapeutic approach for patients not reaching blood pressure targets on triple therapy.',
     'Doente com PA não controlada apesar de 3 anti-hipertensores (incluindo diurético tiazídico) em doses óptimas. Acção: confirmar aderência, avaliar causas reversíveis, propor quadrupla ou encaminhar para secundário.',
     'Patient with uncontrolled BP despite 3 antihypertensives (including a thiazide diuretic) at optimal doses. Action: confirm adherence, assess reversible causes, propose quadrupel therapy or refer to secondary care.',
     'A combinação IECA + espironolactona + diurético poupador de K+ aumenta risco de hipercalemia. Verificar K+ basal antes de iniciar. Não usar em doentes com eGFR < 30 mL/min sem orientação especializada.',
     'The combination of ACEi + spironolactone + a K+-sparing diuretic increases the risk of hyperkalaemia. Check baseline K+ before starting. Do not use in patients with eGFR < 30 mL/min without specialist guidance.',
     'Crise hipertensiva (PA ≥ 180/110 com cefaleia, alterações visuais, dor torácica ou dispneia) → encaminhar de imediato. K+ elevado ou deterioração renal após início de espironolactona → suspender e reavaliar.',
     'Hypertensive crisis (BP ≥ 180/110 with headache, visual disturbance, chest pain or dyspnoea) → refer immediately. Elevated K+ or renal deterioration after starting spironolactone → stop and reassess.',
     'Norma DGS n.º 001/2026 — Abordagem Diagnóstica e Terapêutica da Pessoa com Hipertensão Arterial',
     'DGS Guideline No. 001/2026 — Diagnostic and Therapeutic Approach to the Person with Hypertension',
     'https://www.dgs.pt/normas-orientacoes-e-informacoes/normas-e-circulares-normativas/norma-n-0012026-de-04032026-abordagem-diagnostica-e-terapeutica-da-pessoa-com-hipertensao-arterial.aspx',
     'avancado', true, 'published', 1, '2026-04-01 10:00:00+00')
  RETURNING id INTO hiper_id;

  INSERT INTO public.clinical_protocol_steps (protocol_id, label_pt, label_en, title_pt, title_en, body_pt, body_en, drugs, status, sort_order) VALUES
    (hiper_id, 'Confirmar', 'Confirm',
     'Validar a resistência verdadeira', 'Confirm true resistance',
     'Confirmar aderência (entrevista + contagem de comprimidos). Excluir pseudo-resistência: técnica de medição incorrecta, uso de AINEs não declarados, álcool, ou white-coat effect (MAPPA).',
     'Confirm adherence (interview + pill count). Exclude pseudo-resistance: incorrect measurement technique, undeclared NSAID use, alcohol, or white-coat effect (ABPM).',
     '[{"label_pt":"MAPPA · Entrevista","label_en":"ABPM · Interview"}]', 'published', 1),
    (hiper_id, 'Identificar', 'Identify',
     'Causas secundárias e reversíveis', 'Secondary and reversible causes',
     'Apneia obstrutiva do sono, hiperaldosteronismo primário, feocromocitoma, estenose da artéria renal, síndrome de Cushing. Pedir orientação médica se suspeita.',
     'Obstructive sleep apnoea, primary hyperaldosteronism, phaeochromocytoma, renal artery stenosis, Cushing syndrome. Seek medical guidance if suspected.',
     '[]', 'published', 2),
    (hiper_id, 'Optimizar', 'Optimise',
     'Esquema quadruplo dirigido', 'Targeted quadrupel regimen',
     'Manter IECA/ARB II na dose óptima + antagonista da aldosterona (espironolactona 25mg) + diurético tiazídico + bloqueador dos canais de cálcio. Monitorizar K+ e função renal em 7–14 dias.',
     'Keep ACEi/ARB at optimal dose + aldosterone antagonist (spironolactone 25mg) + thiazide diuretic + calcium channel blocker. Monitor K+ and renal function in 7–14 days.',
     '[{"label_pt":"Espironolactona 25mg","label_en":"Spironolactone 25mg","dose":"25 mg/dia (máx. 50 mg)"},{"label_pt":"K+ sérico · eGFR","label_en":"Serum K+ · eGFR","dose":"Reavaliar em 7–14 dias"}]', 'published', 3),
    (hiper_id, 'Referenciar', 'Refer',
     'Encaminhar para cuidados secundários', 'Refer to secondary care',
     'Se PA continua não controlada após optimização farmacológica máxima: referenciar para hipertensão de difícil controlo. Documentar todos os fármacos tentados e respectivas doses.',
     'If BP remains uncontrolled after maximal pharmacological optimisation: refer for difficult-to-control hypertension. Document all drugs tried and their doses.',
     '[]', 'published', 4);

  INSERT INTO public.clinical_protocol_references (protocol_id, title_pt, title_en, url, status, sort_order) VALUES
    (hiper_id, 'KDIGO 2024 — Hypertension in CKD', 'KDIGO 2024 — Hypertension in CKD', 'https://kdigo.org/guidelines/', 'published', 1),
    (hiper_id, 'ESC/ESH 2018 — Arterial Hypertension', 'ESC/ESH 2018 — Arterial Hypertension', 'https://www.escardio.org/Guidelines', 'published', 2),
    (hiper_id, 'Infarmed — Protocolo Nacional', 'Infarmed — National Protocol', 'https://www.infarmed.pt', 'published', 3);

  INSERT INTO public.clinical_protocol_quizzes (protocol_id, question_pt, question_en, option_a_pt, option_a_en, option_b_pt, option_b_en, option_c_pt, option_c_en, option_d_pt, option_d_en, correct_index, explanation_pt, explanation_en, status, sort_order) VALUES
    (hiper_id,
     'Qual é o fármaco adicionado no passo 3 do esquema quadruplo?',
     'Which drug is added in step 3 of the quadrupel regimen?',
     'Espironolactona', 'Spironolactone',
     'Metformina', 'Metformin',
     'Doxiciclina', 'Doxycycline',
     'Salbutamol', 'Salbutamol',
     0,
     'A espironolactona 25mg é o antagonista da aldosterona adicionado à IECA/ARB + diurético tiazídico + bloqueador dos canais de cálcio.',
     'Spironolactone 25mg is the aldosterone antagonist added to the ACEi/ARB + thiazide diuretic + calcium channel blocker.',
     'published', 1),
    (hiper_id,
     'Que parâmetros devem ser monitorizados 7–14 dias após iniciar espironolactona?',
     'Which parameters should be monitored 7–14 days after starting spironolactone?',
     'Hemoglobina e plaquetas', 'Haemoglobin and platelets',
     'K+ sérico e função renal (eGFR)', 'Serum K+ and renal function (eGFR)',
     'Glicemia em jejum', 'Fasting glucose',
     'Perfil lipídico', 'Lipid profile',
     1,
     'A combinação IECA + espironolactona + diurético poupador de K+ aumenta o risco de hipercalemia; monitorizar K+ e eGFR.',
     'The combination of ACEi + spironolactone + a K+-sparing diuretic increases the risk of hyperkalaemia; monitor K+ and eGFR.',
     'published', 2),
    (hiper_id,
     'Quando deve o doente com HTA resistente ser referenciado para cuidados secundários?',
     'When should a patient with resistant hypertension be referred to secondary care?',
     'Logo após o primeiro registo de PA elevada', 'Immediately after the first elevated BP reading',
     'Se PA não controlada após optimização farmacológica máxima', 'If BP remains uncontrolled after maximal pharmacological optimisation',
     'Apenas se apresentar cefaleias', 'Only if they present with headaches',
     'Nunca — o farmacêutico trata sozinho', 'Never — the pharmacist treats alone',
     1,
     'A referenciação é indicada quando a PA continua não controlada apesar da optimização farmacológica máxima.',
     'Referral is indicated when BP remains uncontrolled despite maximal pharmacological optimisation.',
     'published', 3);

  -- Restantes 5 protocolos (dados dos cards do demo; conteúdo via Admin CMS)
  INSERT INTO public.clinical_protocols (slug, category_id, title_pt, title_en, description_pt, description_en, difficulty, is_updated, status, sort_order, updated_at)
  SELECT 'infeccao-urinaria-recorrente-adulto', id,
    'Infeção Urinária Recorrente — Adulto', 'Recurrent Urinary Tract Infection — Adult',
    'Profilaxia e tratamento curto de ITU de repetição: esquemas, doses e duração recomendada.',
    'Prophylaxis and short-course treatment of recurrent UTI: regimens, doses and recommended duration.',
    'iniciante', true, 'published', 2, '2026-03-01 10:00:00+00'
  FROM public.clinical_protocol_categories WHERE slug = 'infecciologia';

  INSERT INTO public.clinical_protocols (slug, category_id, title_pt, title_en, description_pt, description_en, difficulty, is_updated, status, sort_order, updated_at)
  SELECT 'diabetes-tipo-2-inicio-terapeutico', id,
    'Diabetes Tipo 2 — Início Terapêutico', 'Type 2 Diabetes — Treatment Initiation',
    'Escolha de antidiabético segundo perfil do doente: função renal, idade, risco hipoglicémia.',
    'Choosing an antidiabetic agent by patient profile: renal function, age, hypoglycaemia risk.',
    'intermedio', true, 'published', 3, '2026-02-01 10:00:00+00'
  FROM public.clinical_protocol_categories WHERE slug = 'endocrinologia';

  INSERT INTO public.clinical_protocols (slug, category_id, title_pt, title_en, description_pt, description_en, difficulty, is_updated, status, sort_order, updated_at)
  SELECT 'desidratacao-aguda-menores-5-anos', id,
    'Desidratação Aguda — Menores de 5 anos', 'Acute Dehydration — Under 5 years',
    'Plano de Terapia de Rehidratação Oral: cálculo de volume, prova e critérios de referenciação.',
    'Oral Rehydration Therapy plan: volume calculation, trial and referral criteria.',
    'intermedio', true, 'published', 4, '2025-11-01 10:00:00+00'
  FROM public.clinical_protocol_categories WHERE slug = 'pediatria';

  INSERT INTO public.clinical_protocols (slug, category_id, title_pt, title_en, description_pt, description_en, difficulty, is_updated, status, sort_order, updated_at)
  SELECT 'ansiedade-generalizada-cuidados-primarios', id,
    'Ansiedade Generalizada — Abordagem em Cuidados Primários', 'Generalised Anxiety — Primary Care Approach',
    'Critérios de referenciação, opções farmacológicas não-benzodiazepínicas e acompanhamento.',
    'Referral criteria, non-benzodiazepine pharmacological options and follow-up.',
    'iniciante', false, 'published', 5, '2025-09-01 10:00:00+00'
  FROM public.clinical_protocol_categories WHERE slug = 'saude-mental';

  INSERT INTO public.clinical_protocols (slug, category_id, title_pt, title_en, description_pt, description_en, difficulty, is_updated, status, sort_order, updated_at)
  SELECT 'notificacao-reaccao-adversa', id,
    'Notificação de Reacção Adversa', 'Adverse Reaction Reporting',
    'Fluxo de notificação ao Infarmed: preencher formulário, gravidade, desfecho e medicação suspeita.',
    'Reporting flow to Infarmed: form completion, severity, outcome and suspected medication.',
    'iniciante', true, 'published', 6, '2026-01-01 10:00:00+00'
  FROM public.clinical_protocol_categories WHERE slug = 'farmacovigilancia';
END $$;
```

- [ ] **Step 3: Commit**

```bash
git add supabase/migrations/039_clinical_protocols.sql
git commit -m "feat(db): add clinical protocols tables (categories, protocols, steps, references, quizzes) with RLS"
```

---

## Task 2: Server Actions — `lib/actions/protocolos.js`

**Files:**
- Create: `lib/actions/protocolos.js`

- [ ] **Step 1: Escrever as Server Actions (público + admin) com Zod**

```js
'use server'

import { createClient } from '@/lib/supabase/server'
import { revalidatePath } from 'next/cache'
import { z } from 'zod'

// ============================================================
//  Helper: requireAdmin (padrão de legalContent.js / guides.js)
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
//  Helpers
// ============================================================
function pickLang(row, prefix, lang) {
  return row[`${prefix}_${lang}`] ?? row[`${prefix}_pt`] ?? ''
}

// ============================================================
//  Zod schemas — validação server-side (URLs: https:// ou relativo)
// ============================================================
const URL_SAFE = z.string().refine(
  (u) => !u || /^(https:\/\/|\/)/i.test(u),
  'URL deve começar por https:// ou ser um caminho relativo'
)

const protocolCategorySchema = z.object({
  slug: z.string().min(1).regex(/^[a-z0-9-]+$/, 'Slug inválido (apenas letras minúsculas, números e hífens)'),
  name_pt: z.string().min(1, 'Nome (PT) é obrigatório'),
  name_en: z.string().min(1, 'Name (EN) is required'),
  color: z.string().optional().default('#0a844f'),
  status: z.enum(['draft', 'published']).default('draft'),
  sort_order: z.number().int().optional().default(0),
})

const drugSchema = z.object({
  label_pt: z.string().min(1, 'Rótulo do fármaco (PT) é obrigatório'),
  label_en: z.string().min(1, 'Drug label (EN) is required'),
  dose: z.string().optional().default(''),
})

const protocolStepSchema = z.object({
  label_pt: z.string().optional().default(''),
  label_en: z.string().optional().default(''),
  title_pt: z.string().min(1, 'Título (PT) é obrigatório'),
  title_en: z.string().min(1, 'Title (EN) is required'),
  body_pt: z.string().optional().default(''),
  body_en: z.string().optional().default(''),
  recommendation: z.enum(['strong', 'conditional']).nullable().optional(),
  evidence: z.enum(['high', 'moderate', 'low']).nullable().optional(),
  drugs: z.array(drugSchema).optional().default([]),
  status: z.enum(['draft', 'published']).default('draft'),
  sort_order: z.number().int().optional().default(0),
})

const protocolReferenceSchema = z.object({
  title_pt: z.string().min(1, 'Título (PT) é obrigatório'),
  title_en: z.string().min(1, 'Title (EN) is required'),
  url: URL_SAFE,
  status: z.enum(['draft', 'published']).default('draft'),
  sort_order: z.number().int().optional().default(0),
})

const protocolQuizSchema = z.object({
  question_pt: z.string().min(1, 'Pergunta (PT) é obrigatória'),
  question_en: z.string().min(1, 'Question (EN) is required'),
  option_a_pt: z.string().optional().default(''),
  option_a_en: z.string().optional().default(''),
  option_b_pt: z.string().optional().default(''),
  option_b_en: z.string().optional().default(''),
  option_c_pt: z.string().optional().default(''),
  option_c_en: z.string().optional().default(''),
  option_d_pt: z.string().optional().default(''),
  option_d_en: z.string().optional().default(''),
  correct_index: z.number().int().min(0).max(3).default(0),
  explanation_pt: z.string().optional().default(''),
  explanation_en: z.string().optional().default(''),
  status: z.enum(['draft', 'published']).default('draft'),
  sort_order: z.number().int().optional().default(0),
})

const protocolSchema = z.object({
  slug: z.string().min(1).regex(/^[a-z0-9-]+$/, 'Slug inválido (apenas letras minúsculas, números e hífens)'),
  category_id: z.string().uuid('Categoria inválida'),
  title_pt: z.string().min(1, 'Título (PT) é obrigatório'),
  title_en: z.string().min(1, 'Title (EN) is required'),
  description_pt: z.string().optional().default(''),
  description_en: z.string().optional().default(''),
  summary_pt: z.string().optional().default(''),
  summary_en: z.string().optional().default(''),
  safety_notes_pt: z.string().optional().default(''),
  safety_notes_en: z.string().optional().default(''),
  red_flags_pt: z.string().optional().default(''),
  red_flags_en: z.string().optional().default(''),
  source_pt: z.string().optional().default(''),
  source_en: z.string().optional().default(''),
  source_url: URL_SAFE.nullable().optional(),
  difficulty: z.enum(['iniciante', 'intermedio', 'avancado']).nullable().optional(),
  pdf_url: URL_SAFE.nullable().optional(),
  is_updated: z.boolean().optional().default(false),
  status: z.enum(['draft', 'published']).default('draft'),
  sort_order: z.number().int().optional().default(0),
})

// ============================================================
//  Público
// ============================================================
export async function getPublicProtocolCategories(lang = 'pt') {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('clinical_protocol_categories')
    .select('id, slug, name_pt, name_en, color, sort_order')
    .eq('status', 'published')
    .eq('is_archived', false)
    .order('sort_order', { ascending: true })
  if (error) return []
  return (data || []).map((c) => ({
    id: c.id,
    slug: c.slug,
    name: pickLang(c, 'name', lang),
    color: c.color,
  }))
}

export async function getPublicProtocols(lang = 'pt') {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('clinical_protocols')
    .select(
      'id, slug, title_pt, title_en, description_pt, description_en, difficulty, is_updated, updated_at, sort_order, ' +
      'clinical_protocol_categories(slug, name_pt, name_en, color), clinical_protocol_steps(count)'
    )
    .eq('status', 'published')
    .eq('is_archived', false)
    .order('sort_order', { ascending: true })
  if (error) return []
  // RLS esconde categorias draft/arquivadas — filtrar protocolos sem categoria visível
  return (data || [])
    .filter((p) => p.clinical_protocol_categories)
    .map((p) => ({
      id: p.id,
      slug: p.slug,
      title: pickLang(p, 'title', lang),
      description: pickLang(p, 'description', lang),
      difficulty: p.difficulty,
      isUpdated: p.is_updated,
      updatedAt: p.updated_at,
      stepCount: p.clinical_protocol_steps?.[0]?.count || 0,
      categorySlug: p.clinical_protocol_categories.slug,
      categoryName: pickLang(p.clinical_protocol_categories, 'name', lang),
      categoryColor: p.clinical_protocol_categories.color,
    }))
}

export async function getPublicProtocolBySlug(slug, lang = 'pt') {
  const supabase = await createClient()
  const { data: row, error } = await supabase
    .from('clinical_protocols')
    .select('*, clinical_protocol_categories(slug, name_pt, name_en, color)')
    .eq('slug', slug)
    .eq('status', 'published')
    .eq('is_archived', false)
    .maybeSingle()
  if (error || !row || !row.clinical_protocol_categories) return null

  const [stepsRes, refsRes, quizzesRes] = await Promise.all([
    supabase.from('clinical_protocol_steps')
      .select('*').eq('protocol_id', row.id).eq('status', 'published').eq('is_archived', false)
      .order('sort_order', { ascending: true }),
    supabase.from('clinical_protocol_references')
      .select('*').eq('protocol_id', row.id).eq('status', 'published').eq('is_archived', false)
      .order('sort_order', { ascending: true }),
    supabase.from('clinical_protocol_quizzes')
      .select('*').eq('protocol_id', row.id).eq('status', 'published').eq('is_archived', false)
      .order('sort_order', { ascending: true }),
  ])

  return {
    id: row.id,
    slug: row.slug,
    title: pickLang(row, 'title', lang),
    description: pickLang(row, 'description', lang),
    summary: pickLang(row, 'summary', lang),
    safetyNotes: pickLang(row, 'safety_notes', lang),
    redFlags: pickLang(row, 'red_flags', lang),
    source: pickLang(row, 'source', lang),
    sourceUrl: row.source_url || null,
    pdfUrl: row.pdf_url || null,
    difficulty: row.difficulty,
    isUpdated: row.is_updated,
    updatedAt: row.updated_at,
    category: {
      slug: row.clinical_protocol_categories.slug,
      name: pickLang(row.clinical_protocol_categories, 'name', lang),
      color: row.clinical_protocol_categories.color,
    },
    steps: (stepsRes.data || []).map((s) => ({
      id: s.id,
      label: pickLang(s, 'label', lang),
      title: pickLang(s, 'title', lang),
      body: pickLang(s, 'body', lang),
      recommendation: s.recommendation,
      evidence: s.evidence,
      drugs: (s.drugs || []).map((d) => ({ label: pickLang(d, 'label', lang), dose: d.dose || '' })),
    })),
    references: (refsRes.data || []).map((r) => ({ id: r.id, title: pickLang(r, 'title', lang), url: r.url })),
    quizzes: (quizzesRes.data || []).map((q) => ({
      id: q.id,
      question: pickLang(q, 'question', lang),
      options: [
        pickLang(q, 'option_a', lang),
        pickLang(q, 'option_b', lang),
        pickLang(q, 'option_c', lang),
        pickLang(q, 'option_d', lang),
      ],
      correctIndex: q.correct_index,
      explanation: pickLang(q, 'explanation', lang),
    })),
  }
}

// ============================================================
//  Admin — Categorias
// ============================================================
export async function getAllProtocolCategories() {
  const ctx = await requireAdmin()
  if (!ctx) return []
  const { data, error } = await ctx.supabase
    .from('clinical_protocol_categories')
    .select('*, clinical_protocols(count)')
    .order('sort_order', { ascending: true })
  if (error) return []
  return (data || []).map((c) => ({
    id: c.id,
    slug: c.slug,
    name_pt: c.name_pt,
    name_en: c.name_en,
    color: c.color,
    status: c.status,
    sort_order: c.sort_order,
    is_archived: c.is_archived,
    protocolCount: c.clinical_protocols?.[0]?.count || 0,
  }))
}

export async function createProtocolCategory(data) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const parsed = protocolCategorySchema.safeParse(data)
  if (!parsed.success) return { success: false, error: parsed.error.issues[0]?.message || 'Dados inválidos' }
  const { error } = await ctx.supabase.from('clinical_protocol_categories').insert(parsed.data)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/protocolos')
  return { success: true }
}

export async function updateProtocolCategory(id, data) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const parsed = protocolCategorySchema.partial().safeParse(data)
  if (!parsed.success) return { success: false, error: parsed.error.issues[0]?.message || 'Dados inválidos' }
  const { error } = await ctx.supabase.from('clinical_protocol_categories').update(parsed.data).eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/protocolos')
  return { success: true }
}

export async function archiveProtocolCategory(id) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const { error } = await ctx.supabase
    .from('clinical_protocol_categories')
    .update({ is_archived: true, archived_at: new Date().toISOString(), archived_by: ctx.user.id })
    .eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/protocolos')
  return { success: true }
}

export async function restoreProtocolCategory(id) {
  const ctx = await requireAdmin()
  if (!ctx || ctx.role !== 'superadmin') return { success: false, error: 'Apenas superadmin' }
  const { error } = await ctx.supabase
    .from('clinical_protocol_categories')
    .update({ is_archived: false, archived_at: null, archived_by: null })
    .eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/protocolos')
  return { success: true }
}

export async function deleteProtocolCategory(id) {
  const ctx = await requireAdmin()
  if (!ctx || ctx.role !== 'superadmin') return { success: false, error: 'Apenas superadmin' }
  const { error } = await ctx.supabase.from('clinical_protocol_categories').delete().eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/protocolos')
  return { success: true }
}

// ============================================================
//  Admin — Protocolos
// ============================================================
export async function getAllClinicalProtocols() {
  const ctx = await requireAdmin()
  if (!ctx) return []
  const { data, error } = await ctx.supabase
    .from('clinical_protocols')
    .select(
      'id, slug, title_pt, title_en, category_id, difficulty, is_updated, status, sort_order, is_archived, updated_at, ' +
      'clinical_protocol_categories(name_pt, name_en, color), clinical_protocol_steps(count)'
    )
    .order('sort_order', { ascending: true })
  if (error) return []
  return (data || []).map((p) => ({
    id: p.id,
    slug: p.slug,
    title_pt: p.title_pt,
    title_en: p.title_en,
    category_id: p.category_id,
    categoryName: p.clinical_protocol_categories?.name_pt || '—',
    categoryColor: p.clinical_protocol_categories?.color || '#0a844f',
    difficulty: p.difficulty,
    is_updated: p.is_updated,
    status: p.status,
    sort_order: p.sort_order,
    is_archived: p.is_archived,
    stepCount: p.clinical_protocol_steps?.[0]?.count || 0,
  }))
}

export async function getProtocolDetail(id) {
  const ctx = await requireAdmin()
  if (!ctx) return null
  const { data, error } = await ctx.supabase
    .from('clinical_protocols')
    .select('*, clinical_protocol_steps(*), clinical_protocol_references(*), clinical_protocol_quizzes(*)')
    .eq('id', id)
    .order('sort_order', { ascending: true, referencedTable: 'clinical_protocol_steps' })
    .order('sort_order', { ascending: true, referencedTable: 'clinical_protocol_references' })
    .order('sort_order', { ascending: true, referencedTable: 'clinical_protocol_quizzes' })
    .maybeSingle()
  if (error || !data) return null
  return data
}

export async function createProtocol(data) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const parsed = protocolSchema.safeParse(data)
  if (!parsed.success) return { success: false, error: parsed.error.issues[0]?.message || 'Dados inválidos' }
  const { error } = await ctx.supabase.from('clinical_protocols').insert(parsed.data)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/protocolos')
  return { success: true }
}

export async function updateProtocol(id, data) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const parsed = protocolSchema.partial().safeParse(data)
  if (!parsed.success) return { success: false, error: parsed.error.issues[0]?.message || 'Dados inválidos' }
  const { error } = await ctx.supabase.from('clinical_protocols').update(parsed.data).eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/protocolos')
  return { success: true }
}

export async function archiveProtocol(id) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const { error } = await ctx.supabase
    .from('clinical_protocols')
    .update({ is_archived: true, archived_at: new Date().toISOString(), archived_by: ctx.user.id })
    .eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/protocolos')
  return { success: true }
}

export async function restoreProtocol(id) {
  const ctx = await requireAdmin()
  if (!ctx || ctx.role !== 'superadmin') return { success: false, error: 'Apenas superadmin' }
  const { error } = await ctx.supabase
    .from('clinical_protocols')
    .update({ is_archived: false, archived_at: null, archived_by: null })
    .eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/protocolos')
  return { success: true }
}

export async function deleteProtocol(id) {
  const ctx = await requireAdmin()
  if (!ctx || ctx.role !== 'superadmin') return { success: false, error: 'Apenas superadmin' }
  const { error } = await ctx.supabase.from('clinical_protocols').delete().eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/protocolos')
  return { success: true }
}

// ============================================================
//  Admin — Passos
// ============================================================
export async function createProtocolStep(protocolId, data) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const parsed = protocolStepSchema.safeParse(data)
  if (!parsed.success) return { success: false, error: parsed.error.issues[0]?.message || 'Dados inválidos' }
  const { error } = await ctx.supabase.from('clinical_protocol_steps').insert({ ...parsed.data, protocol_id: protocolId })
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/protocolos')
  return { success: true }
}

export async function updateProtocolStep(id, data) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const parsed = protocolStepSchema.partial().safeParse(data)
  if (!parsed.success) return { success: false, error: parsed.error.issues[0]?.message || 'Dados inválidos' }
  const { error } = await ctx.supabase.from('clinical_protocol_steps').update(parsed.data).eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/protocolos')
  return { success: true }
}

export async function deleteProtocolStep(id) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const { error } = await ctx.supabase.from('clinical_protocol_steps').delete().eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/protocolos')
  return { success: true }
}

// ============================================================
//  Admin — Referências
// ============================================================
export async function createProtocolReference(protocolId, data) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const parsed = protocolReferenceSchema.safeParse(data)
  if (!parsed.success) return { success: false, error: parsed.error.issues[0]?.message || 'Dados inválidos' }
  const { error } = await ctx.supabase.from('clinical_protocol_references').insert({ ...parsed.data, protocol_id: protocolId })
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/protocolos')
  return { success: true }
}

export async function updateProtocolReference(id, data) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const parsed = protocolReferenceSchema.partial().safeParse(data)
  if (!parsed.success) return { success: false, error: parsed.error.issues[0]?.message || 'Dados inválidos' }
  const { error } = await ctx.supabase.from('clinical_protocol_references').update(parsed.data).eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/protocolos')
  return { success: true }
}

export async function deleteProtocolReference(id) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const { error } = await ctx.supabase.from('clinical_protocol_references').delete().eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/protocolos')
  return { success: true }
}

// ============================================================
//  Admin — Quiz
// ============================================================
export async function createProtocolQuiz(protocolId, data) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const parsed = protocolQuizSchema.safeParse(data)
  if (!parsed.success) return { success: false, error: parsed.error.issues[0]?.message || 'Dados inválidos' }
  const { error } = await ctx.supabase.from('clinical_protocol_quizzes').insert({ ...parsed.data, protocol_id: protocolId })
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/protocolos')
  return { success: true }
}

export async function updateProtocolQuiz(id, data) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const parsed = protocolQuizSchema.partial().safeParse(data)
  if (!parsed.success) return { success: false, error: parsed.error.issues[0]?.message || 'Dados inválidos' }
  const { error } = await ctx.supabase.from('clinical_protocol_quizzes').update(parsed.data).eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/protocolos')
  return { success: true }
}

export async function deleteProtocolQuiz(id) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const { error } = await ctx.supabase.from('clinical_protocol_quizzes').delete().eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/protocolos')
  return { success: true }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/actions/protocolos.js
git commit -m "feat(actions): add clinical protocols server actions with zod validation"
```

---

## Task 3: i18n + Navegação

**Files:**
- Modify: `lib/i18n-routes.js`
- Modify: `public/i18n/pt.json`, `public/i18n/en.json`
- Modify: `components/layout/Header.jsx`, `components/layout/MobileDrawer.jsx`, `components/layout/Footer.jsx`, `components/layout/AdminSidebar.jsx`

- [ ] **Step 1: Rota i18n** — adicionar `protocolos` ao `PT_TO_EN` (após `guias`)

```js
  guias: 'guides',
  protocolos: 'protocols',
}
```

- [ ] **Step 2: Chaves PT (`public/i18n/pt.json`)** — adicionar antes do `}` final

```json
  "nav": { "... existente ...", "protocolos": "Protocolos" },
  "footer": { "... existente ...", "protocolos": "Protocolos" },
  "protocolos_page": {
    "hero_title": "Protocolos Clínicos",
    "hero_subtitle": "Guias de tratamento validados por especialistas — consulte no balcão ou na consulta.",
    "todos": "Todos",
    "placeholder": "Pesquisar protocolo...",
    "passos": "passos",
    "minutos_leitura": "min",
    "actualizado": "Actualizado",
    "no_results": "Nenhum protocolo encontrado para os filtros seleccionados."
  },
  "protocolos_detalhe": {
    "breadcrumb_protocolos": "Protocolos",
    "resumo_rapido": "Resumo Rápido",
    "sinais_alarme": "Sinais de Alarme",
    "passo_a_passo": "Protocolo passo a passo",
    "notas_seguranca": "Notas de Segurança",
    "o_que_diz_a_norma": "O que diz a Norma",
    "fonte_oficial": "Fonte oficial",
    "neste_protocolo": "Neste protocolo",
    "farmacos_mencionados": "Fármacos mencionados",
    "referencias": "Referências",
    "descarregar_pdf": "Descarregar PDF",
    "partilhar": "Partilhar",
    "copiar_link": "Copiar link",
    "copiado": "Link copiado!",
    "minutos_leitura": "min de leitura",
    "passos": "passos",
    "actualizado_em": "Actualizado",
    "passo": "Passo",
    "de": "de",
    "recomendacao_forte": "Recomendação forte",
    "recomendacao_condicional": "Recomendação condicional",
    "evidencia_alta": "Evidência alta",
    "evidencia_moderada": "Evidência moderada",
    "evidencia_baixa": "Evidência baixa",
    "dificuldade_iniciante": "Iniciante",
    "dificuldade_intermedio": "Intermediário",
    "dificuldade_avancado": "Avançado",
    "dose": "Dose",
    "testa_te": "Testa-te",
    "acertaste": "Acertaste",
    "explicacao": "Explicação",
    "continuar": "Continuar",
    "ver_resultado": "Ver resultado",
    "erro_carregar": "Não foi possível carregar o protocolo."
  }
```

- [ ] **Step 3: Chaves EN (`public/i18n/en.json`)** — mesmas chaves em inglês

```json
  "protocolos_page": {
    "hero_title": "Clinical Protocols",
    "hero_subtitle": "Expert-validated treatment guides — consult at the counter or in practice.",
    "todos": "All",
    "placeholder": "Search protocols...",
    "passos": "steps",
    "minutos_leitura": "min",
    "actualizado": "Updated",
    "no_results": "No protocols found for the selected filters."
  },
  "protocolos_detalhe": {
    "breadcrumb_protocolos": "Protocols",
    "resumo_rapido": "Quick Summary",
    "sinais_alarme": "Red Flags",
    "passo_a_passo": "Step-by-step protocol",
    "notas_seguranca": "Safety Notes",
    "o_que_diz_a_norma": "What the guideline says",
    "fonte_oficial": "Official source",
    "neste_protocolo": "In this protocol",
    "farmacos_mencionados": "Medications mentioned",
    "referencias": "References",
    "descarregar_pdf": "Download PDF",
    "partilhar": "Share",
    "copiar_link": "Copy link",
    "copiado": "Link copied!",
    "minutos_leitura": "min read",
    "passos": "steps",
    "actualizado_em": "Updated",
    "passo": "Step",
    "de": "of",
    "recomendacao_forte": "Strong recommendation",
    "recomendacao_condicional": "Conditional recommendation",
    "evidencia_alta": "High evidence",
    "evidencia_moderada": "Moderate evidence",
    "evidencia_baixa": "Low evidence",
    "dificuldade_iniciante": "Beginner",
    "dificuldade_intermedio": "Intermediate",
    "dificuldade_avancado": "Advanced",
    "dose": "Dose",
    "testa_te": "Test yourself",
    "acertaste": "You got",
    "explicacao": "Explanation",
    "continuar": "Continue",
    "ver_resultado": "See result",
    "erro_carregar": "Could not load the protocol."
  }
```

- [ ] **Step 4: Header/MobileDrawer** — adicionar o link entre `guias` e `sobre` (mesmo objeto nos dois ficheiros)

```jsx
{ href: getSectionHref(lang, 'protocolos'), label: t('nav.protocolos'), path: 'protocolos' },
```

- [ ] **Step 5: Footer** — na coluna "Navegação" (após os Guias)

```jsx
<li><Link href={getSectionHref(lang, 'protocolos')}>{t('footer.protocolos')}</Link></li>
```

- [ ] **Step 6: AdminSidebar** — após "Guias de Estudo" (importar `ClipboardList` de `lucide-react`)

```jsx
{ href: `/${lang}/admin/protocolos`, label: 'Protocolos Clínicos', icon: ClipboardList },
```

- [ ] **Step 7: Commit**

```bash
git add lib/i18n-routes.js public/i18n/pt.json public/i18n/en.json components/layout/Header.jsx components/layout/MobileDrawer.jsx components/layout/Footer.jsx components/layout/AdminSidebar.jsx
git commit -m "feat(i18n): add protocolos routes, keys and navigation links"
```

---

## Task 4: Listagem pública — `/[lang]/protocolos`

**Files:**
- Create: `app/[lang]/(public)/protocolos/page.js`
- Create: `app/[lang]/(public)/protocolos/protocolosPageClient.jsx`
- Create: `components/protocolos/ProtocolCard.jsx`

- [ ] **Step 1: Server Component `page.js`** (metadata + dados live)

```jsx
import { loadTranslations, SUPPORTED_LANGS, DEFAULT_LANG, t } from '@/lib/i18n'
import { getPublicProtocolCategories, getPublicProtocols } from '@/lib/actions/protocolos'
import ProtocolosPageClient from './protocolosPageClient'

export const dynamic = 'force-dynamic'

export async function generateMetadata({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  return {
    title: t(translations, 'protocolos_page.hero_title'),
    description: t(translations, 'protocolos_page.hero_subtitle'),
    alternates: { languages: { pt: '/pt/protocolos', en: '/en/protocols' } },
  }
}

export default async function ProtocolosPage({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const [categories, protocols] = await Promise.all([
    getPublicProtocolCategories(safeLang),
    getPublicProtocols(safeLang),
  ])
  return <ProtocolosPageClient lang={safeLang} categories={categories} protocols={protocols} />
}
```

- [ ] **Step 2: Client Component `protocolosPageClient.jsx`** (filtros + pesquisa com atalho `/` + grid)

```jsx
'use client'

import { useContext, useEffect, useMemo, useRef, useState } from 'react'
import { Search } from 'lucide-react'
import { LangContext } from '@/lib/contexts'
import { Breadcrumb } from '@/components/ui/Breadcrumb'
import ProtocolCard from '@/components/protocolos/ProtocolCard'

export default function ProtocolosPageClient({ lang, categories, protocols }) {
  const { t } = useContext(LangContext)
  const [activeCategory, setActiveCategory] = useState('all')
  const [query, setQuery] = useState('')
  const searchRef = useRef(null)

  // Atalhos: "/" foca a pesquisa; Ctrl/Cmd+K idem
  useEffect(() => {
    const onKey = (e) => {
      if (e.key === '/' && document.activeElement !== searchRef.current) {
        e.preventDefault()
        searchRef.current?.focus()
      }
      if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'k') {
        e.preventDefault()
        searchRef.current?.focus()
      }
    }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [])

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase()
    return protocols.filter((p) => {
      if (activeCategory !== 'all' && p.categorySlug !== activeCategory) return false
      if (!q) return true
      return (p.title + ' ' + p.description + ' ' + p.categoryName).toLowerCase().includes(q)
    })
  }, [protocols, activeCategory, query])

  return (
    <div>
      <Breadcrumb items={[
        { label: t('nav.inicio'), href: '/' + lang },
        { label: t('protocolos_page.hero_title') },
      ]} />

      <section className="hero">
        <h1 className="hero-title">{t('protocolos_page.hero_title')}</h1>
        <p className="hero-subtitle">{t('protocolos_page.hero_subtitle')}</p>
      </section>

      <nav className="protocol-filters-bar" aria-label={t('protocolos_page.hero_title')}>
        <button
          className={`protocol-filter-btn ${activeCategory === 'all' ? 'active' : ''}`}
          onClick={() => setActiveCategory('all')}
        >
          {t('protocolos_page.todos')}
        </button>
        {categories.map((c) => (
          <button
            key={c.id}
            className={`protocol-filter-btn ${activeCategory === c.slug ? 'active' : ''}`}
            onClick={() => setActiveCategory(c.slug)}
          >
            {c.name}
          </button>
        ))}
        <div className="protocol-search">
          <Search size={16} aria-hidden="true" />
          <input
            ref={searchRef}
            type="search"
            className="protocol-search-input"
            placeholder={t('protocolos_page.placeholder')}
            value={query}
            onChange={(e) => setQuery(e.target.value)}
          />
        </div>
      </nav>

      <section className="protocolos-section">
        <div className="protocolos-grid">
          {filtered.map((p) => (
            <ProtocolCard key={p.id} protocol={p} lang={lang} t={t} />
          ))}
        </div>
        {filtered.length === 0 && (
          <div className="protocol-empty-state">{t('protocolos_page.no_results')}</div>
        )}
      </section>
    </div>
  )
}
```

- [ ] **Step 3: `components/protocolos/ProtocolCard.jsx`**

```jsx
import Link from 'next/link'
import { CalendarDays, Clock, ListChecks, Signal } from 'lucide-react'

// Estimativa rápida para o card (o detalhe calcula sobre o conteúdo completo)
function readingMin(protocol) {
  const words = (protocol.description || '').split(/\s+/).filter(Boolean).length
  return Math.max(1, Math.round(words / 200))
}

export default function ProtocolCard({ protocol, lang, t }) {
  const dateStr = protocol.updatedAt ? protocol.updatedAt.slice(0, 7) : ''
  return (
    <Link href={`/${lang}/protocolos/${protocol.slug}`} className="protocol-card">
      <span className="protocol-card-top-strip" style={{ background: protocol.categoryColor }} />
      <div className="protocol-card-body">
        <span className="protocol-card-category">{protocol.categoryName}</span>
        {protocol.difficulty && (
          <span className={`protocol-difficulty protocol-difficulty--${protocol.difficulty}`}>
            <Signal size={12} aria-hidden="true" />
            {t(`protocolos_detalhe.dificuldade_${protocol.difficulty}`)}
          </span>
        )}
        <h2 className="protocol-card-title">{protocol.title}</h2>
        <p className="protocol-card-desc">{protocol.description}</p>
        <div className="protocol-card-meta">
          <span className="protocol-card-meta-item">
            <ListChecks size={14} aria-hidden="true" />
            {protocol.stepCount} {t('protocolos_page.passos')}
          </span>
          <span className="protocol-card-meta-item">
            <CalendarDays size={14} aria-hidden="true" />
            {dateStr}
          </span>
          <span className="protocol-card-meta-item">
            <Clock size={14} aria-hidden="true" />
            {readingMin(protocol)} {t('protocolos_page.minutos_leitura')}
          </span>
          {protocol.isUpdated && (
            <span className="protocol-card-updated">{t('protocolos_page.actualizado')}</span>
          )}
        </div>
      </div>
    </Link>
  )
}
```

- [ ] **Step 4: Commit**

```bash
git add "app/[lang]/(public)/protocolos/page.js" "app/[lang]/(public)/protocolos/protocolosPageClient.jsx" components/protocolos/ProtocolCard.jsx
git commit -m "feat(protocolos): add public index page with filters, search and cards"
```

---

## Task 5: Detalhe público — `/[lang]/protocolos/[slug]` + CSS

**Files:**
- Create: `app/[lang]/(public)/protocolos/[slug]/page.js`
- Create: `app/[lang]/(public)/protocolos/[slug]/protocoloDetailClient.jsx`
- Create: `components/protocolos/ProtocolStep.jsx`
- Create: `components/protocolos/ProtocolSidebar.jsx`
- Create: `components/protocolos/ProtocolQuiz.jsx`
- Modify: `styles/globals.css` — bloco `/* CLINICAL PROTOCOLS */`

- [ ] **Step 1: Server Component `[slug]/page.js`**

```jsx
import { notFound } from 'next/navigation'
import { loadTranslations, SUPPORTED_LANGS, DEFAULT_LANG, t } from '@/lib/i18n'
import { getPublicProtocolBySlug } from '@/lib/actions/protocolos'
import ProtocoloDetailClient from './protocoloDetailClient'

export const dynamic = 'force-dynamic'

export async function generateMetadata({ params }) {
  const { lang, slug } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const protocol = await getPublicProtocolBySlug(slug, safeLang)
  if (!protocol) return { title: t(translations, 'protocolos_detalhe.erro_carregar') }
  return {
    title: `${protocol.title} — ${t(translations, 'protocolos_page.hero_title')}`,
    description: protocol.description,
    alternates: { languages: { pt: `/pt/protocolos/${slug}`, en: `/en/protocols/${slug}` } },
  }
}

export default async function ProtocoloDetalhePage({ params }) {
  const { lang, slug } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const protocol = await getPublicProtocolBySlug(slug, safeLang)
  if (!protocol) notFound()
  return <ProtocoloDetailClient lang={safeLang} protocol={protocol} />
}
```

- [ ] **Step 2: Client Component `protocoloDetailClient.jsx`** (resumo, red flags, passos interativos + progresso, proveniência, quiz, partilha, barra mobile)

```jsx
'use client'

import { useContext, useEffect, useMemo, useState } from 'react'
import {
  ArrowUpRight, CalendarDays, CheckCircle2, Clock, Copy, Download, ListChecks, Share2,
  ShieldAlert, TriangleAlert, Zap,
} from 'lucide-react'
import { LangContext } from '@/lib/contexts'
import { getSectionHref } from '@/lib/i18n-routes'
import { Breadcrumb } from '@/components/ui/Breadcrumb'
import ProtocolStep from '@/components/protocolos/ProtocolStep'
import ProtocolSidebar from '@/components/protocolos/ProtocolSidebar'
import ProtocolQuiz from '@/components/protocolos/ProtocolQuiz'

function estimateReadingTime(protocol) {
  const text = [
    protocol.summary,
    protocol.safetyNotes,
    protocol.redFlags,
    ...protocol.steps.map((s) => `${s.label} ${s.title} ${s.body}`),
  ].join(' ')
  return Math.max(1, Math.round(text.split(/\s+/).filter(Boolean).length / 200))
}

function formatMonthYear(iso, lang) {
  if (!iso) return ''
  try {
    return new Intl.DateTimeFormat(lang === 'pt' ? 'pt-PT' : 'en-US', {
      month: 'long', year: 'numeric',
    }).format(new Date(iso))
  } catch {
    return iso.slice(0, 7)
  }
}

export default function ProtocoloDetailClient({ lang, protocol }) {
  const { t } = useContext(LangContext)
  const storageKey = `cf_protocolo_progress_${protocol.slug}`

  const [done, setDone] = useState(() => {
    if (typeof window === 'undefined') return []
    try { return JSON.parse(localStorage.getItem(storageKey) || '[]') } catch { return [] }
  })
  const [copied, setCopied] = useState(false)
  const total = protocol.steps.length
  const readingMin = useMemo(() => estimateReadingTime(protocol), [protocol])

  useEffect(() => {
    try { localStorage.setItem(storageKey, JSON.stringify(done)) } catch { /* privado/erro */ }
  }, [done, storageKey])

  const toggleStep = (id) =>
    setDone((d) => (d.includes(id) ? d.filter((x) => x !== id) : [...d, id]))

  const pageUrl = typeof window !== 'undefined'
    ? window.location.href
    : `/${lang}/protocolos/${protocol.slug}`

  const share = async () => {
    if (typeof navigator !== 'undefined' && navigator.share) {
      try { await navigator.share({ title: protocol.title, url: pageUrl }) } catch { /* cancelado */ }
      return
    }
    window.open(`https://wa.me/?text=${encodeURIComponent(`${protocol.title} — ${pageUrl}`)}`, '_blank', 'noopener')
  }

  const copyLink = async () => {
    try {
      await navigator.clipboard.writeText(pageUrl)
      setCopied(true)
      setTimeout(() => setCopied(false), 2000)
    } catch { /* clipboard indisponível */ }
  }

  const mentionedDrugs = useMemo(() => {
    const seen = new Set()
    const out = []
    for (const s of protocol.steps) {
      for (const d of s.drugs) {
        const key = d.label.toLowerCase()
        if (!seen.has(key)) { seen.add(key); out.push(d.label) }
      }
    }
    return out
  }, [protocol])

  return (
    <div className="protocol-detail">
      <Breadcrumb items={[
        { label: t('nav.inicio'), href: '/' + lang },
        { label: t('protocolos_detalhe.breadcrumb_protocolos'), href: getSectionHref(lang, 'protocolos') },
        { label: protocol.category.name, href: getSectionHref(lang, 'protocolos') },
        { label: protocol.title },
      ]} />

      {total > 0 && (
        <div className="protocol-progress">
          <div className="protocol-progress-track">
            <div className="protocol-progress-fill" style={{ width: `${Math.round((done.length / total) * 100)}%` }} />
          </div>
          <span className="protocol-progress-label">
            {t('protocolos_detalhe.passo')} {done.length} {t('protocolos_detalhe.de')} {total}
          </span>
        </div>
      )}

      <div className="protocol-detail-layout">
        <main>
          <div className="protocol-hero">
            <span className="protocol-category">{protocol.category.name}</span>
            <h1>{protocol.title}</h1>
            <div className="protocol-hero-meta">
              <span className="protocol-meta-item">
                <CalendarDays size={14} aria-hidden="true" />
                {t('protocolos_detalhe.actualizado_em')}: {formatMonthYear(protocol.updatedAt, lang)}
              </span>
              <span className="protocol-meta-sep">·</span>
              <span className="protocol-meta-item">
                <ListChecks size={14} aria-hidden="true" />
                {total} {t('protocolos_detalhe.passos')}
              </span>
              <span className="protocol-meta-sep">·</span>
              <span className="protocol-meta-item">
                <Clock size={14} aria-hidden="true" />
                {readingMin} {t('protocolos_detalhe.minutos_leitura')}
              </span>
            </div>
          </div>

          {protocol.summary && (
            <div className="quick-summary">
              <Zap size={20} className="qs-icon" aria-hidden="true" />
              <div className="qs-body">
                <div className="qs-title">{t('protocolos_detalhe.resumo_rapido')}</div>
                <p className="qs-text">{protocol.summary}</p>
              </div>
            </div>
          )}

          {protocol.redFlags && (
            <div className="red-flags-box">
              <ShieldAlert size={18} className="rf-icon" aria-hidden="true" />
              <div>
                <div className="rf-title">{t('protocolos_detalhe.sinais_alarme')}</div>
                <p className="rf-body">{protocol.redFlags}</p>
              </div>
            </div>
          )}

          {total > 0 && (
            <section className="steps-section">
              <div className="steps-title">{t('protocolos_detalhe.passo_a_passo')}</div>
              {protocol.steps.map((step, i) => (
                <ProtocolStep
                  key={step.id}
                  step={step}
                  index={i}
                  done={done.includes(step.id)}
                  onToggle={() => toggleStep(step.id)}
                  t={t}
                />
              ))}
            </section>
          )}

          {protocol.safetyNotes && (
            <div className="notes-box">
              <TriangleAlert size={18} className="notes-icon" aria-hidden="true" />
              <div>
                <div className="notes-title">{t('protocolos_detalhe.notas_seguranca')}</div>
                <p className="notes-body">{protocol.safetyNotes}</p>
              </div>
            </div>
          )}

          {protocol.source && (
            <div className="provenance-box">
              <div className="provenance-title">{t('protocolos_detalhe.o_que_diz_a_norma')}</div>
              <p className="provenance-text">{protocol.source}</p>
              {protocol.sourceUrl && (
                <a href={protocol.sourceUrl} target="_blank" rel="noopener noreferrer" className="provenance-link">
                  {t('protocolos_detalhe.fonte_oficial')}
                  <ArrowUpRight size={14} aria-hidden="true" />
                </a>
              )}
            </div>
          )}

          {protocol.quizzes.length > 0 && <ProtocolQuiz quizzes={protocol.quizzes} t={t} />}

          <div className="protocol-share-row">
            <a
              href={`https://wa.me/?text=${encodeURIComponent(`${protocol.title} — ${pageUrl}`)}`}
              target="_blank"
              rel="noopener noreferrer"
              className="protocol-share-btn"
            >
              <Share2 size={16} aria-hidden="true" />
              {t('protocolos_detalhe.partilhar')}
            </a>
            <button className="protocol-share-btn" onClick={copyLink}>
              {copied ? <CheckCircle2 size={16} aria-hidden="true" /> : <Copy size={16} aria-hidden="true" />}
              {copied ? t('protocolos_detalhe.copiado') : t('protocolos_detalhe.copiar_link')}
            </button>
          </div>
        </main>

        <ProtocolSidebar protocol={protocol} mentionedDrugs={mentionedDrugs} t={t} />
      </div>

      <div className="protocol-mobile-bar">
        {protocol.pdfUrl && (
          <a href={protocol.pdfUrl} target="_blank" rel="noopener noreferrer" className="protocol-mobile-btn protocol-mobile-btn--secondary">
            <Download size={16} aria-hidden="true" />
            {t('protocolos_detalhe.descarregar_pdf')}
          </a>
        )}
        <button onClick={share} className="protocol-mobile-btn protocol-mobile-btn--primary">
          <Share2 size={16} aria-hidden="true" />
          {t('protocolos_detalhe.partilhar')}
        </button>
      </div>
    </div>
  )
}
```

- [ ] **Step 3: Componentes públicos**

`components/protocolos/ProtocolStep.jsx` (checkbox + badges de evidência + chips com dose toque-expande):

```jsx
'use client'

import { useState } from 'react'
import { CheckCircle2, Circle, FlaskConical, Pill } from 'lucide-react'

// Heurística simples: chip de medicamento → Pill; chip de teste/analítica → FlaskConical
function chipIcon(label) {
  return /test|analit|exame|k\+|egfr|map|glic/i.test(label) ? FlaskConical : Pill
}

export default function ProtocolStep({ step, index, done, onToggle, t }) {
  const [openDrug, setOpenDrug] = useState(null)
  return (
    <div className={`protocol-step ${done ? 'is-done' : ''}`} id={`passo-${index + 1}`}>
      <button
        className="step-check"
        onClick={onToggle}
        aria-pressed={done}
        aria-label={`${t('protocolos_detalhe.passo')} ${index + 1}`}
      >
        {done ? <CheckCircle2 size={24} aria-hidden="true" /> : <Circle size={24} aria-hidden="true" />}
      </button>
      <div className="step-number">{index + 1}</div>
      <div className="step-content">
        {step.label && <div className="step-label">{step.label}</div>}
        {(step.recommendation || step.evidence) && (
          <div className="step-badges">
            {step.recommendation && (
              <span className={`step-badge step-badge--rec-${step.recommendation}`}>
                {t(`protocolos_detalhe.recomendacao_${step.recommendation}`)}
              </span>
            )}
            {step.evidence && (
              <span className={`step-badge step-badge--ev-${step.evidence}`}>
                {t(`protocolos_detalhe.evidencia_${step.evidence}`)}
              </span>
            )}
          </div>
        )}
        <div className="step-title">{step.title}</div>
        <p className="step-body">{step.body}</p>
        {step.drugs.length > 0 && (
          <div className="step-drugs">
            {step.drugs.map((d, i) => {
              const Icon = chipIcon(d.label)
              return (
                <div key={i} className="step-drug-wrap">
                  <button
                    className={`step-drug ${openDrug === i ? 'is-open' : ''}`}
                    onClick={() => setOpenDrug(openDrug === i ? null : i)}
                    aria-expanded={openDrug === i}
                  >
                    <Icon size={13} aria-hidden="true" />
                    {d.label}
                  </button>
                  {openDrug === i && d.dose && (
                    <div className="step-drug-dose">
                      {t('protocolos_detalhe.dose')}: {d.dose}
                    </div>
                  )}
                </div>
              )
            })}
          </div>
        )}
      </div>
    </div>
  )
}
```

`components/protocolos/ProtocolSidebar.jsx`:

```jsx
import { Download, FileText } from 'lucide-react'

export default function ProtocolSidebar({ protocol, mentionedDrugs, t }) {
  return (
    <aside className="protocol-sidebar">
      {protocol.steps.length > 0 && (
        <div className="sidebar-card">
          <div className="sidebar-label">{t('protocolos_detalhe.neste_protocolo')}</div>
          <ul className="toc-list">
            {protocol.steps.map((s, i) => (
              <li key={s.id}>
                <a href={`#passo-${i + 1}`}>
                  <span className="toc-num">{i + 1}</span>
                  {s.title}
                </a>
              </li>
            ))}
          </ul>
        </div>
      )}
      {mentionedDrugs.length > 0 && (
        <div className="sidebar-card">
          <div className="sidebar-label">{t('protocolos_detalhe.farmacos_mencionados')}</div>
          <ul className="drug-list">
            {mentionedDrugs.map((name) => <li key={name}>• {name}</li>)}
          </ul>
        </div>
      )}
      {protocol.references.length > 0 && (
        <div className="sidebar-card">
          <div className="sidebar-label">{t('protocolos_detalhe.referencias')}</div>
          {protocol.references.map((r) => (
            <a key={r.id} href={r.url} target="_blank" rel="noopener noreferrer" className="ref-link">
              <FileText size={13} aria-hidden="true" />
              {r.title}
            </a>
          ))}
        </div>
      )}
      {protocol.pdfUrl && (
        <a href={protocol.pdfUrl} target="_blank" rel="noopener noreferrer" className="download-btn">
          <Download size={15} aria-hidden="true" />
          {t('protocolos_detalhe.descarregar_pdf')}
        </a>
      )}
    </aside>
  )
}
```

`components/protocolos/ProtocolQuiz.jsx` (pontuação efémera, sem contas):

```jsx
'use client'

import { useState } from 'react'
import { CheckCircle2, CircleHelp, XCircle } from 'lucide-react'

export default function ProtocolQuiz({ quizzes, t }) {
  const [index, setIndex] = useState(0)
  const [selected, setSelected] = useState(null)
  const [score, setScore] = useState(0)
  const [finished, setFinished] = useState(false)
  const quiz = quizzes[index]
  if (!quiz) return null

  const answer = (i) => {
    if (selected !== null) return
    setSelected(i)
    if (i === quiz.correctIndex) setScore((s) => s + 1)
  }
  const next = () => {
    if (index + 1 >= quizzes.length) { setFinished(true); return }
    setIndex(index + 1)
    setSelected(null)
  }

  return (
    <section className="quiz-box">
      <div className="quiz-header">
        <CircleHelp size={18} aria-hidden="true" />
        <span className="quiz-title">{t('protocolos_detalhe.testa_te')}</span>
        <span className="quiz-count">{index + 1}/{quizzes.length}</span>
      </div>
      {finished ? (
        <div className="quiz-result">
          <CheckCircle2 size={22} aria-hidden="true" />
          {t('protocolos_detalhe.acertaste')} {score} {t('protocolos_detalhe.de')} {quizzes.length}
        </div>
      ) : (
        <>
          <p className="quiz-question">{quiz.question}</p>
          <div className="quiz-options">
            {quiz.options.map((opt, i) => {
              let cls = 'quiz-option'
              if (selected !== null) {
                if (i === quiz.correctIndex) cls += ' is-correct'
                else if (i === selected) cls += ' is-wrong'
                else cls += ' is-dim'
              }
              return (
                <button key={i} className={cls} onClick={() => answer(i)} disabled={selected !== null}>
                  {selected !== null && i === quiz.correctIndex && <CheckCircle2 size={16} aria-hidden="true" />}
                  {selected !== null && i === selected && i !== quiz.correctIndex && <XCircle size={16} aria-hidden="true" />}
                  {opt}
                </button>
              )
            })}
          </div>
          {selected !== null && (
            <div className="quiz-feedback">
              {quiz.explanation && (
                <p className="quiz-explanation">
                  <strong>{t('protocolos_detalhe.explicacao')}:</strong> {quiz.explanation}
                </p>
              )}
              <button className="quiz-next" onClick={next}>
                {index + 1 < quizzes.length ? t('protocolos_detalhe.continuar') : t('protocolos_detalhe.ver_resultado')}
              </button>
            </div>
          )}
        </>
      )}
    </section>
  )
}
```

- [ ] **Step 4: CSS — bloco `/* CLINICAL PROTOCOLS */` no fim de `styles/globals.css`** (usar `var(--color-brand-*)`; overrides `html.dark`; breakpoints 840px e 640px)

```css
/* ==========================================================
   CLINICAL PROTOCOLS — /[lang]/protocolos
   ========================================================== */

/* ----- Lista: filtros ----- */
.protocol-filters-bar {
  max-width: 1100px;
  margin: 0 auto;
  padding: 8px 24px 28px;
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
  align-items: center;
}
.protocol-filter-btn {
  padding: 7px 16px;
  border-radius: 999px;
  border: 1px solid var(--color-brand-divider);
  background: var(--color-brand-bg);
  font-size: 13px;
  font-weight: 500;
  color: var(--color-brand-deep);
  cursor: pointer;
  transition: all 0.15s;
}
.protocol-filter-btn:hover { border-color: var(--color-brand-accent); color: var(--color-brand-accent); }
.protocol-filter-btn.active { background: var(--color-brand-accent); color: #fff; border-color: var(--color-brand-accent); }
.protocol-search { position: relative; display: flex; align-items: center; margin-left: auto; color: var(--color-brand-deep); opacity: 0.55; }
.protocol-search svg { position: absolute; left: 10px; pointer-events: none; }
.protocol-search-input {
  padding: 8px 12px 8px 32px;
  border-radius: 10px;
  border: 1px solid var(--color-brand-divider);
  background: var(--color-brand-bg);
  font-size: 13px;
  width: 220px;
  color: var(--color-brand-deep);
}
.protocol-search-input:focus { outline: 2px solid var(--color-brand-accent); outline-offset: 1px; }

/* ----- Lista: grid + cards ----- */
.protocolos-section { max-width: 1100px; margin: 0 auto; padding: 0 24px 100px; }
.protocolos-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
  gap: 20px;
}
.protocol-card {
  background: var(--color-brand-bg);
  border-radius: 16px;
  border: 1px solid var(--color-brand-divider);
  box-shadow: 0 1px 2px rgba(15, 26, 20, 0.04), 0 4px 12px rgba(15, 26, 20, 0.06);
  overflow: hidden;
  text-decoration: none;
  color: inherit;
  display: flex;
  flex-direction: column;
  transition: transform 0.25s cubic-bezier(0.22, 1, 0.36, 1), box-shadow 0.25s;
}
.protocol-card:hover { transform: translateY(-3px); box-shadow: 0 8px 24px rgba(15, 26, 20, 0.10), 0 2px 8px rgba(15, 26, 20, 0.06); }
.protocol-card-top-strip { height: 4px; }
.protocol-card-body { padding: 20px 22px; flex: 1; display: flex; flex-direction: column; }
.protocol-card-category {
  display: inline-flex;
  align-self: flex-start;
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.05em;
  text-transform: uppercase;
  padding: 3px 10px;
  border-radius: 999px;
  background: rgba(10, 132, 79, 0.08);
  color: var(--color-brand-accent);
  margin-bottom: 12px;
}
.protocol-difficulty {
  display: inline-flex;
  align-self: flex-start;
  align-items: center;
  gap: 4px;
  font-size: 11px;
  font-weight: 600;
  padding: 2px 9px;
  border-radius: 999px;
  margin-bottom: 10px;
}
.protocol-difficulty--iniciante { background: rgba(10, 132, 79, 0.1); color: var(--color-brand-accent); }
.protocol-difficulty--intermedio { background: rgba(245, 158, 11, 0.12); color: #92400e; }
.protocol-difficulty--avancado { background: rgba(220, 38, 38, 0.10); color: #991b1b; }
.protocol-card-title { font-size: 16px; font-weight: 700; line-height: 1.35; letter-spacing: -0.01em; margin-bottom: 8px; }
.protocol-card-desc { font-size: 13px; color: var(--color-brand-deep); opacity: 0.65; line-height: 1.55; margin-bottom: 14px; flex: 1; }
.protocol-card-meta {
  display: flex;
  gap: 14px;
  flex-wrap: wrap;
  font-size: 12px;
  color: var(--color-brand-deep);
  opacity: 0.5;
  padding-top: 14px;
  border-top: 1px solid var(--color-brand-divider);
}
.protocol-card-meta-item { display: inline-flex; align-items: center; gap: 5px; }
.protocol-card-updated { font-size: 11px; color: var(--color-brand-accent); font-weight: 600; margin-left: auto; }
.protocol-empty-state { grid-column: 1 / -1; text-align: center; padding: 60px 24px; color: var(--color-brand-deep); opacity: 0.5; }

/* ----- Detalhe: progresso ----- */
.protocol-progress {
  max-width: 1100px;
  margin: 0 auto;
  padding: 14px 24px 0;
  display: flex;
  align-items: center;
  gap: 12px;
  position: sticky;
  top: 0;
  z-index: 40;
  background: var(--color-brand-bg);
}
.protocol-progress-track { flex: 1; height: 6px; border-radius: 999px; background: var(--color-brand-divider); overflow: hidden; }
.protocol-progress-fill { height: 100%; background: var(--color-brand-accent); border-radius: 999px; transition: width 0.3s ease; }
.protocol-progress-label { font-size: 12px; font-weight: 600; color: var(--color-brand-deep); opacity: 0.6; white-space: nowrap; }

/* ----- Detalhe: layout ----- */
.protocol-detail-layout {
  max-width: 1100px;
  margin: 0 auto;
  padding: 24px 24px 100px;
  display: grid;
  grid-template-columns: 1fr 320px;
  gap: 48px;
  align-items: start;
}
.protocol-hero {
  padding: 28px 30px;
  background: var(--color-brand-bg);
  border-radius: 18px;
  border: 1px solid var(--color-brand-divider);
  margin-bottom: 24px;
}
.protocol-category {
  display: inline-block;
  font-size: 12px;
  font-weight: 700;
  letter-spacing: 0.06em;
  text-transform: uppercase;
  padding: 4px 12px;
  border-radius: 999px;
  background: rgba(10, 132, 79, 0.08);
  color: var(--color-brand-accent);
  margin-bottom: 14px;
}
.protocol-hero h1 { font-size: clamp(24px, 3.5vw, 36px); font-weight: 800; letter-spacing: -0.02em; line-height: 1.15; margin-bottom: 12px; }
.protocol-hero-meta { display: flex; gap: 10px; flex-wrap: wrap; font-size: 13px; color: var(--color-brand-deep); opacity: 0.6; }
.protocol-meta-item { display: inline-flex; align-items: center; gap: 5px; }
.protocol-meta-sep { opacity: 0.4; }

/* ----- Resumo rápido ----- */
.quick-summary {
  background: var(--color-brand-bg-alt);
  border-radius: 14px;
  padding: 18px 22px;
  margin-bottom: 24px;
  border-left: 4px solid var(--color-brand-accent);
  display: flex;
  gap: 14px;
  align-items: flex-start;
}
.qs-icon { flex-shrink: 0; color: var(--color-brand-accent); }
.qs-title { font-size: 13px; font-weight: 700; color: var(--color-brand-accent); margin-bottom: 6px; text-transform: uppercase; letter-spacing: 0.05em; }
.qs-text { font-size: 14px; line-height: 1.65; color: var(--color-brand-deep); opacity: 0.85; }

/* ----- Sinais de alarme (vermelho) ----- */
.red-flags-box {
  background: #fef2f2;
  border-radius: 12px;
  border: 1px solid #dc2626;
  padding: 16px 20px;
  margin-bottom: 24px;
  display: flex;
  gap: 10px;
  align-items: flex-start;
}
.rf-icon { flex-shrink: 0; color: #dc2626; }
.rf-title { font-size: 12px; font-weight: 700; color: #991b1b; margin-bottom: 4px; text-transform: uppercase; letter-spacing: 0.05em; }
.rf-body { font-size: 13px; line-height: 1.6; color: #991b1b; opacity: 0.9; }

/* ----- Passos ----- */
.steps-section { margin-bottom: 24px; }
.steps-title { font-size: 13px; font-weight: 700; letter-spacing: 0.06em; text-transform: uppercase; color: var(--color-brand-deep); opacity: 0.45; margin-bottom: 16px; }
.protocol-step {
  display: flex;
  gap: 14px;
  align-items: flex-start;
  padding: 18px 22px;
  background: var(--color-brand-bg);
  border-radius: 14px;
  border: 1px solid var(--color-brand-divider);
  margin-bottom: 10px;
  transition: box-shadow 0.2s, border-color 0.2s, opacity 0.2s;
}
.protocol-step:hover { box-shadow: 0 3px 12px rgba(15, 26, 20, 0.06); border-color: var(--color-brand-accent); }
.protocol-step.is-done { opacity: 0.62; }
.step-check {
  background: none;
  border: none;
  cursor: pointer;
  color: var(--color-brand-divider);
  padding: 2px 0;
  flex-shrink: 0;
}
.step-check svg { transition: color 0.2s; }
.step-check:hover svg { color: var(--color-brand-accent); }
.protocol-step.is-done .step-check svg { color: var(--color-brand-accent); }
.step-number {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: var(--color-brand-accent);
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  font-weight: 800;
  flex-shrink: 0;
}
.protocol-step.is-done .step-number { background: var(--color-brand-accent); opacity: 0.7; }
.step-content { flex: 1; }
.step-label { font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; color: var(--color-brand-accent); margin-bottom: 4px; }
.step-badges { display: flex; gap: 6px; flex-wrap: wrap; margin: 4px 0 6px; }
.step-badge { font-size: 11px; font-weight: 700; padding: 2px 9px; border-radius: 999px; }
.step-badge--rec-strong { background: var(--color-brand-accent); color: #fff; }
.step-badge--rec-conditional { background: rgba(245, 158, 11, 0.15); color: #92400e; }
.step-badge--ev-high { background: rgba(10, 132, 79, 0.12); color: var(--color-brand-accent); }
.step-badge--ev-moderate { background: rgba(245, 158, 11, 0.15); color: #92400e; }
.step-badge--ev-low { background: rgba(220, 38, 38, 0.10); color: #991b1b; }
.step-title { font-size: 15px; font-weight: 700; margin-bottom: 8px; }
.step-body { font-size: 13px; line-height: 1.65; color: var(--color-brand-deep); opacity: 0.8; }
.step-drugs { display: flex; flex-wrap: wrap; gap: 8px; margin-top: 10px; }
.step-drug-wrap { display: flex; flex-direction: column; gap: 6px; align-items: flex-start; }
.step-drug {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  padding: 4px 10px;
  border-radius: 6px;
  background: rgba(10, 132, 79, 0.08);
  border: 1px solid var(--color-brand-accent);
  font-size: 12px;
  font-weight: 600;
  color: var(--color-brand-accent);
  cursor: pointer;
  font-family: inherit;
}
.step-drug:hover, .step-drug.is-open { background: var(--color-brand-accent); color: #fff; }
.step-drug-dose {
  font-size: 12px;
  color: var(--color-brand-deep);
  opacity: 0.75;
  background: var(--color-brand-bg-alt);
  padding: 5px 10px;
  border-radius: 6px;
}

/* ----- Notas de segurança (âmbar) ----- */
.notes-box {
  background: #fffbeb;
  border-radius: 12px;
  border: 1px solid #f59e0b;
  padding: 16px 20px;
  margin-bottom: 24px;
  display: flex;
  gap: 10px;
  align-items: flex-start;
}
.notes-icon { flex-shrink: 0; color: #b45309; }
.notes-title { font-size: 12px; font-weight: 700; color: #92400e; margin-bottom: 4px; text-transform: uppercase; letter-spacing: 0.05em; }
.notes-body { font-size: 13px; line-height: 1.6; color: #92400e; opacity: 0.9; }

/* ----- Proveniência ----- */
.provenance-box {
  background: var(--color-brand-bg-alt);
  border-radius: 12px;
  border: 1px solid var(--color-brand-divider);
  padding: 16px 20px;
  margin-bottom: 24px;
}
.provenance-title { font-size: 12px; font-weight: 700; color: var(--color-brand-deep); opacity: 0.55; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 6px; }
.provenance-text { font-size: 13px; line-height: 1.6; color: var(--color-brand-deep); opacity: 0.85; margin-bottom: 8px; }
.provenance-link { display: inline-flex; align-items: center; gap: 5px; font-size: 13px; font-weight: 600; color: var(--color-brand-accent); text-decoration: none; }
.provenance-link:hover { text-decoration: underline; }

/* ----- Sidebar ----- */
.protocol-sidebar { position: sticky; top: 90px; }
.sidebar-card {
  background: var(--color-brand-bg);
  border-radius: 14px;
  border: 1px solid var(--color-brand-divider);
  padding: 18px;
  margin-bottom: 14px;
}
.sidebar-label { font-size: 11px; font-weight: 700; letter-spacing: 0.06em; text-transform: uppercase; color: var(--color-brand-deep); opacity: 0.4; margin-bottom: 10px; }
.toc-list { list-style: none; display: flex; flex-direction: column; gap: 6px; }
.toc-list a { font-size: 13px; color: var(--color-brand-accent); text-decoration: none; display: flex; align-items: center; gap: 8px; }
.toc-list a:hover { text-decoration: underline; }
.toc-num {
  width: 20px;
  height: 20px;
  border-radius: 50%;
  background: rgba(10, 132, 79, 0.08);
  color: var(--color-brand-accent);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 11px;
  font-weight: 700;
  flex-shrink: 0;
}
.drug-list { list-style: none; display: flex; flex-direction: column; gap: 6px; font-size: 13px; color: var(--color-brand-deep); opacity: 0.8; }
.ref-link {
  font-size: 13px;
  color: var(--color-brand-accent);
  text-decoration: none;
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 6px 0;
  border-bottom: 1px solid var(--color-brand-divider);
}
.ref-link:last-child { border-bottom: none; }
.ref-link:hover { text-decoration: underline; }
.download-btn {
  width: 100%;
  padding: 11px;
  background: var(--color-brand-accent);
  color: #fff;
  border: none;
  border-radius: 10px;
  font-size: 13px;
  font-weight: 700;
  cursor: pointer;
  text-align: center;
  text-decoration: none;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  margin-top: 6px;
}
.download-btn:hover { background: #0d6b3f; }

/* ----- Partilha ----- */
.protocol-share-row { display: flex; gap: 10px; flex-wrap: wrap; margin-top: 28px; }
.protocol-share-btn {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 9px 16px;
  border-radius: 999px;
  border: 1px solid var(--color-brand-divider);
  background: var(--color-brand-bg);
  font-size: 13px;
  font-weight: 600;
  color: var(--color-brand-deep);
  cursor: pointer;
  text-decoration: none;
  transition: border-color 0.15s, color 0.15s;
}
.protocol-share-btn:hover { border-color: var(--color-brand-accent); color: var(--color-brand-accent); }

/* ----- Quiz ----- */
.quiz-box {
  background: var(--color-brand-bg);
  border-radius: 14px;
  border: 1px solid var(--color-brand-divider);
  padding: 20px 22px;
  margin-top: 28px;
}
.quiz-header { display: flex; align-items: center; gap: 8px; margin-bottom: 12px; color: var(--color-brand-accent); }
.quiz-title { font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; }
.quiz-count { margin-left: auto; font-size: 12px; font-weight: 700; color: var(--color-brand-deep); opacity: 0.5; }
.quiz-question { font-size: 14px; font-weight: 600; margin-bottom: 12px; }
.quiz-options { display: flex; flex-direction: column; gap: 8px; }
.quiz-option {
  display: flex;
  align-items: center;
  gap: 8px;
  text-align: left;
  padding: 10px 14px;
  border-radius: 10px;
  border: 1px solid var(--color-brand-divider);
  background: var(--color-brand-bg);
  font-size: 13px;
  color: var(--color-brand-deep);
  cursor: pointer;
  font-family: inherit;
  transition: border-color 0.15s;
}
.quiz-option:hover:not(:disabled) { border-color: var(--color-brand-accent); }
.quiz-option.is-correct { border-color: var(--color-brand-accent); background: rgba(10, 132, 79, 0.08); color: var(--color-brand-accent); font-weight: 600; }
.quiz-option.is-wrong { border-color: #dc2626; background: rgba(220, 38, 38, 0.06); color: #991b1b; }
.quiz-option.is-dim { opacity: 0.5; }
.quiz-feedback { margin-top: 12px; }
.quiz-explanation { font-size: 13px; line-height: 1.6; color: var(--color-brand-deep); opacity: 0.8; margin-bottom: 12px; }
.quiz-next {
  padding: 9px 18px;
  border-radius: 999px;
  background: var(--color-brand-accent);
  color: #fff;
  border: none;
  font-size: 13px;
  font-weight: 700;
  cursor: pointer;
}
.quiz-next:hover { background: #0d6b3f; }
.quiz-result { display: flex; align-items: center; gap: 10px; font-size: 15px; font-weight: 700; color: var(--color-brand-accent); }

/* ----- Barra mobile (≤840px) ----- */
.protocol-mobile-bar {
  display: none;
  position: sticky;
  bottom: 0;
  z-index: 40;
  background: var(--color-brand-bg);
  border-top: 1px solid var(--color-brand-divider);
  padding: 10px 16px;
  gap: 10px;
}
.protocol-mobile-btn {
  flex: 1;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  padding: 12px;
  border-radius: 10px;
  font-size: 13px;
  font-weight: 700;
  text-decoration: none;
  cursor: pointer;
  border: none;
  font-family: inherit;
}
.protocol-mobile-btn--secondary { background: var(--color-brand-bg-alt); color: var(--color-brand-deep); border: 1px solid var(--color-brand-divider); }
.protocol-mobile-btn--primary { background: var(--color-brand-accent); color: #fff; }

/* ----- Dark mode ----- */
html.dark .protocol-card,
html.dark .protocol-hero,
html.dark .protocol-step,
html.dark .sidebar-card,
html.dark .quiz-box { background: var(--color-brand-bg-alt); }
html.dark .protocol-filter-btn,
html.dark .protocol-search-input { background: var(--color-brand-bg-alt); }
html.dark .red-flags-box { background: rgba(220, 38, 38, 0.10); border-color: rgba(220, 38, 38, 0.5); }
html.dark .red-flags-box .rf-title,
html.dark .red-flags-box .rf-body { color: #fca5a5; }
html.dark .notes-box { background: rgba(245, 158, 11, 0.10); border-color: rgba(245, 158, 11, 0.5); }
html.dark .notes-box .notes-title,
html.dark .notes-box .notes-body { color: #fcd34d; }
html.dark .protocol-difficulty--intermedio,
html.dark .step-badge--ev-moderate,
html.dark .step-badge--rec-conditional { color: #fcd34d; }
html.dark .protocol-difficulty--avancado,
html.dark .step-badge--ev-low { color: #fca5a5; }
html.dark .step-drug { color: var(--color-brand-accent); }
html.dark .protocol-progress { background: var(--color-brand-bg); }

/* ----- Responsivo ----- */
@media (max-width: 840px) {
  .protocol-detail-layout { grid-template-columns: 1fr; gap: 24px; padding-bottom: 140px; }
  .protocol-sidebar { position: static; }
  .protocol-mobile-bar { display: flex; }
  .protocol-progress { top: 0; }
}
@media (max-width: 640px) {
  .protocol-filters-bar { flex-direction: column; align-items: stretch; }
  .protocol-search { margin-left: 0; width: 100%; }
  .protocol-search-input { width: 100%; }
  .protocolos-grid { grid-template-columns: 1fr; }
  .protocol-hero { padding: 22px 20px; }
}
```

- [ ] **Step 5: Commit**

```bash
git add "app/[lang]/(public)/protocolos/[slug]/page.js" "app/[lang]/(public)/protocolos/[slug]/protocoloDetailClient.jsx" components/protocolos/ProtocolStep.jsx components/protocolos/ProtocolSidebar.jsx components/protocolos/ProtocolQuiz.jsx styles/globals.css
git commit -m "feat(protocolos): add detail page with interactive steps, red flags, quiz, share and responsive CSS"
```

---

## Task 6: Admin — página + categorias

**Files:**
- Create: `app/[lang]/admin/(protected)/protocolos/page.js`
- Create: `components/admin/ProtocolsAdminPage.jsx`
- Create: `components/admin/ProtocolCategoryForm.jsx`

- [ ] **Step 1: Server Component `app/[lang]/admin/(protected)/protocolos/page.js`**

```jsx
import { getAllProtocolCategories, getAllClinicalProtocols } from '@/lib/actions/protocolos'
import { getCurrentRole } from '@/lib/actions/content'
import ProtocolsAdminPage from '@/components/admin/ProtocolsAdminPage'

export const dynamic = 'force-dynamic'

export default async function ProtocolsAdminRoute({ params }) {
  const { lang } = await params
  const [categories, protocols, currentUserRole] = await Promise.all([
    getAllProtocolCategories(),
    getAllClinicalProtocols(),
    getCurrentRole(),
  ])
  return (
    <ProtocolsAdminPage
      lang={lang}
      initialCategories={categories}
      initialProtocols={protocols}
      currentUserRole={currentUserRole}
    />
  )
}
```

- [ ] **Step 2: `components/admin/ProtocolsAdminPage.jsx`** (duas tabelas + 3 painéis slide-in; reutiliza `admin-card`, `admin-table`, `admin-btn`, `admin-badge-*`, `admin-message`)

```jsx
'use client'

import { useCallback, useState } from 'react'
import { useRouter } from 'next/navigation'
import {
  archiveProtocol, archiveProtocolCategory, createProtocolCategory, deleteProtocol,
  deleteProtocolCategory, getAllProtocolCategories, getAllClinicalProtocols, getProtocolDetail,
  restoreProtocol, restoreProtocolCategory, updateProtocolCategory,
} from '@/lib/actions/protocolos'
import ProtocolCategoryForm from './ProtocolCategoryForm'
import ProtocolForm from './ProtocolForm'
import ProtocolContentForm from './ProtocolContentForm'

function statusBadge(status) {
  if (status === 'published') return <span className="admin-badge admin-badge-success">Publicado</span>
  if (status === 'draft') return <span className="admin-badge admin-badge-warning">Rascunho</span>
  return <span className="admin-badge">Arquivado</span>
}

export default function ProtocolsAdminPage({ lang, initialCategories, initialProtocols, currentUserRole }) {
  const router = useRouter()
  const [categories, setCategories] = useState(initialCategories)
  const [protocols, setProtocols] = useState(initialProtocols)
  const [message, setMessage] = useState(null)
  const [error, setError] = useState(null)

  // Painel: Categoria
  const [catPanelOpen, setCatPanelOpen] = useState(false)
  const [catPanelRendered, setCatPanelRendered] = useState(false)
  const [editingCategory, setEditingCategory] = useState(null)

  // Painel: Protocolo (base)
  const [protoPanelOpen, setProtoPanelOpen] = useState(false)
  const [protoPanelRendered, setProtoPanelRendered] = useState(false)
  const [editingProtocol, setEditingProtocol] = useState(null)

  // Painel: Conteúdo (passos + referências + quiz)
  const [contentPanelOpen, setContentPanelOpen] = useState(false)
  const [contentPanelRendered, setContentPanelRendered] = useState(false)
  const [contentProtocolId, setContentProtocolId] = useState(null)
  const [contentProtocolTitle, setContentProtocolTitle] = useState('')
  const [contentDetail, setContentDetail] = useState(null)

  const openPanel = (renderedSetter, openSetter) => {
    renderedSetter(true)
    requestAnimationFrame(() => openSetter(true))
  }
  const closePanel = (openSetter, renderedSetter) => {
    openSetter(false)
    setTimeout(() => renderedSetter(false), 250)
  }

  const showMessage = (ok, text) => {
    if (ok) { setMessage(text); setError(null) }
    else { setError(text); setMessage(null) }
  }

  const reload = useCallback(async () => {
    const [cats, protos] = await Promise.all([getAllProtocolCategories(), getAllClinicalProtocols()])
    setCategories(cats)
    setProtocols(protos)
    router.refresh()
  }, [router])

  const run = async (fn, okText) => {
    const res = await fn()
    showMessage(res.success, res.success ? okText : res.error)
    if (res.success) reload()
  }

  const openCategoryForm = (cat) => {
    setEditingCategory(cat)
    openPanel(setCatPanelRendered, setCatPanelOpen)
  }
  const openProtocolForm = (proto) => {
    setEditingProtocol(proto)
    openPanel(setProtoPanelRendered, setProtoPanelOpen)
  }
  const openContent = async (proto) => {
    const detail = await getProtocolDetail(proto.id)
    if (!detail) { showMessage(false, 'Não foi possível carregar o conteúdo.'); return }
    setContentProtocolId(detail.id)
    setContentProtocolTitle(detail.title_pt)
    setContentDetail(detail)
    openPanel(setContentPanelRendered, setContentPanelOpen)
  }

  const isSuper = currentUserRole === 'superadmin'

  return (
    <div className="admin-protocols">
      <div className="admin-page-header">
        <h1>Protocolos Clínicos</h1>
        <p className="admin-page-subtitle">Categorias, protocolos e conteúdo (passos, referências e quiz).</p>
      </div>

      {message && <div className="admin-message admin-success-message">{message}</div>}
      {error && <div className="admin-message admin-error-message">{error}</div>}

      <div className="admin-card" style={{ marginBottom: 24 }}>
        <div className="admin-card-header">
          <h2>Categorias</h2>
          <button className="admin-btn admin-btn-primary" onClick={() => openCategoryForm(null)}>Nova categoria</button>
        </div>
        <div className="admin-card-body">
          {categories.length === 0 ? (
            <p className="admin-table-empty">Sem categorias.</p>
          ) : (
            <table className="admin-table">
              <thead>
                <tr><th>Nome</th><th>Slug</th><th>Cor</th><th>Estado</th><th>Protocolos</th><th>Ações</th></tr>
              </thead>
              <tbody>
                {categories.map((c) => (
                  <tr key={c.id} className={c.is_archived ? 'admin-table-row-archived' : ''}>
                    <td>{c.name_pt} / {c.name_en}</td>
                    <td>{c.slug}</td>
                    <td><span style={{ display: 'inline-block', width: 18, height: 18, borderRadius: 4, background: c.color }} /></td>
                    <td>{statusBadge(c.is_archived ? 'archived' : c.status)}</td>
                    <td>{c.protocolCount}</td>
                    <td className="admin-table-actions">
                      <button className="admin-btn admin-btn-sm" onClick={() => openCategoryForm(c)}>Editar</button>
                      {!c.is_archived ? (
                        <button className="admin-btn admin-btn-sm" onClick={() => run(() => archiveProtocolCategory(c.id), 'Categoria arquivada.')}>Arquivar</button>
                      ) : (
                        isSuper && (
                          <button className="admin-btn admin-btn-sm" onClick={() => run(() => restoreProtocolCategory(c.id), 'Categoria restaurada.')}>Restaurar</button>
                        )
                      )}
                      {isSuper && (
                        <button className="admin-btn admin-btn-sm admin-btn-danger" onClick={() => {
                          if (window.confirm('Eliminar categoria? (bloqueado se tiver protocolos)')) run(() => deleteProtocolCategory(c.id), 'Categoria eliminada.')
                        }}>Eliminar</button>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      </div>

      <div className="admin-card">
        <div className="admin-card-header">
          <h2>Protocolos</h2>
          <button className="admin-btn admin-btn-primary" onClick={() => openProtocolForm(null)}>Novo protocolo</button>
        </div>
        <div className="admin-card-body">
          {protocols.length === 0 ? (
            <p className="admin-table-empty">Sem protocolos.</p>
          ) : (
            <table className="admin-table">
              <thead>
                <tr><th>Título</th><th>Categoria</th><th>Estado</th><th>Passos</th><th>Ordem</th><th>Ações</th></tr>
              </thead>
              <tbody>
                {protocols.map((p) => (
                  <tr key={p.id} className={p.is_archived ? 'admin-table-row-archived' : ''}>
                    <td>{p.title_pt} / {p.title_en}</td>
                    <td>{p.categoryName}</td>
                    <td>{statusBadge(p.is_archived ? 'archived' : p.status)}</td>
                    <td>{p.stepCount}</td>
                    <td>{p.sort_order}</td>
                    <td className="admin-table-actions">
                      <button className="admin-btn admin-btn-sm" onClick={() => openProtocolForm(p)}>Editar</button>
                      <button className="admin-btn admin-btn-sm" onClick={() => openContent(p)}>Gerir conteúdo</button>
                      {!p.is_archived ? (
                        <button className="admin-btn admin-btn-sm" onClick={() => run(() => archiveProtocol(p.id), 'Protocolo arquivado.')}>Arquivar</button>
                      ) : (
                        isSuper && (
                          <button className="admin-btn admin-btn-sm" onClick={() => run(() => restoreProtocol(p.id), 'Protocolo restaurado.')}>Restaurar</button>
                        )
                      )}
                      {isSuper && (
                        <button className="admin-btn admin-btn-sm admin-btn-danger" onClick={() => {
                          if (window.confirm('Eliminar protocolo? (elimina passos, referências e quiz)')) run(() => deleteProtocol(p.id), 'Protocolo eliminado.')
                        }}>Eliminar</button>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      </div>

      {catPanelRendered && (
        <ProtocolCategoryForm
          category={editingCategory}
          panelOpen={catPanelOpen}
          onClose={() => closePanel(setCatPanelOpen, setCatPanelRendered)}
          onSaved={(ok, text) => { showMessage(ok, text); if (ok) reload(); closePanel(setCatPanelOpen, setCatPanelRendered) }}
        />
      )}

      {protoPanelRendered && (
        <ProtocolForm
          protocol={editingProtocol}
          categories={categories}
          panelOpen={protoPanelOpen}
          onClose={() => closePanel(setProtoPanelOpen, setProtoPanelRendered)}
          onSaved={(ok, text) => { showMessage(ok, text); if (ok) reload(); closePanel(setProtoPanelOpen, setProtoPanelRendered) }}
        />
      )}

      {contentPanelRendered && (
        <ProtocolContentForm
          protocolId={contentProtocolId}
          protocolTitle={contentProtocolTitle}
          initialContent={contentDetail}
          panelOpen={contentPanelOpen}
          onClose={() => closePanel(setContentPanelOpen, setContentPanelRendered)}
          onSaved={(ok, text) => { showMessage(ok, text); if (ok) reload(); closePanel(setContentPanelOpen, setContentPanelRendered) }}
        />
      )}
    </div>
  )
}
```

- [ ] **Step 3: `components/admin/ProtocolCategoryForm.jsx`** (painel slide-in — mesmo padrão `GuideCursoForm`: overlay + `translateX(100%)→0`, estilos inline)

```jsx
'use client'

import { useState } from 'react'
import { createProtocolCategory, updateProtocolCategory } from '@/lib/actions/protocolos'

const panelStyle = {
  position: 'fixed', top: 0, right: 0, height: '100%', width: 'min(640px, 100%)',
  background: '#fff', zIndex: 1000, overflowY: 'auto', padding: 32,
  transform: 'translateX(100%)', transition: 'transform 250ms ease', boxShadow: '-8px 0 32px rgba(0,0,0,0.15)',
}
const overlayStyle = { position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.4)', zIndex: 999, backdropFilter: 'blur(2px)' }
const inputStyle = { width: '100%', padding: 8, borderRadius: 8, border: '1px solid #ddd', marginBottom: 12 }
const labelStyle = { display: 'block', fontSize: 13, fontWeight: 600, marginBottom: 4 }
const btnStyle = { padding: '10px 18px', borderRadius: 8, border: 'none', cursor: 'pointer', fontWeight: 600 }

export default function ProtocolCategoryForm({ category, panelOpen, onClose, onSaved }) {
  const [slug, setSlug] = useState(category?.slug || '')
  const [namePt, setNamePt] = useState(category?.name_pt || '')
  const [nameEn, setNameEn] = useState(category?.name_en || '')
  const [color, setColor] = useState(category?.color || '#0a844f')
  const [status, setStatus] = useState(category?.status || 'draft')
  const [sortOrder, setSortOrder] = useState(category?.sort_order ?? 0)
  const [error, setError] = useState(null)
  const [saving, setSaving] = useState(false)

  const save = async () => {
    setSaving(true)
    setError(null)
    const payload = { slug, name_pt: namePt, name_en: nameEn, color, status, sort_order: Number(sortOrder) }
    const res = category
      ? await updateProtocolCategory(category.id, payload)
      : await createProtocolCategory(payload)
    setSaving(false)
    if (!res.success) { setError(res.error); return }
    onSaved(true, category ? 'Categoria atualizada.' : 'Categoria criada.')
  }

  return (
    <>
      {panelOpen && <div style={overlayStyle} onClick={onClose} />}
      <div style={{ ...panelStyle, ...(panelOpen ? { transform: 'translateX(0)' } : {}) }} role="dialog" aria-label="Categoria">
        <h2 style={{ marginTop: 0 }}>{category ? 'Editar categoria' : 'Nova categoria'}</h2>
        {error && <p style={{ color: '#b91c1c', background: '#fef2f2', padding: 10, borderRadius: 8 }}>{error}</p>}
        <label style={labelStyle}>Slug</label>
        <input style={inputStyle} value={slug} onChange={(e) => setSlug(e.target.value)} placeholder="cardiologia" />
        <label style={labelStyle}>Nome (PT)</label>
        <input style={inputStyle} value={namePt} onChange={(e) => setNamePt(e.target.value)} />
        <label style={labelStyle}>Name (EN)</label>
        <input style={inputStyle} value={nameEn} onChange={(e) => setNameEn(e.target.value)} />
        <label style={labelStyle}>Cor</label>
        <input type="color" value={color} onChange={(e) => setColor(e.target.value)} style={{ marginBottom: 12 }} />
        <label style={labelStyle}>Estado</label>
        <select style={inputStyle} value={status} onChange={(e) => setStatus(e.target.value)}>
          <option value="draft">Rascunho</option>
          <option value="published">Publicado</option>
        </select>
        <label style={labelStyle}>Ordem</label>
        <input type="number" style={inputStyle} value={sortOrder} onChange={(e) => setSortOrder(Number(e.target.value))} />
        <div style={{ display: 'flex', gap: 10, marginTop: 8 }}>
          <button style={{ ...btnStyle, background: '#0a844f', color: '#fff' }} onClick={save} disabled={saving}>
            {saving ? 'A guardar...' : 'Guardar'}
          </button>
          <button style={{ ...btnStyle, background: '#eee' }} onClick={onClose}>Cancelar</button>
        </div>
      </div>
    </>
  )
}
```

- [ ] **Step 4: Commit**

```bash
git add "app/[lang]/admin/(protected)/protocolos/page.js" components/admin/ProtocolsAdminPage.jsx components/admin/ProtocolCategoryForm.jsx
git commit -m "feat(admin): add protocols admin page with categories management"
```

---

## Task 7: Admin — ProtocolForm

**Files:**
- Create: `components/admin/ProtocolForm.jsx`

- [ ] **Step 1: `components/admin/ProtocolForm.jsx`** (painel slide-in largo, maxWidth 720 — mesmos estilos inline do `ProtocolCategoryForm`; categoria num `<select>`; `is_updated` toggle; `difficulty` select com 3 opções)

```jsx
'use client'

import { useState } from 'react'
import { createProtocol, updateProtocol } from '@/lib/actions/protocolos'

const panelStyle = {
  position: 'fixed', top: 0, right: 0, height: '100%', width: 'min(720px, 100%)',
  background: '#fff', zIndex: 1000, overflowY: 'auto', padding: 32,
  transform: 'translateX(100%)', transition: 'transform 250ms ease', boxShadow: '-8px 0 32px rgba(0,0,0,0.15)',
}
const overlayStyle = { position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.4)', zIndex: 999, backdropFilter: 'blur(2px)' }
const inputStyle = { width: '100%', padding: 8, borderRadius: 8, border: '1px solid #ddd', marginBottom: 12 }
const labelStyle = { display: 'block', fontSize: 13, fontWeight: 600, marginBottom: 4 }
const btnStyle = { padding: '10px 18px', borderRadius: 8, border: 'none', cursor: 'pointer', fontWeight: 600 }

export default function ProtocolForm({ protocol, categories, panelOpen, onClose, onSaved }) {
  const [slug, setSlug] = useState(protocol?.slug || '')
  const [categoryId, setCategoryId] = useState(protocol?.category_id || categories[0]?.id || '')
  const [titlePt, setTitlePt] = useState(protocol?.title_pt || '')
  const [titleEn, setTitleEn] = useState(protocol?.title_en || '')
  const [descriptionPt, setDescriptionPt] = useState(protocol?.description_pt || '')
  const [descriptionEn, setDescriptionEn] = useState(protocol?.description_en || '')
  const [summaryPt, setSummaryPt] = useState(protocol?.summary_pt || '')
  const [summaryEn, setSummaryEn] = useState(protocol?.summary_en || '')
  const [safetyNotesPt, setSafetyNotesPt] = useState(protocol?.safety_notes_pt || '')
  const [safetyNotesEn, setSafetyNotesEn] = useState(protocol?.safety_notes_en || '')
  const [redFlagsPt, setRedFlagsPt] = useState(protocol?.red_flags_pt || '')
  const [redFlagsEn, setRedFlagsEn] = useState(protocol?.red_flags_en || '')
  const [sourcePt, setSourcePt] = useState(protocol?.source_pt || '')
  const [sourceEn, setSourceEn] = useState(protocol?.source_en || '')
  const [sourceUrl, setSourceUrl] = useState(protocol?.source_url || '')
  const [difficulty, setDifficulty] = useState(protocol?.difficulty || 'iniciante')
  const [pdfUrl, setPdfUrl] = useState(protocol?.pdf_url || '')
  const [isUpdated, setIsUpdated] = useState(protocol?.is_updated ?? true)
  const [status, setStatus] = useState(protocol?.status || 'draft')
  const [sortOrder, setSortOrder] = useState(protocol?.sort_order ?? 0)
  const [error, setError] = useState(null)
  const [saving, setSaving] = useState(false)

  const save = async () => {
    setSaving(true)
    setError(null)
    const payload = {
      slug, category_id: categoryId,
      title_pt: titlePt, title_en: titleEn,
      description_pt: descriptionPt, description_en: descriptionEn,
      summary_pt: summaryPt, summary_en: summaryEn,
      safety_notes_pt: safetyNotesPt, safety_notes_en: safetyNotesEn,
      red_flags_pt: redFlagsPt, red_flags_en: redFlagsEn,
      source_pt: sourcePt, source_en: sourceEn, source_url: sourceUrl,
      difficulty, pdf_url: pdfUrl, is_updated: isUpdated,
      status, sort_order: Number(sortOrder),
    }
    const res = protocol
      ? await updateProtocol(protocol.id, payload)
      : await createProtocol(payload)
    setSaving(false)
    if (!res.success) { setError(res.error); return }
    onSaved(true, protocol ? 'Protocolo atualizado.' : 'Protocolo criado.')
  }

  return (
    <>
      {panelOpen && <div style={overlayStyle} onClick={onClose} />}
      <div style={{ ...panelStyle, ...(panelOpen ? { transform: 'translateX(0)' } : {}) }} role="dialog" aria-label="Protocolo">
        <h2 style={{ marginTop: 0 }}>{protocol ? 'Editar protocolo' : 'Novo protocolo'}</h2>
        {error && <p style={{ color: '#b91c1c', background: '#fef2f2', padding: 10, borderRadius: 8 }}>{error}</p>}

        <label style={labelStyle}>Slug</label>
        <input style={inputStyle} value={slug} onChange={(e) => setSlug(e.target.value)} placeholder="hipertensao-arterial-resistente" />

        <label style={labelStyle}>Categoria</label>
        <select style={inputStyle} value={categoryId} onChange={(e) => setCategoryId(e.target.value)}>
          {categories.map((c) => <option key={c.id} value={c.id}>{c.name_pt} / {c.name_en}</option>)}
        </select>

        <label style={labelStyle}>Título (PT)</label>
        <input style={inputStyle} value={titlePt} onChange={(e) => setTitlePt(e.target.value)} />
        <label style={labelStyle}>Title (EN)</label>
        <input style={inputStyle} value={titleEn} onChange={(e) => setTitleEn(e.target.value)} />

        <label style={labelStyle}>Descrição (PT) — card da listagem</label>
        <textarea style={{ ...inputStyle, minHeight: 60 }} value={descriptionPt} onChange={(e) => setDescriptionPt(e.target.value)} />
        <label style={labelStyle}>Description (EN)</label>
        <textarea style={{ ...inputStyle, minHeight: 60 }} value={descriptionEn} onChange={(e) => setDescriptionEn(e.target.value)} />

        <label style={labelStyle}>Resumo rápido (PT) — "Resumo Rápido" no detalhe</label>
        <textarea style={{ ...inputStyle, minHeight: 70 }} value={summaryPt} onChange={(e) => setSummaryPt(e.target.value)} />
        <label style={labelStyle}>Quick summary (EN)</label>
        <textarea style={{ ...inputStyle, minHeight: 70 }} value={summaryEn} onChange={(e) => setSummaryEn(e.target.value)} />

        <label style={labelStyle}>Notas de Segurança (PT)</label>
        <textarea style={{ ...inputStyle, minHeight: 60 }} value={safetyNotesPt} onChange={(e) => setSafetyNotesPt(e.target.value)} />
        <label style={labelStyle}>Safety notes (EN)</label>
        <textarea style={{ ...inputStyle, minHeight: 60 }} value={safetyNotesEn} onChange={(e) => setSafetyNotesEn(e.target.value)} />

        <label style={labelStyle}>Sinais de Alarme (PT) — uma linha por sinal</label>
        <textarea style={{ ...inputStyle, minHeight: 60 }} value={redFlagsPt} onChange={(e) => setRedFlagsPt(e.target.value)} placeholder="PA ≥ 180/120 mmHg com sintomas → encaminhar de imediato" />
        <label style={labelStyle}>Red flags (EN)</label>
        <textarea style={{ ...inputStyle, minHeight: 60 }} value={redFlagsEn} onChange={(e) => setRedFlagsEn(e.target.value)} />

        <label style={labelStyle}>Proveniência (PT) — "O que diz a Norma"</label>
        <input style={inputStyle} value={sourcePt} onChange={(e) => setSourcePt(e.target.value)} placeholder="Norma DGS n.º 001/2026 — Abordagem da Hipertensão Arterial" />
        <label style={labelStyle}>Source (EN)</label>
        <input style={inputStyle} value={sourceEn} onChange={(e) => setSourceEn(e.target.value)} />
        <label style={labelStyle}>Source URL</label>
        <input style={inputStyle} value={sourceUrl} onChange={(e) => setSourceUrl(e.target.value)} placeholder="https://www.dgs.pt/..." />

        <label style={labelStyle}>Dificuldade</label>
        <select style={inputStyle} value={difficulty} onChange={(e) => setDifficulty(e.target.value)}>
          <option value="iniciante">Iniciante</option>
          <option value="intermedio">Intermedio</option>
          <option value="avancado">Avancado</option>
        </select>

        <label style={labelStyle}>URL do PDF (opcional)</label>
        <input style={inputStyle} value={pdfUrl} onChange={(e) => setPdfUrl(e.target.value)} placeholder="https://..." />

        <label style={labelStyle}>Estado</label>
        <select style={inputStyle} value={status} onChange={(e) => setStatus(e.target.value)}>
          <option value="draft">Rascunho</option>
          <option value="published">Publicado</option>
        </select>

        <label style={labelStyle}>Ordem</label>
        <input type="number" style={inputStyle} value={sortOrder} onChange={(e) => setSortOrder(Number(e.target.value))} />

        <label style={{ ...labelStyle, display: 'flex', alignItems: 'center', gap: 8, cursor: 'pointer' }}>
          <input type="checkbox" checked={isUpdated} onChange={(e) => setIsUpdated(e.target.checked)} />
          Chip "Actualizado" no card
        </label>

        <div style={{ display: 'flex', gap: 10, marginTop: 8 }}>
          <button style={{ ...btnStyle, background: '#0a844f', color: '#fff' }} onClick={save} disabled={saving}>
            {saving ? 'A guardar...' : 'Guardar'}
          </button>
          <button style={{ ...btnStyle, background: '#eee' }} onClick={onClose}>Cancelar</button>
        </div>
      </div>
    </>
  )
}
```

- [ ] **Step 2: Commit**

```bash
git add components/admin/ProtocolForm.jsx
git commit -m "feat(admin): add ProtocolForm slide-in with clinical fields, difficulty and pdf url"
```

---

## Task 8: Admin — ProtocolContentForm (passos + referências + quiz)

**Files:**
- Create: `components/admin/ProtocolContentForm.jsx`

- [ ] **Step 1: `components/admin/ProtocolContentForm.jsx`** (painel slide-in largo maxWidth 780; seções **Passos** (label/title/body + selects recomendação/evidência + linhas de fármacos com dose), **Referências** (title/url) e **Quiz** (pergunta, 4 opções, resposta correta, explicação). Grava em ordem: apaga os removidos → upsert passos → upsert referências → upsert quizzes, cada um com `sort_order: i + 1`)

```jsx
'use client'

import { useMemo, useState } from 'react'
import {
  createProtocolQuiz, createProtocolReference, createProtocolStep,
  deleteProtocolQuiz, deleteProtocolReference, deleteProtocolStep,
  updateProtocolQuiz, updateProtocolReference, updateProtocolStep,
} from '@/lib/actions/protocolos'

const panelStyle = {
  position: 'fixed', top: 0, right: 0, height: '100%', width: 'min(780px, 100%)',
  background: '#fff', zIndex: 1000, overflowY: 'auto', padding: 32,
  transform: 'translateX(100%)', transition: 'transform 250ms ease', boxShadow: '-8px 0 32px rgba(0,0,0,0.15)',
}
const overlayStyle = { position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.4)', zIndex: 999, backdropFilter: 'blur(2px)' }
const inputStyle = { width: '100%', padding: 8, borderRadius: 8, border: '1px solid #ddd', marginBottom: 10 }
const labelStyle = { display: 'block', fontSize: 12, fontWeight: 600, marginBottom: 3 }
const btnStyle = { padding: '9px 16px', borderRadius: 8, border: 'none', cursor: 'pointer', fontWeight: 600 }
const sectionStyle = { border: '1px solid #e5e7e4', borderRadius: 12, padding: 18, marginBottom: 20, background: '#fafaf8' }
const rowStyle = { display: 'flex', gap: 8, alignItems: 'flex-start', marginBottom: 10, background: '#fff', border: '1px solid #e5e7e4', borderRadius: 10, padding: 12 }

export default function ProtocolContentForm({ protocolId, protocolTitle, initialContent, panelOpen, onClose, onSaved }) {
  // -------- Passos --------
  const [steps, setSteps] = useState(() =>
    (initialContent?.steps || []).map((s) => ({
      id: s.id, label_pt: s.label_pt, label_en: s.label_en,
      title_pt: s.title_pt, title_en: s.title_en, body_pt: s.body_pt, body_en: s.body_en,
      recommendation: s.recommendation || '', evidence: s.evidence || '',
      drugs: (s.drugs || []).map((d) => ({ label_pt: d.label_pt, label_en: d.label_en, dose: d.dose || '' })),
    }))
  )
  const [removedStepIds, setRemovedStepIds] = useState([])

  // -------- Referências --------
  const [refs, setRefs] = useState(() =>
    (initialContent?.references || []).map((r) => ({ id: r.id, title_pt: r.title_pt, title_en: r.title_en, url: r.url }))
  )
  const [removedRefIds, setRemovedRefIds] = useState([])

  // -------- Quiz --------
  const [quizzes, setQuizzes] = useState(() =>
    (initialContent?.quizzes || []).map((q) => ({
      id: q.id, question_pt: q.question_pt, question_en: q.question_en,
      option_a_pt: q.option_a_pt, option_b_pt: q.option_b_pt, option_c_pt: q.option_c_pt, option_d_pt: q.option_d_pt,
      option_a_en: q.option_a_en, option_b_en: q.option_b_en, option_c_en: q.option_c_en, option_d_en: q.option_d_en,
      correct_index: q.correct_index, explanation_pt: q.explanation_pt, explanation_en: q.explanation_en,
    }))
  )
  const [removedQuizIds, setRemovedQuizIds] = useState([])

  const [error, setError] = useState(null)
  const [saving, setSaving] = useState(false)
  const [message, setMessage] = useState(null)

  const dirty = useMemo(
    () => steps.length + refs.length + quizzes.length + removedStepIds.length + removedRefIds.length + removedQuizIds.length > 0,
    [steps, refs, quizzes, removedStepIds, removedRefIds, removedQuizIds]
  )

  // helpers genéricos de arrays
  const update = (setter, index, patch) => setter((arr) => arr.map((it, i) => (i === index ? { ...it, ...patch } : it)))
  const remove = (setter, arr, setRemoved, index) => {
    const item = arr[index]
    if (item?.id) setRemoved((ids) => [...ids, item.id])
    setter((list) => list.filter((_, i) => i !== index))
  }

  // -------- Save --------
  const save = async () => {
    setSaving(true)
    setError(null)
    setMessage(null)

    // 1) apagar removidos
    for (const id of removedStepIds) await deleteProtocolStep(id)
    for (const id of removedRefIds) await deleteProtocolReference(id)
    for (const id of removedQuizIds) await deleteProtocolQuiz(id)

    // 2) upsert passos (com sort_order sequencial)
    for (let i = 0; i < steps.length; i += 1) {
      const s = steps[i]
      const payload = {
        label_pt: s.label_pt, label_en: s.label_en, title_pt: s.title_pt, title_en: s.title_en,
        body_pt: s.body_pt, body_en: s.body_en,
        recommendation: s.recommendation || null, evidence: s.evidence || null,
        drugs: s.drugs.filter((d) => d.label_pt.trim() || d.label_en.trim()),
        sort_order: i + 1,
      }
      const res = s.id ? await updateProtocolStep(s.id, payload) : await createProtocolStep(protocolId, payload)
      if (!res.success) { setSaving(false); setError(`Erro no passo ${i + 1}: ${res.error}`); return }
    }

    // 3) upsert referências
    for (let i = 0; i < refs.length; i += 1) {
      const r = refs[i]
      const payload = { title_pt: r.title_pt, title_en: r.title_en, url: r.url, sort_order: i + 1 }
      const res = r.id ? await updateProtocolReference(r.id, payload) : await createProtocolReference(protocolId, payload)
      if (!res.success) { setSaving(false); setError(`Erro na referência ${i + 1}: ${res.error}`); return }
    }

    // 4) upsert quizzes
    for (let i = 0; i < quizzes.length; i += 1) {
      const q = quizzes[i]
      const payload = {
        question_pt: q.question_pt, question_en: q.question_en,
        option_a_pt: q.option_a_pt, option_b_pt: q.option_b_pt, option_c_pt: q.option_c_pt, option_d_pt: q.option_d_pt,
        option_a_en: q.option_a_en, option_b_en: q.option_b_en, option_c_en: q.option_c_en, option_d_en: q.option_d_en,
        correct_index: Number(q.correct_index),
        explanation_pt: q.explanation_pt, explanation_en: q.explanation_en,
        sort_order: i + 1,
      }
      const res = q.id ? await updateProtocolQuiz(q.id, payload) : await createProtocolQuiz(protocolId, payload)
      if (!res.success) { setSaving(false); setError(`Erro na pergunta ${i + 1}: ${res.error}`); return }
    }

    setSaving(false)
    setMessage('Conteúdo guardado.')
    onSaved(true, 'Conteúdo guardado.')
  }

  return (
    <>
      {panelOpen && <div style={overlayStyle} onClick={onClose} />}
      <div style={{ ...panelStyle, ...(panelOpen ? { transform: 'translateX(0)' } : {}) }} role="dialog" aria-label="Conteúdo do protocolo">
        <h2 style={{ marginTop: 0 }}>Conteúdo: {protocolTitle}</h2>
        {message && <p style={{ color: '#065f46', background: '#ecfdf5', padding: 10, borderRadius: 8 }}>{message}</p>}
        {error && <p style={{ color: '#b91c1c', background: '#fef2f2', padding: 10, borderRadius: 8 }}>{error}</p>}

        {/* ============ PASSOS ============ */}
        <div style={sectionStyle}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 }}>
            <h3 style={{ margin: 0 }}>Passos ({steps.length})</h3>
            <button
              style={{ ...btnStyle, background: '#0a844f', color: '#fff' }}
              onClick={() => setSteps((arr) => [...arr, { id: null, label_pt: '', label_en: '', title_pt: '', title_en: '', body_pt: '', body_en: '', recommendation: '', evidence: '', drugs: [] }])}
            >+ Passo</button>
          </div>
          {steps.length === 0 && <p style={{ opacity: 0.6, fontSize: 13 }}>Sem passos. O protocolo aparece só na listagem.</p>}
          {steps.map((s, i) => (
            <div key={s.id ?? `new-${i}`} style={rowStyle}>
              <div style={{ flex: 1 }}>
                <div style={{ display: 'flex', gap: 8 }}>
                  <div style={{ flex: 1 }}>
                    <label style={labelStyle}>Label (PT) — ex. "Confirmar"</label>
                    <input style={inputStyle} value={s.label_pt} onChange={(e) => update(setSteps, i, { label_pt: e.target.value })} />
                  </div>
                  <div style={{ flex: 1 }}>
                    <label style={labelStyle}>Label (EN)</label>
                    <input style={inputStyle} value={s.label_en} onChange={(e) => update(setSteps, i, { label_en: e.target.value })} />
                  </div>
                </div>
                <div style={{ display: 'flex', gap: 8 }}>
                  <div style={{ flex: 1 }}>
                    <label style={labelStyle}>Título (PT)</label>
                    <input style={inputStyle} value={s.title_pt} onChange={(e) => update(setSteps, i, { title_pt: e.target.value })} />
                  </div>
                  <div style={{ flex: 1 }}>
                    <label style={labelStyle}>Title (EN)</label>
                    <input style={inputStyle} value={s.title_en} onChange={(e) => update(setSteps, i, { title_en: e.target.value })} />
                  </div>
                </div>
                <label style={labelStyle}>Corpo (PT)</label>
                <textarea style={{ ...inputStyle, minHeight: 60 }} value={s.body_pt} onChange={(e) => update(setSteps, i, { body_pt: e.target.value })} />
                <label style={labelStyle}>Body (EN)</label>
                <textarea style={{ ...inputStyle, minHeight: 60 }} value={s.body_en} onChange={(e) => update(setSteps, i, { body_en: e.target.value })} />
                <div style={{ display: 'flex', gap: 8 }}>
                  <div style={{ flex: 1 }}>
                    <label style={labelStyle}>Recomendação</label>
                    <select style={inputStyle} value={s.recommendation} onChange={(e) => update(setSteps, i, { recommendation: e.target.value })}>
                      <option value="">— sem badge —</option>
                      <option value="strong">Forte</option>
                      <option value="conditional">Condicional</option>
                    </select>
                  </div>
                  <div style={{ flex: 1 }}>
                    <label style={labelStyle}>Evidência</label>
                    <select style={inputStyle} value={s.evidence} onChange={(e) => update(setSteps, i, { evidence: e.target.value })}>
                      <option value="">— sem badge —</option>
                      <option value="high">Alta</option>
                      <option value="moderate">Moderada</option>
                      <option value="low">Baixa</option>
                    </select>
                  </div>
                </div>

                {/* Fármacos com dose */}
                <div style={{ marginTop: 4 }}>
                  <label style={labelStyle}>Fármacos mencionados</label>
                  {s.drugs.map((d, di) => (
                    <div key={di} style={{ display: 'flex', gap: 6, marginBottom: 6 }}>
                      <input style={{ ...inputStyle, marginBottom: 0, flex: 1 }} placeholder="label_pt" value={d.label_pt} onChange={(e) => update(setSteps, i, { drugs: s.drugs.map((x, xi) => xi === di ? { ...x, label_pt: e.target.value } : x) })} />
                      <input style={{ ...inputStyle, marginBottom: 0, flex: 1 }} placeholder="label_en" value={d.label_en} onChange={(e) => update(setSteps, i, { drugs: s.drugs.map((x, xi) => xi === di ? { ...x, label_en: e.target.value } : x) })} />
                      <input style={{ ...inputStyle, marginBottom: 0, flex: 1 }} placeholder="dose (ex. 25 mg/dia)" value={d.dose} onChange={(e) => update(setSteps, i, { drugs: s.drugs.map((x, xi) => xi === di ? { ...x, dose: e.target.value } : x) })} />
                      <button style={{ ...btnStyle, background: '#fee2e2', color: '#b91c1c' }} onClick={() => update(setSteps, i, { drugs: s.drugs.filter((_, xi) => xi !== di) })}>x</button>
                    </div>
                  ))}
                  <button
                    style={{ ...btnStyle, background: '#eef2ef', fontSize: 12 }}
                    onClick={() => update(setSteps, i, { drugs: [...s.drugs, { label_pt: '', label_en: '', dose: '' }] })}
                  >+ Fármaco</button>
                </div>
              </div>
              <button style={{ ...btnStyle, background: '#fee2e2', color: '#b91c1c' }} onClick={() => remove(setSteps, steps, setRemovedStepIds, i)}>Remover</button>
            </div>
          ))}
        </div>

        {/* ============ REFERÊNCIAS ============ */}
        <div style={sectionStyle}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 }}>
            <h3 style={{ margin: 0 }}>Referências ({refs.length})</h3>
            <button style={{ ...btnStyle, background: '#0a844f', color: '#fff' }} onClick={() => setRefs((arr) => [...arr, { id: null, title_pt: '', title_en: '', url: '' }])}>+ Referência</button>
          </div>
          {refs.map((r, i) => (
            <div key={r.id ?? `new-ref-${i}`} style={rowStyle}>
              <div style={{ flex: 1 }}>
                <div style={{ display: 'flex', gap: 8 }}>
                  <div style={{ flex: 1 }}>
                    <label style={labelStyle}>Título (PT)</label>
                    <input style={inputStyle} value={r.title_pt} onChange={(e) => update(setRefs, i, { title_pt: e.target.value })} />
                  </div>
                  <div style={{ flex: 1 }}>
                    <label style={labelStyle}>Title (EN)</label>
                    <input style={inputStyle} value={r.title_en} onChange={(e) => update(setRefs, i, { title_en: e.target.value })} />
                  </div>
                </div>
                <label style={labelStyle}>URL</label>
                <input style={inputStyle} value={r.url} onChange={(e) => update(setRefs, i, { url: e.target.value })} placeholder="https://..." />
              </div>
              <button style={{ ...btnStyle, background: '#fee2e2', color: '#b91c1c' }} onClick={() => remove(setRefs, refs, setRemovedRefIds, i)}>Remover</button>
            </div>
          ))}
        </div>

        {/* ============ QUIZ ============ */}
        <div style={sectionStyle}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 }}>
            <h3 style={{ margin: 0 }}>Quiz "Testa-te" ({quizzes.length})</h3>
            <button style={{ ...btnStyle, background: '#0a844f', color: '#fff' }} onClick={() => setQuizzes((arr) => [...arr, { id: null, question_pt: '', question_en: '', option_a_pt: '', option_b_pt: '', option_c_pt: '', option_d_pt: '', option_a_en: '', option_b_en: '', option_c_en: '', option_d_en: '', correct_index: 0, explanation_pt: '', explanation_en: '' }])}>+ Pergunta</button>
          </div>
          {quizzes.map((q, i) => (
            <div key={q.id ?? `new-q-${i}`} style={rowStyle}>
              <div style={{ flex: 1 }}>
                <div style={{ display: 'flex', gap: 8 }}>
                  <div style={{ flex: 1 }}>
                    <label style={labelStyle}>Pergunta (PT)</label>
                    <input style={inputStyle} value={q.question_pt} onChange={(e) => update(setQuizzes, i, { question_pt: e.target.value })} />
                  </div>
                  <div style={{ flex: 1 }}>
                    <label style={labelStyle}>Question (EN)</label>
                    <input style={inputStyle} value={q.question_en} onChange={(e) => update(setQuizzes, i, { question_en: e.target.value })} />
                  </div>
                </div>
                {['a', 'b', 'c', 'd'].map((opt) => (
                  <div key={opt} style={{ display: 'flex', gap: 8 }}>
                    <div style={{ flex: 1 }}>
                      <label style={labelStyle}>Opção {opt.toUpperCase()} (PT)</label>
                      <input style={inputStyle} value={q[`option_${opt}_pt`]} onChange={(e) => update(setQuizzes, i, { [`option_${opt}_pt`]: e.target.value })} />
                    </div>
                    <div style={{ flex: 1 }}>
                      <label style={labelStyle}>Option {opt.toUpperCase()} (EN)</label>
                      <input style={inputStyle} value={q[`option_${opt}_en`]} onChange={(e) => update(setQuizzes, i, { [`option_${opt}_en`]: e.target.value })} />
                    </div>
                  </div>
                ))}
                <label style={labelStyle}>Resposta correta</label>
                <select style={inputStyle} value={q.correct_index} onChange={(e) => update(setQuizzes, i, { correct_index: Number(e.target.value) })}>
                  {['A', 'B', 'C', 'D'].map((letter, li) => <option key={letter} value={li}>Opção {letter}</option>)}
                </select>
                <div style={{ display: 'flex', gap: 8 }}>
                  <div style={{ flex: 1 }}>
                    <label style={labelStyle}>Explicação (PT)</label>
                    <textarea style={{ ...inputStyle, minHeight: 50 }} value={q.explanation_pt} onChange={(e) => update(setQuizzes, i, { explanation_pt: e.target.value })} />
                  </div>
                  <div style={{ flex: 1 }}>
                    <label style={labelStyle}>Explanation (EN)</label>
                    <textarea style={{ ...inputStyle, minHeight: 50 }} value={q.explanation_en} onChange={(e) => update(setQuizzes, i, { explanation_en: e.target.value })} />
                  </div>
                </div>
              </div>
              <button style={{ ...btnStyle, background: '#fee2e2', color: '#b91c1c' }} onClick={() => remove(setQuizzes, quizzes, setRemovedQuizIds, i)}>Remover</button>
            </div>
          ))}
        </div>

        <div style={{ display: 'flex', gap: 10, position: 'sticky', bottom: 0, background: '#fff', padding: '12px 0' }}>
          <button style={{ ...btnStyle, background: '#0a844f', color: '#fff' }} onClick={save} disabled={saving || !dirty}>
            {saving ? 'A guardar...' : 'Guardar conteúdo'}
          </button>
          <button style={{ ...btnStyle, background: '#eee' }} onClick={onClose}>Fechar</button>
        </div>
      </div>
    </>
  )
}
```

- [ ] **Step 2: Commit**

```bash
git add components/admin/ProtocolContentForm.jsx
git commit -m "feat(admin): add ProtocolContentForm editor for steps, references and quiz"
```

---

## Task 9: Verificação Final

**Files:**
- Verify: `public/i18n/pt.json`, `public/i18n/en.json`, `lib/actions/protocolos.js`, `lib/i18n-routes.js`, `components/Header.jsx`, `components/MobileDrawer.jsx`, `components/Footer.jsx`, `components/admin/AdminSidebar.jsx`

- [ ] **Step 1: Validar os JSON de i18n (ambos os ficheiros têm de dar parse; sem emojis)**

```bash
node -e "JSON.parse(require('fs').readFileSync('public/i18n/pt.json','utf8')); JSON.parse(require('fs').readFileSync('public/i18n/en.json','utf8')); console.log('i18n JSON OK')"
```

- [ ] **Step 2: Syntax check do actions file e dos componentes novos**

```bash
node --check lib/actions/protocolos.js
```

- [ ] **Step 3: Build de produção (apanha erros de import/export, RSC boundary, JSX)**

```bash
npm run build
```

- [ ] **Step 4: Checklist manual**
  - [ ] Aplicar a migração 039 no Supabase (feito pelo utilizador) e confirmar tabelas + RLS + seed (6 categorias, 6 protocolos, 4 passos da Hipertensão AR, 3 referências, 3 perguntas de quiz).
  - [ ] `/pt/protocolos` e `/en/protocols`: hero, pills de categorias (cor da categoria), pesquisa com atalho `/` e Ctrl/Cmd+K, cards com fita colorida, badge de dificuldade, meta (passos/data/chip Actualizado), sem emojis.
  - [ ] Filtro por categoria + pesquisa combinados; empty state.
  - [ ] `/pt/protocolos/hipertensao-arterial-resistente`: breadcrumb, resumo rápido (Zap), passos interativos com progresso sticky "Passo X de Y" persistido (recarregar a página mantém), chips de fármacos com `Pill`/`FlaskConical` e dose no toque, notas de segurança (âmbar), "O que diz a Norma" com link DGS, sidebar (TOC/Fármacos/Referências), quiz com feedback e explicação, partilha WhatsApp + copiar link, botão PDF apenas se `pdf_url` preenchido.
  - [ ] Dark mode (`html.dark`): cards, badges, caixas de alarme/segurança, painéis admin coerentes.
  - [ ] Mobile ≤840px: grid 1 coluna, sidebar static, barra fixa inferior (PDF + partilhar); ≤640px: filtros em coluna.
  - [ ] Admin: criar/editar categoria (cor visível na fita), criar/editar protocolo (dificuldade, pdf_url, is_updated), gerir conteúdo (passos com badges e fármacos, referências, quiz), arquivar/restaurar/eliminar com gate `superadmin`; publicar → visível na listagem pública.
  - [ ] SEO: `generateMetadata` com `alternates.languages` nas duas páginas públicas.
  - [ ] Zero emojis em todo o fluxo (código, i18n, seed, admin).

---

## Self-Review (Spec → Plano)

- [x] **Listagem** (demos `protocolos-lista.html`): hero com subtítulo, pills "Todos" + categorias, search input, grid `auto-fit minmax(320px,1fr)`, cards com fita superior, categoria em caps, título, descrição, meta (passos/data), chip "Actualizado", empty state → **Task 4**.
- [x] **Detalhe** (demo `protocolos-detalhe.html`): breadcrumb, hero com pill + meta, Resumo Rápido, passos numerados com label/título/corpo e chips de fármacos, Notas de Segurança, sidebar (Neste protocolo / Fármacos mencionados / Referências / Descarregar PDF), grid `1fr 320px` colapsa ≤840px → **Task 5**.
- [x] **Mobile** (demo `protocolos-mobile.html`): mesmos campos, grid 1 coluna, filtros em coluna, barra fixa inferior → **Task 5 CSS** (≤640px/≤840px breakpoints).
- [x] **Pesquisa (melhoramentos para público jovem)**: passos interativos + progresso persistido em `localStorage` → **Task 5**; sinais de alarme → **Task 5** (`red_flags` + caixa ShieldAlert); quiz "Testa-te" com feedback e explicação (efeito de teste, sem streaks/badges — decisão da pesquisa) → **Task 5 + Task 8**; chips de fármacos com dose → **Task 5** (`drugs` JSONB); badges de evidência (GRADE simplificado, nullable) → **Task 5 + Task 8**; proveniência "O que diz a Norma" → **Task 5**; atalho `/` para pesquisa → **Task 4**; partilha WhatsApp + copiar link → **Task 5**; dificuldade nos cards → **Task 4**.
- [x] **Categorias geridas no admin** com cor própria → **Tasks 1, 6**.
- [x] **Modelo completo** (5 tabelas com PT/EN, RLS `admin_all_*` + `anon_read_*`, triggers `update_updated_at_column()`) → **Task 1**.
- [x] **PDF opcional** (`pdf_url` + botão só quando preenchido) → **Tasks 1, 5, 7**.
- [x] **100% Lucide, zero emojis** (Search, Zap, ShieldAlert, CheckCircle2/Circle, ListChecks/CalendarDays/Clock, Pill/FlaskConical, Signal, Download/Share2, ArrowUpRight, FileText, GraduationCap/CircleHelp, ClipboardList) → **Tasks 3, 4, 5, 6**.
- [x] **Server Actions com validação zod** (espelha `guides.js`: `requireAdmin`, `URL_SAFE`, enums) → **Task 2**.
- [x] **i18n** (pares `_pt/_en` em DB, `pt.json`/`en.json`, `PT_TO_EN` `protocolos: 'protocols'`, nav/footer/sidebar) → **Task 3**.
- [x] **Admin slide-in** (padrão dos Guias: 3 painéis, gate de superadmin para restaurar/eliminar, `router.refresh()`) → **Tasks 6, 7, 8**.
- [x] **Verificação** (JSON parse, `node --check`, `npm run build`, checklist manual com dark mode e SEO) → **Task 9**.

**Open questions resolved:**
- Migração numerada `039` (a próxima livre após 038).
- Categorias `ON DELETE RESTRICT` (não se pode eliminar categoria com protocolos) e listagem pública filtra protocolos cuja categoria não esteja published (`filter(Boolean)` no map) para nunca partir a página.
- `recommendation`/`evidence` **NULL na seed** — a UI omite o badge vazio; o editor admin preenche quando houver fonte. Não se inventam níveis de evidência.
- Quiz seedado só para a Hipertensão AR (3 MCQs derivados do conteúdo do próprio demo); os restantes protocolos são cards e o utilizador preenche conteúdo via admin.
- Progresso dos passos em `localStorage` (`cf_protocolo_progress_<slug>`) — sem contas, efémero por dispositivo.
- Partilha = `navigator.share` quando disponível, fallback `wa.me` (link + texto) + copiar link com feedback de 2s.
- `requireAdmin` duplicado em `lib/actions/protocolos.js` (padrão consistente com guides.js/legalContent.js).
- Dificuldade editorial ("iniciante/intermedio/avancado") ajustável no admin.
- PDF = campo `pdf_url` apenas; a auto-geração com `pdf-lib` (já em `package.json`) fica documentada como opção futura fora deste plano.
- Dark mode segue a implementação dos Guias (`html.dark` overrides por componente); painéis admin inline mantêm-se claros como os restantes painéis admin.

---

**Próximo passo:** aplicar a migração `039` no Supabase (feito pelo utilizador), depois "pode implementar" para executar as Tasks 1–9 por commits.
