import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:welltrack/pages/login_page.dart';
import 'package:welltrack/providers/user_provider.dart';
import 'package:welltrack/providers/proximity_provider.dart';
import 'package:welltrack/providers/bluetooth_provider.dart';
import 'package:welltrack/services/settings_service.dart';
import 'package:welltrack/core/injection.dart';
import 'package:welltrack/services/navigation_service.dart';
import 'package:welltrack/viewmodels/mental_state_view_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  configureDependencies();

  // Initialize settings service
  await SettingsService.initialize();

  await Supabase.initialize(
    url: 'https://kaekvbykswfrevmsaslt.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImthZWt2Ynlrc3dmcmV2bXNhc2x0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg2NTEwNDQsImV4cCI6MjA2NDIyNzA0NH0.PKtjHuwsDWBtTtDpL-aI--pjp5E_T2ZEpvtWqTCWjoc',
  );
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MentalStateViewModel()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => ProximityProvider()),
        ChangeNotifierProxyProvider<UserProvider, BluetoothProvider>(
          create: (context) => BluetoothProvider(),
          update: (context, userProvider, bluetoothProvider) {
            bluetoothProvider?.setUserProvider(userProvider);
            return bluetoothProvider!;
          },
        ),
      ],
      child: MaterialApp(
        title: 'WellTrack',
        debugShowCheckedModeBanner: false,
        navigatorKey: locate<NavigationService>().navigatorKey,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const LoginPage(),
      ),
    );
  }
}
