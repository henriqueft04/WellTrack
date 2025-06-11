-- Fix for the bluetooth lookup function type mismatch error
-- This replaces the existing function with correct type casting

-- Drop the existing function first
DROP FUNCTION IF EXISTS lookup_users_by_bluetooth_ids(TEXT[]);

-- Recreate with proper type casting
CREATE OR REPLACE FUNCTION lookup_users_by_bluetooth_ids(
    device_ids TEXT[]
)
RETURNS TABLE (
    user_id BIGINT,
    name TEXT,
    avatar VARCHAR,
    mental_state mental_states,
    bluetooth_device_id VARCHAR,
    bluetooth_mac_address VARCHAR,
    matched_id VARCHAR
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    WITH normalized_ids AS (
        -- Normalize any MAC addresses in the input
        SELECT 
            unnest(device_ids) as original_id,
            normalize_mac_address(unnest(device_ids)) as normalized_mac
    )
    SELECT DISTINCT
        u.id as user_id,
        u.name::TEXT,
        u.avatar::VARCHAR,
        u.mental_state,
        u.bluetooth_device_id::VARCHAR,
        u.bluetooth_mac_address::VARCHAR,
        COALESCE(
            CASE 
                WHEN u.bluetooth_device_id = n.original_id THEN n.original_id
                WHEN u.bluetooth_mac_address = n.original_id THEN n.original_id
                WHEN u.bluetooth_mac_address = n.normalized_mac THEN n.original_id
                ELSE NULL
            END,
            u.bluetooth_device_id
        )::VARCHAR as matched_id
    FROM public.users u
    CROSS JOIN normalized_ids n
    WHERE 
        (u.privacy_visible = TRUE OR u.privacy_visible IS NULL)
        AND (
            u.bluetooth_device_id = n.original_id
            OR u.bluetooth_mac_address = n.original_id
            OR u.bluetooth_mac_address = n.normalized_mac
        );
END;
$$;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION lookup_users_by_bluetooth_ids TO authenticated;

-- Test the function to make sure it works
-- Uncomment and run this to test:
-- SELECT * FROM lookup_users_by_bluetooth_ids(ARRAY['56:1F:14:C8:C9:41', 'BT_46622298']);