import 'package:flutter/material.dart';
import 'package:welltrack/pages/journal_page.dart';
import 'package:welltrack/pages/stats_page.dart';
import 'package:welltrack/pages/about_page.dart';
import 'package:welltrack/pages/calendar_page.dart';
import 'package:welltrack/pages/intro_page.dart';
import 'package:welltrack/pages/profile_page.dart';
import 'package:welltrack/pages/mental_state_page.dart';
import '../components/bottom_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  double _moodValue = 1.0; // 0 = unpleasant, 1 = neutral, 2 = pleasant
  int _selectedDayIndex = 3; // Index for the 16th in the mockup

  void navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onMoodChanged(double value) {
    setState(() {
      _moodValue = value;
    });
  }

  void _onDayTapped(int index) {
    setState(() {
      _selectedDayIndex = index;
    });
  }

  final List<Widget> _pages = [
    const JournalPage(),
    const CalendarPage(),
    const StatsPage(steps: 12212.0, calories: 210.0, distance: 2.5),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    if (_selectedIndex != 0) {
      return Scaffold(
        bottomNavigationBar: MyBottomNavBar(
          onTabChange: (index) => navigateBottomBar(index),
        ),
        body: _pages[_selectedIndex],
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Logo at top
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Center(
                  child: Image.asset(
                    'lib/images/martim.png',
                    height: 60,
                  ),
                ),
              ),
              // Mood Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.07),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _moodValue <= 0.5
                            ? Icons.sentiment_very_dissatisfied
                            : _moodValue <= 1.5
                                ? Icons.sentiment_neutral
                                : Icons.sentiment_very_satisfied,
                        size: 48,
                        color: _moodValue <= 0.5
                            ? Colors.red
                            : _moodValue <= 1.5
                                ? Colors.orange
                                : Colors.green,
                      ),
                      const SizedBox(height: 8),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 12,
                          activeTrackColor: const Color(0xFF9CD0FF),
                          inactiveTrackColor: const Color(0xFF9CD0FF),
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 20),
                          overlayShape: SliderComponentShape.noOverlay,
                          thumbColor: Colors.white,
                          trackShape: RoundedRectSliderTrackShape(),
                        ),
                        child: Slider(
                          min: 0,
                          max: 2,
                          divisions: 4,
                          value: _moodValue,
                          onChanged: _onMoodChanged,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('unpleasant'),
                          Text(''),
                          Text('neutral'),
                          Text(''),
                          Text('pleasant'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Horizontal Calendar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    itemCount: 7,
                    itemBuilder: (context, index) {
                      final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                      final dates = [12, 13, 14, 15, 16, 17, 18];
                      final isSelected = index == _selectedDayIndex;
                      return GestureDetector(
                        onTap: () => _onDayTapped(index),
                        child: Container(
                          width: 56,
                          margin: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF9CD0FF) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.15),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                weekDays[index],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dates[index].toString(),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isSelected ? Colors.white : Colors.black,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Quick Access Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    _buildHomeCard(
                      context,
                      title: 'Mental State',
                      icon: Icons.sentiment_satisfied,
                      color: Colors.lightBlue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MentalStatePage()),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildHomeCard(
                      context,
                      title: 'Journal',
                      icon: Icons.book,
                      color: Colors.pink.shade200,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const JournalSelectionPage()),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildHomeCard(
                      context,
                      title: 'Stats',
                      icon: Icons.pie_chart,
                      color: Colors.orange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const StatsPage(steps: 12212.0, calories: 210.0, distance: 2.5)),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Bottom Stats Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: const [
                          Icon(Icons.location_on, size: 28, color: Colors.black),
                          SizedBox(height: 4),
                          Text('327'),
                        ],
                      ),
                      Column(
                        children: const [
                          Icon(Icons.local_fire_department, size: 28, color: Colors.black),
                          SizedBox(height: 4),
                          Text('327'),
                        ],
                      ),
                      Column(
                        children: const [
                          Icon(Icons.directions_run, size: 28, color: Colors.black),
                          SizedBox(height: 4),
                          Text('5.3 km'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MyBottomNavBar(
        onTabChange: (index) => navigateBottomBar(index),
      ),
    );
  }

  Widget _buildHomeCard(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(width: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}