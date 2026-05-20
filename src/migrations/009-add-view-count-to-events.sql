-- Migration 009: Add view_count to events + RPC function
-- Applied via Supabase MCP

ALTER TABLE events ADD COLUMN IF NOT EXISTS view_count INTEGER DEFAULT 0;
CREATE INDEX IF NOT EXISTS idx_events_view_count ON events(view_count DESC);

CREATE OR REPLACE FUNCTION increment_event_view_count(event_slug TEXT)
RETURNS VOID AS $$
  UPDATE events SET view_count = view_count + 1 WHERE slug = event_slug;
$$ LANGUAGE sql SECURITY DEFINER;
