import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:welltrack/components/app_layout.dart';
import 'package:welltrack/components/calendar.dart';

import 'package:welltrack/models/action_card.dart';
import 'package:welltrack/pages/mental_state_form_page.dart';
import 'package:welltrack/pages/mental_state_page.dart';
import 'package:welltrack/pages/journal_selection_page.dart';
import 'package:welltrack/components/mood_slider.dart';

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
  double _moodValue = 1.0;
  late int _selectedDayIndex;
  late List<DateTime> _calendarDays;
  final ScrollController _calendarScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _calendarDays = List.generate(11, (i) => DateTime.now().subtract(Duration(days: 5 - i)));
    _selectedDayIndex = 5; // Today is at index 5
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToDay(_selectedDayIndex);
    });
  }

  @override
  void dispose() {
    _calendarScrollController.dispose();
    super.dispose();
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

  void _onMoodChanged(double value) {
    setState(() => _moodValue = value);
  }

  void _onDayTapped(int index) {
    setState(() => _selectedDayIndex = index);
    _scrollToDay(index);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
          return;
        }
        
        // Show confirmation dialog before exiting app only if this is the root
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
      child: AppLayout(
        showLogo: true,
        isMainPage: true,
        content: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                buildMoodSlider(context, _moodValue, _onMoodChanged),
                const SizedBox(height: 24),
                buildCalendar(context, _calendarDays, _selectedDayIndex, _onDayTapped, _calendarScrollController),
                const SizedBox(height: HomePageConstants.bottomSpacing),
                _buildActionCards(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          buildActionCard(
            context,
            _calendarDays,
            _selectedDayIndex,
            Colors.blue,
            const Color(0xFFE3F2FD),
            Icons.sentiment_satisfied,
            'State of Mind',
            'update your state333',
            () => MaterialPageRoute(
              builder: (context) => MentalStatePage(),
            ),
          ),
          const SizedBox(height: HomePageConstants.cardSpacing),
          buildActionCard(
            context,
            _calendarDays,
            _selectedDayIndex,
            Colors.pink.shade200,
            const Color(0xFFFCE4EC),
            Icons.bookmark,
            'Journal',
            'create a journal entry',
            () => MaterialPageRoute(
              builder: (context) => JournalSelectionPage(selectedDate: _calendarDays[_selectedDayIndex]),
            ),
          ),
        ],
      ),
    );
  }
}
