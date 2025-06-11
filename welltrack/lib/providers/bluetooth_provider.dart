import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:welltrack/models/bluetooth_user.dart';
import 'package:welltrack/services/settings_service.dart';
import 'package:welltrack/providers/user_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibration/vibration.dart';
import 'package:welltrack/services/bluetooth_service.dart' as welltrack_bluetooth;

class BluetoothProvider with ChangeNotifier {
  // Private state variables
  List<ScanResult> _scanResults = [];
  final List<BluetoothUser> _nearbyUsers = [];
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
  final Set<String> _alertedUsers = <String>{}; // Track users we've already alerted for
  
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
        // Don't parse immediately - wait for scan to complete
        notifyListeners();
      },
    );

    _scanningStateSubscription = FlutterBluePlus.isScanning.listen(
      (bool scanning) {
        _isScanning = scanning;
        
        if (!scanning) {
          // Scan completed - now parse the results
          if (_scanResults.isNotEmpty) {
            _parseNearbyUsers(_scanResults);
          } else {
            _setStatusMessage('No nearby devices found');
          }
        }
        
        notifyListeners();
      },
    );
  }

  // Parse scan results to find WellTrack users
  void _parseNearbyUsers(List<ScanResult> results) {
    _nearbyUsers.clear();
    
    debugPrint('BluetoothProvider: Found ${results.length} scan results');
    
    // Get device IDs from scan results
    final deviceIds = results
        .map((result) => result.device.remoteId.toString())
        .where((id) => id.isNotEmpty)
        .toList();
    
    debugPrint('BluetoothProvider: Device IDs found: $deviceIds');
    
    if (deviceIds.isNotEmpty) {
      // Only pass scan results, no hardcoded addresses
      _lookupWellTrackUsers(deviceIds, results);
    } else {
      debugPrint('BluetoothProvider: No device IDs found in scan results');
      // Clear alerts if no users found
      _clearStaleAlerts();
    }
  }

  // Lookup WellTrack users by Bluetooth device IDs in Supabase
  Future<void> _lookupWellTrackUsers(List<String> deviceIds, List<ScanResult> scanResults) async {
    // Add retry logic for network issues
    int retryCount = 0;
    const maxRetries = 3;
    
    while (retryCount < maxRetries) {
      try {
        debugPrint('BluetoothProvider: Looking up WellTrack users for device IDs: $deviceIds (attempt ${retryCount + 1}/$maxRetries)');
        
        final supabase = Supabase.instance.client;
        
        // Use the new lookup function that handles both MAC addresses and BT_ IDs
        // Add timeout to prevent hanging
        final response = await supabase
            .rpc('lookup_users_by_bluetooth_ids', params: {
              'device_ids': deviceIds
            })
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                throw Exception('Database lookup timed out');
              },
            );
        
        debugPrint('BluetoothProvider: Database lookup response: $response');
        
        if (response == null || (response as List).isEmpty) {
          debugPrint('BluetoothProvider: No WellTrack users found in database for scanned devices');
          
          // Try hardcoded addresses as fallback
          debugPrint('BluetoothProvider: Trying hardcoded addresses as fallback...');
          await _tryHardcodedAddresses();
          return;
        }
      
      // Create a map for quick device ID to scan result lookup
      final deviceToScanResult = <String, ScanResult>{};
      for (final result in scanResults) {
        final deviceId = result.device.remoteId.toString();
        deviceToScanResult[deviceId] = result;
        // Also map normalized versions
        deviceToScanResult[deviceId.toUpperCase()] = result;
        deviceToScanResult[deviceId.toLowerCase()] = result;
      }
      
      // Keep track of already added users to avoid duplicates
      final addedUserIds = <int>{};
      
      // Convert database results to BluetoothUser objects
      for (final userData in response) {
        // Check if we've already added this user
        final userId = userData['user_id'] as int;
        if (addedUserIds.contains(userId)) {
          debugPrint('BluetoothProvider: Skipping duplicate user ID: $userId');
          continue;
        }
        
        final matchedId = userData['matched_id'] as String?;
        if (matchedId == null) continue;
        
        // Try to find the scan result using various ID formats
        ScanResult? scanResult = deviceToScanResult[matchedId];
        
        // If not found by matched_id, try the original scanned IDs
        if (scanResult == null) {
          for (final entry in deviceToScanResult.entries) {
            if (userData['bluetooth_device_id'] == entry.key ||
                userData['bluetooth_mac_address'] == entry.key) {
              scanResult = entry.value;
              break;
            }
          }
        }
        
        
        if (scanResult == null) continue;
        
        debugPrint('BluetoothProvider: Found WellTrack user: ${userData['name']} with mood: ${userData['mental_state']}');
        
        final bluetoothUser = BluetoothUser(
          deviceId: scanResult.device.remoteId.toString(),
          username: userData['name'] ?? 'WellTrack User',
          avatarUrl: userData['avatar'],
          mentalState: userData['mental_state'],
          lastUpdate: DateTime.now(), // Current time since we just found them
          signalStrength: scanResult.rssi,
        );
        
        _nearbyUsers.add(bluetoothUser);
        addedUserIds.add(userId); // Mark as added
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
        return; // Success - exit the retry loop
        
      } catch (e, stackTrace) {
        retryCount++;
        
        if (retryCount >= maxRetries) {
          debugPrint('BluetoothProvider: Failed to lookup nearby users after $maxRetries attempts: $e');
          debugPrint('Stack trace: $stackTrace');
          
          // Check if it's a connection error
          if (e.toString().contains('connection closed') || 
              e.toString().contains('timed out') ||
              e.toString().contains('SocketException')) {
            _setError('Network error: Check your internet connection');
          } else {
            _setError('Failed to lookup nearby users: ${e.toString().split('\n').first}');
          }
          return;
        }
        
        // Wait before retrying
        debugPrint('BluetoothProvider: Retrying in 2 seconds... (attempt $retryCount/$maxRetries)');
        await Future.delayed(const Duration(seconds: 2));
      }
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
      final deviceId = await _getCurrentDeviceBluetoothId();
      
      if (deviceId == null) {
        _setError('Could not get device Bluetooth ID');
        return;
      }

      final supabase = Supabase.instance.client;
      final userId = _userProvider!.userProfile!['id'];
      
      // Prepare updates based on the device ID format
      final updates = <String, dynamic>{};
      
      // Check if the device ID looks like a MAC address (XX:XX:XX:XX:XX:XX)
      if (deviceId.contains(':') && deviceId.length == 17) {
        // It's a MAC address - store in both columns for compatibility
        updates['bluetooth_mac_address'] = deviceId.toUpperCase();
        updates['bluetooth_device_id'] = deviceId.toUpperCase(); // Also update the legacy column
      } else if (deviceId.startsWith('WT_') || deviceId.startsWith('BT_')) {
        // It's a legacy format ID - store only in bluetooth_device_id
        updates['bluetooth_device_id'] = deviceId;
      } else {
        // Unknown format - store in bluetooth_device_id
        updates['bluetooth_device_id'] = deviceId;
      }
      
      debugPrint('BluetoothProvider: Storing device ID $deviceId for user $userId');
      
      await supabase
          .from('users')
          .update(updates)
          .eq('id', userId);
      
      // Update the user profile in the provider
      await _userProvider!.refresh();
      
      // Update registration state
      _isDeviceRegistered = true;
      
      // Also check how many users have registered Bluetooth IDs for debugging
      await _debugCheckRegisteredUsers();
      
      _setStatusMessage('Device registered successfully! You can now be discovered by nearby WellTrack users.');
      notifyListeners();
    } catch (e) {
      debugPrint('BluetoothProvider: Failed to store Bluetooth ID: $e');
      _setError('Failed to store Bluetooth ID: $e');
    }
  }
  
  // Debug method to check registered users
  Future<void> _debugCheckRegisteredUsers() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('users')
          .select('id, name, bluetooth_device_id')
          .not('bluetooth_device_id', 'is', null);
      
      debugPrint('BluetoothProvider: ${response.length} users have registered Bluetooth IDs:');
      for (final user in response) {
        debugPrint('  - ${user['name']}: ${user['bluetooth_device_id']}');
      }
    } catch (e) {
      debugPrint('BluetoothProvider: Error checking registered users: $e');
    }
  }

  // Get current device's Bluetooth ID using the BluetoothService
  Future<String?> _getCurrentDeviceBluetoothId() async {
    try {
      final adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        debugPrint('BluetoothProvider: Bluetooth is not on, cannot get device ID');
        return null;
      }
      
      // Use the BluetoothService to get a proper device identifier
      final bluetoothService = welltrack_bluetooth.BluetoothService();
      return await bluetoothService.getDeviceBluetoothId();
    } catch (e) {
      debugPrint('BluetoothProvider: Error getting device ID: $e');
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
      debugPrint('BluetoothProvider: Starting Bluetooth scan...');
      await FlutterBluePlus.startScan(
        timeout: timeout ?? const Duration(seconds: 15),
        androidUsesFineLocation: true,
      );
      debugPrint('BluetoothProvider: Scan started successfully');
    } catch (e) {
      debugPrint('BluetoothProvider: Failed to start scan: $e');
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
  
  // Try hardcoded addresses when no users found in database
  Future<void> _tryHardcodedAddresses() async {
    _setStatusMessage('No users found. Checking test addresses...');
    
    final hardcodedAddresses = ['SK:Q1:21:10:06:00', 'UP:1A:23:10:05:00'];
    debugPrint('BluetoothProvider: Trying hardcoded addresses: $hardcodedAddresses');
    
    // Don't clear existing results - we might have found devices, just no users
    // _nearbyUsers should already be empty if we're here
    
    // Lookup hardcoded addresses
    await _lookupWellTrackUsersDirectly(hardcodedAddresses);
  }
  
  // Direct lookup without scan results
  Future<void> _lookupWellTrackUsersDirectly(List<String> deviceIds) async {
    int retryCount = 0;
    const maxRetries = 3;
    
    while (retryCount < maxRetries) {
      try {
        debugPrint('BluetoothProvider: Direct lookup for device IDs: $deviceIds (attempt ${retryCount + 1}/$maxRetries)');
        
        final supabase = Supabase.instance.client;
        
        final response = await supabase
            .rpc('lookup_users_by_bluetooth_ids', params: {
              'device_ids': deviceIds
            })
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                throw Exception('Database lookup timed out');
              },
            );
        
        debugPrint('BluetoothProvider: Database lookup response: $response');
        
        if (response == null || (response as List).isEmpty) {
          debugPrint('BluetoothProvider: No WellTrack users found with hardcoded addresses');
          _setStatusMessage('No test users found');
          return;
        }
        
        // Keep track of already added users to avoid duplicates
        final addedUserIds = <int>{};
        
        // Convert database results to BluetoothUser objects
        for (final userData in response) {
          // Check if we've already added this user
          final userId = userData['user_id'] as int;
          if (addedUserIds.contains(userId)) {
            continue;
          }
          
          debugPrint('BluetoothProvider: Found test user: ${userData['name']} with mood: ${userData['mental_state']}');
          
          final bluetoothUser = BluetoothUser(
            deviceId: userData['bluetooth_device_id'] ?? userData['bluetooth_mac_address'] ?? 'unknown',
            username: userData['name'] ?? 'WellTrack User',
            avatarUrl: userData['avatar'],
            mentalState: userData['mental_state'],
            lastUpdate: DateTime.now(),
            signalStrength: -70, // Mock signal strength
          );
          
          _nearbyUsers.add(bluetoothUser);
          addedUserIds.add(userId);
        }
        
        if (_nearbyUsers.isNotEmpty) {
          _setStatusMessage('Found ${_nearbyUsers.length} test users');
        }
        
        notifyListeners();
        return; // Success - exit the retry loop
        
      } catch (e, stackTrace) {
        retryCount++;
        
        if (retryCount >= maxRetries) {
          debugPrint('BluetoothProvider: Failed to lookup test addresses after $maxRetries attempts: $e');
          debugPrint('Stack trace: $stackTrace');
          _setStatusMessage('Failed to check test addresses');
          return;
        }
        
        // Wait before retrying
        await Future.delayed(const Duration(seconds: 2));
      }
    }
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