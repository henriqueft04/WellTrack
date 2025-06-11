import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// Service to handle Bluetooth operations including getting the device's MAC address
/// and managing Bluetooth advertising/scanning with custom UUIDs
class BluetoothService {
  static const String WELLTRACK_SERVICE_UUID = "12345678-1234-5678-1234-567812345678";
  static const String WELLTRACK_CHARACTERISTIC_UUID = "87654321-4321-8765-4321-876543218765";
  
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  String? _cachedDeviceId;

  /// Get a unique device identifier that can be used for Bluetooth matching
  /// This will try to get the actual MAC address on Android, or a stable device ID on iOS
  Future<String?> getDeviceBluetoothId() async {
    if (_cachedDeviceId != null) {
      return _cachedDeviceId;
    }

    try {
      if (Platform.isAndroid) {
        // On Android, we can potentially get the Bluetooth MAC address
        // Note: This requires BLUETOOTH_CONNECT permission and may not work on newer Android versions
        final androidInfo = await _deviceInfo.androidInfo;
        
        // Try to get Bluetooth MAC via platform channel
        try {
          final String? macAddress = await _getBluetoothMacAddress();
          if (macAddress != null && macAddress.isNotEmpty) {
            _cachedDeviceId = macAddress;
            return macAddress;
          }
        } catch (e) {
          print('Failed to get Bluetooth MAC address: $e');
        }
        
        // Fallback: Use Android ID as a stable identifier
        // Format it as a pseudo-MAC address for consistency
        final androidId = androidInfo.id;
        if (androidId.isNotEmpty) {
          _cachedDeviceId = _formatAsPseudoMac(androidId);
          return _cachedDeviceId;
        }
      } else if (Platform.isIOS) {
        // On iOS, we cannot get the Bluetooth MAC address due to privacy restrictions
        // Use the identifierForVendor as a stable device identifier
        final iosInfo = await _deviceInfo.iosInfo;
        final deviceId = iosInfo.identifierForVendor ?? '';
        
        if (deviceId.isNotEmpty) {
          _cachedDeviceId = _formatAsPseudoMac(deviceId);
          return _cachedDeviceId;
        }
      }
      
      // Final fallback: Generate a unique ID based on timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      _cachedDeviceId = 'WT_${timestamp.substring(timestamp.length - 8)}';
      return _cachedDeviceId;
      
    } catch (e) {
      print('Error getting device Bluetooth ID: $e');
      return null;
    }
  }

  /// Platform channel to get Bluetooth MAC address (Android only)
  Future<String?> _getBluetoothMacAddress() async {
    if (!Platform.isAndroid) {
      return null;
    }

    try {
      const platform = MethodChannel('com.welltrack/bluetooth');
      final String? macAddress = await platform.invokeMethod('getBluetoothMacAddress');
      return macAddress;
    } on PlatformException catch (e) {
      print('Failed to get Bluetooth MAC address: ${e.message}');
      return null;
    }
  }

  /// Format a string as a pseudo-MAC address for consistency
  String _formatAsPseudoMac(String input) {
    // Remove any non-alphanumeric characters
    final clean = input.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    
    // Ensure we have enough characters (pad with zeros if needed)
    final padded = clean.padRight(12, '0');
    
    // Take first 12 characters and format as MAC
    final truncated = padded.substring(0, 12).toUpperCase();
    
    // Format as XX:XX:XX:XX:XX:XX
    return '${truncated.substring(0,2)}:${truncated.substring(2,4)}:${truncated.substring(4,6)}:'
           '${truncated.substring(6,8)}:${truncated.substring(8,10)}:${truncated.substring(10,12)}';
  }

  /// Create a mapping between MAC addresses and WellTrack IDs
  /// This allows us to handle the discrepancy between scanned MAC addresses
  /// and stored device IDs
  Map<String, String> createDeviceIdMapping(List<ScanResult> scanResults) {
    final mapping = <String, String>{};
    
    for (final result in scanResults) {
      final macAddress = result.device.remoteId.toString();
      
      // Check if this device is advertising WellTrack service
      if (_isWellTrackDevice(result)) {
        // Extract the WellTrack ID from the advertisement data
        final welltrackId = _extractWellTrackId(result);
        if (welltrackId != null) {
          mapping[macAddress] = welltrackId;
        }
      }
    }
    
    return mapping;
  }

  /// Check if a scanned device is a WellTrack device
  bool _isWellTrackDevice(ScanResult result) {
    // Check for WellTrack service UUID in advertisement
    return result.advertisementData.serviceUuids.contains(WELLTRACK_SERVICE_UUID);
  }

  /// Extract WellTrack ID from advertisement data
  String? _extractWellTrackId(ScanResult result) {
    // Look for manufacturer data or service data containing the WellTrack ID
    final manufacturerData = result.advertisementData.manufacturerData;
    if (manufacturerData.isNotEmpty) {
      // Parse the WellTrack ID from manufacturer data
      // This is where you'd extract the actual ID based on your protocol
      // For now, return the MAC address as fallback
      return result.device.remoteId.toString();
    }
    
    return null;
  }
}