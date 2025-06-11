# Bluetooth ID Handling Fix Documentation

## Problem Summary

The WellTrack app has a critical mismatch between how Bluetooth devices are identified:

1. **Scanning**: The app scans for nearby Bluetooth devices and retrieves their MAC addresses (format: `XX:XX:XX:XX:XX:XX`)
2. **Storage**: The database stores Bluetooth IDs in a custom format (e.g., `BT_46622298`)
3. **Lookup Failure**: When trying to match scanned devices with database users, no matches are found because MAC addresses don't match the `BT_` format IDs

## Root Cause

The `_getCurrentDeviceBluetoothId()` method generates a pseudo-ID using timestamp instead of getting the actual device's Bluetooth MAC address. This means:
- Each user's stored `bluetooth_device_id` is a unique `BT_` prefixed ID
- Scanned devices return actual MAC addresses
- The lookup query fails because it's comparing MAC addresses against `BT_` IDs

## Solutions Implemented

### 1. Enhanced Bluetooth Service
Created `lib/services/bluetooth_service.dart` that:
- Attempts to get the actual Bluetooth MAC address on Android
- Falls back to device-specific stable identifiers on iOS
- Provides consistent ID formatting

### 2. Platform Channel for Android
Created Android-specific code to retrieve the actual Bluetooth MAC address:
- `BluetoothPlugin.kt`: Implements method channel to get MAC address
- Updated `MainActivity.kt`: Registers the Bluetooth plugin

### 3. Database Schema Enhancement
Created `bluetooth_migration.sql` that:
- Adds `bluetooth_mac_address` column to store actual MAC addresses
- Creates a lookup function that can match both ID formats
- Provides backward compatibility with existing `BT_` format IDs

### 4. Updated Bluetooth Provider
Modified the provider to:
- Use the new BluetoothService for device ID retrieval
- Use the enhanced database lookup function
- Store both ID formats when registering a device

## How It Works Now

1. **Device Registration**:
   - Attempts to get actual MAC address (Android) or stable device ID (iOS)
   - Stores both `bluetooth_device_id` and `bluetooth_mac_address` if applicable

2. **Device Scanning**:
   - Scans nearby devices and gets their MAC addresses
   - Uses the `lookup_users_by_bluetooth_ids` function that can match either format

3. **Backward Compatibility**:
   - Existing users with `BT_` format IDs continue to work
   - New users get proper MAC addresses stored
   - The lookup function handles both formats transparently

## Migration Steps

1. **Run the SQL migration**:
   ```sql
   -- Execute bluetooth_migration.sql on your Supabase database
   ```

2. **Update dependencies**:
   ```bash
   flutter pub get
   ```

3. **Test the implementation**:
   - Register a new device and verify MAC address is stored
   - Test Bluetooth scanning between devices
   - Verify existing `BT_` format users still work

## Future Improvements

1. **iOS MAC Address**: iOS doesn't allow MAC address access. Consider using:
   - Custom BLE advertising with app-specific UUIDs
   - iBeacon protocol for iOS devices

2. **Privacy Considerations**:
   - MAC addresses can be used for tracking
   - Consider implementing rotating IDs for privacy
   - Use encryption for sensitive data in BLE advertisements

3. **Performance Optimization**:
   - Cache Bluetooth ID mappings locally
   - Implement batch lookups for multiple devices
   - Add connection pooling for database queries

## Testing Checklist

- [ ] Android device can retrieve its MAC address
- [ ] iOS device falls back to stable identifier
- [ ] New users get MAC addresses stored in database
- [ ] Scanning finds nearby WellTrack users
- [ ] Legacy `BT_` format IDs still work
- [ ] Privacy settings are respected
- [ ] Performance is acceptable with multiple nearby devices