import 'package:flutter/material.dart';
import 'package:welltrack/components/app_layout.dart';
import 'package:welltrack/components/main_navigation.dart';
import 'package:welltrack/components/user_info.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  @override
  Widget build(BuildContext context) {
    return NonMainPageWrapper(
      originIndex: 4,
      child: AppLayout(
        pageTitle: 'Edit Profile',
        showLogo: false,
        isMainPage: false,
        showBackButton: true,
        content: const Column(
          children: [
            UserInfo(),
          ],
        ),
      ),
    );
  }
}