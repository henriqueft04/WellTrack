import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _moodSharingKey = 'mood_sharing_enabled';
  static const String _bluetoothNameKey = 'bluetooth_display_name';
  static const String _vibrationAlertsKey = 'vibration_alerts_enabled';
  
  static SharedPreferences? _preferences;

  // Initialize SharedPreferences
  static Future<void> initialize() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  // Mood Sharing Settings
  static Future<bool> isMoodSharingEnabled() async {
    await initialize();
    return _preferences?.getBool(_moodSharingKey) ?? false; // Default: disabled for privacy
  }

  static Future<void> setMoodSharingEnabled(bool enabled) async {
    await initialize();
    await _preferences?.setBool(_moodSharingKey, enabled);
  }

  // Bluetooth Display Name
  static Future<String?> getBluetoothDisplayName() async {
    await initialize();
    return _preferences?.getString(_bluetoothNameKey);
  }

  static Future<void> setBluetoothDisplayName(String name) async {
    await initialize();
    await _preferences?.setString(_bluetoothNameKey, name);
  }

  // Vibration Alert Settings
  static Future<bool> isVibrationAlertsEnabled() async {
    await initialize();
    return _preferences?.getBool(_vibrationAlertsKey) ?? true; // Default: enabled
  }

  static Future<void> setVibrationAlertsEnabled(bool enabled) async {
    await initialize();
    await _preferences?.setBool(_vibrationAlertsKey, enabled);
  }

  // Clear all settings (for logout)
  static Future<void> clearSettings() async {
    await initialize();
    await _preferences?.remove(_moodSharingKey);
    await _preferences?.remove(_bluetoothNameKey);
    await _preferences?.remove(_vibrationAlertsKey);
  }
} 