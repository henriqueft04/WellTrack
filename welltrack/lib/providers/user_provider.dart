import 'package:flutter/material.dart';
import 'package:welltrack/controllers/sign_up_controller.dart';

class UserProvider with ChangeNotifier {
  final SignUpController _controller = SignUpController();
  
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;
  String? _error;

  // Getters
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasUser => _userProfile != null;
  int? get userId => _userProfile?['id'] as int?;

  // Load user profile
  Future<void> loadUserProfile() async {
    if (_isLoading) return; // Prevent multiple simultaneous calls
    
    _setLoading(true);
    _clearError();
    
    try {
      final profile = await _controller.getUserProfile();
      _userProfile = profile;
      
      // Clean up any placeholder URLs
      if (_userProfile != null && _userProfile!['avatar'] != null) {
        final avatarUrl = _userProfile!['avatar'] as String;
        if (avatarUrl.contains('placeholder.com') || avatarUrl.contains('via.placeholder')) {
          debugPrint('Cleaning up placeholder avatar URL');
          await _controller.updateUserAvatar(''); // Clear the placeholder URL
          _userProfile!['avatar'] = '';
        }
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load user profile: $e';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }

  // Get user name
  String? getUserName() {
    return _userProfile?['name'];
  }

  // Update user name
  Future<bool> updateUserName(String name) async {
    try {
      await _controller.updateUserName(name);
      // Update local state
      if (_userProfile != null) {
        _userProfile!['name'] = name;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Failed to update name: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  // Update user avatar
  Future<bool> updateUserAvatar(String avatarUrl) async {
    try {
      await _controller.updateUserAvatar(avatarUrl);
      // Update local state
      if (_userProfile != null) {
        _userProfile!['avatar'] = avatarUrl;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Failed to update avatar: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  // Update mental state
  Future<bool> updateMentalState(String mentalState) async {
    try {
      await _controller.updateMentalState(mentalState);
      // Update local state
      if (_userProfile != null) {
        _userProfile!['mental_state'] = mentalState;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Failed to update mental state: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  // Clear user data (for logout)
  void clearUser() {
    _userProfile = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // Refresh user profile
  Future<void> refresh() async {
    await loadUserProfile();
  }
} 