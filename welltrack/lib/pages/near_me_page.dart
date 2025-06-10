import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:welltrack/providers/bluetooth_provider.dart';
import 'package:welltrack/models/action_card.dart';
import 'package:welltrack/models/bluetooth_user.dart';

class NearMePage extends StatefulWidget {
  const NearMePage({super.key});

  @override
  State<NearMePage> createState() => _NearMePageState();
}

class _NearMePageState extends State<NearMePage> {
  @override
  void initState() {
    super.initState();
    // Initialize Bluetooth when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BluetoothProvider>().initialize();
    });
  }

  void _showBluetoothStatusDetails(BluetoothProvider bluetoothProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bluetooth Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Supported: ${bluetoothProvider.isBluetoothSupported ? "Yes" : "No"}'),
              const SizedBox(height: 8),
              Text('Enabled: ${bluetoothProvider.isBluetoothOn ? "Yes" : "No"}'),
              const SizedBox(height: 8),
              Text('Currently Scanning: ${bluetoothProvider.isScanning ? "Yes" : "No"}'),
              const SizedBox(height: 8),
              Text('Mood Sharing: ${bluetoothProvider.isMoodSharingEnabled ? "Enabled" : "Disabled"}'),
              const SizedBox(height: 8),
              Text('Advertising: ${bluetoothProvider.isAdvertising ? "Active" : "Inactive"}'),
              const SizedBox(height: 8),
              Text('Vibration Alerts: ${bluetoothProvider.isVibrationSupported ? (bluetoothProvider.isVibrationEnabled ? "Enabled" : "Disabled") : "Not Supported"}'),
              const SizedBox(height: 8),
              Text('Nearby WellTrack Users: ${bluetoothProvider.nearbyUsers.length}'),
              if (bluetoothProvider.error != null) ...[
                const SizedBox(height: 8),
                Text('Error: ${bluetoothProvider.error}', style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showBluetoothDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enable Bluetooth'),
          content: const Text(
            'Bluetooth is required to discover nearby WellTrack users. '
            'Please enable Bluetooth in your device settings and try again.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserCard(BluetoothUser user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        // Add mood color border
        border: Border.all(
          color: user.moodColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar with mood color background
            Stack(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: user.moodColor.withOpacity(0.2),
                  child: user.avatarUrl != null 
                      ? ClipOval(
                          child: Image.network(
                            user.avatarUrl!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => 
                                Icon(Icons.person, size: 30, color: user.moodColor),
                          ),
                        )
                      : Icon(Icons.person, size: 30, color: user.moodColor),
                ),
                // Mood indicator dot
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: user.moodColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        user.moodEmoji,
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            
            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.username,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: user.moodColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: user.moodColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          user.moodEmoji,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          user.moodDescription,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: user.moodColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        user.estimatedDistance,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        user.lastSeenText,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Signal strength
            Column(
              children: [
                Icon(
                  _getSignalStrengthIcon(user.signalStrength),
                  color: _getSignalStrengthColor(user.signalStrength),
                  size: 20,
                ),
                Text(
                  '${user.signalStrength}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getSignalStrengthIcon(int rssi) {
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

  Color _getSignalStrengthColor(int rssi) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Near Me',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<BluetoothProvider>(
        builder: (context, bluetoothProvider, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Mood Sharing Toggle
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: SwitchListTile(
                      title: const Text(
                        'Share My Mood',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        bluetoothProvider.isMoodSharingEnabled
                            ? 'Other WellTrack users can see your mood'
                            : 'Your mood is private',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      value: bluetoothProvider.isMoodSharingEnabled,
                      onChanged: (value) {
                        bluetoothProvider.toggleMoodSharing(value);
                      },
                      activeColor: Colors.blue,
                    ),
                  ),
                ),

                // Vibration Alerts Toggle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.purple.shade200),
                    ),
                    child: SwitchListTile(
                      title: Row(
                        children: [
                          const Text(
                            'Vibration Alerts',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 8),
                          if (!bluetoothProvider.isVibrationSupported)
                            Icon(
                              Icons.not_interested,
                              color: Colors.grey.shade500,
                              size: 16,
                            ),
                        ],
                      ),
                      subtitle: Text(
                        bluetoothProvider.isVibrationSupported
                            ? (bluetoothProvider.isVibrationEnabled
                                ? 'Get vibration alerts when someone nearby needs support'
                                : 'Vibration alerts are disabled')
                            : 'Vibration not supported on this device',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      value: bluetoothProvider.isVibrationEnabled && bluetoothProvider.isVibrationSupported,
                      onChanged: bluetoothProvider.isVibrationSupported
                          ? (value) {
                              bluetoothProvider.toggleVibrationAlerts(value);
                            }
                          : null,
                      activeColor: Colors.purple,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Simulation Mode Toggle (for testing)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: SwitchListTile(
                      title: const Text(
                        'Demo Mode',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        bluetoothProvider.simulationMode
                            ? 'Showing mock nearby users for testing'
                            : 'Real Bluetooth scanning (may not find users due to technical limitations)',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      value: bluetoothProvider.simulationMode,
                      onChanged: (value) {
                        bluetoothProvider.toggleSimulationMode(value);
                      },
                      activeColor: Colors.orange,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Register Bluetooth ID Button (only show if not registered)
                if (!bluetoothProvider.isDeviceRegistered)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: StyledActionButton(
                      icon: Icons.bluetooth_connected,
                      label: 'Register My Device for Discovery',
                      color: Colors.purple.shade700,
                      background: Colors.purple.shade50,
                      onTap: () async {
                        await bluetoothProvider.storeBluetoothDeviceId();
                      },
                    ),
                  ),

                // Registration Status (show if registered)
                if (bluetoothProvider.isDeviceRegistered)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green.shade700,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Device Registered!',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                                Text(
                                  'Other WellTrack users can now discover you when you\'re nearby',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Status Section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: StyledActionButton(
                    icon: bluetoothProvider.isBluetoothOn 
                        ? Icons.bluetooth 
                        : Icons.bluetooth_disabled,
                    label: bluetoothProvider.statusMessage,
                    color: bluetoothProvider.isBluetoothOn 
                        ? Colors.blue.shade700 
                        : Colors.red.shade700,
                    background: bluetoothProvider.isBluetoothOn 
                        ? Colors.blue.shade50 
                        : Colors.red.shade50,
                    onTap: () => _showBluetoothStatusDetails(bluetoothProvider),
                  ),
                ),

                // Scan Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: bluetoothProvider.isLoading
                      ? Container(
                          width: double.infinity,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade300, width: 2),
                          ),
                          child: const Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(width: 12),
                                Text('Initializing Bluetooth...'),
                              ],
                            ),
                          ),
                        )
                      : StyledActionButton(
                          icon: bluetoothProvider.isScanning 
                              ? Icons.stop 
                              : Icons.search,
                          label: bluetoothProvider.isScanning 
                              ? 'Stop Scanning' 
                              : 'Scan for Nearby Users',
                          color: bluetoothProvider.canScan 
                              ? Colors.green.shade700 
                              : Colors.grey.shade500,
                          background: bluetoothProvider.canScan 
                              ? Colors.green.shade50 
                              : Colors.grey.shade100,
                          onTap: bluetoothProvider.canScan
                              ? () {
                                  if (bluetoothProvider.isScanning) {
                                    bluetoothProvider.stopScan();
                                  } else {
                                    bluetoothProvider.startScan();
                                  }
                                }
                              : () {
                                  if (!bluetoothProvider.isBluetoothOn) {
                                    _showBluetoothDialog();
                                  }
                                },
                        ),
                ),

                const SizedBox(height: 20),

                // Nearby Users List
                if (bluetoothProvider.nearbyUsers.isEmpty)
                  SizedBox(
                    height: 300,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bluetooth_searching,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              bluetoothProvider.isScanning
                                  ? 'Scanning for nearby users...'
                                  : 'No nearby WellTrack users found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          if (!bluetoothProvider.isScanning && bluetoothProvider.canScan) ...[
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                'Tap "Scan for Nearby Users" to search',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          'Nearby WellTrack Users (${bluetoothProvider.nearbyUsers.length})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: bluetoothProvider.nearbyUsers.length,
                        itemBuilder: (context, index) {
                          final user = bluetoothProvider.nearbyUsers[index];
                          return _buildUserCard(user);
                        },
                      ),
                    ],
                  ),

                // Error Display
                if (bluetoothProvider.error != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            bluetoothProvider.error!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Bottom padding for scrolling
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }
} 