import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:welltrack/components/bottom_nav_bar.dart';
import 'package:welltrack/pages/home_page.dart';
import 'package:welltrack/pages/journal_page.dart';
import 'package:welltrack/pages/calendar_page.dart';
import 'package:welltrack/pages/stats_page.dart';
import 'package:welltrack/pages/profile_page.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;
  
  const MainNavigation({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> get _pages => [
    const HomePage(),
    const JournalPage(),
    const CalendarPage(),
    const StatsPage(steps: 12212.0, calories: 210.0, distance: 2.5),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        // Show confirmation dialog before exiting app only on main page
        if (_selectedIndex == 0) {
          final shouldExit = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Exit App'),
              content: const Text('Are you sure you want to exit the app?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Exit'),
                ),
              ],
            ),
          );
          if (shouldExit ?? false) {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: MyBottomNavBar(
          onTabChange: _navigateBottomBar,
        ),
      ),
    );
  }
}

class NonMainPageWrapper extends StatelessWidget {
  final Widget child;
  final bool showBackButton;
  
  const NonMainPageWrapper({
    super.key,
    required this.child,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: MyBottomNavBar(
        onTabChange: (index) {
          // Navigate back to main navigation with selected index
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MainNavigation(initialIndex: index),
            ),
          );
        },
      ),
    );
  }
} 