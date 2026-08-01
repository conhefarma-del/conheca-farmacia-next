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

-- ============================================================
-- Seed de amostra: conteúdo dos demos. Detalhe completo apenas
-- para "Hipertensão Arterial Resistente"; os restantes entram
-- como cards (passos/referências via Admin CMS).
-- recommendation/evidence ficam NULL na seed (não se inventam
-- níveis de evidência).
-- ============================================================

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
