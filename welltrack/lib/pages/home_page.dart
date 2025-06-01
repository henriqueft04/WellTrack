import 'package:flutter/material.dart';
import 'package:welltrack/pages/journal_page.dart';
import 'package:welltrack/pages/stats_page.dart';
import 'package:welltrack/pages/calendar_page.dart';
import 'package:welltrack/pages/profile_page.dart';
import 'package:welltrack/pages/mental_state_page.dart';
import 'package:welltrack/pages/mental_state_page.dart' show MentalStateFormPage, JournalSelectionPage;
import '../components/bottom_nav_bar.dart';

// Constants
class HomePageConstants {
  static const double logoHeight = 50.0;
  static const double horizontalPadding = 24.0;
  static const double cardHeight = 100.0;
  static const double iconSize = 40.0;
  static const double cardSpacing = 16.0;
  static const double bottomSpacing = 24.0;
  
  // Updated colors
  static const Color primaryColor = Color(0xFF4A90E2);
  static const Color secondaryColor = Color(0xFF6B7C93);
  static const Color backgroundColor = Color(0xFFF5F7FA);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF2C3E50);
  static const Color accentColor = Color(0xFF4A90E2);
  static const Color sliderActiveColor = Color(0xFF4A90E2);
  static const Color sliderInactiveColor = Color(0xFFE0E0E0);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  double _moodValue = 1.0;
  late int _selectedDayIndex;
  late List<DateTime> _calendarDays;
  final ScrollController _calendarScrollController = ScrollController();

  final List<Widget> _pages = [
    const JournalPage(),
    const CalendarPage(),
    const StatsPage(steps: 12212.0, calories: 210.0, distance: 2.5),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _calendarDays = List.generate(11, (i) => DateTime.now().subtract(Duration(days: 5 - i)));
    _selectedDayIndex = 5; // Today is at index 5
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToDay(_selectedDayIndex);
    });
  }

  void _scrollToDay(int index) {
    // Each item is 60 width + 16 margin (8 left, 8 right)
    double itemWidth = 60 + 16;
    double screenWidth = MediaQuery.of(context).size.width;
    double offset = (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);
    _calendarScrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void navigateBottomBar(int index) {
    setState(() => _selectedIndex = index);
  }

  void _onMoodChanged(double value) {
    setState(() => _moodValue = value);
  }

  void _onDayTapped(int index) {
    setState(() => _selectedDayIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedIndex != 0) {
      return Scaffold(
        backgroundColor: HomePageConstants.backgroundColor,
        bottomNavigationBar: MyBottomNavBar(onTabChange: navigateBottomBar),
        body: _pages[_selectedIndex],
      );
    }

    return Scaffold(
      backgroundColor: HomePageConstants.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildLogo(),
              _buildMoodSlider(),
              _buildCalendar(),
              const SizedBox(height: HomePageConstants.bottomSpacing),
              _buildActionCards(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MyBottomNavBar(onTabChange: navigateBottomBar),
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Image.asset(
        'lib/images/martim.png',
        height: HomePageConstants.logoHeight,
      ),
    );
  }

  Widget _buildMoodSlider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: HomePageConstants.horizontalPadding),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HomePageConstants.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            _getMoodIcon(),
            size: 50, // Increased size
            color: _getMoodColor(),
          ),
          const SizedBox(height: 16), // Spacing between icon and slider
          // Labels above the slider
          const SizedBox(height: 4), // Spacing between labels above and slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 8,
              activeTrackColor: HomePageConstants.sliderActiveColor,
              inactiveTrackColor: HomePageConstants.sliderInactiveColor,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 16),
              overlayShape: SliderComponentShape.noOverlay,
              thumbColor: Colors.white,
              trackShape: RoundedRectSliderTrackShape(),
            ),
            child: Slider(
              min: 0,
              max: 2,
              divisions: 4, // 5 possible values (0.0, 0.5, 1.0, 1.5, 2.0)
              value: _moodValue,
              onChanged: _onMoodChanged,
            ),
          ),
          const SizedBox(height: 8),
          // Labels below the slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Very Unpleasant',
                style: TextStyle(
                  color: HomePageConstants.secondaryColor,
                  fontSize: 12,
                ),
              ),
            
              Text(
                'Neutral',
                style: TextStyle(
                  color: HomePageConstants.secondaryColor,
                  fontSize: 12,
                ),
              ),
            
              Text(
                'Very Pleasant',
                style: TextStyle(
                  color: HomePageConstants.secondaryColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getMoodIcon() {
    if (_moodValue == 0.0) {
      return Icons.sentiment_very_dissatisfied;
    } else if (_moodValue == 0.5) {
      return Icons.sentiment_dissatisfied;
    } else if (_moodValue <= 1.5) {
      return Icons.sentiment_neutral;
    } else {
      return Icons.sentiment_very_satisfied; // This will be for value 2.0
    }
  }

  Color _getMoodColor() {
    if (_moodValue == 0.0) {
      return Colors.red; // Very Unpleasant
    } else if (_moodValue == 0.5) {
      return Colors.deepOrange; // Unpleasant
    } else if (_moodValue == 1.0) {
      return Colors.orange; // Neutral
    } else if (_moodValue == 1.5) {
      return Colors.lightGreen; // Pleasant
    } else {
      return Colors.green; // Very Pleasant (value 2.0)
    }
  }

  Widget _buildCalendar() {
    final today = DateTime.now();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      height: 82,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        controller: _calendarScrollController,
        itemCount: _calendarDays.length,
        itemBuilder: (context, index) {
          final date = _calendarDays[index];
          final isSelected = index == _selectedDayIndex;
          final isToday = date.day == today.day && date.month == today.month && date.year == today.year;
          final weekDay = _getWeekdayLetter(date.weekday);
          return GestureDetector(
            onTap: () {
              setState(() => _selectedDayIndex = index);
              _scrollToDay(index);
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                color: isSelected
                    ? HomePageConstants.primaryColor
                    : isToday
                        ? Colors.white
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: isToday
                    ? Border.all(color: HomePageConstants.primaryColor, width: 2)
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: HomePageConstants.primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weekDay,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : isToday
                              ? HomePageConstants.primaryColor
                              : HomePageConstants.secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      color: isSelected
                          ? Colors.white
                          : isToday
                              ? HomePageConstants.primaryColor
                              : HomePageConstants.textColor,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (isToday) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: HomePageConstants.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Today',
                        style: TextStyle(
                          color: Color(0xFF4A90E2),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getWeekdayLetter(int weekday) {
    // 1 = Monday, 7 = Sunday
    const weekLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return weekLetters[weekday - 1];
  }

  Widget _buildActionCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          _StyledActionButton(
            icon: Icons.sentiment_satisfied,
            label: 'State of Mind',
            color: Colors.blue,
            background: const Color(0xFFE3F2FD),
            onTap: () {
              // Check if the selected date is in the future
              final selectedDate = _calendarDays[_selectedDayIndex];
              if (selectedDate.isAfter(DateTime.now())) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Future Date'),
                      content: const Text('You cannot update your state in the future.'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              } else {
                // Navigate to MentalStateFormPage if the date is not in the future
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MentalStateFormPage(selectedDate: _calendarDays[_selectedDayIndex])),
                );
              }
            },
          ),
          const SizedBox(height: HomePageConstants.cardSpacing),
          _StyledActionButton(
            icon: Icons.bookmark,
            label: 'Journal',
            color: Colors.pink,
            background: Color(0xFFFCE4EC),
            onTap: () {
              // Check if the selected date is in the future
              final selectedDate = _calendarDays[_selectedDayIndex];
              if (selectedDate.isAfter(DateTime.now())) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Future Date'),
                      content: const Text('You cannot create a journal entry in the future.'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              } else {
                // Navigate to JournalSelectionPage if the date is not in the future
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => JournalSelectionPage(selectedDate: selectedDate)),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

// Custom styled button widget
class _StyledActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  const _StyledActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 2),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}