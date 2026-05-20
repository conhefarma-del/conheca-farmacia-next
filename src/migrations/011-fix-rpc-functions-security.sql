-- Migration: Fix RPC functions - add input validation and change INVOKER to DEFINER
-- Date: 2026-05-19
-- Security: All tracking functions now validate input and only update published content

-- 1. add_reading_time: validate seconds > 0 and max 3600
CREATE OR REPLACE FUNCTION add_reading_time(row_id UUID, seconds INTEGER)
RETURNS VOID AS $$
BEGIN
  IF seconds <= 0 OR seconds > 3600 THEN
    RAISE EXCEPTION 'Invalid seconds: must be between 1 and 3600';
  END IF;
  UPDATE articles SET total_reading_time = total_reading_time + seconds WHERE id = row_id AND status = 'published';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. increment_view_count: validate slug not empty
CREATE OR REPLACE FUNCTION increment_view_count(article_slug TEXT)
RETURNS VOID AS $$
BEGIN
  IF article_slug IS NULL OR length(trim(article_slug)) = 0 THEN
    RAISE EXCEPTION 'Invalid slug';
  END IF;
  UPDATE articles SET view_count = view_count + 1 WHERE slug = article_slug AND status = 'published';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. increment_share_count: validate row_id
CREATE OR REPLACE FUNCTION increment_share_count(row_id UUID)
RETURNS VOID AS $$
BEGIN
  IF row_id IS NULL THEN
    RAISE EXCEPTION 'Invalid row_id';
  END IF;
  UPDATE articles SET share_count = share_count + 1 WHERE id = row_id AND status = 'published';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. increment_event_view_count: validate slug
CREATE OR REPLACE FUNCTION increment_event_view_count(event_slug TEXT)
RETURNS VOID AS $$
BEGIN
  IF event_slug IS NULL OR length(trim(event_slug)) = 0 THEN
    RAISE EXCEPTION 'Invalid slug';
  END IF;
  UPDATE events SET view_count = view_count + 1 WHERE slug = event_slug AND status = 'published';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. increment_live_view_count: INVOKER -> DEFINER + validate slug
CREATE OR REPLACE FUNCTION increment_live_view_count(live_slug TEXT)
RETURNS VOID AS $$
BEGIN
  IF live_slug IS NULL OR length(trim(live_slug)) = 0 THEN
    RAISE EXCEPTION 'Invalid slug';
  END IF;
  UPDATE lives SET view_count = view_count + 1 WHERE slug = live_slug AND status = 'published';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. increment_live_access_count: INVOKER -> DEFINER + validate slug
CREATE OR REPLACE FUNCTION increment_live_access_count(live_slug TEXT)
RETURNS VOID AS $$
BEGIN
  IF live_slug IS NULL OR length(trim(live_slug)) = 0 THEN
    RAISE EXCEPTION 'Invalid slug';
  END IF;
  UPDATE lives SET access_count = access_count + 1 WHERE slug = live_slug AND status = 'published';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. increment_live_download_count: INVOKER -> DEFINER + validate slug
CREATE OR REPLACE FUNCTION increment_live_download_count(live_slug TEXT)
RETURNS VOID AS $$
BEGIN
  IF live_slug IS NULL OR length(trim(live_slug)) = 0 THEN
    RAISE EXCEPTION 'Invalid slug';
  END IF;
  UPDATE lives SET download_count = download_count + 1 WHERE slug = live_slug AND status = 'published';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
