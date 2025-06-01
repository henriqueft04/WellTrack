import 'package:flutter/material.dart';

class MyBottomNavBar extends StatefulWidget {
  final void Function(int)? onTabChange;
  final int? currentIndex;
  
  const MyBottomNavBar({
    super.key, 
    required this.onTabChange,
    this.currentIndex,
  });

  @override
  State<MyBottomNavBar> createState() => _MyBottomNavBarState();
}

class _MyBottomNavBarState extends State<MyBottomNavBar> {
  int _getActiveIndex() {
    return widget.currentIndex ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final activeIndex = _getActiveIndex();

    return BottomNavigationBar(
      currentIndex: activeIndex,
      onTap: widget.onTabChange,
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF9CD0FF),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white.withOpacity(0.5),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: 'Journal',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Calendar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.fitness_center),
          label: 'Stats',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}