-- Migration 007: Create page_views table for website analytics
-- Applied via Supabase Dashboard SQL Editor

CREATE TABLE IF NOT EXISTS page_views (
  id BIGSERIAL PRIMARY KEY,
  page_path TEXT NOT NULL,
  page_title TEXT,
  referrer TEXT,
  session_id TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for aggregation queries
CREATE INDEX idx_page_views_created_at ON page_views(created_at);
CREATE INDEX idx_page_views_path ON page_views(page_path);

-- Enable RLS
ALTER TABLE page_views ENABLE ROW LEVEL SECURITY;

-- Allow anonymous inserts (public tracking)
CREATE POLICY "Allow anonymous page view inserts" ON page_views
  FOR INSERT
  WITH CHECK (true);

-- Allow authenticated reads (admin dashboard)
CREATE POLICY "Allow authenticated page view reads" ON page_views
  FOR SELECT
  USING (auth.role() = 'authenticated');
