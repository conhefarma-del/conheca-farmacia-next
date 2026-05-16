-- Migration: Create RLS policies for security
-- Date: 2026-05-14
-- Note: Applied via Supabase Dashboard SQL Editor

-- Enable RLS on all tables
ALTER TABLE articles ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE lives ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;

-- ============================================
-- Articles Policies
-- ============================================

-- Public can read published articles
CREATE POLICY "Public can read published articles"
ON articles FOR SELECT
USING (status = 'published');

-- Admin users can read all articles
CREATE POLICY "Admin users can read all articles"
ON articles FOR SELECT
USING (
 EXISTS (
 SELECT 1 FROM admin_users WHERE user_id = auth.uid()
 )
);

-- Admin users can insert articles
CREATE POLICY "Admin users can insert articles"
ON articles FOR INSERT
WITH CHECK (
 EXISTS (
 SELECT 1 FROM admin_users WHERE user_id = auth.uid()
 )
);

-- Admin users can update articles
CREATE POLICY "Admin users can update articles"
ON articles FOR UPDATE
USING (
 EXISTS (
 SELECT 1 FROM admin_users WHERE user_id = auth.uid()
 )
);

-- Admin users can delete articles
CREATE POLICY "Admin users can delete articles"
ON articles FOR DELETE
USING (
 EXISTS (
 SELECT 1 FROM admin_users WHERE user_id = auth.uid()
 )
);

-- ============================================
-- Events Policies
-- ============================================

-- Public can read published events
CREATE POLICY "Public can read published events"
ON events FOR SELECT
USING (status = 'published');

-- Admin users can read all events
CREATE POLICY "Admin users can read all events"
ON events FOR SELECT
USING (
 EXISTS (
 SELECT 1 FROM admin_users WHERE user_id = auth.uid()
 )
);

-- Admin users can insert events
CREATE POLICY "Admin users can insert events"
ON events FOR INSERT
WITH CHECK (
 EXISTS (
 SELECT 1 FROM admin_users WHERE user_id = auth.uid()
 )
);

-- Admin users can update events
CREATE POLICY "Admin users can update events"
ON events FOR UPDATE
USING (
 EXISTS (
 SELECT 1 FROM admin_users WHERE user_id = auth.uid()
 )
);

-- Admin users can delete events
CREATE POLICY "Admin users can delete events"
ON events FOR DELETE
USING (
 EXISTS (
 SELECT 1 FROM admin_users WHERE user_id = auth.uid()
 )
);

-- ============================================
-- Lives Policies
-- ============================================

-- Public can read published lives
CREATE POLICY "Public can read published lives"
ON lives FOR SELECT
USING (status = 'published');

-- Admin users can read all lives
CREATE POLICY "Admin users can read all lives"
ON lives FOR SELECT
USING (
 EXISTS (
 SELECT 1 FROM admin_users WHERE user_id = auth.uid()
 )
);

-- Admin users can insert lives
CREATE POLICY "Admin users can insert lives"
ON lives FOR INSERT
WITH CHECK (
 EXISTS (
 SELECT 1 FROM admin_users WHERE user_id = auth.uid()
 )
);

-- Admin users can update lives
CREATE POLICY "Admin users can update lives"
ON lives FOR UPDATE
USING (
 EXISTS (
 SELECT 1 FROM admin_users WHERE user_id = auth.uid()
 )
);

-- Admin users can delete lives
CREATE POLICY "Admin users can delete lives"
ON lives FOR DELETE
USING (
 EXISTS (
 SELECT 1 FROM admin_users WHERE user_id = auth.uid()
 )
);

-- ============================================
-- Audit Logs Policies
-- ============================================

-- Users can read their own audit logs
CREATE POLICY "Users can read own audit logs"
ON audit_logs FOR SELECT
USING (user_id = auth.uid());

-- Admins can insert audit logs
CREATE POLICY "Admins can insert audit logs"
ON audit_logs FOR INSERT
WITH CHECK (
 EXISTS (
 SELECT 1 FROM admin_users WHERE user_id = auth.uid()
 )
);

-- ============================================
-- Admin Users Policies
-- ============================================

-- Admin users can read admin_users
CREATE POLICY "Admin users can read admin_users"
ON admin_users FOR SELECT
USING (
 EXISTS (
 SELECT 1 FROM admin_users WHERE user_id = auth.uid()
 )
);
