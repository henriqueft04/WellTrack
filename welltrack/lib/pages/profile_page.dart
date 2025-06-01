import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:welltrack/components/app_layout.dart';
import 'package:welltrack/components/user_info.dart';
import 'package:welltrack/pages/login_page.dart';
import 'package:welltrack/providers/user_provider.dart';
import 'package:welltrack/models/profile_button.dart';
import 'package:welltrack/pages/edit_profile_page.dart';
import 'package:welltrack/controllers/sign_up_controller.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final SignUpController authController = SignUpController();

  @override
  void initState() {
    super.initState();
    // Load user profile when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadUserProfile();
    });
  }

  Future<void> _handleLogout() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Sign out from Supabase authentication
      await authController.signOut();
      
      // Clear local user data
      if (mounted) {
        context.read<UserProvider>().clearUser();
      }

      // Hide loading dialog
      if (mounted) Navigator.pop(context);

      // Navigate to login page
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      // Hide loading dialog
      if (mounted) Navigator.pop(context);
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      pageTitle: "My Profile",
      showLogo: true,
      isMainPage: true,
      content: SingleChildScrollView(
        child: Column(
          children: [
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
                    onTap: _handleLogout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget para o botão da página