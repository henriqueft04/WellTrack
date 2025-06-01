import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:welltrack/components/app_layout.dart';
import 'package:welltrack/providers/proximity_provider.dart';
import 'package:welltrack/providers/user_provider.dart';
import 'package:welltrack/utils/mood_utils.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:welltrack/pages/debug_proximity.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};

  @override
  void initState() {
    super.initState();
    // Initialize proximity services when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProximityProvider>().initialize();
      // Load user profile to get current user's mental state
      if (!context.read<UserProvider>().hasUser) {
        context.read<UserProvider>().loadUserProfile();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listen to provider changes and update markers
    final provider = context.watch<ProximityProvider>();
    final userProvider = context.watch<UserProvider>();
    if (provider.isLocationEnabled && provider.currentPosition != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateMapMarkers(provider, userProvider);
      });
    }
  }

  // Create custom marker with mood icon
  Future<BitmapDescriptor> _createMoodMarker(String? mentalState) async {
    final icon = MoodUtils.getMoodIconFromState(mentalState);
    final color = MoodUtils.getMoodColorFromState(mentalState);

    // Create a custom marker using the mood icon
    return BitmapDescriptor.bytes(
      await _createMarkerImageFromIcon(icon, color),
    );
  }

  // Helper method to create marker image from icon
  Future<Uint8List> _createMarkerImageFromIcon(IconData iconData, Color color) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    // Create a circular background
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const size = 25.0;
    const radius = size / 2;
    
    // Draw white circle background
    canvas.drawCircle(const Offset(radius, radius), radius - 1, paint);
    
    // Draw colored border
    canvas.drawCircle(const Offset(radius, radius), radius - 1, borderPaint);
    
    // Draw the icon
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        fontSize: 20,
        fontFamily: iconData.fontFamily,
        color: color,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size - textPainter.width) / 2,
        (size - textPainter.height) / 2,
      ),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    return byteData!.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      pageTitle: "Proximity Map",
      showLogo: true,
      isMainPage: true,
      content: Consumer2<ProximityProvider, UserProvider>(
        builder: (context, proximityProvider, userProvider, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Debug Button Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DebugProximityPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.bug_report, size: 18),
                        label: const Text('Debug'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Google Maps Section
                _buildMapSection(proximityProvider, userProvider),
                
                // Existing Components
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Card
                      _buildStatusCard(proximityProvider),
                      const SizedBox(height: 16),
                      
                      // Proximity Radius Control
                      _buildRadiusControl(proximityProvider),
                      const SizedBox(height: 16),
                      
                      // Nearby Users Section
                      _buildNearbyUsersSection(proximityProvider),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMapSection(ProximityProvider provider, UserProvider userProvider) {
    if (!provider.isLocationEnabled || provider.currentPosition == null) {
      return Container(
        height: 300,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Location services not available',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              if (provider.error != null) ...[
                const SizedBox(height: 8),
                Text(
                  provider.error!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      );
    }

    // Update markers after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateMapMarkers(provider, userProvider);
    });

    return Container(
      height: 300,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(
              provider.currentPosition!.latitude,
              provider.currentPosition!.longitude,
            ),
            zoom: 15,
          ),
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
            // Update markers once map is created
            _updateMapMarkers(provider, userProvider);
          },
          markers: _markers,
          circles: _circles,
          myLocationEnabled: false,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: true,
          zoomGesturesEnabled: true,
          scrollGesturesEnabled: true,
          rotateGesturesEnabled: true,
          tiltGesturesEnabled: true,
          compassEnabled: true,
          mapToolbarEnabled: false,
        ),
      ),
    );
  }

  void _updateMapMarkers(ProximityProvider provider, UserProvider userProvider) async {
    final currentPos = provider.currentPosition;
    if (currentPos == null) return;

    Set<Marker> newMarkers = {};
    Set<Circle> newCircles = {};

    // Add proximity radius circle
    newCircles.add(
      Circle(
        circleId: const CircleId('proximity_radius'),
        center: LatLng(currentPos.latitude, currentPos.longitude),
        radius: provider.proximityRadius,
        fillColor: Colors.blue.withValues(alpha: 0.1),
        strokeColor: Colors.blue.withValues(alpha: 0.5),
        strokeWidth: 2,
      ),
    );

    // Add marker for current user's location
    final currentUserMentalState = userProvider.userProfile?['mental_state'];
    final currentUserMarker = await _createMoodMarker(currentUserMentalState);
    
    newMarkers.add(
      Marker(
        markerId: const MarkerId('current_user'),
        position: LatLng(currentPos.latitude, currentPos.longitude),
        icon: currentUserMarker,
        infoWindow: InfoWindow(
          title: 'You (${userProvider.userProfile?['name'] ?? 'Me'})',
          snippet: 'Current mood: ${MoodUtils.getMoodDisplayName(currentUserMentalState)}',
        ),
      ),
    );

    // Add markers for nearby users with mood icons
    for (int i = 0; i < provider.nearbyUsers.length; i++) {
      final user = provider.nearbyUsers[i];
      final distance = user['distance_meters']?.toDouble() ?? 0.0;
      
      // Create custom mood marker
      final markerIcon = await _createMoodMarker(user['mental_state']);
      
      newMarkers.add(
        Marker(
          markerId: MarkerId('user_${user['user_id']}'),
          position: LatLng(
            user['latitude'],
            user['longitude'],
          ),
          icon: markerIcon,
          infoWindow: InfoWindow(
            title: user['name'] ?? 'Unknown User',
            snippet: 'Distance: ${provider.formatDistance(distance)}\n'
                    'Mood: ${MoodUtils.getMoodDisplayName(user['mental_state'])}',
          ),
          onTap: () => _showUserDetails(context, user, provider),
        ),
      );
    }

    // Only update if markers or circles actually changed
    if (!_markersEqual(newMarkers, _markers) || !_circlesEqual(newCircles, _circles)) {
      if (mounted) {
        setState(() {
          _markers = newMarkers;
          _circles = newCircles;
        });
      }
    }
  }

  // Helper method to compare marker sets
  bool _markersEqual(Set<Marker> set1, Set<Marker> set2) {
    if (set1.length != set2.length) return false;
    for (final marker in set1) {
      if (!set2.any((m) => m.markerId == marker.markerId)) return false;
    }
    return true;
  }

  // Helper method to compare circle sets
  bool _circlesEqual(Set<Circle> set1, Set<Circle> set2) {
    if (set1.length != set2.length) return false;
    for (final circle in set1) {
      final matching = set2.where((c) => c.circleId == circle.circleId).firstOrNull;
      if (matching == null || matching.radius != circle.radius) return false;
    }
    return true;
  }

  // Move camera to show all markers
  void _fitMarkersInView(ProximityProvider provider) {
    if (_mapController == null || provider.nearbyUsers.isEmpty || provider.currentPosition == null) {
      return;
    }

    List<LatLng> points = [
      LatLng(provider.currentPosition!.latitude, provider.currentPosition!.longitude),
    ];

    for (var user in provider.nearbyUsers) {
      points.add(LatLng(user['latitude'], user['longitude']));
    }

    if (points.length == 1) {
      // Only current user, just center on them
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(points.first, 15),
      );
      return;
    }

    // Calculate bounds
    double minLat = points.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    double maxLat = points.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    double minLng = points.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    double maxLng = points.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100.0, // padding
      ),
    );
  }

  Widget _buildStatusCard(ProximityProvider provider) {
    return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              children: [
                Icon(
                  provider.isLocationEnabled ? Icons.location_on : Icons.location_off,
                  color: provider.isLocationEnabled ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  'Location Status',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              provider.isLocationEnabled 
                ? 'Location services enabled' 
                : 'Location services disabled',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (provider.error != null) ...[
              const SizedBox(height: 8),
              Text(
                provider.error!,
                style: TextStyle(color: Colors.red),
              ),
            ],
            if (provider.currentPosition != null) ...[
              const SizedBox(height: 8),
              Text(
                'Lat: ${provider.currentPosition!.latitude.toStringAsFixed(6)}\n'
                'Lng: ${provider.currentPosition!.longitude.toStringAsFixed(6)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRadiusControl(ProximityProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Proximity Radius',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ElevatedButton.icon(
                  onPressed: () => _fitMarkersInView(provider),
                  icon: const Icon(Icons.center_focus_strong, size: 18),
                  label: const Text('Center Map'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Slider(
              value: provider.proximityRadius,
              min: 100.0,
              max: 5000.0,
              divisions: 49,
              label: provider.formatDistance(provider.proximityRadius),
              onChanged: (value) {
                provider.setProximityRadius(value);
              },
            ),
            Text(
              'Current radius: ${provider.formatDistance(provider.proximityRadius)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyUsersSection(ProximityProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nearby Users (${provider.nearbyUsers.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: provider.isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                  onPressed: provider.isLoading 
                    ? null 
                    : () async {
                        await provider.refreshNearbyUsers();
                        // Center map after refresh
                        _fitMarkersInView(provider);
                      },
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (provider.nearbyUsers.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No users found nearby',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try increasing the proximity radius or check back later',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.nearbyUsers.length,
                itemBuilder: (context, index) {
                  final user = provider.nearbyUsers[index];
                  return _buildUserTile(user, provider);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTile(Map<String, dynamic> user, ProximityProvider provider) {
    final distance = user['distance_meters']?.toDouble() ?? 0.0;
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue[100],
        child: Text(
          user['name']?.substring(0, 1).toUpperCase() ?? 'U',
          style: TextStyle(
            color: Colors.blue[800],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        user['name'] ?? 'Unknown User',
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Distance: ${provider.formatDistance(distance)}'),
          Text(
            'Last seen: ${_formatLastSeen(user['updated_at'])}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          if (user['mental_state'] != null)
            Text(
              'Mood: ${MoodUtils.getMoodDisplayName(user['mental_state'])}',
              style: TextStyle(
                fontSize: 12,
                color: MoodUtils.getMoodColorFromState(user['mental_state']),
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on,
            color: _getDistanceColor(distance),
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(
            _getProximityStatus(distance),
            style: TextStyle(
              color: _getDistanceColor(distance),
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
      onTap: () {
        // Could navigate to user profile or chat
        _showUserDetails(context, user, provider);
      },
    );
  }

  String _formatLastSeen(String? updatedAt) {
    if (updatedAt == null) return 'Unknown';
    
    try {
      final DateTime lastSeen = DateTime.parse(updatedAt);
      final Duration diff = DateTime.now().difference(lastSeen);
      
      if (diff.inMinutes < 1) {
        return 'Just now';
      } else if (diff.inMinutes < 60) {
        return '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        return '${diff.inHours}h ago';
      } else {
        return '${diff.inDays}d ago';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  Color _getDistanceColor(double distance) {
    if (distance < 100) return Colors.green;
    if (distance < 500) return Colors.orange;
    return Colors.red;
  }

  String _getProximityStatus(double distance) {
    if (distance < 100) return 'Very Close';
    if (distance < 500) return 'Close';
    return 'Nearby';
  }

  void _showUserDetails(BuildContext context, Map<String, dynamic> user, ProximityProvider provider) {
    final distance = user['distance_meters']?.toDouble() ?? 0.0;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(user['name'] ?? 'Unknown User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Distance: ${provider.formatDistance(distance)}'),
              const SizedBox(height: 8),
              Text('Status: ${_getProximityStatus(distance)}'),
              const SizedBox(height: 8),
              Text('Last seen: ${_formatLastSeen(user['updated_at'])}'),
              if (user['mental_state'] != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Current mood: ${MoodUtils.getMoodDisplayName(user['mental_state'])}',
                  style: TextStyle(
                    color: MoodUtils.getMoodColorFromState(user['mental_state']),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Could implement connect/message functionality here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Connect feature coming soon!')),
                );
              },
              child: const Text('Connect'),
            ),
          ],
        );
      },
    );
  }
}
