-- =====================================================================
-- 147 — Fix: RLS de scientific_authors + slugs do backfill 145
-- ---------------------------------------------------------------------
-- 1) RLS: a policy anon de scientific_authors usava `saa.author_id = id`
--    SEM qualificar. Dentro do subquery, `scientific_articles` (alias `a`)
--    tem uma coluna `id`, e o Postgres resolve colunas não qualificadas
--    para o escopo mais interno — logo `id` era o ID DO ARTIGO, nunca o
--    do autor. O EXISTS nunca era verdadeiro → anon via 0 autores
--    (índice vazio e páginas de autor a 404). Fix: scientific_authors.id.
--
-- 2) Slugs: o backfill 145 corria `lower()` DEPOIS do regexp_replace com
--    `[^a-z0-9]+` (case-sensitive) → as maiúsculas eram removidas:
--    'Dario Cattaneo' → 'ario-attaneo'. Recalcula o slug correto
--    (lower → diacríticos → não-alfanuméricos) e garante unicidade
--    com sufixo -2/-3. Idempotente.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. RLS — qualificar a coluna do autor
-- ---------------------------------------------------------------------
DROP POLICY IF EXISTS "anon_read_scientific_authors" ON public.scientific_authors;
CREATE POLICY "anon_read_scientific_authors" ON public.scientific_authors
  FOR SELECT TO anon, authenticated
  USING (EXISTS (
    SELECT 1
    FROM public.scientific_article_authors saa
    JOIN public.scientific_articles a ON a.id = saa.article_id
    WHERE saa.author_id = scientific_authors.id
      AND a.status = 'published' AND a.is_archived = false
  ));

-- ---------------------------------------------------------------------
-- 2. Reparar slugs existentes
-- ---------------------------------------------------------------------
DO $$
DECLARE
  a          RECORD;
  v_base     TEXT;
  v_slug     TEXT;
  v_suffix   INT;
BEGIN
  FOR a IN
    SELECT id, name
    FROM public.scientific_authors
    ORDER BY created_at, id
  LOOP
    v_base := btrim(
      regexp_replace(
        regexp_replace(lower(a.name), E'[\u0300-\u036f]', '', 'g'),
        E'[^a-z0-9]+', '-', 'g'),
      '-');
    IF v_base = '' THEN v_base := 'autor'; END IF;

    v_slug := v_base;
    v_suffix := 2;
    WHILE EXISTS (
      SELECT 1 FROM public.scientific_authors
      WHERE slug = v_slug AND id <> a.id
    ) LOOP
      v_slug := v_base || '-' || v_suffix;
      v_suffix := v_suffix + 1;
    END LOOP;

    UPDATE public.scientific_authors
    SET slug = v_slug, updated_at = now()
    WHERE id = a.id;
  END LOOP;
END $$;

-- =====================================================================
-- FIM — 147: fix RLS + slugs
-- =====================================================================
