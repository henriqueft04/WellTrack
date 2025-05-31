import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:welltrack/providers/user_provider.dart';

class UserInfo extends StatelessWidget {
  const UserInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        // Show loading indicator while fetching data
        if (userProvider.isLoading) {
          return const Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading profile...'),
            ],
          );
        }

        // Show error if something went wrong
        if (userProvider.error != null) {
          return Column(
            children: [
              Icon(Icons.error, color: Colors.red, size: 50),
              SizedBox(height: 16),
              Text(
                'Error loading profile',
                style: TextStyle(color: Colors.red),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => userProvider.refresh(),
                child: Text('Retry'),
              ),
            ],
          );
        }

        final userProfile = userProvider.userProfile;

        return Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage:
                  userProfile?['avatar'] != null
                      ? NetworkImage(userProfile!['avatar'])
                      : const AssetImage('lib/images/profile_photo.png')
                          as ImageProvider,
              child:
                  userProfile?['avatar'] == null
                      ? const Icon(Icons.person, size: 50, color: Colors.grey)
                      : null,
            ),
            const SizedBox(height: 16),
            Text(
              userProfile?['name'] ?? 'No Name Found',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            Text(
              userProfile?['email'] ?? 'No Email Found',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        );
      },
    );
  }
}
