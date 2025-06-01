import 'package:flutter/material.dart';
import 'package:welltrack/components/main_navigation.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainNavigation(initialIndex: 0);
  }
}