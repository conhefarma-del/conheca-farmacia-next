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
    COUNT(i.id)::BIGINT AS inscription_count
  FROM events e
  LEFT JOIN inscricoes i ON i.evento_slug = e.slug
  WHERE e.status = 'published'
  GROUP BY e.id, e.slug, e.title, e.excerpt, e.image_url,
    e.category, e.category_label, e.date, e.time, e.end_time,
    e.location, e.type, e.capacity, e.hosts, e.status,
    e.featured, e.registration_link
  ORDER BY e.date ASC;
END;
$$;