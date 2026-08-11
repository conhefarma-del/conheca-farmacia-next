-- =====================================================================
-- 145 — Backfill: povoar scientific_authors + scientific_article_authors
-- ---------------------------------------------------------------------
-- Lê o JSONB `authors` de todas as scientific_articles (dado canónico
-- por artigo) e constrói o registo de autores:
--
-- Regra de correspondência (também usada pelo sync das server actions):
--   1. nome IGUAL e instituição IGUAL (ambas conhecidas)  → mesmo autor
--   2. nome IGUAL e pelo menos um lado SEM instituição    → mesmo autor
--   3. nome IGUAL mas instituições conhecidas e DIFERENTES → AUTOR NOVO
--      (slug desambiguado: nome, nome-2, nome-3, ...)
--
-- A junction é reconstruída por artigo (DELETE + INSERT), por isso a
-- migração é idempotente — pode ser reaplicada sem duplicar nada.
-- ORCID fica NULL (o JSONB não o tem); é preenchido via admin/form.
-- =====================================================================

DO $$
DECLARE
  art          RECORD;
  entry        JSONB;
  pos          INT;
  v_name       TEXT;
  v_inst       TEXT;
  v_dept       TEXT;
  v_role       TEXT;
  v_avatar     TEXT;
  v_avatar_bg  TEXT;
  v_corr       BOOLEAN;
  v_base_slug  TEXT;
  v_slug       TEXT;
  v_suffix     INT;
  v_author_id  UUID;
  v_candidates INT;
  v_existing_inst TEXT;
BEGIN
  FOR art IN
    SELECT id, authors
    FROM public.scientific_articles
    WHERE jsonb_typeof(authors) = 'array'
  LOOP
    DELETE FROM public.scientific_article_authors WHERE article_id = art.id;

    pos := 0;
    FOR entry IN
      SELECT value FROM jsonb_array_elements(art.authors)
    LOOP
      pos := pos + 1;

      v_name := NULLIF(btrim(COALESCE(entry->>'name', '')), '');
      IF v_name IS NULL THEN CONTINUE; END IF;

      v_inst      := NULLIF(btrim(COALESCE(entry->>'institution', '')), '');
      v_dept      := NULLIF(btrim(COALESCE(entry->>'department', '')), '');
      v_role      := NULLIF(btrim(COALESCE(entry->>'role', '')), '');
      v_avatar    := NULLIF(btrim(COALESCE(entry->>'avatar', '')), '');
      v_avatar_bg := NULLIF(btrim(COALESCE(entry->>'avatarBg', '')), '');
      v_corr      := COALESCE((entry->>'corresponding')::boolean, false);

      v_author_id := NULL;

      -- Regra 1: nome + instituição iguais (ambas conhecidas)
      SELECT id INTO v_author_id
      FROM public.scientific_authors
      WHERE name = v_name AND institution IS NOT DISTINCT FROM v_inst
      LIMIT 1;

      -- Regra 2: nome igual e um dos lados sem instituição → fundir
      IF v_author_id IS NULL THEN
        SELECT count(*) INTO v_candidates
        FROM public.scientific_authors WHERE name = v_name;

        IF v_candidates = 1 THEN
          SELECT institution INTO v_existing_inst
          FROM public.scientific_authors WHERE name = v_name;

          IF v_existing_inst IS NULL OR v_inst IS NULL THEN
            SELECT id INTO v_author_id
            FROM public.scientific_authors WHERE name = v_name;
          END IF;
        END IF;
      END IF;

      IF v_author_id IS NULL THEN
        -- Regra 3: instituições conhecidas e diferentes → autor novo (slug único)
        v_base_slug := btrim(
          regexp_replace(
            regexp_replace(v_name, E'[\u0300-\u036f]', '', 'g'),
            E'[^a-z0-9]+', '-', 'g'),
          '-');
        v_base_slug := lower(v_base_slug);
        IF v_base_slug = '' THEN v_base_slug := 'autor'; END IF;

        v_slug   := v_base_slug;
        v_suffix := 2;
        WHILE EXISTS (SELECT 1 FROM public.scientific_authors WHERE slug = v_slug) LOOP
          v_slug   := v_base_slug || '-' || v_suffix;
          v_suffix := v_suffix + 1;
        END LOOP;

        INSERT INTO public.scientific_authors
          (name, slug, institution, department, role, avatar, avatar_bg)
        VALUES
          (v_name, v_slug, v_inst, v_dept, v_role, v_avatar, COALESCE(v_avatar_bg, '#0a844f'))
        RETURNING id INTO v_author_id;
      ELSE
        -- Fusão: completar campos base que venham preenchidos (nunca sobrescreve
        -- uma instituição conhecida por outra diferente — impossível pelas regras)
        UPDATE public.scientific_authors
        SET institution = COALESCE(v_inst, institution),
            department  = COALESCE(v_dept, department),
            role        = COALESCE(v_role, role),
            avatar      = COALESCE(v_avatar, avatar),
            avatar_bg   = COALESCE(v_avatar_bg, avatar_bg),
            updated_at  = now()
        WHERE id = v_author_id;
      END IF;

      INSERT INTO public.scientific_article_authors (article_id, author_id, position, corresponding)
      VALUES (art.id, v_author_id, pos, v_corr)
      ON CONFLICT (article_id, author_id)
      DO UPDATE SET position = EXCLUDED.position, corresponding = EXCLUDED.corresponding;
    END LOOP;
  END LOOP;
END $$;

-- =====================================================================
-- FIM — 145: backfill do registo de autores
-- =====================================================================
