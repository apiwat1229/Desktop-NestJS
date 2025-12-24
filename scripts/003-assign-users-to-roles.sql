-- Assign Users to Roles based on current role text field

-- Step 1: Assign ADMIN users to Administrator role
UPDATE users 
SET role_id = (SELECT id FROM roles WHERE name = 'Administrator' LIMIT 1)
WHERE role IN ('ADMIN', 'admin', 'Administrator')
  AND role_id IS NULL;

-- Step 2: Assign Manager/HOD users to Manager role
UPDATE users 
SET role_id = (SELECT id FROM roles WHERE name = 'Manager' LIMIT 1)
WHERE role IN ('manager', 'Manager', 'hod', 'HOD')
  AND role_id IS NULL;

-- Step 3: Assign Staff users to Staff role
UPDATE users 
SET role_id = (SELECT id FROM roles WHERE name = 'Staff' LIMIT 1)
WHERE role IN ('staff', 'Staff', 'staff_1', 'staff_2', 'employee')
  AND role_id IS NULL;

-- Step 4: Verify assignment
SELECT 
  r.name as role_name,
  COUNT(u.id) as user_count,
  STRING_AGG(u.email, ', ') as users
FROM roles r
LEFT JOIN users u ON u.role_id = r.id
GROUP BY r.id, r.name
ORDER BY r.name;

-- Step 5: Check for users without roleId
SELECT email, role, role_id
FROM users
WHERE role_id IS NULL;
