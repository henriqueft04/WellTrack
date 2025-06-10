import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:welltrack/notifications/noti_service.dart';
import 'package:welltrack/pages/login_page.dart';
import 'package:welltrack/providers/stats_provider.dart';
import 'package:welltrack/providers/user_provider.dart';
import 'package:welltrack/providers/proximity_provider.dart';
import 'package:welltrack/core/injection.dart';
import 'package:welltrack/services/navigation_service.dart';
import 'package:welltrack/viewmodels/mental_state_view_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // init notifications
  NotiService().initNotification();

  // Initialize dependency injection
  configureDependencies();

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
        ChangeNotifierProvider(create: (_) => UserStatsProvider()),
      ],
      child: MaterialApp(
        title: 'WellTrack',
        debugShowCheckedModeBanner: false,
        navigatorKey: locate<NavigationService>().navigatorKey, // DI for navigation
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const LoginPage(),
      ),
    );
  }
}
