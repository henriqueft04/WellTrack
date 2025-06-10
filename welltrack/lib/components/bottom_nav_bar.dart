import 'package:flutter/material.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';


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
  static const Color activeColor = Colors.blue;
  static const Color inactiveColor = Colors.white;

  int _getActiveIndex() {
    if (widget.currentIndex != null) {
      return widget.currentIndex!;
    }

    final modalRoute = ModalRoute.of(context);
    if (modalRoute?.settings.name != null) {
      final routeName = modalRoute!.settings.name!;
      if (routeName.contains('HomePage')) return 0;
      if (routeName.contains('MapPage')) return 1;
      if (routeName.contains('CalendarPage')) return 2;
      if (routeName.contains('StatsPage')) return 3;
      if (routeName.contains('NearMePage')) return 4;
      if (routeName.contains('ProfilePage')) return 5;
    }

    context.visitAncestorElements((element) {
      final elementWidget = element.widget;
      final elementType = elementWidget.runtimeType.toString();
      
      if (elementType.contains('HomePage')) return false;
      if (elementType.contains('MapPage')) return false;
      if (elementType.contains('CalendarPage')) return false;
      if (elementType.contains('StatsPage')) return false;
      if (elementType.contains('NearMePage')) return false;
      if (elementType.contains('ProfilePage')) return false;
      
      return true;
    });

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final activeIndex = _getActiveIndex();

    return CircleNavBar(
      activeIcons: const [
        Icon(Icons.home, color: activeColor),
        Icon(Icons.map, color: activeColor),
        Icon(Icons.calendar_today, color: activeColor),
        Icon(Icons.fitness_center, color: activeColor),
        Icon(Icons.bluetooth, color: activeColor),
        Icon(Icons.person, color: activeColor),
      ],
      inactiveIcons: [
        Icon(Icons.home, color: inactiveColor),
        Icon(Icons.map, color: inactiveColor),
        Icon(Icons.calendar_today, color: inactiveColor),
        Icon(Icons.fitness_center, color: inactiveColor),
        Icon(Icons.bluetooth, color: inactiveColor),
        Icon(Icons.person, color: inactiveColor),
      ],
      color: const Color(0xFF9CD0FF),
      height: 60,
      circleWidth: 55,
      activeIndex: activeIndex,
      onTap: (index) {
        widget.onTabChange?.call(index);
      },
    );
  }
}