import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:welltrack/main.dart';
import 'package:welltrack/providers/proximity_provider.dart';
import 'package:welltrack/providers/user_provider.dart';
import 'package:welltrack/services/location_service.dart';
import 'dart:math' as math;

class DebugProximityPage extends StatefulWidget {
  const DebugProximityPage({super.key});

  @override
  State<DebugProximityPage> createState() => _DebugProximityPageState();
}

class _DebugProximityPageState extends State<DebugProximityPage> {
  List<Map<String, dynamic>> _debugInfo = [];
  List<Map<String, dynamic>> _allUserLocations = [];
  bool _isLoading = false;
  String? _currentUserEmail;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadDebugInfo();
  }

  Future<void> _loadDebugInfo() async {
    setState(() {
      _isLoading = true;
      _debugInfo = [];
    });

    try {
      // Get current user info
      final user = supabase.auth.currentUser;
      _currentUserEmail = user?.email;

      if (_currentUserEmail != null) {
        // Get user ID from users table
        final userResponse = await supabase
            .from('users')
            .select('id, name')
            .eq('email', _currentUserEmail!)
            .maybeSingle();

        if (userResponse != null) {
          _currentUserId = userResponse['id'];
          _debugInfo.add({
            'label': 'Current User',
            'value': '${userResponse['name']} (ID: $_currentUserId, Email: $_currentUserEmail)',
          });
        }

        // Run debug function
        final debugResponse = await supabase
            .rpc('debug_proximity_info', params: {'user_email': _currentUserEmail});

        if (debugResponse != null) {
          for (var row in debugResponse) {
            _debugInfo.add({
              'label': row['info_type'],
              'value': row['info_value'],
            });
          }
        }
      } else {
        _debugInfo.add({
          'label': 'Error',
          'value': 'No authenticated user found',
        });
      }

      // Get all user locations directly
      final locationsResponse = await supabase
          .from('user_locations')
          .select('''
            *,
            users!inner(
              id,
              name,
              email,
              mental_state,
              privacy_visible
            )
          ''')
          .order('updated_at', ascending: false);

      _allUserLocations = List<Map<String, dynamic>>.from(locationsResponse);

      // Get proximity provider info
      if (mounted) {
        final proximityProvider = context.read<ProximityProvider>();
        final userProvider = context.read<UserProvider>();

        _debugInfo.add({
          'label': 'Proximity Provider Status',
          'value': 'Enabled: ${proximityProvider.isLocationEnabled}, '
              'Position: ${proximityProvider.currentPosition != null ? 'Available' : 'Not available'}, '
              'Radius: ${proximityProvider.proximityRadius}m',
        });

        _debugInfo.add({
          'label': 'Nearby Users Count',
          'value': '${proximityProvider.nearbyUsers.length}',
        });

        if (proximityProvider.currentPosition != null) {
          _debugInfo.add({
            'label': 'Current Position',
            'value': 'Lat: ${proximityProvider.currentPosition!.latitude.toStringAsFixed(6)}, '
                'Lng: ${proximityProvider.currentPosition!.longitude.toStringAsFixed(6)}',
          });
        }
      }

      // Test the get_nearby_users function directly
      if (_currentUserId != null && mounted) {
        final proximityProvider = context.read<ProximityProvider>();
        if (proximityProvider.currentPosition != null) {
          try {
            final nearbyUsersTest = await supabase.rpc('get_nearby_users', params: {
              'current_user_id': _currentUserId!,
              'user_lat': proximityProvider.currentPosition!.latitude,
              'user_lng': proximityProvider.currentPosition!.longitude,
              'radius_meters': proximityProvider.proximityRadius,
            });

            _debugInfo.add({
              'label': 'Direct RPC Test',
              'value': 'Found ${nearbyUsersTest.length} nearby users',
            });

            // Calculate distances to all users
            for (var location in _allUserLocations) {
              final distance = _calculateDistance(
                proximityProvider.currentPosition!.latitude,
                proximityProvider.currentPosition!.longitude,
                location['latitude'],
                location['longitude'],
              );

              location['calculated_distance'] = distance;
            }

            // Sort by distance
            _allUserLocations.sort((a, b) => 
              (a['calculated_distance'] ?? double.infinity)
                  .compareTo(b['calculated_distance'] ?? double.infinity));

          } catch (e) {
            _debugInfo.add({
              'label': 'RPC Error',
              'value': e.toString(),
            });
          }
        }
      }

    } catch (e) {
      _debugInfo.add({
        'label': 'Error',
        'value': e.toString(),
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // meters
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);
    
    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) * math.cos(_toRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Proximity'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadDebugInfo,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Debug Info Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Debug Information',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),
                          ..._debugInfo.map((info) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 200,
                                      child: Text(
                                        '${info['label']}:',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        info['value'],
                                        style: TextStyle(
                                          color: info['label'].contains('Error')
                                              ? Colors.red
                                              : null,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // All User Locations Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'All User Locations (${_allUserLocations.length})',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),
                          ..._allUserLocations.map((location) {
                            final user = location['users'];
                            final isCurrentUser = user['id'] == _currentUserId;
                            final distance = location['calculated_distance'];

                            return Card(
                              color: isCurrentUser ? Colors.blue[50] : null,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          '${user['name']} (ID: ${user['id']})',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isCurrentUser
                                                ? Colors.blue
                                                : null,
                                          ),
                                        ),
                                        if (isCurrentUser)
                                          const Chip(
                                            label: Text('YOU'),
                                            backgroundColor: Colors.blue,
                                            labelStyle:
                                                TextStyle(color: Colors.white),
                                          ),
                                      ],
                                    ),
                                    Text('Email: ${user['email']}'),
                                    Text(
                                        'Location: ${location['latitude']}, ${location['longitude']}'),
                                    Text(
                                        'Privacy: location=${location['privacy_location']}, visible=${user['privacy_visible']}'),
                                    Text(
                                        'Updated: ${_formatDateTime(location['updated_at'])}'),
                                    if (distance != null)
                                      Text(
                                        'Distance: ${distance.toStringAsFixed(0)}m',
                                        style: TextStyle(
                                          color: distance <= context
                                                  .read<ProximityProvider>()
                                                  .proximityRadius
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null) return 'Unknown';
    try {
      final dt = DateTime.parse(dateTime);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) {
        return '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        return '${diff.inHours}h ago';
      } else {
        return '${diff.inDays}d ago';
      }
    } catch (e) {
      return dateTime;
    }
  }
} 