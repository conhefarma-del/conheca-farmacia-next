-- 159: Fundir lives/webinars em /eventos (decisão com os parceiros, 2026-08).
-- A página /lives é eliminada; as lives existentes passam a eventos
-- (categoria live/webinar, tipo online). A tabela lives fica intacta
-- (dados preservados) mas deixa de ser usada publicamente.

-- 1. Colunas de "evento online" nas events (vinham das lives)
ALTER TABLE public.events
  ADD COLUMN IF NOT EXISTS platform text,
  ADD COLUMN IF NOT EXISTS access_link text,
  ADD COLUMN IF NOT EXISTS meeting_id text,
  ADD COLUMN IF NOT EXISTS password text,
  ADD COLUMN IF NOT EXISTS materials text,
  ADD COLUMN IF NOT EXISTS topic text,
  ADD COLUMN IF NOT EXISTS registration_enabled boolean NOT NULL DEFAULT true;

-- 2. RPC de listagem atualizado: expõe os novos campos (DROP antes do CREATE
--    porque o RETURN TYPE muda)
DROP FUNCTION IF EXISTS get_events_with_inscription_counts();

CREATE FUNCTION get_events_with_inscription_counts()
RETURNS TABLE (
  id UUID,
  slug TEXT,
  title TEXT,
  excerpt TEXT,
  image_url TEXT,
  category TEXT,
  category_label TEXT,
  date DATE,
  "time" TIME,
  end_time TIME,
  location TEXT,
  type TEXT,
  capacity INT,
  hosts JSONB,
  status TEXT,
  featured BOOLEAN,
  registration_link TEXT,
  platform TEXT,
  access_link TEXT,
  meeting_id TEXT,
  password TEXT,
  materials TEXT,
  topic TEXT,
  registration_enabled BOOLEAN,
  inscription_count BIGINT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT
    e.id, e.slug, e.title, e.excerpt, e.image_url,
    e.category, e.category_label, e.date, e.time, e.end_time,
    e.location, e.type, e.capacity, e.hosts, e.status,
    e.featured, e.registration_link,
    e.platform, e.access_link, e.meeting_id, e.password, e.materials,
    e.topic, e.registration_enabled,
    COUNT(i.id)::BIGINT AS inscription_count
  FROM events e
  LEFT JOIN inscricoes i ON i.evento_slug = e.slug
  WHERE e.status = 'published'
  GROUP BY e.id, e.slug, e.title, e.excerpt, e.image_url,
    e.category, e.category_label, e.date, e.time, e.end_time,
    e.location, e.type, e.capacity, e.hosts, e.status,
    e.featured, e.registration_link,
    e.platform, e.access_link, e.meeting_id, e.password, e.materials,
    e.topic, e.registration_enabled
  ORDER BY e.date ASC;
END;
$$;

-- 3. Migrar as lives existentes para eventos.
--    - categoria 'entrevista' → 'outro' (a categoria Entrevista é eliminada)
--    - type = 'online', registration_enabled = false (não há inscrição por defeito)
--    - slugs já existentes em events são ignorados (WHERE NOT EXISTS)
INSERT INTO events (
  slug, title, excerpt, category, category_label, date, time, end_time,
  status, location, type, capacity, hosts, image_url, registration_link,
  published_at, view_count, featured, is_archived, archived_at, archived_by,
  featured_langs, platform, access_link, meeting_id, password, materials,
  topic, registration_enabled
)
SELECT
  l.slug, l.title, l.excerpt,
  CASE WHEN l.category = 'entrevista' THEN 'outro' ELSE l.category END,
  l.category_label, l.date, l.time, l.end_time,
  l.status, NULL, 'online', NULL, l.hosts, l.image_url, NULL,
  l.published_at, l.view_count, l.featured, l.is_archived, l.archived_at, l.archived_by,
  l.featured_langs, l.platform, l.access_link, l.meeting_id, l.password, l.materials,
  l.topic, false
FROM lives l
WHERE NOT EXISTS (SELECT 1 FROM events e WHERE e.slug = l.slug);
