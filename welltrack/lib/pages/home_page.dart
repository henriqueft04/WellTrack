import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:welltrack/utils/pedometer_utils.dart';
import 'package:welltrack/components/app_layout.dart';
import 'package:welltrack/components/calendar.dart';

import 'package:welltrack/models/action_card.dart';
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
  //To Pedometer
  StreamSubscription<PedestrianStatus>? pedestrianSubscription;
  Timer? stepTimer;
  Timer? sessionTimer;

  String _status = "Stopped";
  int steps = 0;
  int todaySteps = 0;
  bool isWalking = false;
  bool isIntialized = false;
  bool ispermissionGranted = false;
  bool isLoading = false;

  final Random random = Random();
  DateTime? walkingStartTime;
  int currentWalkingSession = 0;
  double walkingPlace = 1.0;
  int consecutiveSteps = 0;

  double calories = 0;
  double distance = 0;
  int dailyGoal = 10000;

  final List<Map<String, dynamic>> _weeklyData = [];

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

  @override
  void dispose() {
    pedestrianSubscription?.cancel();
    stepTimer?.cancel();
    sessionTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    // Check and request permissions for pedometer
    // This is a placeholder; actual implementation may vary based on platform
    setState(() {
      isLoading = true;
    });
    final status = checkActivityPermission();
    debugPrint('Permission status: $status');
    setState(() {
      ispermissionGranted = status == PermissionStatus.granted;
    });
    if (ispermissionGranted) {
      await initializeApp();
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> initializeApp() async {
    await _loadDailyData();
    await _loadTodaySteps();
    pedestrianSubscription = await setupMovementDetection(_handleMovement);

    setState(() {
      isIntialized = true;
    });
  }

  void _handleMovement(String status) {
    setState(() {
      _status = status;
    });
    if (status == "walking" && !isWalking) {
      _startWalkingSession();
    } else if (status == "stopped" && isWalking) {
      _stopWalkingSession();
    }
  }

  void _startWalkingSession() {
    isWalking = true;
    walkingStartTime = DateTime.now();
    currentWalkingSession++;

    walkingPlace = 0.85 + (random.nextDouble() * 0.3);
    consecutiveSteps = 0;

    _startStepCounting();
  }

  void _stopWalkingSession() {
    isWalking = false;
    walkingStartTime = null;

    stepTimer?.cancel();
    sessionTimer?.cancel();
    stepTimer = null;
    sessionTimer = null;
  }

  void _startStepCounting() {
    stepTimer?.cancel();

    int baseInterval = (600 / walkingPlace).round();

    stepTimer = Timer.periodic(Duration(milliseconds: baseInterval), (timer) {
      if (!isWalking) {
        timer.cancel();
        return;
      }
      double stepChance = calculateStepProbability(consecutiveSteps, random);

      if (random.nextDouble() < stepChance) {
        setState(() {
          steps++;
          todaySteps++;
          consecutiveSteps++;

          _calculateMetrics();
        });
        _saveSteps();
      }

      if (consecutiveSteps >= 0 && consecutiveSteps % 20 == 0) {
        double adjustment = 0.95 + (random.nextDouble() * 0.1);
        walkingPlace = (walkingPlace * adjustment).clamp(0.7, 1.3);

        _startStepCounting();
      }
    });

    _startSessionPatterns();
  }

  void _startSessionPatterns() {
    sessionTimer = Timer.periodic(
      Duration(seconds: 15 + random.nextInt(30)),
      (timer) {
        if (!isWalking) {
          timer.cancel();
          return;
        }

        if (random.nextDouble() < 0.2) {
          stepTimer?.cancel();

          Timer(Duration(seconds: 1 + random.nextInt(3)), () {
            if (isWalking) {
              _startStepCounting();
            }
          });
        }
      },
    );
  }

  // calculate calories and distance
  void _calculateMetrics() {
    calories = calculateCalories(steps);
    distance = calculateDistance(steps);
  }

  Future<void> _loadTodaySteps() async {
    final prefs = await SharedPreferences.getInstance();
    final today = getDateKey();
    final lastDate = prefs.getString('lastDate') ?? '';

    if (lastDate == today) {
      setState(() {
        todaySteps = prefs.getInt('steps_$today') ?? 0;
        steps = todaySteps;
      });
    } else {
      setState(() {
        todaySteps = 0;
        steps = 0;
      });
      await prefs.setInt('steps_$today', 0);
      await prefs.setString('lastDate', today);
    }
    _calculateMetrics();
  }

  Future<void> _saveSteps() async {
    final prefs = await SharedPreferences.getInstance();
    final today = getDateKey();

    await prefs.setInt('steps_$today', steps);
    await prefs.setString('lastDate', today);
  }

  Future<void> _loadDailyData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      dailyGoal = prefs.getInt('dailyGoal') ?? 10000;
    });
    loadWeeklyData();
  }

  void _showGoalDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: dailyGoal.toString());
        return AlertDialog(
          title: const Text('Set Daily Step Goal'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Daily Step Goal',
              hintText: 'Enter your daily step goal',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newGoal = int.tryParse(controller.text) ?? 10000;

                setState(() {
                  dailyGoal = newGoal;
                });

                final prefs = await SharedPreferences.getInstance();
                await prefs.setInt('dailyGoal', newGoal);
                Navigator.pop(context);
              },
              child: const Text('Set Goal'),
            ),
          ],
        );
      },
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
    
    final progress = dailyGoal > 0 ? steps / dailyGoal : 0.0;

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
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Step Counter',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (ispermissionGranted)
                        IconButton(
                          icon: const Icon(Icons.settings),
                          onPressed: _showGoalDialog,
                        ),
                    ],
                  ),
                ),
                if (isLoading)
                  const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  )
                else if (!ispermissionGranted)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.directions_walk,
                        size: 100,
                        color: Colors.blue[300],
                      ),
                      Text(
                        'Permission Required',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      SizedBox(height: 15),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Please grant permission to access your step count.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: _checkPermissions,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                        ),
                        child: const Text(
                          'Grant Permission',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextButton(
                        onPressed: () async {
                          await openAppSettings();
                        },
                        child: Text(
                          "Open Settings",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                if (isIntialized &&
                    ispermissionGranted) //(_isIntialized && _ispermissionGranted)?
                  //Step Counter Card
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue[400]!, Colors.blue[600]!],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.5),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    height: 200,
                                    width: 200,
                                    child: CircularProgressIndicator(
                                      value: progress.clamp(0.0, 1.0),
                                      strokeWidth: 12,
                                      backgroundColor: Colors.white.withOpacity(
                                        0.3,
                                      ),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  //infos on the card
                                  Column(
                                    children: [
                                      Icon(
                                        size: 50,
                                        color: Colors.white,
                                        _status == "walking"
                                            ? Icons.directions_walk
                                            : Icons.accessibility_new,
                                      ),
                                      Text(
                                        '$steps',
                                        style: TextStyle(
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        " of $dailyGoal Steps",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              //Message Walking/Stopped within blue card
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      _status == "walking"
                                          ? Colors.green[400]
                                          : Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _status == "walking" ? "Walking" : "Stopped",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatCard(
                              icon: Icons.local_fire_department,
                              value: calories.toStringAsFixed(1),
                              unit: 'cal',
                              color: Colors.orange,
                            ),
                            _buildStatCard(
                              icon: Icons.straighten,
                              value: distance.toStringAsFixed(2),
                              unit: 'km',
                              color: Colors.purple,
                            ),
                            _buildStatCard(
                              icon: Icons.timer,
                              value: (steps * 0.008).toStringAsFixed(0),
                              unit: 'min',
                              color: Colors.teal,
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Weekly Activity",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children:
                                    _weeklyData.map((data) {
                                      final height = (data['steps'] /
                                              dailyGoal *
                                              100)
                                          .clamp(10.0, 100.0);

                                      final isToday =
                                          DateFormat('yyyy-MM-dd').format(
                                            DateTime.parse(data['date']),
                                          ) ==
                                          DateFormat(
                                            'yyyy-MM-dd',
                                          ).format(DateTime.now());

                                      return Column(
                                        children: [
                                          Container(
                                            width: 30,
                                            height: height.toDouble(),
                                            decoration: BoxDecoration(
                                              gradient:
                                                  isToday
                                                      ? LinearGradient(
                                                        colors: [
                                                          Colors.blue[400]!,
                                                          Colors.blue[600]!,
                                                        ],
                                                      )
                                                      : null,
                                              color:
                                                  !isToday
                                                      ? Colors.grey[300]
                                                      : null,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            data['day'],
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight:
                                                  isToday
                                                      ? FontWeight.bold
                                                      : null,
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ),
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

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      width: MediaQuery.of(context).size.width * 0.25,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(20),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          SizedBox(height: 10),
          Text(
            (value),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(unit, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
