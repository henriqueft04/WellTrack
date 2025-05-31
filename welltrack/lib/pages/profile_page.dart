import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:welltrack/components/user_info.dart';
import 'package:welltrack/pages/login_page.dart';
import 'package:welltrack/providers/user_provider.dart';
import 'package:welltrack/models/profile_button.dart';
import 'package:welltrack/pages/edit_profile_page.dart';

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

              const UserInfo(),

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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfilePage(),
                          ),
                        );
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