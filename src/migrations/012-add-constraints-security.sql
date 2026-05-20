-- Migration: Add CHECK and NOT NULL constraints
-- Date: 2026-05-19

-- MED-04: CHECK constraint on admin_users.role
ALTER TABLE admin_users ADD CONSTRAINT admin_users_role_check
  CHECK (role IN ('editor', 'admin', 'superadmin'));

-- MED-05: NOT NULL on status columns
ALTER TABLE articles ALTER COLUMN status SET NOT NULL;
ALTER TABLE events ALTER COLUMN status SET NOT NULL;
ALTER TABLE lives ALTER COLUMN status SET NOT NULL;
