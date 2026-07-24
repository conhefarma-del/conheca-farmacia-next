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

-- Triggers for updated_at (reuse existing function if it exists, create if not)
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

-- Seed FAQ tabs + questions from policiesfc/CF-FAQ-Website.md
INSERT INTO public.faq_tabs (slug, label_pt, label_en, sort_order) VALUES
  ('geral', 'Geral', 'General', 1),
  ('parceiros', 'Parceiros e Patrocinadores', 'Partners & Sponsors', 2);

-- Seed questions using a cross-join pattern
DO $$
DECLARE
  geral_id UUID;
  parceiros_id UUID;
BEGIN
  SELECT id INTO geral_id FROM public.faq_tabs WHERE slug = 'geral';
  SELECT id INTO parceiros_id FROM public.faq_tabs WHERE slug = 'parceiros';

  -- Tab: Geral (sort_order 1..5)
  INSERT INTO public.faq_questions (tab_id, question_pt, question_en, answer_pt, answer_en, pending, sort_order) VALUES
  (geral_id,
   'A Conheça Farmácia é uma farmácia?',
   'Is Conheça Farmácia a pharmacy?',
   'Não. Somos uma organização de educação e promoção da saúde — não vendemos medicamentos nem prestamos serviços farmacêuticos comerciais. Este é um dos equívocos mais comuns sobre o nosso trabalho, por isso preferimos deixar claro desde já.',
   'No. We are a health education and promotion organization — we do not sell medicines or provide commercial pharmaceutical services. This is one of the most common misconceptions about our work, so we prefer to make it clear from the start.',
   false, 1),
  (geral_id,
   'O certificado de participação é pago?',
   'Is the participation certificate paid?',
   'Sim. O valor varia de acordo com o evento — pode ser consultado na página de detalhes de cada evento específico.',
   'Yes. The fee varies depending on the event — you can check it on each event''s detail page.',
   false, 2),
  (geral_id,
   'Como me inscrevo num evento?',
   'How do I register for an event?',
   '[a confirmar — descrever o processo de inscrição no website, uma vez definido]',
   '[to be confirmed — describe the registration process on the website, once defined]',
   true, 3),
  (geral_id,
   'Posso cancelar a minha inscrição?',
   'Can I cancel my registration?',
   '[a confirmar — definir política de cancelamento/reembolso antes de publicar]',
   '[to be confirmed — define cancellation/refund policy before publishing]',
   true, 4),
  (geral_id,
   'Como posso tornar-me voluntário na Conheça Farmácia?',
   'How can I become a volunteer at Conheça Farmácia?',
   'Atualmente não estamos em processo de recrutamento de novos colaboradores voluntários. Quando abrirmos novas vagas, o anúncio será feito através das nossas redes sociais.',
   'We are currently not recruiting new volunteers. When new openings become available, the announcement will be made through our social media channels.',
   false, 5);

  -- Tab: Parceiros (sort_order 1..3) — ALL pending
  INSERT INTO public.faq_questions (tab_id, question_pt, question_en, answer_pt, answer_en, pending, sort_order) VALUES
  (parceiros_id,
   'Como posso propor uma parceria com a Conheça Farmácia?',
   'How can I propose a partnership with Conheça Farmácia?',
   '[a confirmar — indicar canal de contacto, ex.: geral@conhecafarmacia.com, ou formulário próprio]',
   '[to be confirmed — indicate contact channel, e.g.: geral@conhecafarmacia.com, or dedicated form]',
   true, 1),
  (parceiros_id,
   'Como posso patrocinar um evento da Conheça Farmácia?',
   'How can I sponsor a Conheça Farmácia event?',
   '[a confirmar — indicar canal de contacto e/ou nível de detalhe a expor publicamente sobre os níveis de patrocínio]',
   '[to be confirmed — indicate contact channel and/or level of detail to publicly disclose about sponsorship levels]',
   true, 2),
  (parceiros_id,
   'Que tipo de contrapartidas os patrocinadores recebem?',
   'What kind of benefits do sponsors receive?',
   '[a confirmar — decidir se o detalhe de contrapartidas (visibilidade de marca, menção institucional, etc.) deve ser público na FAQ, ou tratado apenas diretamente por ofício/proposta]',
   '[to be confirmed — decide whether benefit details (brand visibility, institutional mention, etc.) should be public in the FAQ, or handled directly via proposal]',
   true, 3);
END $$;
