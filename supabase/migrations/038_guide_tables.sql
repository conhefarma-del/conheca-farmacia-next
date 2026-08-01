-- 038: Study guides — courses, disciplines, books, resources
-- Bilíngue (PT/EN), soft-delete via is_archived, gate público via status='published'.
-- Padrão: espelho de faq_tabs/privacy_sections (migrações 034/035).

CREATE TABLE IF NOT EXISTS public.guide_courses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT UNIQUE NOT NULL,
  name_pt TEXT NOT NULL,
  name_en TEXT NOT NULL,
  description_pt TEXT NOT NULL DEFAULT '',
  description_en TEXT NOT NULL DEFAULT '',
  hero_subtitle_pt TEXT NOT NULL DEFAULT '',
  hero_subtitle_en TEXT NOT NULL DEFAULT '',
  icon_emoji TEXT NOT NULL DEFAULT '📚',
  color TEXT NOT NULL DEFAULT '#0a844f',
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
  sort_order INT NOT NULL DEFAULT 0,
  is_archived BOOLEAN NOT NULL DEFAULT false,
  archived_at TIMESTAMPTZ,
  archived_by UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.guide_disciplines (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT UNIQUE NOT NULL,
  course_id UUID NOT NULL REFERENCES public.guide_courses(id) ON DELETE CASCADE,
  name_pt TEXT NOT NULL,
  name_en TEXT NOT NULL,
  description_pt TEXT NOT NULL DEFAULT '',
  description_en TEXT NOT NULL DEFAULT '',
  phase_pt TEXT NOT NULL DEFAULT '',
  phase_en TEXT NOT NULL DEFAULT '',
  importance_pt TEXT NOT NULL DEFAULT '',
  importance_en TEXT NOT NULL DEFAULT '',
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
  sort_order INT NOT NULL DEFAULT 0,
  is_archived BOOLEAN NOT NULL DEFAULT false,
  archived_at TIMESTAMPTZ,
  archived_by UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.guide_books (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  discipline_id UUID NOT NULL REFERENCES public.guide_disciplines(id) ON DELETE CASCADE,
  title_pt TEXT NOT NULL,
  title_en TEXT NOT NULL,
  author TEXT NOT NULL DEFAULT '',
  edition TEXT NOT NULL DEFAULT '',
  year INTEGER,
  cover_url TEXT NOT NULL DEFAULT '',
  team_paragraph_pt TEXT NOT NULL DEFAULT '',
  team_paragraph_en TEXT NOT NULL DEFAULT '',
  -- [{label_pt, label_en, url}] — links externos (loja/editora)
  links JSONB NOT NULL DEFAULT '[]',
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
  sort_order INT NOT NULL DEFAULT 0,
  is_archived BOOLEAN NOT NULL DEFAULT false,
  archived_at TIMESTAMPTZ,
  archived_by UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.guide_resources (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  discipline_id UUID NOT NULL REFERENCES public.guide_disciplines(id) ON DELETE CASCADE,
  title_pt TEXT NOT NULL,
  title_en TEXT NOT NULL,
  description_pt TEXT NOT NULL DEFAULT '',
  description_en TEXT NOT NULL DEFAULT '',
  url TEXT NOT NULL,
  type TEXT NOT NULL DEFAULT 'pdf' CHECK (type IN ('pdf', 'guideline', 'article', 'other')),
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
  sort_order INT NOT NULL DEFAULT 0,
  is_archived BOOLEAN NOT NULL DEFAULT false,
  archived_at TIMESTAMPTZ,
  archived_by UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- RLS
ALTER TABLE public.guide_courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.guide_disciplines ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.guide_books ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.guide_resources ENABLE ROW LEVEL SECURITY;

-- Admin can do everything (auth check enforced via Server Actions + admin_users)
CREATE POLICY "admin_all_guide_courses" ON public.guide_courses
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()));

CREATE POLICY "admin_all_guide_disciplines" ON public.guide_disciplines
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()));

CREATE POLICY "admin_all_guide_books" ON public.guide_books
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()));

CREATE POLICY "admin_all_guide_resources" ON public.guide_resources
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()));

-- Anon can only read published, non-archived data (public pages)
CREATE POLICY "anon_read_guide_courses" ON public.guide_courses
  FOR SELECT TO anon, authenticated
  USING (status = 'published' AND is_archived = false);

CREATE POLICY "anon_read_guide_disciplines" ON public.guide_disciplines
  FOR SELECT TO anon, authenticated
  USING (status = 'published' AND is_archived = false);

CREATE POLICY "anon_read_guide_books" ON public.guide_books
  FOR SELECT TO anon, authenticated
  USING (status = 'published' AND is_archived = false);

CREATE POLICY "anon_read_guide_resources" ON public.guide_resources
  FOR SELECT TO anon, authenticated
  USING (status = 'published' AND is_archived = false);

-- Triggers for updated_at (função já existe — migração 034)
CREATE TRIGGER set_guide_courses_updated_at
  BEFORE UPDATE ON public.guide_courses
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER set_guide_disciplines_updated_at
  BEFORE UPDATE ON public.guide_disciplines
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER set_guide_books_updated_at
  BEFORE UPDATE ON public.guide_books
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER set_guide_resources_updated_at
  BEFORE UPDATE ON public.guide_resources
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================================
-- Seed de amostra: 4 cursos + 1 disciplina completa
-- (Farmácia → Farmacologia, com livro Goodman & Gilman e recurso OMS).
-- O conteúdo editorial completo é introduzido via Admin CMS.
-- ============================================================
INSERT INTO public.guide_courses (slug, name_pt, name_en, description_pt, description_en, hero_subtitle_pt, hero_subtitle_en, icon_emoji, color, status, sort_order) VALUES
  ('farmacia', 'Farmácia', 'Pharmacy',
   'Formação centrada na descoberta, desenvolvimento, produção e uso racional de medicamentos.',
   'Training focused on the discovery, development, production and rational use of medicines.',
   'Do laboratório ao balcão — a ciência que protege a saúde.',
   'From the lab to the counter — the science that protects health.',
   '💊', '#0a844f', 'published', 1),
  ('medicina', 'Medicina', 'Medicine',
   'Formação médica generalista com base nas ciências fundamentais e clínicas.',
   'Generalist medical training grounded in the fundamental and clinical sciences.',
   'A arte de curar, sustentada pela ciência.',
   'The art of healing, grounded in science.',
   '🩺', '#0a844f', 'published', 2),
  ('enfermagem', 'Enfermagem', 'Nursing',
   'Formação em cuidados de enfermagem, gestão e educação para a saúde.',
   'Training in nursing care, management and health education.',
   'Cuidar é a nossa ciência.',
   'Caring is our science.',
   '🩹', '#0a844f', 'published', 3),
  ('analises-clinicas', 'Análises Clínicas', 'Clinical Laboratory Science',
   'Formação em diagnóstico laboratorial e controlo de qualidade.',
   'Training in laboratory diagnostics and quality control.',
   'A verdade escondida em cada amostra.',
   'The truth hidden in every sample.',
   '🔬', '#0a844f', 'published', 4);

DO $$
DECLARE
  farmacia_id UUID;
  farmacologia_id UUID;
BEGIN
  SELECT id INTO farmacia_id FROM public.guide_courses WHERE slug = 'farmacia';

  INSERT INTO public.guide_disciplines (slug, course_id, name_pt, name_en, description_pt, description_en, phase_pt, phase_en, importance_pt, importance_en, status, sort_order)
  VALUES ('farmacologia', farmacia_id,
    'Farmacologia', 'Pharmacology',
    'Estudo dos fármacos, mecanismos de ação, efeitos terapêuticos e adversos.',
    'Study of drugs, mechanisms of action, therapeutic and adverse effects.',
    '2º Ano', '2nd Year',
    'Base fundamental para qualquer profissional que lida com medicamentos. Sem farmacologia, o farmacêutico não consegue compreender interações medicamentosas nem aconselhar doentes.',
    'The fundamental basis for any professional who works with medicines. Without pharmacology, the pharmacist cannot understand drug interactions or counsel patients.',
    'published', 1)
  RETURNING id INTO farmacologia_id;

  INSERT INTO public.guide_books (discipline_id, title_pt, title_en, author, edition, year, cover_url, team_paragraph_pt, team_paragraph_en, links, status, sort_order)
  VALUES (farmacologia_id,
    'Goodman & Gilman''s The Pharmacological Basis of Therapeutics',
    'Goodman & Gilman''s The Pharmacological Basis of Therapeutics',
    'Laurence L. Brunton, Bjorn Knollmann', '14ª Edição', 2023,
    'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1681245397i/63289543.jpg',
    'Considerado a bíblia da farmacologia. Essencial para qualquer estudante de farmácia ou medicina que queira uma compreensão profunda dos mecanismos de ação dos fármacos.',
    'Considered the bible of pharmacology. Essential for any pharmacy or medicine student who wants a deep understanding of drug mechanisms of action.',
    '[{"label_pt":"Comprar na Amazon","label_en":"Buy on Amazon","url":"https://www.amazon.com/dp/1260464164"},{"label_pt":"Ver na Editora","label_en":"View on Publisher","url":"https://www.mhprofessional.com"}]',
    'published', 1);

  INSERT INTO public.guide_resources (discipline_id, title_pt, title_en, description_pt, description_en, url, type, status, sort_order)
  VALUES (farmacologia_id,
    'Lista de Medicamentos Essenciais OMS 2025', 'WHO Model List of Essential Medicines 2025',
    'Lista atualizada de medicamentos essenciais pela Organização Mundial da Saúde.',
    'Updated list of essential medicines by the World Health Organization.',
    'https://www.who.int/publications/i/item/EML2025', 'guideline', 'published', 1);
END $$;
