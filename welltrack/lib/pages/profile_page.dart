import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:welltrack/pages/login_page.dart';
import 'package:welltrack/providers/user_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Load user profile when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                alignment: Alignment.centerLeft,
                child: const Text(
                  'My Profile',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 20),

              Consumer<UserProvider>(
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
                        backgroundImage: userProfile?['avatar'] != null 
                          ? NetworkImage(userProfile!['avatar']) 
                          : const AssetImage('lib/images/profile_photo.png') as ImageProvider,
                        child: userProfile?['avatar'] == null 
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
              ),

              const SizedBox(height: 30),

              // Buttons or Options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    ProfileButton(
                      icon: Icons.edit,
                      text: 'Editar Perfil',
                      onTap: () {
                        // TO DO
                      },
                    ),
                    ProfileButton(
                      icon: Icons.settings,
                      text: 'Definições',
                      onTap: () {
                        // TO DO
                      },
                    ),
                    ProfileButton(
                      icon: Icons.logout,
                      text: 'Logout',
                      onTap: () {
                        // Clear user data on logout
                        context.read<UserProvider>().clearUser();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget para o botão da página
class ProfileButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const ProfileButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black),
            const SizedBox(width: 15),
            Text(text, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
