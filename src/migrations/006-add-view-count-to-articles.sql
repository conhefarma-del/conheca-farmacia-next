-- Add view_count column to articles table
ALTER TABLE articles
ADD COLUMN IF NOT EXISTS view_count INTEGER DEFAULT 0;

-- Create index for better performance when ordering by view_count
CREATE INDEX IF NOT EXISTS idx_articles_view_count ON articles(view_count DESC);