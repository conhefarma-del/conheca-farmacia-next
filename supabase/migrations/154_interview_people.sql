-- =====================================================================
-- 154 — Entrevistas: registo de entrevistados (interview_people) + ligação
-- ---------------------------------------------------------------------
-- Mini perfil dos Entrevistados (equivalente ao scientific_authors 144):
-- cada entrevistado é uma entidade própria com slug ÚNICO (desambiguado
-- com sufixo -2/-3). O JSONB `interviewee` da interviews continua a ser o
-- dado canónico por entrevista (ordem, cargo, bio); esta tabela é o
-- registo de identidade e a junction liga entrevistas↔pessoas.
--
-- Regra de correspondência (mesma da 145, com `role` no lugar de
-- `institution` — o campo distintivo dos entrevistados):
--   1. nome IGUAL e role IGUAL (ambas conhecidas)      → mesma pessoa
--   2. nome IGUAL e um dos lados SEM role               → mesma pessoa
--   3. nome IGUAL mas roles conhecidos e DIFERENTES     → pessoa NOVA
--      (slug desambiguado: nome, nome-2, nome-3, ...)
--
-- RLS no padrão da 144: público lê só pessoas ligadas a entrevistas
-- publicadas e não arquivadas; admin cria/edita; delete só superadmin
-- (a junction permite DELETE admin para o sync reconstruir).
-- Idempotente: IF NOT EXISTS + DROP POLICY IF EXISTS + ON CONFLICT.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. TABELAS
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.interview_people (
  id         UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name       TEXT NOT NULL,
  slug       TEXT NOT NULL UNIQUE,
  role       TEXT,
  bio        TEXT,
  avatar     TEXT,
  avatar_bg  TEXT DEFAULT '#00493a',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.interview_person_links (
  interview_id UUID NOT NULL REFERENCES public.interviews(id) ON DELETE CASCADE,
  person_id    UUID NOT NULL REFERENCES public.interview_people(id) ON DELETE CASCADE,
  position     INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (interview_id, person_id)
);

-- ---------------------------------------------------------------------
-- 2. RLS
-- ---------------------------------------------------------------------
ALTER TABLE public.interview_people ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.interview_person_links ENABLE ROW LEVEL SECURITY;

-- 2.1 PEOPLE — públicos só os ligados a entrevistas publicadas e não arquivadas
DROP POLICY IF EXISTS "anon_read_interview_people" ON public.interview_people;
CREATE POLICY "anon_read_interview_people" ON public.interview_people
  FOR SELECT TO anon, authenticated
  USING (EXISTS (
    SELECT 1
    FROM public.interview_person_links ipl
    JOIN public.interviews i ON i.id = ipl.interview_id
    WHERE ipl.person_id = id AND i.status = 'published' AND i.is_archived = false
  ));

-- Admin também lê pessoas de RASCUNHOS (o sync do form precisa de
-- corresponder entrevistados de entrevistas ainda não publicadas)
DROP POLICY IF EXISTS "admin_read_interview_people" ON public.interview_people;
CREATE POLICY "admin_read_interview_people" ON public.interview_people
  FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));

DROP POLICY IF EXISTS "admin_insert_interview_people" ON public.interview_people;
CREATE POLICY "admin_insert_interview_people" ON public.interview_people
  FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));

DROP POLICY IF EXISTS "admin_update_interview_people" ON public.interview_people;
CREATE POLICY "admin_update_interview_people" ON public.interview_people
  FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));

DROP POLICY IF EXISTS "admin_delete_interview_people" ON public.interview_people;
CREATE POLICY "admin_delete_interview_people" ON public.interview_people
  FOR DELETE TO authenticated
  USING (public.is_current_user_superadmin());

-- 2.2 JUNCTION — públicas só para entrevistas publicadas e não arquivadas
DROP POLICY IF EXISTS "anon_read_interview_person_links" ON public.interview_person_links;
CREATE POLICY "anon_read_interview_person_links" ON public.interview_person_links
  FOR SELECT TO anon, authenticated
  USING (EXISTS (
    SELECT 1 FROM public.interviews i
    WHERE i.id = interview_id AND i.status = 'published' AND i.is_archived = false
  ));

DROP POLICY IF EXISTS "admin_insert_interview_person_links" ON public.interview_person_links;
CREATE POLICY "admin_insert_interview_person_links" ON public.interview_person_links
  FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));

DROP POLICY IF EXISTS "admin_update_interview_person_links" ON public.interview_person_links;
CREATE POLICY "admin_update_interview_person_links" ON public.interview_person_links
  FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));

-- DELETE admin (não só superadmin): o sync reconstrói a junction sempre
-- que a entrevista é guardada; restringir a superadmin partiria o fluxo.
DROP POLICY IF EXISTS "admin_delete_interview_person_links" ON public.interview_person_links;
CREATE POLICY "admin_delete_interview_person_links" ON public.interview_person_links
  FOR DELETE TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));

-- ---------------------------------------------------------------------
-- 3. INDEXES
-- ---------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_interview_person_links_person ON public.interview_person_links(person_id);
CREATE INDEX IF NOT EXISTS idx_interview_person_links_interview ON public.interview_person_links(interview_id, position);
CREATE INDEX IF NOT EXISTS idx_interview_people_name ON public.interview_people(name);

-- =====================================================================
-- 4. BACKFILL — povoar interview_people + interview_person_links a partir
--    do JSONB `interviewee` das entrevistas existentes (padrão da 145)
-- =====================================================================
DO $$
DECLARE
  iv          RECORD;
  entry       JSONB;
  pos         INT;
  v_name      TEXT;
  v_role      TEXT;
  v_bio       TEXT;
  v_avatar    TEXT;
  v_avatar_bg TEXT;
  v_base_slug TEXT;
  v_slug      TEXT;
  v_suffix    INT;
  v_person_id UUID;
  v_candidates INT;
  v_existing_role TEXT;
BEGIN
  FOR iv IN
    SELECT id, interviewee
    FROM public.interviews
    WHERE jsonb_typeof(interviewee) IN ('array', 'object')
  LOOP
    DELETE FROM public.interview_person_links WHERE interview_id = iv.id;

    pos := 0;
    FOR entry IN
      SELECT value FROM jsonb_array_elements(
        CASE WHEN jsonb_typeof(iv.interviewee) = 'array'
             THEN iv.interviewee
             ELSE jsonb_build_array(iv.interviewee)
        END
      )
    LOOP
      pos := pos + 1;

      v_name := NULLIF(btrim(COALESCE(entry->>'name', '')), '');
      IF v_name IS NULL THEN CONTINUE; END IF;

      v_role      := NULLIF(btrim(COALESCE(entry->>'role', '')), '');
      v_bio       := NULLIF(btrim(COALESCE(entry->>'bio', '')), '');
      v_avatar    := NULLIF(btrim(COALESCE(entry->>'avatar', '')), '');
      v_avatar_bg := NULLIF(btrim(COALESCE(entry->>'avatarBg', '')), '');

      v_person_id := NULL;

      -- Regra 1: nome + role iguais (ambas conhecidas)
      SELECT id INTO v_person_id
      FROM public.interview_people
      WHERE name = v_name AND role IS NOT DISTINCT FROM v_role
      LIMIT 1;

      -- Regra 2: nome igual e um dos lados sem role → fundir (só se único)
      IF v_person_id IS NULL THEN
        SELECT count(*) INTO v_candidates
        FROM public.interview_people WHERE name = v_name;

        IF v_candidates = 1 THEN
          SELECT role INTO v_existing_role
          FROM public.interview_people WHERE name = v_name;

          IF v_existing_role IS NULL OR v_role IS NULL THEN
            SELECT id INTO v_person_id
            FROM public.interview_people WHERE name = v_name;
          END IF;
        END IF;
      END IF;

      IF v_person_id IS NULL THEN
        -- Regra 3: roles conhecidos e diferentes → pessoa nova (slug único)
        v_base_slug := btrim(
          regexp_replace(
            regexp_replace(lower(v_name), E'[\u0300-\u036f]', '', 'g'),
            E'[^a-z0-9]+', '-', 'g'),
          '-');
        IF v_base_slug = '' THEN v_base_slug := 'entrevistado'; END IF;

        v_slug   := v_base_slug;
        v_suffix := 2;
        WHILE EXISTS (SELECT 1 FROM public.interview_people WHERE slug = v_slug) LOOP
          v_slug   := v_base_slug || '-' || v_suffix;
          v_suffix := v_suffix + 1;
        END LOOP;

        INSERT INTO public.interview_people
          (name, slug, role, bio, avatar, avatar_bg)
        VALUES
          (v_name, v_slug, v_role, v_bio, v_avatar, COALESCE(v_avatar_bg, '#00493a'))
        RETURNING id INTO v_person_id;
      ELSE
        -- Fusão: completar campos base que venham preenchidos
        UPDATE public.interview_people
        SET role      = COALESCE(v_role, role),
            bio       = COALESCE(v_bio, bio),
            avatar    = COALESCE(v_avatar, avatar),
            avatar_bg = COALESCE(v_avatar_bg, avatar_bg),
            updated_at = now()
        WHERE id = v_person_id;
      END IF;

      INSERT INTO public.interview_person_links (interview_id, person_id, position)
      VALUES (iv.id, v_person_id, pos)
      ON CONFLICT (interview_id, person_id)
      DO UPDATE SET position = EXCLUDED.position;
    END LOOP;
  END LOOP;
END $$;

-- =====================================================================
-- FIM — 154: registo de entrevistados + ligação
-- =====================================================================
