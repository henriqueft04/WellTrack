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
    final inactiveColor = Colors.white.withOpacity(0.5); // softer, faded look

    return CircleNavBar(
      activeIcons: const [
        Icon(Icons.home, color: activeColor),
        Icon(Icons.calendar_month, color: activeColor),
        Icon(Icons.stacked_bar_chart_sharp, color: activeColor),
        Icon(Icons.person, color: activeColor),
      ],
      inactiveIcons: [
        Icon(Icons.home, color: inactiveColor),
        Icon(Icons.calendar_month, color: inactiveColor),
        Icon(Icons.stacked_bar_chart_sharp, color: inactiveColor),
        Icon(Icons.person, color: inactiveColor),
      ],
      color: const Color.fromARGB(255, 30, 173, 245),
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