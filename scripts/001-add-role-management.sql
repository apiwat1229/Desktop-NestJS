-- Migration: Add Role Management System
-- Add roleId to users table and create roles table

-- Step 1: Create roles table
CREATE TABLE IF NOT EXISTS roles (
    id TEXT PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    description TEXT,
    icon TEXT,
    color TEXT,
    permissions JSONB DEFAULT '[]'::jsonb NOT NULL,
    is_active BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP(3) NOT NULL
);

-- Step 2: Add role_id column to users table
ALTER TABLE users ADD COLUMN IF NOT EXISTS role_id TEXT;

-- Step 3: Add foreign key constraint
ALTER TABLE users 
ADD CONSTRAINT users_role_id_fkey 
FOREIGN KEY (role_id) REFERENCES roles(id) 
ON DELETE SET NULL 
ON UPDATE CASCADE;

-- Step 4: Create index on role_id
CREATE INDEX IF NOT EXISTS users_role_id_idx ON users(role_id);

-- Verify
SELECT 'Migration completed successfully' as status;
