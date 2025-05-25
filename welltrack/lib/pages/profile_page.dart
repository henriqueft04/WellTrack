import 'package:flutter/material.dart';
import 'package:welltrack/pages/intro_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFCDEDFD), // Background color
      body: SafeArea(
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

            // Profile Picture - 
            //TO DO: why don't show the image
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(
                'lib/images/profile_photo.png',
              ),
            ),

            const SizedBox(height: 20),

            // User Info
            const Text(
              'Carlos verenzuela',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            const Text(
              'carlos@email.com',
              style: TextStyle(color: Colors.grey),
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
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const IntroPage(),
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
