-- Create Default Roles with Permissions

-- Administrator Role (Full Access)
INSERT INTO roles (id, name, description, icon, color, permissions, is_active, created_at, updated_at)
VALUES (
  gen_random_uuid(),
  'Administrator',
  'Full system access and configuration',
  'shield-check',
  '#ef4444',
  '[
    "users:read", "users:create", "users:update", "users:delete",
    "suppliers:read", "suppliers:create", "suppliers:update", "suppliers:delete", "suppliers:approve",
    "suppliers:update:request", "suppliers:delete:request",
    "rubberTypes:read", "rubberTypes:create", "rubberTypes:update", "rubberTypes:delete", "rubberTypes:approve",
    "rubberTypes:update:request", "rubberTypes:delete:request",
    "approvals:view", "approvals:approve", "approvals:reject",
    "notifications:read", "notifications:create", "notifications:delete",
    "roles:read", "roles:create", "roles:update", "roles:delete",
    "bookings:read", "bookings:create", "bookings:update", "bookings:delete",
    "analytics:view"
  ]'::jsonb,
  true,
  NOW(),
  NOW()
) ON CONFLICT (name) DO UPDATE SET
  description = EXCLUDED.description,
  permissions = EXCLUDED.permissions,
  updated_at = NOW();

-- Manager Role (Department Management)
INSERT INTO roles (id, name, description, icon, color, permissions, is_active, created_at, updated_at)
VALUES (
  gen_random_uuid(),
  'Manager',
  'Department management and approvals',
  'user-check',
  '#3b82f6',
  '[
    "users:read",
    "suppliers:read", "suppliers:update:request", "suppliers:delete:request",
    "rubberTypes:read", "rubberTypes:update:request", "rubberTypes:delete:request",
    "approvals:view", "approvals:approve",
    "notifications:read",
    "bookings:read", "bookings:create", "bookings:update",
    "analytics:view"
  ]'::jsonb,
  true,
  NOW(),
  NOW()
) ON CONFLICT (name) DO UPDATE SET
  description = EXCLUDED.description,
  permissions = EXCLUDED.permissions,
  updated_at = NOW();

-- Staff Role (Basic Access)
INSERT INTO roles (id, name, description, icon, color, permissions, is_active, created_at, updated_at)
VALUES (
  gen_random_uuid(),
  'Staff',
  'Standard employee access',
  'user',
  '#10b981',
  '[
    "suppliers:read",
    "rubberTypes:read",
    "bookings:read", "bookings:create",
    "notifications:read"
  ]'::jsonb,
  true,
  NOW(),
  NOW()
) ON CONFLICT (name) DO UPDATE SET
  description = EXCLUDED.description,
  permissions = EXCLUDED.permissions,
  updated_at = NOW();

-- Verify roles created
SELECT id, name, description, jsonb_array_length(permissions) as permission_count
FROM roles
ORDER BY name;
