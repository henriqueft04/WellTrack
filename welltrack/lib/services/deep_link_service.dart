import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:welltrack/main.dart';
import 'package:welltrack/pages/login_page.dart';
import 'package:welltrack/components/main_navigation.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  static const MethodChannel _channel = MethodChannel('app.channel.shared.data');
  StreamSubscription? _deepLinkSubscription;

  Future<void> initDeepLinks(BuildContext context) async {
    // Handle app already open case
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'initialLink' || call.method == 'onLink') {
        final link = call.arguments as String?;
        if (link != null) {
          _handleDeepLink(link, context);
        }
      }
    });

    // Check if app was opened with a deep link
    try {
      final initialLink = await _channel.invokeMethod<String>('initialLink');
      if (initialLink != null) {
        _handleDeepLink(initialLink, context);
      }
    } on PlatformException catch (e) {
      debugPrint('Failed to get initial deep link: ${e.message}');
    }
  }

  void _handleDeepLink(String link, BuildContext context) {
    debugPrint('Deep link received: $link');

    // Extract auth parameters if present
    if (link.contains('type=email_confirmation') || 
        link.contains('type=recovery') ||
        link.contains('type=signup')) {
      
      try {
        // Check if user is authenticated after deep link
        final user = supabase.auth.currentUser;
        
        if (user != null) {
          // User is authenticated - go to main app
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const MainNavigation(initialIndex: 0),
              ), 
              (route) => false
            );
            
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Email verified successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          });
        } else {
          // User not authenticated - go to login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const LoginPage(),
              ), 
              (route) => false
            );
            
            // Show verification message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Email verified! Please sign in.'),
                backgroundColor: Colors.green,
              ),
            );
          });
        }
      } catch (e) {
        debugPrint('Error handling deep link auth: $e');
      }
    }
  }

  void dispose() {
    _deepLinkSubscription?.cancel();
  }
} 