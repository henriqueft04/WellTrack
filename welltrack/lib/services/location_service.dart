import 'package:geolocator/geolocator.dart';
import 'package:welltrack/main.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Position? _currentPosition;
  bool _isLocationEnabled = false;
  int? _currentUserId;

  Position? get currentPosition => _currentPosition;
  bool get isLocationEnabled => _isLocationEnabled;

  // Initialize location services
  Future<bool> initialize() async {
    try {
      // Get current user ID from your users table
      await _getCurrentUserId();
      
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      _isLocationEnabled = true;
      await getCurrentLocation();
      return true;
    } catch (e) {
      print('Error initializing location service: $e');
      return false;
    }
  }

  // Get current user ID from your users table
  Future<void> _getCurrentUserId() async {
    try {
      final user = supabase.auth.currentUser;
      if (user?.email != null) {
        // Query your users table to get the user ID by email
        final response = await supabase
            .from('users')
            .select('id')
            .eq('email', user!.email!)
            .maybeSingle();
        
        if (response != null) {
          _currentUserId = response['id'];
        }
      }
    } catch (e) {
      print('Error getting current user ID: $e');
    }
  }

  // Get current location
  Future<Position?> getCurrentLocation() async {
    if (!_isLocationEnabled) {
      await initialize();
    }

    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return _currentPosition;
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  // Start location updates
  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    );
  }

  // Calculate distance between two positions
  double calculateDistance(Position pos1, Position pos2) {
    return Geolocator.distanceBetween(
      pos1.latitude,
      pos1.longitude,
      pos2.latitude,
      pos2.longitude,
    );
  }

  // Update user location in Supabase
  Future<void> updateUserLocation(Position position) async {
    try {
      if (_currentUserId != null) {
        // First try to update existing location
        final response = await supabase.from('user_locations').update({
          'latitude': position.latitude,
          'longitude': position.longitude,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('user_id', _currentUserId!);

        // If no rows were updated, insert a new location
        if (response == null || response.isEmpty) {
          await supabase.from('user_locations').insert({
            'user_id': _currentUserId,
            'latitude': position.latitude,
            'longitude': position.longitude,
            'updated_at': DateTime.now().toIso8601String(),
          });
        }
      }
    } catch (e) {
      // If it's a unique constraint error, try update instead
      if (e.toString().contains('unique constraint') || e.toString().contains('23505')) {
        try {
          await supabase.from('user_locations').update({
            'latitude': position.latitude,
            'longitude': position.longitude,
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('user_id', _currentUserId!);
        } catch (updateError) {
          print('Error updating user location: $updateError');
        }
      } else {
        print('Error updating user location: $e');
      }
    }
  }

  // Get nearby users from Supabase using the stored function
  Future<List<Map<String, dynamic>>> getNearbyUsers(double radiusInMeters) async {
    try {
      if (_currentPosition == null) {
        await getCurrentLocation();
      }

      if (_currentPosition == null || _currentUserId == null) {
        print('LocationService: Cannot get nearby users - position: $_currentPosition, userId: $_currentUserId');
        return [];
      }

      print('LocationService: Getting nearby users for user $_currentUserId at ${_currentPosition!.latitude}, ${_currentPosition!.longitude} within ${radiusInMeters}m');

      // Use the stored function for efficient nearby user queries
      final response = await supabase.rpc('get_nearby_users', params: {
        'current_user_id': _currentUserId!,
        'user_lat': _currentPosition!.latitude,
        'user_lng': _currentPosition!.longitude,
        'radius_meters': radiusInMeters,
      });

      final nearbyUsers = List<Map<String, dynamic>>.from(response ?? []);
      print('LocationService: Found ${nearbyUsers.length} nearby users from RPC');
      
      // Log each user found
      for (var user in nearbyUsers) {
        print('LocationService: User ${user['user_id']} (${user['name']}) at distance ${user['distance_meters']}m');
      }

      return nearbyUsers;
    } catch (e) {
      print('LocationService: Error getting nearby users via RPC: $e');
      
      // Fallback to manual query if stored function fails
      return await _getNearbyUsersManual(radiusInMeters);
    }
  }

  // Fallback manual method for getting nearby users
  Future<List<Map<String, dynamic>>> _getNearbyUsersManual(double radiusInMeters) async {
    try {
      if (_currentPosition == null || _currentUserId == null) {
        print('LocationService: Cannot get nearby users manually - position: $_currentPosition, userId: $_currentUserId');
        return [];
      }

      print('LocationService: Falling back to manual query for nearby users');

      // Get all user locations except current user
      final response = await supabase
          .from('user_locations')
          .select('''
            *,
            users!inner(
              id,
              name,
              email,
              avatar,
              mental_state,
              privacy_visible
            )
          ''')
          .neq('user_id', _currentUserId!)
          .eq('privacy_location', true);

      print('LocationService: Manual query returned ${response.length} user locations');

      List<Map<String, dynamic>> nearbyUsers = [];

      for (var userLocation in response) {
        // Check if user allows visibility
        if (userLocation['users']['privacy_visible'] != true && userLocation['users']['privacy_visible'] != null) {
          print('LocationService: Skipping user ${userLocation['user_id']} - privacy_visible is false');
          continue;
        }

        double distance = calculateDistance(
          _currentPosition!,
          Position(
            latitude: userLocation['latitude'],
            longitude: userLocation['longitude'],
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            altitudeAccuracy: 0,
            headingAccuracy: 0,
          ),
        );

        print('LocationService: User ${userLocation['user_id']} is ${distance}m away (radius: ${radiusInMeters}m)');

        if (distance <= radiusInMeters) {
          // Flatten the structure to match the stored function output
          final user = userLocation['users'];
          nearbyUsers.add({
            'user_id': user['id'],
            'name': user['name'],
            'email': user['email'],
            'avatar': user['avatar'],
            'mental_state': user['mental_state'],
            'latitude': userLocation['latitude'],
            'longitude': userLocation['longitude'],
            'distance_meters': distance,
            'updated_at': userLocation['updated_at'],
          });
        }
      }

      // Sort by distance
      nearbyUsers.sort((a, b) => a['distance_meters'].compareTo(b['distance_meters']));
      
      print('LocationService: Found ${nearbyUsers.length} nearby users within radius');
      return nearbyUsers;
    } catch (e) {
      print('LocationService: Error in manual nearby users query: $e');
      return [];
    }
  }

  // Check if two users are in proximity
  bool areUsersInProximity(Position pos1, Position pos2, double thresholdMeters) {
    double distance = calculateDistance(pos1, pos2);
    return distance <= thresholdMeters;
  }

  // Update user privacy settings
  Future<void> updateLocationPrivacy(bool allowLocationSharing) async {
    try {
      final userId = _currentUserId;
      if (userId != null) {
        // Try to update existing record first
        final response = await supabase.from('user_locations').update({
          'privacy_location': allowLocationSharing,
        }).eq('user_id', userId);

        // If no existing record, create one
        if (response == null || response.isEmpty) {
          await supabase.from('user_locations').insert({
            'user_id': userId,
            'privacy_location': allowLocationSharing,
            'latitude': 0.0, // Placeholder until location is available
            'longitude': 0.0, // Placeholder until location is available
          });
        }
      }
    } catch (e) {
      print('Error updating location privacy: $e');
    }
  }

  // Update user visibility settings
  Future<void> updateUserVisibility(bool isVisible) async {
    try {
      final userId = _currentUserId;
      if (userId != null) {
        await supabase.from('users').update({
          'privacy_visible': isVisible,
        }).eq('id', userId);
      }
    } catch (e) {
      print('Error updating user visibility: $e');
    }
  }
} 