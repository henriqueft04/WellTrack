import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MyBottomNavBar extends StatelessWidget {
  final void Function(int)? onTabChange;
  const MyBottomNavBar({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      //Padding between buttons
      padding: EdgeInsets.symmetric(vertical: 20),
      child: GNav(
        //decoration (colors, activecolors and borders)
        color: Colors.grey[500],
        activeColor: Colors.grey.shade800,
        tabActiveBorder: Border.all(color: Colors.white),
        tabBackgroundColor: Colors.grey.shade200,
        mainAxisAlignment: MainAxisAlignment.center,
        tabBorderRadius: 16,

      onTabChange: (value) => onTabChange!(value) ,

        tabs: const [
          //buttons
          GButton(icon: Icons.home, text: 'Me'),
          GButton(icon: Icons.calendar_month, text: 'Calendar'),
          GButton(icon: Icons.stacked_bar_chart_sharp, text: 'Stats'),
          GButton(icon: Icons.person, text: 'Profile'),

        ],
      ),
    );
  }
}
