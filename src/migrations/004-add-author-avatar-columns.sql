-- Migration: Add author avatar columns to articles
-- Date: 2026-05-15
-- Description: Add author_avatar and author_avatar_bg columns for author card customization

ALTER TABLE articles
ADD COLUMN IF NOT EXISTS author_avatar TEXT;

ALTER TABLE articles
ADD COLUMN IF NOT EXISTS author_avatar_bg TEXT;
