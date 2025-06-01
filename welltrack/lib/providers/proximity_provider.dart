import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:welltrack/services/location_service.dart';

class ProximityProvider with ChangeNotifier {
  final LocationService _locationService = LocationService();
  
  List<Map<String, dynamic>> _nearbyUsers = [];
  Position? _currentPosition;
  bool _isLocationEnabled = false;
  bool _isLoading = false;
  String? _error;
  double _proximityRadius = 1000.0; // 1km default
  Timer? _locationUpdateTimer;

  // Getters
  List<Map<String, dynamic>> get nearbyUsers => _nearbyUsers;
  Position? get currentPosition => _currentPosition;
  bool get isLocationEnabled => _isLocationEnabled;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get proximityRadius => _proximityRadius;

  // Initialize proximity services
  Future<void> initialize() async {
    _setLoading(true);
    _setError(null);

    try {
      _isLocationEnabled = await _locationService.initialize();
      if (_isLocationEnabled) {
        _currentPosition = await _locationService.getCurrentLocation();
        await _updateNearbyUsers();
        _startLocationTracking();
      } else {
        _setError('Location services not available');
      }
    } catch (e) {
      _setError('Failed to initialize location services: $e');
    }

    _setLoading(false);
  }

  // Start continuous location tracking
  void _startLocationTracking() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _updateLocationAndNearbyUsers();
    });

    // Also listen to real-time location changes
    _locationService.getLocationStream().listen(
      (Position position) {
        _currentPosition = position;
        _locationService.updateUserLocation(position);
        notifyListeners();
      },
      onError: (error) {
        _setError('Location tracking error: $error');
      },
    );
  }

  // Update location and nearby users
  Future<void> _updateLocationAndNearbyUsers() async {
    try {
      _currentPosition = await _locationService.getCurrentLocation();
      if (_currentPosition != null) {
        await _locationService.updateUserLocation(_currentPosition!);
        await _updateNearbyUsers();
      }
    } catch (e) {
      _setError('Failed to update location: $e');
    }
  }

  // Update nearby users list
  Future<void> _updateNearbyUsers() async {
    try {
      _nearbyUsers = await _locationService.getNearbyUsers(_proximityRadius);
      notifyListeners();
    } catch (e) {
      _setError('Failed to get nearby users: $e');
    }
  }

  // Set proximity radius
  void setProximityRadius(double radius) {
    _proximityRadius = radius;
    _updateNearbyUsers();
    notifyListeners();
  }

  // Refresh nearby users manually
  Future<void> refreshNearbyUsers() async {
    _setLoading(true);
    await _updateNearbyUsers();
    _setLoading(false);
  }

  // Get distance to a specific user
  double? getDistanceToUser(int userId) {
    try {
      final user = _nearbyUsers.firstWhere((user) => user['user_id'] == userId);
      return user['distance_meters']?.toDouble();
    } catch (e) {
      return null;
    }
  }

  // Check if a specific user is in proximity
  bool isUserInProximity(int userId) {
    return _nearbyUsers.any((user) => user['user_id'] == userId);
  }

  // Format distance for display
  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()}m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)}km';
    }
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

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    super.dispose();
  }
} 