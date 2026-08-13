-- =====================================================================
-- 155 — Entrevistas: categorias geríveis (interview_categories)
-- ---------------------------------------------------------------------
-- Permite ao admin criar mais categorias ao longo do tempo (padrão das
-- scientific_categories da 142). As entrevistas continuam a guardar o
-- `category` (slug) + `category_label` (nome) em texto; esta tabela é o
-- registo canónico das categorias válidas (nome, cor, ordem).
--
-- RLS no padrão: público lê todas as categorias (taxonomia pública);
-- admin cria/edita; delete só superadmin. Idempotente.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. TABELA
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.interview_categories (
  id         UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  slug       TEXT NOT NULL UNIQUE,
  name       TEXT NOT NULL,
  color      TEXT NOT NULL DEFAULT '#0a844f',
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ---------------------------------------------------------------------
-- 2. RLS
-- ---------------------------------------------------------------------
ALTER TABLE public.interview_categories ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon_read_interview_categories" ON public.interview_categories;
CREATE POLICY "anon_read_interview_categories" ON public.interview_categories
  FOR SELECT TO anon, authenticated
  USING (true);

DROP POLICY IF EXISTS "admin_insert_interview_categories" ON public.interview_categories;
CREATE POLICY "admin_insert_interview_categories" ON public.interview_categories
  FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));

DROP POLICY IF EXISTS "admin_update_interview_categories" ON public.interview_categories;
CREATE POLICY "admin_update_interview_categories" ON public.interview_categories
  FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));

DROP POLICY IF EXISTS "admin_delete_interview_categories" ON public.interview_categories;
CREATE POLICY "admin_delete_interview_categories" ON public.interview_categories
  FOR DELETE TO authenticated
  USING (public.is_current_user_superadmin());

-- ---------------------------------------------------------------------
-- 3. SEED — as 4 categorias atuais (migração 152)
-- ---------------------------------------------------------------------
INSERT INTO public.interview_categories (slug, name, color, sort_order) VALUES
  ('profissionais',   'Profissionais',   '#ff6c23', 0),
  ('lideres',         'Líderes',         '#0a844f', 1),
  ('educadores',      'Educadores',      '#002a32', 2),
  ('investigadores',  'Investigadores',  '#006171', 3)
ON CONFLICT (slug) DO NOTHING;

-- =====================================================================
-- FIM — 155: categorias de entrevistas
-- =====================================================================
