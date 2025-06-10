import 'dart:convert';
import 'package:welltrack/utils/mood_utils.dart';

class BluetoothUser {
  final String deviceId;
  final String username;
  final String? avatarUrl;
  final String? mentalState; // Changed from moodValue to mentalState
  final DateTime lastUpdate;
  final int signalStrength;

  BluetoothUser({
    required this.deviceId,
    required this.username,
    this.avatarUrl,
    this.mentalState,
    required this.lastUpdate,
    required this.signalStrength,
  });

  // Convert to JSON for Bluetooth advertisement
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'avatar': avatarUrl,
      'mental_state': mentalState,
      'timestamp': lastUpdate.millisecondsSinceEpoch,
    };
  }

  // Create from JSON (received from Bluetooth)
  factory BluetoothUser.fromJson(String deviceId, Map<String, dynamic> json, int rssi) {
    return BluetoothUser(
      deviceId: deviceId,
      username: json['username'] ?? 'Unknown User',
      avatarUrl: json['avatar'],
      mentalState: json['mental_state'],
      lastUpdate: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] ?? 0),
      signalStrength: rssi,
    );
  }

  // Convert to bytes for Bluetooth advertisement (limited to ~20 bytes for name field)
  static String encodeUserData(String username, String? mentalState, String? avatarHash) {
    // Convert mental_state to a short code for Bluetooth transmission
    String moodCode = _mentalStateToCode(mentalState);
    
    final data = {
      'u': username.length > 10 ? username.substring(0, 10) : username, // Truncate username
      'm': moodCode, // Mental state as short code
      'a': avatarHash?.substring(0, 8) ?? '', // Avatar hash (first 8 chars)
      't': DateTime.now().millisecondsSinceEpoch ~/ 1000, // Timestamp in seconds
    };
    return jsonEncode(data);
  }

  // Convert mental_state to short code for Bluetooth transmission
  static String _mentalStateToCode(String? mentalState) {
    switch (mentalState?.toLowerCase()) {
      case 'very_unpleasant':
        return 'vu';
      case 'unpleasant':
        return 'u';
      case 'ok':
        return 'o';
      case 'pleasant':
        return 'p';
      case 'very_pleasant':
        return 'vp';
      default:
        return 'o'; // Default to 'ok'
    }
  }

  // Convert short code back to mental_state
  static String? _codeToMentalState(String? code) {
    switch (code?.toLowerCase()) {
      case 'vu':
        return 'very_unpleasant';
      case 'u':
        return 'unpleasant';
      case 'o':
        return 'ok';
      case 'p':
        return 'pleasant';
      case 'vp':
        return 'very_pleasant';
      default:
        return 'ok'; // Default to 'ok'
    }
  }

  // Parse user data from Bluetooth advertisement
  static BluetoothUser? parseAdvertisementData(String deviceId, String? advertisementName, int rssi) {
    if (advertisementName == null || !advertisementName.startsWith('WT:')) {
      return null; // Not a WellTrack user
    }

    try {
      final jsonData = advertisementName.substring(3); // Remove 'WT:' prefix
      final data = jsonDecode(jsonData);
      
      return BluetoothUser(
        deviceId: deviceId,
        username: data['u'] ?? 'Unknown User',
        avatarUrl: null, // Will be resolved later if needed
        mentalState: _codeToMentalState(data['m']),
        lastUpdate: DateTime.fromMillisecondsSinceEpoch((data['t'] ?? 0) * 1000),
        signalStrength: rssi,
      );
    } catch (e) {
      return null; // Invalid data format
    }
  }

  // Get mood emoji representation using mood_utils.dart
  String get moodEmoji {
    // Use a simple mapping based on mental state instead of IconData conversion
    switch (mentalState?.toLowerCase()) {
      case 'very_unpleasant':
        return '😢';
      case 'unpleasant':
        return '😔';
      case 'ok':
        return '😐';
      case 'pleasant':
        return '😊';
      case 'very_pleasant':
        return '😄';
      default:
        return '😐';
    }
  }

  // Get mood icon using mood_utils.dart
  get moodIcon {
    return MoodUtils.getMoodIconFromState(mentalState);
  }

  // Get mood description using mood_utils.dart
  String get moodDescription {
    return MoodUtils.getMoodDisplayName(mentalState);
  }

  // Get mood color using mood_utils.dart
  get moodColor {
    return MoodUtils.getMoodColorFromState(mentalState);
  }

  // Distance estimation from signal strength
  String get estimatedDistance {
    if (signalStrength > -50) return 'Very close (~1m)';
    if (signalStrength > -70) return 'Close (~5m)';
    if (signalStrength > -90) return 'Medium distance (~10m)';
    return 'Far away (~20m+)';
  }

  // Time since last update
  String get lastSeenText {
    final difference = DateTime.now().difference(lastUpdate);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }

  @override
  String toString() {
    return 'BluetoothUser{username: $username, mentalState: $mentalState, lastUpdate: $lastUpdate}';
  }
} 