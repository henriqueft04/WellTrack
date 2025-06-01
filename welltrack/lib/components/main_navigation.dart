import 'package:flutter/material.dart';
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

  List<Widget> get _pages => [
    const HomePage(),
    const JournalPage(),
    const CalendarPage(),
    const StatsPage(steps: 12212.0, calories: 210.0, distance: 2.5),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MainPageWrapper(
      currentIndex: _selectedIndex,
      child: _pages[_selectedIndex],
    );
  }
}

/// Wrapper for main pages that handles navigation and navbar
class MainPageWrapper extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const MainPageWrapper({
    super.key,
    required this.currentIndex,
    required this.child,
  });

  void _navigateBottomBar(BuildContext context, int index) {
    if (index != currentIndex) {
      // Create proper navigation history
      Widget targetPage;
      switch (index) {
        case 0:
          targetPage = const HomePage();
          break;
        case 1:
          targetPage = const JournalPage();
          break;
        case 2:
          targetPage = const CalendarPage();
          break;
        case 3:
          targetPage = const StatsPage(steps: 12212.0, calories: 210.0, distance: 2.5);
          break;
        case 4:
          targetPage = const ProfilePage();
          break;
        default:
          targetPage = const HomePage();
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MainPageWrapper(
            currentIndex: index,
            child: targetPage,
          ),
        ),
      );
    }
  }

  // Helper method to determine current index from child type
  int _getCurrentIndexFromChild() {
    if (child is HomePage) return 0;
    if (child is JournalPage) return 1;
    if (child is CalendarPage) return 2;
    if (child is StatsPage) return 3;
    if (child is ProfilePage) return 4;
    return currentIndex; // fallback to provided index
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: MyBottomNavBar(
        currentIndex: _getCurrentIndexFromChild(),
        onTabChange: (index) => _navigateBottomBar(context, index),
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
        currentIndex: null, // No current index for secondary pages
        onTabChange: (index) {
          // When user taps navbar from a non-main page, navigate to main navigation
          // This preserves the back stack so Android back button still works
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MainNavigation(initialIndex: index),
            ),
          );
        },
      ),
    );
  }
} 