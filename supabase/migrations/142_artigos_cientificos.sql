-- =====================================================================
-- 142 — Artigos científicos: schema + categorias seed
-- ---------------------------------------------------------------------
-- Secção separada dos Artigos (decisões 2026-08-11):
--   • tabela própria scientific_articles + traduções + categorias geríveis;
--   • categorias com CRUD admin (tabela, não constantes);
--   • RLS no padrão do projeto (141): público lê só published e não
--     arquivado; admin gere tudo; delete só superadmin.
-- Requerida pela 143 (seed de 5 artigos reais).
-- Idempotente: IF NOT EXISTS + DROP POLICY IF EXISTS + ON CONFLICT.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. TABELAS
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.scientific_categories (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  slug        TEXT NOT NULL UNIQUE,
  name_pt     TEXT NOT NULL,
  name_en     TEXT,
  color       TEXT NOT NULL DEFAULT '#0a844f',
  sort_order  INTEGER NOT NULL DEFAULT 0,
  created_at  TIMESTAMPTZ DEFAULT now(),
  updated_at  TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.scientific_articles (
  id             UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  slug           TEXT NOT NULL UNIQUE,
  title          TEXT NOT NULL,
  abstract       TEXT,
  keywords       TEXT[] DEFAULT '{}',
  category_id    UUID REFERENCES public.scientific_categories(id),
  doi            TEXT,
  authors        JSONB NOT NULL DEFAULT '[]',
  content        TEXT,
  references_arr TEXT[],
  read_time      INTEGER,
  status         TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
  featured       BOOLEAN NOT NULL DEFAULT false,
  published_at   TIMESTAMPTZ,
  is_archived    BOOLEAN NOT NULL DEFAULT false,
  created_at     TIMESTAMPTZ DEFAULT now(),
  updated_at     TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.scientific_article_translations (
  id             UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  article_id     UUID NOT NULL REFERENCES public.scientific_articles(id) ON DELETE CASCADE,
  lang           TEXT NOT NULL CHECK (lang IN ('pt', 'en')),
  slug           TEXT NOT NULL,
  title          TEXT NOT NULL,
  abstract       TEXT,
  keywords       TEXT[] DEFAULT '{}',
  content        TEXT,
  references_arr TEXT[],
  updated_at     TIMESTAMPTZ DEFAULT now(),
  UNIQUE (article_id, lang)
);

-- ---------------------------------------------------------------------
-- 2. RLS
-- ---------------------------------------------------------------------
ALTER TABLE public.scientific_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scientific_articles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scientific_article_translations ENABLE ROW LEVEL SECURITY;

-- 2.1 CATEGORIES — públicas de leitura; admin gere tudo
DROP POLICY IF EXISTS "anon_read_scientific_categories" ON public.scientific_categories;
CREATE POLICY "anon_read_scientific_categories" ON public.scientific_categories
  FOR SELECT TO anon, authenticated
  USING (true);

DROP POLICY IF EXISTS "admin_insert_scientific_categories" ON public.scientific_categories;
CREATE POLICY "admin_insert_scientific_categories" ON public.scientific_categories
  FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));

DROP POLICY IF EXISTS "admin_update_scientific_categories" ON public.scientific_categories;
CREATE POLICY "admin_update_scientific_categories" ON public.scientific_categories
  FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));

DROP POLICY IF EXISTS "admin_delete_scientific_categories" ON public.scientific_categories;
CREATE POLICY "admin_delete_scientific_categories" ON public.scientific_categories
  FOR DELETE TO authenticated
  USING (public.is_current_user_superadmin());

-- 2.2 ARTICLES — público só published e não arquivado; admin cria/edita; delete superadmin
DROP POLICY IF EXISTS "anon_read_scientific_articles" ON public.scientific_articles;
CREATE POLICY "anon_read_scientific_articles" ON public.scientific_articles
  FOR SELECT TO anon, authenticated
  USING (status = 'published' AND is_archived = false);

DROP POLICY IF EXISTS "admin_insert_scientific_articles" ON public.scientific_articles;
CREATE POLICY "admin_insert_scientific_articles" ON public.scientific_articles
  FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));

DROP POLICY IF EXISTS "admin_update_scientific_articles" ON public.scientific_articles;
CREATE POLICY "admin_update_scientific_articles" ON public.scientific_articles
  FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));

DROP POLICY IF EXISTS "admin_delete_scientific_articles" ON public.scientific_articles;
CREATE POLICY "admin_delete_scientific_articles" ON public.scientific_articles
  FOR DELETE TO authenticated
  USING (public.is_current_user_superadmin());

-- 2.3 TRANSLATIONS — públicas só quando o artigo base está publicado; admin gere
DROP POLICY IF EXISTS "anon_read_scientific_translations" ON public.scientific_article_translations;
CREATE POLICY "anon_read_scientific_translations" ON public.scientific_article_translations
  FOR SELECT TO anon, authenticated
  USING (EXISTS (
    SELECT 1 FROM public.scientific_articles a
    WHERE a.id = article_id AND a.status = 'published' AND a.is_archived = false));

DROP POLICY IF EXISTS "admin_insert_scientific_translations" ON public.scientific_article_translations;
CREATE POLICY "admin_insert_scientific_translations" ON public.scientific_article_translations
  FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));

DROP POLICY IF EXISTS "admin_update_scientific_translations" ON public.scientific_article_translations;
CREATE POLICY "admin_update_scientific_translations" ON public.scientific_article_translations
  FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));

DROP POLICY IF EXISTS "admin_delete_scientific_translations" ON public.scientific_article_translations;
CREATE POLICY "admin_delete_scientific_translations" ON public.scientific_article_translations
  FOR DELETE TO authenticated
  USING (public.is_current_user_superadmin());

-- ---------------------------------------------------------------------
-- 3. INDEXES
-- ---------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_sci_articles_status ON public.scientific_articles(status, is_archived);
CREATE INDEX IF NOT EXISTS idx_sci_articles_category ON public.scientific_articles(category_id);
CREATE INDEX IF NOT EXISTS idx_sci_articles_featured ON public.scientific_articles(featured) WHERE featured = true;
CREATE INDEX IF NOT EXISTS idx_sci_translations_lang ON public.scientific_article_translations(lang);

-- ---------------------------------------------------------------------
-- 4. SEED — 5 categorias académicas (cores do design demo 2026-08-11)
-- ---------------------------------------------------------------------
INSERT INTO public.scientific_categories (slug, name_pt, name_en, color, sort_order) VALUES
  ('farmacologia-clinica',    'Farmacologia Clínica',   'Clinical Pharmacology',     '#0a844f', 1),
  ('saude-publica',           'Saúde Pública',          'Public Health',             '#006171', 2),
  ('farmacovigilancia',       'Farmacovigilância',      'Pharmacovigilance',         '#e85d18', 3),
  ('educacao-farmaceutica',   'Educação Farmacêutica',  'Pharmaceutical Education',  '#002a32', 4),
  ('fitoterapia',             'Fitoterapia',            'Phytotherapy',              '#6b7280', 5)
ON CONFLICT (slug) DO NOTHING;

-- =====================================================================
-- FIM — 142: artigos científicos (schema + categorias)
-- =====================================================================
