import 'package:flutter/material.dart';
import 'package:welltrack/controllers/sign_up_controller.dart';

class UserInfoWidget extends StatefulWidget {
  const UserInfoWidget({super.key});

  @override
  State<UserInfoWidget> createState() => _UserInfoWidgetState();
}

class _UserInfoWidgetState extends State<UserInfoWidget> {
  final SignUpController _controller = SignUpController();
  Map<String, dynamic>? userProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await _controller.getUserProfile();
      setState(() {
        userProfile = profile;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error loading user profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (userProfile == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No user profile found'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('ID: ${userProfile!['id']}'),
            Text('Name: ${userProfile!['name'] ?? 'Not set'}'),
            Text('Email: ${userProfile!['email']}'),
            Text('Mental State: ${userProfile!['mental_state']}'),
            Text('Created: ${userProfile!['created_at']}'),
            if (userProfile!['avatar'] != null && userProfile!['avatar'].isNotEmpty)
              Text('Avatar: ${userProfile!['avatar']}'),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await _controller.updateUserName('John Doe');
                    _loadUserProfile(); // Refresh
                  },
                  child: const Text('Update Name'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    await _controller.updateMentalState('pleasant');
                    _loadUserProfile(); // Refresh
                  },
                  child: const Text('Set Good Mood'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 