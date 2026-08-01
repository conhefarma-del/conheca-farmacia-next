-- 042: Study guides — universities that teach each course
-- Bilíngue não é necessário: nomes de instituições são substantivos próprios (iguais PT/EN).
-- Padrão: espelho de guide_disciplines (migração 038): RLS admin_all + anon_read, soft-delete.

CREATE TABLE IF NOT EXISTS public.guide_universities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID NOT NULL REFERENCES public.guide_courses(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  city TEXT NOT NULL DEFAULT '',
  is_public BOOLEAN NOT NULL DEFAULT true,
  website_url TEXT NOT NULL DEFAULT '',
  course_url TEXT NOT NULL DEFAULT '',
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
  sort_order INT NOT NULL DEFAULT 0,
  is_archived BOOLEAN NOT NULL DEFAULT false,
  archived_at TIMESTAMPTZ,
  archived_by UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- RLS
ALTER TABLE public.guide_universities ENABLE ROW LEVEL SECURITY;

CREATE POLICY "admin_all_guide_universities" ON public.guide_universities
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()));

CREATE POLICY "anon_read_guide_universities" ON public.guide_universities
  FOR SELECT TO anon, authenticated
  USING (status = 'published' AND is_archived = false);

CREATE TRIGGER set_guide_universities_updated_at
  BEFORE UPDATE ON public.guide_universities
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================================
-- Seed inicial (Angola) — ponto de partida para rever/curar no admin.
-- As URLs apontam para o site institucional; course_url (link direto
-- ao curso) pode ser preenchido depois no painel de administração.
-- ============================================================
DO $$
DECLARE
  v_farmacia UUID;
  v_medicina UUID;
  v_enfermagem UUID;
BEGIN
  SELECT id INTO v_farmacia FROM public.guide_courses WHERE slug = 'farmacia';
  SELECT id INTO v_medicina FROM public.guide_courses WHERE slug = 'medicina';
  SELECT id INTO v_enfermagem FROM public.guide_courses WHERE slug = 'enfermagem';

  -- Farmácia
  INSERT INTO public.guide_universities (course_id, name, city, is_public, website_url, course_url, status, sort_order) VALUES
    (v_farmacia, 'Universidade Agostinho Neto', 'Luanda', true, 'https://www.uan.ao', '', 'published', 1),
    (v_farmacia, 'Universidade José Eduardo dos Santos', 'Huambo', true, 'https://www.ujes.ao', '', 'published', 2);

  -- Medicina
  INSERT INTO public.guide_universities (course_id, name, city, is_public, website_url, course_url, status, sort_order) VALUES
    (v_medicina, 'Universidade Agostinho Neto', 'Luanda', true, 'https://www.uan.ao', '', 'published', 1),
    (v_medicina, 'Universidade José Eduardo dos Santos', 'Huambo', true, 'https://www.ujes.ao', '', 'published', 2),
    (v_medicina, 'Universidade Mandume ya Ndemufayo', 'Lubango', true, 'https://www.umn.ed.ao', '', 'published', 3);

  -- Enfermagem
  INSERT INTO public.guide_universities (course_id, name, city, is_public, website_url, course_url, status, sort_order) VALUES
    (v_enfermagem, 'Universidade Agostinho Neto', 'Luanda', true, 'https://www.uan.ao', '', 'published', 1),
    (v_enfermagem, 'Universidade Católica de Angola', 'Luanda', false, 'https://www.ucan.edu', '', 'published', 2);
END $$;
