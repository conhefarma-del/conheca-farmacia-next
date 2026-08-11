-- =====================================================================
-- 144 — Artigos científicos: registo de autores (scientific_authors) + ligação
-- ---------------------------------------------------------------------
-- Resolve a fusão de nomes iguais: cada autor é uma entidade própria com
-- slug ÚNICO (desambiguado com sufixo -2/-3) e ORCID opcional. O JSONB
-- `authors` da scientific_articles continua a ser o dado canónico por
-- artigo (ordem, instituição/departamento por artigo); esta tabela é o
-- registo de identidade e a junction liga artigos↔autores.
--
-- RLS no padrão da 142:
--   • público lê só autores ligados a artigos publicados e não arquivados;
--   • admin cria/edita; delete só superadmin.
-- Idempotente: IF NOT EXISTS + DROP POLICY IF EXISTS + ON CONFLICT.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. TABELAS
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.scientific_authors (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name        TEXT NOT NULL,
  slug        TEXT NOT NULL UNIQUE,
  orcid       TEXT UNIQUE,
  institution TEXT,
  department  TEXT,
  role        TEXT,
  avatar      TEXT,
  avatar_bg   TEXT DEFAULT '#0a844f',
  bio         TEXT,
  created_at  TIMESTAMPTZ DEFAULT now(),
  updated_at  TIMESTAMPTZ DEFAULT now(),
  CONSTRAINT scientific_authors_orcid_format CHECK (
    orcid IS NULL OR orcid ~ '^[0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{3}[0-9X]$'
  )
);

CREATE TABLE IF NOT EXISTS public.scientific_article_authors (
  article_id    UUID NOT NULL REFERENCES public.scientific_articles(id) ON DELETE CASCADE,
  author_id     UUID NOT NULL REFERENCES public.scientific_authors(id) ON DELETE CASCADE,
  position      INTEGER NOT NULL DEFAULT 0,
  corresponding BOOLEAN NOT NULL DEFAULT false,
  PRIMARY KEY (article_id, author_id)
);

-- ---------------------------------------------------------------------
-- 2. RLS
-- ---------------------------------------------------------------------
ALTER TABLE public.scientific_authors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scientific_article_authors ENABLE ROW LEVEL SECURITY;

-- 2.1 AUTHORS — públicos só os ligados a artigos publicados e não arquivados
DROP POLICY IF EXISTS "anon_read_scientific_authors" ON public.scientific_authors;
CREATE POLICY "anon_read_scientific_authors" ON public.scientific_authors
  FOR SELECT TO anon, authenticated
  USING (EXISTS (
    SELECT 1
    FROM public.scientific_article_authors saa
    JOIN public.scientific_articles a ON a.id = saa.article_id
    WHERE saa.author_id = id AND a.status = 'published' AND a.is_archived = false
  ));

-- Admin também lê autores de RASCUNHOS (o sync do form precisa de
-- corresponder autores de artigos ainda não publicados)
DROP POLICY IF EXISTS "admin_read_scientific_authors" ON public.scientific_authors;
CREATE POLICY "admin_read_scientific_authors" ON public.scientific_authors
  FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));

DROP POLICY IF EXISTS "admin_insert_scientific_authors" ON public.scientific_authors;
CREATE POLICY "admin_insert_scientific_authors" ON public.scientific_authors
  FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));

DROP POLICY IF EXISTS "admin_update_scientific_authors" ON public.scientific_authors;
CREATE POLICY "admin_update_scientific_authors" ON public.scientific_authors
  FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));

DROP POLICY IF EXISTS "admin_delete_scientific_authors" ON public.scientific_authors;
CREATE POLICY "admin_delete_scientific_authors" ON public.scientific_authors
  FOR DELETE TO authenticated
  USING (public.is_current_user_superadmin());

-- 2.2 JUNCTION — públicas só para artigos publicados e não arquivados
DROP POLICY IF EXISTS "anon_read_scientific_article_authors" ON public.scientific_article_authors;
CREATE POLICY "anon_read_scientific_article_authors" ON public.scientific_article_authors
  FOR SELECT TO anon, authenticated
  USING (EXISTS (
    SELECT 1 FROM public.scientific_articles a
    WHERE a.id = article_id AND a.status = 'published' AND a.is_archived = false
  ));

DROP POLICY IF EXISTS "admin_insert_scientific_article_authors" ON public.scientific_article_authors;
CREATE POLICY "admin_insert_scientific_article_authors" ON public.scientific_article_authors
  FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));

DROP POLICY IF EXISTS "admin_update_scientific_article_authors" ON public.scientific_article_authors;
CREATE POLICY "admin_update_scientific_article_authors" ON public.scientific_article_authors
  FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));

-- DELETE admin (não só superadmin): o sync reconstrói a junction sempre
-- que o artigo é guardado; restringir a superadmin partiria o fluxo do form.
DROP POLICY IF EXISTS "admin_delete_scientific_article_authors" ON public.scientific_article_authors;
CREATE POLICY "admin_delete_scientific_article_authors" ON public.scientific_article_authors
  FOR DELETE TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));

-- ---------------------------------------------------------------------
-- 3. INDEXES
-- ---------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_sci_article_authors_author ON public.scientific_article_authors(author_id);
CREATE INDEX IF NOT EXISTS idx_sci_article_authors_article ON public.scientific_article_authors(article_id, position);
CREATE INDEX IF NOT EXISTS idx_sci_authors_name ON public.scientific_authors(name);

-- =====================================================================
-- FIM — 144: registo de autores + ligação
-- =====================================================================
