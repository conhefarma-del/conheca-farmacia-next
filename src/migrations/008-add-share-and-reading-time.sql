-- Migration 008: Add share_count and total_reading_time to articles
-- Plus RPC functions for analytics tracking

-- Add new columns
ALTER TABLE articles ADD COLUMN IF NOT EXISTS share_count INTEGER DEFAULT 0;
ALTER TABLE articles ADD COLUMN IF NOT EXISTS total_reading_time INTEGER DEFAULT 0;

-- Indexes for ordering
CREATE INDEX IF NOT EXISTS idx_articles_share_count ON articles(share_count DESC);
CREATE INDEX IF NOT EXISTS idx_articles_reading_time ON articles(total_reading_time DESC);

-- RPC: Increment view count by slug
CREATE OR REPLACE FUNCTION increment_view_count(article_slug TEXT)
RETURNS VOID AS $$
  UPDATE articles SET view_count = view_count + 1 WHERE slug = article_slug;
$$ LANGUAGE sql SECURITY DEFINER;

-- RPC: Increment share count by id
CREATE OR REPLACE FUNCTION increment_share_count(row_id UUID)
RETURNS VOID AS $$
  UPDATE articles SET share_count = share_count + 1 WHERE id = row_id;
$$ LANGUAGE sql SECURITY DEFINER;

-- RPC: Add reading time by id
CREATE OR REPLACE FUNCTION add_reading_time(row_id UUID, seconds INTEGER)
RETURNS VOID AS $$
  UPDATE articles SET total_reading_time = total_reading_time + seconds WHERE id = row_id;
$$ LANGUAGE sql SECURITY DEFINER;
