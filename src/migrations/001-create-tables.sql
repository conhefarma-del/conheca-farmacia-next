-- Migration: Create main content tables
-- Date: 2026-05-14
-- Note: Applied via Supabase Dashboard SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Table: articles
CREATE TABLE IF NOT EXISTS articles (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
 slug TEXT UNIQUE NOT NULL,
 title TEXT NOT NULL,
 excerpt TEXT,
 category TEXT NOT NULL,
 category_label TEXT NOT NULL,
 content TEXT NOT NULL,
 author_name TEXT,
 author_role TEXT,
 author_bio TEXT,
 author_avatar TEXT,
 author_avatar_bg TEXT,
 published_date DATE,
 read_time INTEGER,
 image_url TEXT,
 references_arr TEXT[],
 status TEXT DEFAULT 'draft',
 published_at TIMESTAMPTZ,
 created_at TIMESTAMPTZ DEFAULT NOW(),
 updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table: events
CREATE TABLE IF NOT EXISTS events (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
 slug TEXT UNIQUE NOT NULL,
 title TEXT NOT NULL,
 excerpt TEXT,
 category TEXT NOT NULL,
 category_label TEXT NOT NULL,
 date DATE NOT NULL,
 time TIME,
 end_time TIME,
 status TEXT DEFAULT 'draft',
 location TEXT,
 type TEXT,
 capacity INTEGER,
 hosts JSONB,
 image_url TEXT,
 registration_link TEXT,
 published_at TIMESTAMPTZ,
 created_at TIMESTAMPTZ DEFAULT NOW(),
 updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table: lives
CREATE TABLE IF NOT EXISTS lives (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
 slug TEXT UNIQUE NOT NULL,
 title TEXT NOT NULL,
 excerpt TEXT,
 category TEXT NOT NULL,
 category_label TEXT NOT NULL,
 date DATE NOT NULL,
 time TIME NOT NULL,
 end_time TIME,
 status TEXT DEFAULT 'draft',
 platform TEXT,
 access_link TEXT,
 meeting_id TEXT,
 password TEXT,
 materials JSONB,
 host_name TEXT,
 host_role TEXT,
 host_organization TEXT,
 image_url TEXT,
 published_at TIMESTAMPTZ,
 created_at TIMESTAMPTZ DEFAULT NOW(),
 updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table: admin_users
CREATE TABLE IF NOT EXISTS admin_users (
 user_id UUID REFERENCES auth.users(id) PRIMARY KEY,
 role TEXT DEFAULT 'editor',
 created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS articles_status_idx ON articles(status);
CREATE INDEX IF NOT EXISTS articles_category_idx ON articles(category);
CREATE INDEX IF NOT EXISTS articles_published_date_idx ON articles(published_date);

CREATE INDEX IF NOT EXISTS events_status_idx ON events(status);
CREATE INDEX IF NOT EXISTS events_date_idx ON events(date);

CREATE INDEX IF NOT EXISTS lives_status_idx ON lives(status);
CREATE INDEX IF NOT EXISTS lives_date_idx ON lives(date);

-- Add check constraints for status columns
ALTER TABLE articles ADD CONSTRAINT articles_status_check
CHECK (status IN ('draft', 'published'));

ALTER TABLE events ADD CONSTRAINT events_status_check
CHECK (status IN ('draft', 'published'));

ALTER TABLE lives ADD CONSTRAINT lives_status_check
CHECK (status IN ('draft', 'published'));
