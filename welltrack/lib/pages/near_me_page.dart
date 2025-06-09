import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:welltrack/providers/bluetooth_provider.dart';
import 'package:welltrack/models/action_card.dart';

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
              Text('Devices Found: ${bluetoothProvider.scanResults.length}'),
              if (bluetoothProvider.error != null) ...[
                const SizedBox(height: 8),
                Text('Error: ${bluetoothProvider.error}'),
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
          title: const Text('Bluetooth Required'),
          content: const Text('Please enable Bluetooth to discover nearby users.'),
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

  Widget _buildScanResultCard(ScanResult result, BluetoothProvider bluetoothProvider) {
    final deviceDetails = bluetoothProvider.getDeviceDetails(result);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(
            Icons.person,
            color: Colors.blue.shade700,
          ),
        ),
        title: Text(
          deviceDetails['name']!,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Signal: ${deviceDetails['rssi']}'),
            Text('ID: ${deviceDetails['shortId']}...'),
          ],
        ),
        trailing: Icon(
          bluetoothProvider.getSignalStrengthIcon(result.rssi),
          color: bluetoothProvider.getSignalStrengthColor(result.rssi),
        ),
        onTap: () => _showDeviceDetails(result, bluetoothProvider),
      ),
    );
  }

  void _showDeviceDetails(ScanResult result, BluetoothProvider bluetoothProvider) {
    final deviceDetails = bluetoothProvider.getDeviceDetails(result);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(deviceDetails['name']!),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Device ID: ${deviceDetails['id']}'),
              const SizedBox(height: 8),
              Text('Signal Strength: ${deviceDetails['rssi']}'),
              const SizedBox(height: 8),
              Text('Distance: ${deviceDetails['distance']}'),
              const SizedBox(height: 8),
              Text('Last Seen: Just now'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Near Me'),
        backgroundColor: const Color(0xFF9CD0FF),
        centerTitle: true,
      ),
      body: Consumer<BluetoothProvider>(
        builder: (context, bluetoothProvider, child) {
          return Column(
            children: [
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
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Initializing...',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : StyledActionButton(
                        icon: bluetoothProvider.isScanning ? Icons.stop : Icons.search,
                        label: bluetoothProvider.isScanning ? 'Stop Scanning' : 'Find Nearby Users',
                        color: bluetoothProvider.canScan
                            ? (bluetoothProvider.isScanning ? Colors.red : Colors.blue)
                            : Colors.grey,
                        background: bluetoothProvider.canScan
                            ? (bluetoothProvider.isScanning ? Colors.red.shade50 : Colors.blue.shade50)
                            : Colors.grey.shade100,
                        onTap: bluetoothProvider.canScan
                            ? (bluetoothProvider.isScanning 
                                ? bluetoothProvider.stopScan 
                                : bluetoothProvider.startScan)
                            : () => _showBluetoothDialog(),
                      ),
              ),

              const SizedBox(height: 16),

              // Results Section
              Expanded(
                child: bluetoothProvider.scanResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              bluetoothProvider.isScanning
                                  ? 'Searching for nearby users...'
                                  : 'No nearby users found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (!bluetoothProvider.isScanning) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Tap "Find Nearby Users" to start scanning',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: bluetoothProvider.refresh,
                        child: ListView.builder(
                          itemCount: bluetoothProvider.scanResults.length,
                          itemBuilder: (context, index) {
                            return _buildScanResultCard(
                              bluetoothProvider.scanResults[index], 
                              bluetoothProvider,
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
} 