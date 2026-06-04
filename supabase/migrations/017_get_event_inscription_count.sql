DROP FUNCTION IF EXISTS get_event_inscription_count(TEXT);

CREATE FUNCTION get_event_inscription_count(event_slug TEXT)
RETURNS BIGINT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  result BIGINT;
BEGIN
  SELECT COUNT(*)::BIGINT INTO result
  FROM inscricoes
  WHERE evento_slug = event_slug;
  RETURN COALESCE(result, 0);
END;
$$;