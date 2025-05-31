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

  // Check if email already exists in auth system
  Future<bool> checkIfEmailExists(String email) async {
    try {
      // Try to trigger a password reset for the email
      // If it succeeds, the email exists; if it fails, it doesn't
      await supabase.auth.resetPasswordForEmail(email);
      return true; // Email exists
    } catch (e) {
      // If we get an error, it might mean the email doesn't exist
      // But we should be careful with this approach
      return false; // Assume email doesn't exist
    }
  }

  // Register user with email and password
  Future<Map<String, dynamic>> registerUser(String email, String password, {String? name}) async {
    try {
      final AuthResponse response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': name ?? '',
        },
      );

      if (response.user != null) {
        debugPrint('User registered successfully: ${response.user!.id}');
        
        // Create user in public.users table
        await _createUserInUsersTable(
          response.user!,
          name: name ?? '',
        );
        
        return {'success': true, 'message': 'Account created successfully!'};
      } else {
        debugPrint('Registration failed: No user returned');
        return {'success': false, 'message': 'Registration failed. Please try again.'};
      }
    } on AuthException catch (e) {
      debugPrint('Auth error during registration: ${e.message}');
      
      // Check for specific error messages that indicate email already exists
      if (e.message.toLowerCase().contains('already') || 
          e.message.toLowerCase().contains('exists') ||
          e.message.toLowerCase().contains('registered')) {
        return {
          'success': false, 
          'message': 'This email is already registered.',
          'emailExists': true
        };
      }
      
      return {'success': false, 'message': 'Registration failed: ${e.message}'};
    } catch (e) {
      debugPrint('Unknown error during registration: $e');
      return {'success': false, 'message': 'Registration failed: ${e.toString()}'};
    }
  }

  // Sign in user with email and password
  Future<Map<String, dynamic>> signInUser(String email, String password) async {
    try {
      final AuthResponse response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        debugPrint('User signed in successfully: ${response.user!.id}');
        
        // Check if user exists in users table, create if not
        await _ensureUserExistsInUsersTable(response.user!);
        
        return {'success': true, 'message': 'Signed in successfully!'};
      } else {
        debugPrint('Sign in failed: No user returned');
        return {'success': false, 'message': 'Sign in failed. Please try again.'};
      }
    } on AuthException catch (e) {
      debugPrint('Auth error during sign in: ${e.message}');
      
      if (e.message.toLowerCase().contains('invalid') || 
          e.message.toLowerCase().contains('credentials') ||
          e.message.toLowerCase().contains('password')) {
        return {'success': false, 'message': 'Invalid email or password'};
      }
      
      return {'success': false, 'message': 'Sign in failed: ${e.message}'};
    } catch (e) {
      debugPrint('Unknown error during sign in: $e');
      return {'success': false, 'message': 'Sign in failed: ${e.toString()}'};
    }
  }

  // Google Sign In - using existing authenticators.dart function
  Future<bool> signInWithGoogle() async {
    try {
      await nativeGoogleSignIn();
      
      final user = supabase.auth.currentUser;
      if (user != null) {
        debugPrint('Google sign in successful: ${user.id}');
        
        // Create or update user in public.users table
        await _createUserInUsersTable(
          user,
          name: user.userMetadata?['full_name'] ?? '',
        );
        
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

  // Create user in public.users table
  Future<void> _createUserInUsersTable(User user, {String? name}) async {
    try {
      // Check if user already exists
      final existingUser = await supabase
          .from('users')
          .select()
          .eq('email', user.email!)
          .maybeSingle();

      if (existingUser == null) {
        // Create new user
        await supabase.from('users').insert({
          'name': name ?? user.userMetadata?['full_name'] ?? '',
          'email': user.email,
          'avatar': user.userMetadata?['avatar_url'] ?? '',
          'mental_state': 'ok', // Default mental state
        });

        debugPrint('User created in users table successfully');
      } else {
        debugPrint('User already exists in users table');
      }
    } catch (e) {
      debugPrint('Error creating user in users table: $e');
      // Don't throw error here as authentication was successful
    }
  }

  // Ensure user exists in users table (for existing auth users)
  Future<void> _ensureUserExistsInUsersTable(User user) async {
    try {
      final existingUser = await supabase
          .from('users')
          .select()
          .eq('email', user.email!)
          .maybeSingle();

      if (existingUser == null) {
        await _createUserInUsersTable(user);
      }
    } catch (e) {
      debugPrint('Error ensuring user exists in users table: $e');
    }
  }

  // Get user profile from users table
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final authUser = supabase.auth.currentUser;
      if (authUser == null) return null;

      final response = await supabase
          .from('users')
          .select()
          .eq('email', authUser.email!)
          .single();

      return response;
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return null;
    }
  }

  // Update user profile in users table
  Future<bool> updateUserProfile(Map<String, dynamic> updates) async {
    try {
      final authUser = supabase.auth.currentUser;
      if (authUser == null) return false;

      await supabase
          .from('users')
          .update(updates)
          .eq('email', authUser.email!);

      debugPrint('User profile updated successfully');
      return true;
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      return false;
    }
  }

  // Update user's mental state
  Future<bool> updateMentalState(String mentalState) async {
    return await updateUserProfile({'mental_state': mentalState});
  }

  // Update user's name
  Future<bool> updateUserName(String name) async {
    return await updateUserProfile({'name': name});
  }

  // Update user's avatar
  Future<bool> updateUserAvatar(String avatarUrl) async {
    return await updateUserProfile({'avatar': avatarUrl});
  }

  // Get current user's mental state
  Future<String?> getUserMentalState() async {
    try {
      final profile = await getUserProfile();
      return profile?['mental_state'];
    } catch (e) {
      debugPrint('Error getting user mental state: $e');
      return null;
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
