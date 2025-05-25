import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MyBottomNavBar extends StatelessWidget {
  final void Function(int)? onTabChange;
  const MyBottomNavBar({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 30, 173, 245), // Cor de fundo
      //Padding between buttons
      padding: EdgeInsets.symmetric(vertical: 20),
      child: GNav(
        //decoration (colors, activecolors and borders)
        color: const Color.fromARGB(255, 0, 0, 0),
        activeColor: const Color(0xFF2799FF),
        tabActiveBorder: Border.all(
          color: const Color.fromARGB(255, 101, 114, 236),
        ),

        // Background color of the active tab
        tabBackgroundColor: const Color(0xFFCDEDFD),
        mainAxisAlignment: MainAxisAlignment.center,
        tabBorderRadius: 16,

        onTabChange: (value) => onTabChange!(value),

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
