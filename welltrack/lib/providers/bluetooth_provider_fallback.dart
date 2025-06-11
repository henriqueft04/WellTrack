// Fallback method to query users directly if RPC function fails
// Add this to BluetoothProvider if needed

Future<List<Map<String, dynamic>>> _fallbackUserLookup(List<String> deviceIds) async {
  try {
    final supabase = Supabase.instance.client;
    
    // Normalize MAC addresses
    final normalizedIds = deviceIds.map((id) {
      // Remove colons and convert to uppercase for comparison
      if (id.contains(':') && id.length == 17) {
        return id.toUpperCase();
      }
      return id;
    }).toList();
    
    // Query users table directly
    final response = await supabase
        .from('users')
        .select('id, name, avatar, mental_state, bluetooth_device_id, bluetooth_mac_address')
        .or(
          normalizedIds.map((id) => 
            'bluetooth_device_id.eq.$id,bluetooth_mac_address.eq.$id'
          ).join(',')
        )
        .eq('privacy_visible', true);
    
    // Transform response to match expected format
    final List<Map<String, dynamic>> results = [];
    for (final user in response) {
      // Find which ID matched
      String? matchedId;
      for (final id in deviceIds) {
        if (user['bluetooth_device_id'] == id || 
            user['bluetooth_mac_address'] == id ||
            user['bluetooth_mac_address'] == id.toUpperCase()) {
          matchedId = id;
          break;
        }
      }
      
      if (matchedId != null) {
        results.add({
          'user_id': user['id'],
          'name': user['name'],
          'avatar': user['avatar'],
          'mental_state': user['mental_state'],
          'bluetooth_device_id': user['bluetooth_device_id'],
          'bluetooth_mac_address': user['bluetooth_mac_address'],
          'matched_id': matchedId,
        });
      }
    }
    
    return results;
  } catch (e) {
    debugPrint('BluetoothProvider: Fallback lookup also failed: $e');
    return [];
  }
}