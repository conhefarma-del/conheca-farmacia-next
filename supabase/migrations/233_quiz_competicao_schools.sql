-- =====================================================================
-- 233 — Quiz Competição: escolas e turmas
-- ---------------------------------------------------------------------
-- Tabelas schools e classes para o sistema de competições inter-escolas.
-- Admin pode criar/editar/eliminar escolas e turmas.
-- Alunos selecionam escola + turma ao entrar numa competição.
-- =====================================================================

-- =====================================================================
-- 1. Escolas
-- =====================================================================
CREATE TABLE IF NOT EXISTS public.schools (
  id           UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  slug         TEXT NOT NULL UNIQUE,
  name         TEXT NOT NULL,
  location     TEXT NOT NULL DEFAULT '',
  status       TEXT NOT NULL DEFAULT 'published' CHECK (status IN ('draft','published')),
  is_archived  BOOLEAN NOT NULL DEFAULT false,
  archived_at  TIMESTAMPTZ,
  archived_by  UUID,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_schools_slug ON public.schools(slug);
CREATE INDEX IF NOT EXISTS idx_schools_status ON public.schools(status);

-- =====================================================================
-- 2. Turmas
-- =====================================================================
CREATE TABLE IF NOT EXISTS public.classes (
  id           UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  slug         TEXT NOT NULL UNIQUE,
  school_id    UUID NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
  name         TEXT NOT NULL,            -- ex: '10.ª A'
  grade        TEXT NOT NULL DEFAULT '', -- ex: '10'
  status       TEXT NOT NULL DEFAULT 'published' CHECK (status IN ('draft','published')),
  is_archived  BOOLEAN NOT NULL DEFAULT false,
  archived_at  TIMESTAMPTZ,
  archived_by  UUID,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (school_id, name)
);

CREATE INDEX IF NOT EXISTS idx_classes_school ON public.classes(school_id);
CREATE INDEX IF NOT EXISTS idx_classes_status ON public.classes(status);

-- =====================================================================
-- 3. RLS
-- =====================================================================
ALTER TABLE public.schools ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.classes ENABLE ROW LEVEL SECURITY;

-- Admin: tudo em schools
CREATE POLICY admin_all_schools ON public.schools
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()));

-- Anon: ler escolas publicadas (para o formulário de entrada)
CREATE POLICY anon_read_schools ON public.schools
  FOR SELECT TO anon, authenticated
  USING (status = 'published' AND NOT is_archived);

-- Admin: tudo em classes
CREATE POLICY admin_all_classes ON public.classes
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()));

-- Anon: ler classes publicadas (para o formulário de entrada)
CREATE POLICY anon_read_classes ON public.classes
  FOR SELECT TO anon, authenticated
  USING (status = 'published' AND NOT is_archived);

-- =====================================================================
-- FIM — 233: schools + classes
-- =====================================================================
