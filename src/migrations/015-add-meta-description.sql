-- Migration 015: Add meta_description column to articles
-- Versiona o campo SEO para meta description nos artigos.
-- Campo opcional — se vazio, o frontend usa excerpt como fallback.

ALTER TABLE articles ADD COLUMN IF NOT EXISTS meta_description TEXT;
