import 'package:flutter/material.dart';
import 'package:welltrack/pages/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

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
    return MaterialApp(
      title: 'WellTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
