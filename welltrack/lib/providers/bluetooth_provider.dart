import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothProvider with ChangeNotifier {
  // Private state variables
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  bool _isBluetoothOn = false;
  bool _isBluetoothSupported = false;
  bool _isLoading = false;
  String? _error;
  String _statusMessage = 'Initializing...';
  
  // Stream subscriptions
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  StreamSubscription<List<ScanResult>>? _scanResultsSubscription;
  StreamSubscription<bool>? _scanningStateSubscription;

  // Getters
  List<ScanResult> get scanResults => _scanResults;
  bool get isScanning => _isScanning;
  bool get isBluetoothOn => _isBluetoothOn;
  bool get isBluetoothSupported => _isBluetoothSupported;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get statusMessage => _statusMessage;
  bool get canScan => _isBluetoothSupported && _isBluetoothOn && !_isLoading;

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

      // Request permissions
      await _requestPermissions();

      // Set up listeners
      _setupBluetoothListeners();

      _setStatusMessage('Bluetooth initialized successfully');
    } catch (e) {
      _setError('Failed to initialize Bluetooth: $e');
      _setStatusMessage('Bluetooth initialization failed');
    } finally {
      _setLoading(false);
    }
  }

  // Request necessary permissions
  Future<void> _requestPermissions() async {
    // Always request permissions on Android, regardless of context
    try {
      final Map<Permission, PermissionStatus> permissions = await [
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
        Permission.location,
      ].request();

      // Check if any critical permissions were denied
      final deniedPermissions = permissions.entries
          .where((entry) => entry.value.isDenied)
          .map((entry) => entry.key.toString())
          .toList();

      if (deniedPermissions.isNotEmpty) {
        _setError('Required permissions denied: ${deniedPermissions.join(', ')}');
      }
    } catch (e) {
      _setError('Failed to request permissions: $e');
    }
  }

  // Set up Bluetooth state listeners
  void _setupBluetoothListeners() {
    // Listen to Bluetooth adapter state
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen(
      (BluetoothAdapterState state) {
        _isBluetoothOn = state == BluetoothAdapterState.on;
        
        if (!_isBluetoothOn) {
          _setStatusMessage('Please turn on Bluetooth');
          _clearScanResults();
        } else {
          _setStatusMessage('Ready to scan for nearby users');
        }
        
        notifyListeners();
      },
    );

    // Listen to scan results
    _scanResultsSubscription = FlutterBluePlus.scanResults.listen(
      (List<ScanResult> results) {
        _scanResults = results;
        notifyListeners();
      },
    );

    // Listen to scanning state
    _scanningStateSubscription = FlutterBluePlus.isScanning.listen(
      (bool scanning) {
        _isScanning = scanning;
        
        if (!scanning && _scanResults.isEmpty) {
          _setStatusMessage('No nearby users found');
        } else if (!scanning && _scanResults.isNotEmpty) {
          _setStatusMessage('Found ${_scanResults.length} nearby devices');
        }
        
        notifyListeners();
      },
    );
  }

  // Start scanning for nearby devices
  Future<void> startScan({Duration? timeout}) async {
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
    notifyListeners();
  }

  // Refresh - restart scanning
  Future<void> refresh() async {
    if (_isScanning) {
      await stopScan();
    }
    await startScan();
  }

  @override
  void dispose() {
    // Cancel all subscriptions
    _adapterStateSubscription?.cancel();
    _scanResultsSubscription?.cancel();
    _scanningStateSubscription?.cancel();
    
    // Stop scanning if in progress
    FlutterBluePlus.stopScan();
    
    super.dispose();
  }
} 