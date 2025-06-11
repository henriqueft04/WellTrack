-- Test data for Bluetooth proximity feature
-- This creates or updates test users with the hardcoded MAC addresses

-- First, check if these users exist
SELECT id, name, bluetooth_device_id, bluetooth_mac_address 
FROM users 
WHERE bluetooth_mac_address IN ('SK:Q1:21:10:06:00', 'UP:1A:23:10:05:00')
   OR bluetooth_device_id IN ('SK:Q1:21:10:06:00', 'UP:1A:23:10:05:00');

-- Update existing users to have these MAC addresses (replace USER_ID with actual IDs)
-- Example:
-- UPDATE users 
-- SET bluetooth_mac_address = 'SK:Q1:21:10:06:00',
--     bluetooth_device_id = 'SK:Q1:21:10:06:00'
-- WHERE id = 1;

-- UPDATE users 
-- SET bluetooth_mac_address = 'UP:1A:23:10:05:00',
--     bluetooth_device_id = 'UP:1A:23:10:05:00'
-- WHERE id = 2;

-- Or if you want to update specific users by email:
UPDATE users 
SET bluetooth_mac_address = 'SK:Q1:21:10:06:00',
    bluetooth_device_id = 'SK:Q1:21:10:06:00'
WHERE email = 'test1@example.com';  -- Replace with actual email

UPDATE users 
SET bluetooth_mac_address = 'UP:1A:23:10:05:00',
    bluetooth_device_id = 'UP:1A:23:10:05:00'
WHERE email = 'test2@example.com';  -- Replace with actual email

-- Verify the updates
SELECT id, name, email, mental_state, bluetooth_device_id, bluetooth_mac_address 
FROM users 
WHERE bluetooth_mac_address IN ('SK:Q1:21:10:06:00', 'UP:1A:23:10:05:00');

-- Test the lookup function with hardcoded addresses
SELECT * FROM lookup_users_by_bluetooth_ids(
  ARRAY['SK:Q1:21:10:06:00', 'UP:1A:23:10:05:00']
);