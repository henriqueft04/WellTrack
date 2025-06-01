import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:welltrack/components/app_layout.dart';
import 'package:welltrack/pages/mental_state_page.dart';
import 'package:welltrack/pages/stats_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _moodValue = 1.0;
  int _selectedDayIndex = 3;

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
        pageTitle: "Welcome",
        showLogo: true,
        isMainPage: true,
        content: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Mood Slider Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 12,
                      activeTrackColor: const Color(0xFF9CD0FF),
                      inactiveTrackColor: const Color(0xFF9CD0FF),
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 20,
                      ),
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
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('unpleasant'),
                    Text(''),
                    Text('neutral'),
                    Text(''),
                    Text('pleasant'),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Horizontal Calendar
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: 7,
                    itemBuilder: (context, index) {
                      final weekDays = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];
                      final dates = [12, 13, 14, 15, 16, 17, 18];
                      final isSelected = index == _selectedDayIndex;
                      return GestureDetector(
                        onTap: () => _onDayTapped(index),
                        child: Container(
                          width: 50,
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue[100] : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                weekDays[index],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.blue : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dates[index].toString(),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isSelected ? Colors.blue : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Navigation Cards for Mental State and Stats
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MentalStatePage(),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 187, 186, 186),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.sentiment_satisfied,
                              size: 40,
                              color: Colors.white,
                            ),
                            SizedBox(width: 16),
                            Text(
                              'mental state',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StatsPage(
                              steps: 12212.0,
                              calories: 210.0,
                              distance: 2.5,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 187, 186, 186),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            SizedBox(width: 16),
                            Icon(
                              Icons.pie_chart,
                              size: 40,
                              color: Colors.white,
                            ),
                            SizedBox(width: 16),
                            Text(
                              'stats',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Bottom Stats Row
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 28,
                            color: Colors.black,
                          ),
                          SizedBox(height: 4),
                          Text('327'),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            size: 28,
                            color: Colors.black,
                          ),
                          SizedBox(height: 4),
                          Text('327'),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(
                            Icons.directions_run,
                            size: 28,
                            color: Colors.black,
                          ),
                          SizedBox(height: 4),
                          Text('5.3 km'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
