-- Migration to support both MAC addresses and legacy BT_ format IDs
-- This allows for a smooth transition from BT_ format to actual MAC addresses

-- Add a new column for MAC addresses if it doesn't exist
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS bluetooth_mac_address VARCHAR(17);

-- Add an index on the MAC address column for efficient lookups
CREATE INDEX IF NOT EXISTS users_bluetooth_mac_address_idx 
ON public.users (bluetooth_mac_address);

-- Create a function to normalize MAC addresses (ensure consistent format)
CREATE OR REPLACE FUNCTION normalize_mac_address(mac_input TEXT)
RETURNS TEXT AS $$
BEGIN
    -- Remove any non-alphanumeric characters
    -- Convert to uppercase
    -- Format as XX:XX:XX:XX:XX:XX
    IF mac_input IS NULL THEN
        RETURN NULL;
    END IF;
    
    -- Remove colons, dashes, dots, and spaces
    mac_input := UPPER(REGEXP_REPLACE(mac_input, '[^A-Fa-f0-9]', '', 'g'));
    
    -- Check if it's a valid MAC address length (12 hex characters)
    IF LENGTH(mac_input) != 12 THEN
        RETURN NULL;
    END IF;
    
    -- Format with colons
    RETURN SUBSTRING(mac_input, 1, 2) || ':' ||
           SUBSTRING(mac_input, 3, 2) || ':' ||
           SUBSTRING(mac_input, 5, 2) || ':' ||
           SUBSTRING(mac_input, 7, 2) || ':' ||
           SUBSTRING(mac_input, 9, 2) || ':' ||
           SUBSTRING(mac_input, 11, 2);
END;
$$ LANGUAGE plpgsql;

-- Create a view that allows searching by either bluetooth_device_id or bluetooth_mac_address
CREATE OR REPLACE VIEW user_bluetooth_lookup AS
SELECT 
    id,
    name,
    email,
    avatar,
    mental_state,
    privacy_visible,
    bluetooth_device_id,
    bluetooth_mac_address,
    -- Create a searchable_ids array that includes both IDs
    ARRAY_REMOVE(ARRAY[bluetooth_device_id, bluetooth_mac_address], NULL) as searchable_bluetooth_ids
FROM public.users;

-- Grant permissions on the view
GRANT SELECT ON user_bluetooth_lookup TO authenticated;

-- Create an optimized function to lookup users by Bluetooth IDs
-- This function can handle both MAC addresses and BT_ format IDs
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
    matched_id TEXT
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
        u.name,
        u.avatar,
        u.mental_state,
        u.bluetooth_device_id,
        u.bluetooth_mac_address,
        COALESCE(
            CASE 
                WHEN u.bluetooth_device_id = n.original_id THEN n.original_id
                WHEN u.bluetooth_mac_address = n.original_id THEN n.original_id
                WHEN u.bluetooth_mac_address = n.normalized_mac THEN n.original_id
                ELSE NULL
            END,
            u.bluetooth_device_id
        ) as matched_id
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

-- Migration helper: Update existing BT_ format IDs that might be MAC addresses
-- This is safe to run multiple times
UPDATE public.users
SET bluetooth_mac_address = normalize_mac_address(
    CASE 
        WHEN bluetooth_device_id LIKE 'BT_%' THEN NULL
        ELSE bluetooth_device_id
    END
)
WHERE bluetooth_mac_address IS NULL 
AND bluetooth_device_id IS NOT NULL
AND bluetooth_device_id NOT LIKE 'BT_%'
AND LENGTH(REGEXP_REPLACE(bluetooth_device_id, '[^A-Fa-f0-9]', '', 'g')) = 12;