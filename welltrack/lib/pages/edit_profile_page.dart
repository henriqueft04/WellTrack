import 'package:flutter/material.dart';
import 'package:welltrack/components/app_layout.dart';
import 'package:welltrack/components/main_navigation.dart';
import 'package:welltrack/models/profile_button.dart';
import 'package:welltrack/components/user_info.dart';
import 'package:welltrack/providers/user_provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final UserProvider userProvider = UserProvider();

  @override
  void initState() {
    super.initState();
    userProvider.loadUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return NonMainPageWrapper(
      originIndex: 4,
      child: AppLayout(
        pageTitle: 'Edit Profile',
        showLogo: false,
        isMainPage: false,
        showBackButton: true,
        content: SingleChildScrollView(
          child: Column(
              children: [
                const SizedBox(height: 20),
                const UserInfo(),
                const SizedBox(height: 30),
                ProfileButton(
                  icon: Icons.edit,
                  text: userProvider.getUserName() ?? 'Alterar Nome',
                  onTap: () {
                    
                  },
                ),
                
                
              ],
            )
        ),
      ),
    );
  }
}