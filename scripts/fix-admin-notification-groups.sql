-- Fix Notification Group Assignment for Admin Users (Updated)
-- This script uses the many-to-many relation between User and NotificationGroup

-- Step 1: Check current admin users and their notification groups
SELECT 
    u.id,
    u.email,
    u."displayName",
    u.role,
    ARRAY_AGG(ng.name) FILTER (WHERE ng.name IS NOT NULL) as groups
FROM users u
LEFT JOIN "_NotificationGroupMembers" ngm ON u.id = ngm."B"
LEFT JOIN notification_groups ng ON ngm."A" = ng.id
WHERE u.role IN ('admin', 'ADMIN', 'Administrator')
GROUP BY u.id, u.email, u."displayName", u.role;

-- Step 2: Get Admin notification group ID
SELECT id, name FROM notification_groups WHERE name = 'Admin';

-- Step 3: Add all admin users to Admin notification group
-- Note: "_NotificationGroupMembers" is the implicit join table created by Prisma
-- Column A = NotificationGroup.id, Column B = User.id
INSERT INTO "_NotificationGroupMembers" ("A", "B")
SELECT 
    (SELECT id FROM notification_groups WHERE name = 'Admin' LIMIT 1) as "A",
    u.id as "B"
FROM users u
WHERE u.role IN ('admin', 'ADMIN', 'Administrator')
  AND NOT EXISTS (
    SELECT 1 
    FROM "_NotificationGroupMembers" ngm
    WHERE ngm."A" = (SELECT id FROM notification_groups WHERE name = 'Admin' LIMIT 1)
      AND ngm."B" = u.id
  )
ON CONFLICT DO NOTHING;

-- Step 4: Verify results
SELECT 
    u.email,
    u."displayName",
    u.role,
    ng.name as group_name
FROM users u
JOIN "_NotificationGroupMembers" ngm ON u.id = ngm."B"
JOIN notification_groups ng ON ngm."A" = ng.id
WHERE u.role IN ('admin', 'ADMIN', 'Administrator')
ORDER BY u.email;
