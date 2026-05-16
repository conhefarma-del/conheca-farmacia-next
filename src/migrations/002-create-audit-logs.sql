-- Migration: Create audit_logs table for tracking user actions
-- Date: 2026-05-14
-- Note: Applied via Supabase Dashboard SQL Editor

-- Table: audit_logs
CREATE TABLE IF NOT EXISTS audit_logs (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
 user_id UUID REFERENCES auth.users(id),
 user_email TEXT,
 action TEXT NOT NULL,
 table_name TEXT NOT NULL,
 record_id UUID,
 old_values JSONB,
 new_values JSONB,
 created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS audit_logs_user_id_idx ON audit_logs(user_id);
CREATE INDEX IF NOT EXISTS audit_logs_created_at_idx ON audit_logs(created_at);
CREATE INDEX IF NOT EXISTS audit_logs_table_name_idx ON audit_logs(table_name);
CREATE INDEX IF NOT EXISTS audit_logs_record_id_idx ON audit_logs(record_id);

-- Add check constraint for action
ALTER TABLE audit_logs ADD CONSTRAINT audit_logs_action_check
CHECK (action IN ('CREATE', 'UPDATE', 'DELETE', 'PUBLISH', 'UNPUBLISH'));

-- Add check constraint for table_name
ALTER TABLE audit_logs ADD CONSTRAINT audit_logs_table_name_check
CHECK (table_name IN ('articles', 'events', 'lives'));
