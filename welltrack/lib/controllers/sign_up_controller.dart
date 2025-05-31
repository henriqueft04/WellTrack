import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:welltrack/main.dart';
import 'package:welltrack/services/authenticators.dart';

class SignUpController {
  static final SignUpController _instance = SignUpController._internal();
  factory SignUpController() => _instance;
  SignUpController._internal();

  String? _email;
  String? _password;

  String? get email => _email;
  String? get password => _password;

  void setEmail(String email) {
    _email = email;
  }

  void setPassword(String password) {
    _password = password;
  }

  void clearData() {
    _email = null;
    _password = null;
  }

  // Register user with email and password
  Future<bool> registerUser(String email, String password, {String? userType}) async {
    try {
      final AuthResponse response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'user_type': userType ?? 'Patient',
          'full_name': '',
        },
      );

      if (response.user != null) {
        debugPrint('User registered successfully: ${response.user!.id}');
        
        // Insert additional user data into profiles table if needed
        await _createUserProfile(response.user!, userType ?? 'Patient');
        
        return true;
      } else {
        debugPrint('Registration failed: No user returned');
        return false;
      }
    } on AuthException catch (e) {
      debugPrint('Auth error during registration: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Unknown error during registration: $e');
      return false;
    }
  }

  // Sign in user with email and password
  Future<bool> signInUser(String email, String password) async {
    try {
      final AuthResponse response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        debugPrint('User signed in successfully: ${response.user!.id}');
        return true;
      } else {
        debugPrint('Sign in failed: No user returned');
        return false;
      }
    } on AuthException catch (e) {
      debugPrint('Auth error during sign in: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Unknown error during sign in: $e');
      return false;
    }
  }

  // Google Sign In - using existing authenticators.dart function
  Future<bool> signInWithGoogle() async {
    try {
      await nativeGoogleSignIn();
      
      final user = supabase.auth.currentUser;
      if (user != null) {
        debugPrint('Google sign in successful: ${user.id}');
        
        // Create profile if it's a new user
        await _createUserProfile(user, 'Patient');
        
        return true;
      } else {
        debugPrint('Google sign in failed: No user returned');
        return false;
      }
    } catch (e) {
      debugPrint('Google sign in error: $e');
      return false;
    }
  }

  // Create user profile in database
  Future<void> _createUserProfile(User user, String userType) async {
    try {
      // Check if profile already exists
      final existingProfile = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (existingProfile == null) {
        // Create new profile
        await supabase.from('profiles').insert({
          'id': user.id,
          'email': user.email,
          'user_type': userType,
          'full_name': user.userMetadata?['full_name'] ?? '',
          'avatar_url': user.userMetadata?['avatar_url'] ?? '',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        debugPrint('User profile created successfully');
      } else {
        debugPrint('User profile already exists');
      }
    } catch (e) {
      debugPrint('Error creating user profile: $e');
      // Don't throw error here as user registration was successful
    }
  }

  // Sign out user
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
      clearData();
      debugPrint('User signed out successfully');
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  // Check if user is signed in
  bool isSignedIn() {
    return supabase.auth.currentUser != null;
  }

  // Get current user
  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
      debugPrint('Password reset email sent');
      return true;
    } catch (e) {
      debugPrint('Error sending password reset email: $e');
      return false;
    }
  }
}
