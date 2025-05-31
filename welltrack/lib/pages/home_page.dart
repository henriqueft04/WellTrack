import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:welltrack/pages/journal_page.dart';
import 'package:welltrack/pages/stats_page.dart';
import 'package:welltrack/pages/about_page.dart';
import 'package:welltrack/pages/calendar_page.dart';
import 'package:welltrack/pages/intro_page.dart';
import 'package:welltrack/pages/profile_page.dart';
import '../components/bottom_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //this selected index is to control the bottom nav bar
  int _selectedIndex = 0;

  //this methos will update our select index
  //when the user taps on the bottom bar
  void navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  //pages to display
  final List<Widget> _pages = [
    //Journal page
    const JournalPage(),

    //Calendar page
    const CalendarPage(),

    //Stats page
    const StatsPage(steps: 12212.0, calories: 210.0, distance: 2.5),

    //Profile page
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        // Show confirmation dialog before exiting app
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
      },
      child: Scaffold(
        bottomNavigationBar: MyBottomNavBar(
          onTabChange: (index) => navigateBottomBar(index),
        ),

        //Menu on Top
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Builder(
            builder:
                (context) => IconButton(
                  icon: const Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Icon(Icons.menu, color: Colors.black),
                  ),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
          ),
        ),

        //Drawer
        drawer: Drawer(
          backgroundColor: Colors.grey[900],
          child: Column(
            //Column to everything except for the logout (end of drawer)
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //logo (clicável)
              Column(
                children: [
                  DrawerHeader(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomePage(),
                          ),
                        );
                      },
                      child: Image.asset('lib/images/logo.png'),
                    ),
                  ),

                  //Dividir between logo and icons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Divider(color: Colors.grey[800]),
                  ),

                  //other pages (can be copied to add others)
                  //Home
                  Padding(
                    padding: EdgeInsets.only(left: 25),
                    child: ListTile(
                      leading: Icon(Icons.home, color: Colors.white),
                      title: Text('Home', style: TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomePage(),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                  ),

                  //Calendar
                  Padding(
                    padding: EdgeInsets.only(left: 25),
                    child: ListTile(
                      leading: Icon(Icons.list_rounded, color: Colors.white),
                      title: Text(
                        'Calendar',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        Navigator.pop(context); // Fecha o drawer primeiro
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CalendarPage(),
                          ),
                        );
                      },
                    ),
                  ),

                  //About
                  Padding(
                    padding: EdgeInsets.only(left: 25),
                    child: ListTile(
                      leading: Icon(Icons.info, color: Colors.white),
                      title: Text('About', style: TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AboutPage(),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                  ),
                ],
              ),

              //Logout
              Padding(
                padding: const EdgeInsets.only(left: 25, bottom: 20),
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.white),
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const IntroPage()),
                      (route) => false,
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        //Buttons to BottomnavBar
        body: _pages[_selectedIndex],
      ),
    );
  }
}
