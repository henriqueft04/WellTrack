import 'package:flutter/material.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';

class MyBottomNavBar extends StatefulWidget {
  final void Function(int)? onTabChange;
  const MyBottomNavBar({super.key, required this.onTabChange});

  @override
  State<MyBottomNavBar> createState() => _MyBottomNavBarState();
}

class _MyBottomNavBarState extends State<MyBottomNavBar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    const activeColor = Colors.white;
    final inactiveColor = Colors.white.withOpacity(0.5);

    return CircleNavBar(
      activeIcons: const [
        Icon(Icons.home, color: activeColor),
        Icon(Icons.book, color: activeColor),
        Icon(Icons.calendar_today, color: activeColor),
        Icon(Icons.fitness_center, color: activeColor),
        Icon(Icons.person, color: activeColor),
      ],
      inactiveIcons: [
        Icon(Icons.home, color: inactiveColor),
        Icon(Icons.book, color: inactiveColor),
        Icon(Icons.calendar_today, color: inactiveColor),
        Icon(Icons.fitness_center, color: inactiveColor),
        Icon(Icons.person, color: inactiveColor),
      ],
      color: const Color(0xFF9CD0FF),
      height: 60,
      circleWidth: 55,
      activeIndex: _selectedIndex,
      onTap: (index) {
        setState(() => _selectedIndex = index);
        widget.onTabChange?.call(index);
      },
    );
  }
}