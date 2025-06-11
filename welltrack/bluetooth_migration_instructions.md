# Bluetooth Migration Instructions

## Step 1: Run the Migration in Supabase

1. Go to your Supabase dashboard
2. Navigate to SQL Editor
3. Copy and paste the contents of `bluetooth_migration.sql`
4. Click "Run" to execute the migration

This migration will:
- Add a `bluetooth_mac_address` column to the users table
- Create a function to normalize MAC addresses
- Create a lookup function that handles both MAC addresses and BT_ format IDs
- Create indexes for efficient lookups

## Step 2: Verify the Migration

After running the migration, verify it worked by running:

```sql
-- Check if the new column exists
SELECT column_name 
FROM information_schema.columns 
WHERE table_name = 'users' 
AND column_name = 'bluetooth_mac_address';

-- Check if the lookup function exists
SELECT routine_name 
FROM information_schema.routines 
WHERE routine_name = 'lookup_users_by_bluetooth_ids';
```

## Step 3: Test the Lookup Function

Test with your existing BT_ IDs and MAC addresses:

```sql
-- Test with both MAC addresses and BT_ IDs
SELECT * FROM lookup_users_by_bluetooth_ids(
  ARRAY['56:1F:14:C8:C9:41', 'BT_46622298']
);
```

## What This Fixes

1. **Backward Compatibility**: Existing BT_ format IDs continue to work
2. **MAC Address Support**: New devices can store actual MAC addresses
3. **Flexible Lookup**: The lookup function searches both columns
4. **Normalized Format**: MAC addresses are normalized to XX:XX:XX:XX:XX:XX format

## Next Steps

After running the migration, the app will:
1. Store MAC addresses for new device registrations
2. Successfully match scanned MAC addresses with database users
3. Continue supporting legacy BT_ format IDs