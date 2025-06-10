import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:welltrack/models/bluetooth_user.dart';
import 'package:welltrack/services/settings_service.dart';
import 'package:welltrack/providers/user_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibration/vibration.dart';

class BluetoothProvider with ChangeNotifier {
  // Private state variables
  List<ScanResult> _scanResults = [];
  List<BluetoothUser> _nearbyUsers = [];
  bool _isScanning = false;
  bool _isAdvertising = false;
  bool _isBluetoothOn = false;
  bool _isBluetoothSupported = false;
  bool _isLoading = false;
  bool _isMoodSharingEnabled = false;
  bool _isDeviceRegistered = false;
  String? _error;
  String _statusMessage = 'Initializing...';
  
  // Vibration settings
  bool _isVibrationEnabled = true;
  bool _isVibrationSupported = false;
  Set<String> _alertedUsers = <String>{}; // Track users we've already alerted for
  
  // Stream subscriptions
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  StreamSubscription<List<ScanResult>>? _scanResultsSubscription;
  StreamSubscription<bool>? _scanningStateSubscription;

  // User data for advertising
  UserProvider? _userProvider;

  // Add simulation mode for testing
  bool _simulationMode = false;
  Timer? _simulationTimer;

  // Getters
  List<ScanResult> get scanResults => _scanResults;
  List<BluetoothUser> get nearbyUsers => _nearbyUsers;
  bool get isScanning => _isScanning;
  bool get isAdvertising => _isAdvertising;
  bool get isBluetoothOn => _isBluetoothOn;
  bool get isBluetoothSupported => _isBluetoothSupported;
  bool get isLoading => _isLoading;
  bool get isMoodSharingEnabled => _isMoodSharingEnabled;
  bool get isDeviceRegistered => _isDeviceRegistered;
  bool get simulationMode => _simulationMode;
  String? get error => _error;
  String get statusMessage => _statusMessage;
  bool get canScan => _isBluetoothSupported && _isBluetoothOn && !_isLoading;
  bool get isVibrationEnabled => _isVibrationEnabled;
  bool get isVibrationSupported => _isVibrationSupported;

  // Set user provider for accessing profile data
  void setUserProvider(UserProvider userProvider) {
    _userProvider = userProvider;
  }

  // Initialize Bluetooth functionality
  Future<void> initialize() async {
    _setLoading(true);
    _clearError();
    
    try {
      // Check if Bluetooth is supported
      _isBluetoothSupported = await FlutterBluePlus.isSupported;
      
      if (!_isBluetoothSupported) {
        _setStatusMessage('Bluetooth not supported by this device');
        _setLoading(false);
        return;
      }

      // Load mood sharing setting
      _isMoodSharingEnabled = await SettingsService.isMoodSharingEnabled();

      // Load vibration settings and check support
      _isVibrationEnabled = await SettingsService.isVibrationAlertsEnabled();
      _isVibrationSupported = await Vibration.hasVibrator() ?? false;

      // Check if device is already registered
      await _checkDeviceRegistration();

      // Request permissions
      await _requestPermissions();

      // Set up listeners
      _setupBluetoothListeners();

      // Start advertising if mood sharing is enabled
      if (_isMoodSharingEnabled && _isBluetoothOn) {
        await _startAdvertising();
      }

      _setStatusMessage('Bluetooth initialized successfully');
    } catch (e) {
      _setError('Failed to initialize Bluetooth: $e');
      _setStatusMessage('Bluetooth initialization failed');
    } finally {
      _setLoading(false);
    }
  }

  // Check if user's device is already registered
  Future<void> _checkDeviceRegistration() async {
    try {
      if (_userProvider?.userProfile == null) {
        _isDeviceRegistered = false;
        return;
      }

      final userProfile = _userProvider!.userProfile!;
      final bluetoothDeviceId = userProfile['bluetooth_device_id'];
      
      _isDeviceRegistered = bluetoothDeviceId != null && bluetoothDeviceId.toString().isNotEmpty;
    } catch (e) {
      _isDeviceRegistered = false;
    }
  }

  // Toggle mood sharing setting
  Future<void> toggleMoodSharing(bool enabled) async {
    _isMoodSharingEnabled = enabled;
    await SettingsService.setMoodSharingEnabled(enabled);
    
    if (enabled && _isBluetoothOn) {
      await _startAdvertising();
    } else {
      await _stopAdvertising();
    }
    
    notifyListeners();
  }

  // Start advertising user mood data
  Future<void> _startAdvertising() async {
    if (!_isMoodSharingEnabled || _userProvider == null) return;
    
    try {
      final userProfile = _userProvider!.userProfile;
      if (userProfile == null) return;

      final username = userProfile['name'] ?? 'WellTrack User';
      final mentalState = userProfile['mental_state']; // Use mental_state instead of current_mood
      final avatarHash = userProfile['avatar']?.hashCode.toString();

      // Create advertisement data with WellTrack prefix
      final advertisementData = BluetoothUser.encodeUserData(username, mentalState, avatarHash);
      final advertisementName = 'WT:$advertisementData';

      // Note: flutter_blue_plus doesn't support advertising directly
      // We'll need to use the device name as a workaround
      // In a production app, you might need a different approach or custom platform implementation
      
      _isAdvertising = true;
      _setStatusMessage('Sharing mood with nearby users');
      notifyListeners();
    } catch (e) {
      _setError('Failed to start advertising: $e');
    }
  }

  // Stop advertising
  Future<void> _stopAdvertising() async {
    try {
      _isAdvertising = false;
      notifyListeners();
    } catch (e) {
      _setError('Failed to stop advertising: $e');
    }
  }

  // Request necessary permissions
  Future<void> _requestPermissions() async {
    try {
      final Map<Permission, PermissionStatus> permissions = await [
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
        Permission.location,
      ].request();

      // Filter out legacy bluetooth permissions that are expected to be denied on Android 12+
      // Focus only on critical permissions that actually affect functionality
      final criticalPermissions = {
        Permission.bluetoothScan: permissions[Permission.bluetoothScan],
        Permission.bluetoothConnect: permissions[Permission.bluetoothConnect],
        Permission.location: permissions[Permission.location],
      };

      final deniedCriticalPermissions = criticalPermissions.entries
          .where((entry) => entry.value?.isDenied == true)
          .map((entry) => entry.key.toString().split('.').last)
          .toList();

      if (deniedCriticalPermissions.isNotEmpty) {
        _setError('Critical permissions denied: ${deniedCriticalPermissions.join(', ')}');
      }
    } catch (e) {
      _setError('Failed to request permissions: $e');
    }
  }

  // Set up Bluetooth state listeners
  void _setupBluetoothListeners() {
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen(
      (BluetoothAdapterState state) {
        _isBluetoothOn = state == BluetoothAdapterState.on;
        
        if (!_isBluetoothOn) {
          _setStatusMessage('Please turn on Bluetooth');
          _clearScanResults();
          _stopAdvertising();
        } else {
          _setStatusMessage('Ready to scan for nearby users');
          if (_isMoodSharingEnabled) {
            _startAdvertising();
          }
        }
        
        notifyListeners();
      },
    );

    _scanResultsSubscription = FlutterBluePlus.scanResults.listen(
      (List<ScanResult> results) {
        _scanResults = results;
        _parseNearbyUsers(results);
        notifyListeners();
      },
    );

    _scanningStateSubscription = FlutterBluePlus.isScanning.listen(
      (bool scanning) {
        _isScanning = scanning;
        
        if (!scanning && _nearbyUsers.isEmpty) {
          _setStatusMessage('No nearby users found');
        } else if (!scanning && _nearbyUsers.isNotEmpty) {
          _setStatusMessage('Found ${_nearbyUsers.length} nearby WellTrack users');
        }
        
        notifyListeners();
      },
    );
  }

  // Parse scan results to find WellTrack users
  void _parseNearbyUsers(List<ScanResult> results) {
    _nearbyUsers.clear();
    
    // Get device IDs from scan results
    final deviceIds = results
        .map((result) => result.device.remoteId.toString())
        .where((id) => id.isNotEmpty)
        .toList();
    
    if (deviceIds.isNotEmpty) {
      _lookupWellTrackUsers(deviceIds, results);
    } else {
      // Clear alerts if no users found
      _clearStaleAlerts();
    }
  }

  // Lookup WellTrack users by Bluetooth device IDs in Supabase
  Future<void> _lookupWellTrackUsers(List<String> deviceIds, List<ScanResult> scanResults) async {
    try {
      final supabase = Supabase.instance.client;
      
      // Query Supabase for users with matching bluetooth_device_id
      final response = await supabase
          .from('users')
          .select('id, name, avatar, mental_state, bluetooth_device_id')
          .inFilter('bluetooth_device_id', deviceIds)
          .eq('privacy_visible', true); // Only include users who are visible
      
      if (response.isEmpty) {
        _clearStaleAlerts();
        return;
      }
      
      // Create a map for quick device ID to scan result lookup
      final deviceToScanResult = <String, ScanResult>{};
      for (final result in scanResults) {
        deviceToScanResult[result.device.remoteId.toString()] = result;
      }
      
      // Convert database results to BluetoothUser objects
      for (final userData in response) {
        final bluetoothId = userData['bluetooth_device_id'] as String?;
        if (bluetoothId == null) continue;
        
        final scanResult = deviceToScanResult[bluetoothId];
        if (scanResult == null) continue;
        
        final bluetoothUser = BluetoothUser(
          deviceId: bluetoothId,
          username: userData['name'] ?? 'WellTrack User',
          avatarUrl: userData['avatar'],
          mentalState: userData['mental_state'],
          lastUpdate: DateTime.now(), // Current time since we just found them
          signalStrength: scanResult.rssi,
        );
        
        _nearbyUsers.add(bluetoothUser);
      }
      
      // Clear stale alerts and check for users needing support
      _clearStaleAlerts();
      
      // Check for users with very_unpleasant mental state and trigger alert
      final usersNeedingSupport = _nearbyUsers
          .where((user) => user.mentalState == 'very_unpleasant')
          .toList();
      
      if (usersNeedingSupport.isNotEmpty) {
        await _triggerSupportAlert(usersNeedingSupport);
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to lookup nearby users: $e');
    }
  }

  // Store user's Bluetooth device ID in their profile
  Future<void> storeBluetoothDeviceId() async {
    try {
      if (_userProvider?.userProfile == null) {
        _setError('User not logged in');
        return;
      }

      // Get the current device's Bluetooth adapter address
      // Note: This is a simplified approach - in reality you'd need platform-specific code
      // to get the actual Bluetooth MAC address
      final deviceId = await _getCurrentDeviceBluetoothId();
      
      if (deviceId == null) {
        _setError('Could not get device Bluetooth ID');
        return;
      }

      final supabase = Supabase.instance.client;
      final userId = _userProvider!.userProfile!['id'];
      
      await supabase
          .from('users')
          .update({'bluetooth_device_id': deviceId})
          .eq('id', userId);
      
      // Update the user profile in the provider
      await _userProvider!.refresh();
      
      // Update registration state
      _isDeviceRegistered = true;
      
      _setStatusMessage('Device registered successfully! You can now be discovered by nearby WellTrack users.');
      notifyListeners();
    } catch (e) {
      _setError('Failed to store Bluetooth ID: $e');
    }
  }

  // Get current device's Bluetooth ID (simplified - would need platform-specific implementation)
  Future<String?> _getCurrentDeviceBluetoothId() async {
    try {
      // For now, use a combination of available device info
      // In a real implementation, you'd use platform channels to get the actual Bluetooth MAC
      final adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        return null;
      }
      
      // This is a placeholder - you'd need platform-specific code to get real Bluetooth MAC
      // For demo purposes, we'll use a hash of device info
      final deviceInfo = DateTime.now().millisecondsSinceEpoch.toString();
      return 'BT_${deviceInfo.substring(deviceInfo.length - 8)}';
    } catch (e) {
      return null;
    }
  }

  // Start scanning for nearby devices
  Future<void> startScan({Duration? timeout}) async {
    if (_simulationMode) {
      _isScanning = true;
      _setStatusMessage('Scanning for nearby users (Simulation Mode)...');
      _startSimulation();
      
      // Auto-stop simulation after timeout
      Timer(timeout ?? const Duration(seconds: 15), () {
        if (_simulationMode && _isScanning) {
          _isScanning = false;
          notifyListeners();
        }
      });
      
      notifyListeners();
      return;
    }

    if (!canScan) {
      if (!_isBluetoothOn) {
        _setError('Bluetooth is not enabled');
      } else if (!_isBluetoothSupported) {
        _setError('Bluetooth is not supported on this device');
      }
      return;
    }

    _clearError();
    _clearScanResults();
    _setStatusMessage('Scanning for nearby users...');

    try {
      await FlutterBluePlus.startScan(
        timeout: timeout ?? const Duration(seconds: 15),
        androidUsesFineLocation: true,
      );
    } catch (e) {
      _setError('Failed to start scan: $e');
      _setStatusMessage('Error starting scan');
    }
  }

  // Stop scanning
  Future<void> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
    } catch (e) {
      _setError('Failed to stop scan: $e');
    }
  }

  // Get signal strength icon based on RSSI
  IconData getSignalStrengthIcon(int rssi) {
    if (rssi > -50) {
      return Icons.signal_cellular_4_bar;
    } else if (rssi > -70) {
      return Icons.signal_cellular_alt;
    } else if (rssi > -90) {
      return Icons.signal_cellular_connected_no_internet_0_bar;
    } else {
      return Icons.signal_cellular_no_sim;
    }
  }

  // Get signal strength color based on RSSI
  Color getSignalStrengthColor(int rssi) {
    if (rssi > -50) {
      return Colors.green;
    } else if (rssi > -70) {
      return Colors.orange;
    } else if (rssi > -90) {
      return Colors.red;
    } else {
      return Colors.red.shade800;
    }
  }

  // Estimate distance based on RSSI
  String estimateDistance(int rssi) {
    if (rssi > -50) return 'Very close (~1m)';
    if (rssi > -70) return 'Close (~5m)';
    if (rssi > -90) return 'Medium distance (~10m)';
    return 'Far away (~20m+)';
  }

  // Get a friendly device name
  String getDeviceName(ScanResult result) {
    String deviceName = result.advertisementData.advName.isNotEmpty
        ? result.advertisementData.advName
        : result.device.platformName.isNotEmpty
            ? result.device.platformName
            : 'Unknown Device';

    if (deviceName == 'Unknown Device' || deviceName.isEmpty) {
      deviceName = 'WellTrack User';
    }

    return deviceName;
  }

  // Get device details for display
  Map<String, String> getDeviceDetails(ScanResult result) {
    return {
      'name': getDeviceName(result),
      'id': result.device.remoteId.toString(),
      'shortId': result.device.remoteId.toString().substring(0, 8),
      'rssi': '${result.rssi} dBm',
      'distance': estimateDistance(result.rssi),
    };
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void _setStatusMessage(String message) {
    _statusMessage = message;
    notifyListeners();
  }

  void _clearScanResults() {
    _scanResults.clear();
    _nearbyUsers.clear();
    notifyListeners();
  }

  // Refresh - restart scanning
  Future<void> refresh() async {
    if (_isScanning) {
      await stopScan();
    }
    await startScan();
  }

  // Toggle simulation mode for testing
  void toggleSimulationMode(bool enabled) {
    _simulationMode = enabled;
    if (enabled) {
      _startSimulation();
    } else {
      _stopSimulation();
    }
    notifyListeners();
  }

  // Start simulation with mock users
  void _startSimulation() {
    _simulationTimer?.cancel();
    _nearbyUsers.clear();
    _alertedUsers.clear(); // Clear alerts when starting new simulation

    // Create mock nearby users
    final mockUsers = [
      BluetoothUser(
        deviceId: 'mock_001',
        username: 'Alice Johnson',
        avatarUrl: null,
        mentalState: 'very_pleasant',
        lastUpdate: DateTime.now().subtract(const Duration(minutes: 2)),
        signalStrength: -45,
      ),
      BluetoothUser(
        deviceId: 'mock_002',
        username: 'Bob Smith',
        avatarUrl: null,
        mentalState: 'pleasant',
        lastUpdate: DateTime.now().subtract(const Duration(minutes: 1)),
        signalStrength: -65,
      ),
      BluetoothUser(
        deviceId: 'mock_003',
        username: 'Carol Davis',
        avatarUrl: null,
        mentalState: 'ok',
        lastUpdate: DateTime.now().subtract(const Duration(seconds: 30)),
        signalStrength: -85,
      ),
      BluetoothUser(
        deviceId: 'mock_004',
        username: 'David Wilson',
        avatarUrl: null,
        mentalState: 'very_unpleasant',
        lastUpdate: DateTime.now().subtract(const Duration(seconds: 15)),
        signalStrength: -55,
      ),
    ];

    // Add users gradually to simulate discovery
    int userIndex = 0;
    _simulationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (userIndex < mockUsers.length && _simulationMode && _isScanning) {
        _nearbyUsers.add(mockUsers[userIndex]);
        
        // Check if the newly added user needs support
        final newUser = mockUsers[userIndex];
        if (newUser.mentalState == 'very_unpleasant') {
          _triggerSupportAlert([newUser]);
        }
        
        userIndex++;
        _setStatusMessage('Found ${_nearbyUsers.length} nearby WellTrack users');
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  // Stop simulation
  void _stopSimulation() {
    _simulationTimer?.cancel();
    if (_simulationMode) {
      _nearbyUsers.clear();
      _alertedUsers.clear(); // Clear alerts when stopping simulation
      notifyListeners();
    }
  }

  // Toggle vibration alerts setting
  Future<void> toggleVibrationAlerts(bool enabled) async {
    _isVibrationEnabled = enabled;
    await SettingsService.setVibrationAlertsEnabled(enabled);
    notifyListeners();
  }

  // Trigger vibration alert for users needing support
  Future<void> _triggerSupportAlert(List<BluetoothUser> usersNeedingSupport) async {
    if (!_isVibrationEnabled || !_isVibrationSupported || usersNeedingSupport.isEmpty) {
      return;
    }

    try {
      // Check if any of these users are new (haven't been alerted for yet)
      final newUsersNeedingSupport = usersNeedingSupport
          .where((user) => !_alertedUsers.contains(user.deviceId))
          .toList();

      if (newUsersNeedingSupport.isEmpty) {
        return; // No new users to alert for
      }

      // Add new users to alerted set
      for (final user in newUsersNeedingSupport) {
        _alertedUsers.add(user.deviceId);
      }

      // Trigger vibration pattern for support alert
      // Pattern: short-long-short (SOS-like pattern)
      await Vibration.vibrate(
        pattern: [0, 200, 100, 400, 100, 200],
        intensities: [0, 128, 0, 255, 0, 128],
      );

      _setStatusMessage(
        'Alert: ${newUsersNeedingSupport.length} ${newUsersNeedingSupport.length == 1 ? 'person nearby needs' : 'people nearby need'} support!'
      );
    } catch (e) {
      // Vibration failed, but don't show error to user as it's not critical
      debugPrint('Vibration alert failed: $e');
    }
  }

  // Clear alerted users when scanning stops or when users are no longer nearby
  void _clearStaleAlerts() {
    final currentDeviceIds = _nearbyUsers.map((user) => user.deviceId).toSet();
    _alertedUsers.removeWhere((deviceId) => !currentDeviceIds.contains(deviceId));
  }

  @override
  void dispose() {
    _adapterStateSubscription?.cancel();
    _scanResultsSubscription?.cancel();
    _scanningStateSubscription?.cancel();
    
    FlutterBluePlus.stopScan();
    _stopAdvertising();
    
    super.dispose();
  }
} 