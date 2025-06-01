import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:welltrack/pages/journal_page.dart';
import 'package:welltrack/pages/stats_page.dart';
import 'package:welltrack/pages/calendar_page.dart';
import 'package:welltrack/pages/profile_page.dart';
import 'package:welltrack/pages/mental_state_page.dart';
import '../components/bottom_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //To Pedometer
  StreamSubscription<PedestrianStatus>? _pedestrianSubscription;
  Timer? _stepTimer;
  Timer? _sessionTimer;

  String _status = "Stopped";
  int _steps = 0;
  int _todaySteps = 0;
  bool _isWalking = false;
  bool _isIntialized = false;
  bool _ispermissionGranted = false;
  bool _isLoading = false;

  Random _random = Random();
  DateTime? _walkingStartTime;
  int _currentWalkingSession = 0;
  double _walkingPlace = 1.0;
  int _consecutiveSteps = 0;

  double _calories = 0;
  double _distance = 0;
  int _dailyGoal = 10000;

  List<Map<String, dynamic>> _weeklyData = [];

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _pedestrianSubscription?.cancel();
    _stepTimer?.cancel();
    _sessionTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    // Check and request permissions for pedometer
    // This is a placeholder; actual implementation may vary based on platform
    setState(() {
      _isLoading = true;
    });
    final status = await Permission.activityRecognition.request();
    setState(() {
      _ispermissionGranted = status == PermissionStatus.granted;
    });
    if (_ispermissionGranted) {
      await initializeApp();
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> initializeApp() async {
    await _loadDailyData();
    await _loadTodaySteps();
    await _setupMovementDetection();

    setState(() {
      _isIntialized = true;
    });
  }

  Future<void> _setupMovementDetection() async {
    try{
    _pedestrianSubscription = Pedometer.pedestrianStatusStream.listen(
      (PedestrianStatus event) {
        _handleMovement(event.status);
      },
      onError: (error) {
        print("Error in pedometer stream: $error");
      },
    );

    }catch (e){
      print("Error setting up movement detection: $e");
    }
  }

  void _handleMovement(String status) {
    setState(() {
      _status = status;
    });
    if (status == "walking" && !_isWalking) {
      _startWalkingSession();
    } else if (status == "stopped" && _isWalking) {
      _stopWalkingSession();
    }
  }

  void _startWalkingSession() {
    _isWalking = true;
    _walkingStartTime = DateTime.now();
    _currentWalkingSession++;

    _walkingPlace = 0.85 + (_random.nextDouble() * 0.3);
    _consecutiveSteps = 0;

    _startStepCountting();
  }

  void _stopWalkingSession() {
    _isWalking = false;
    _walkingStartTime = null;

    _stepTimer?.cancel();
    _sessionTimer?.cancel();
    _stepTimer = null;
    _sessionTimer = null;
  }

  void _startStepCountting() {
    _stepTimer?.cancel();

    int baseInterval = (600/ _walkingPlace).round();

    _stepTimer = Timer.periodic(Duration(milliseconds: baseInterval), (timer){
      if (!_isWalking) {
        timer.cancel();
        return;
      }
      double StepChance = _calculateStepProbability();

      if (_random.nextDouble() < StepChance) {
        setState(() {
        _steps++;
        _todaySteps++;
        _consecutiveSteps++;

        _calculateMetrics();
        });
        _saveSteps();
      } 

      if (_consecutiveSteps >= 0 && _consecutiveSteps % 20 == 0) {
        double adjustment = 0.95 + (_random.nextDouble() * 0.1);
        _walkingPlace = (_walkingPlace * adjustment).clamp(0.7, 1.3);

        _startStepCountting();
      }
      });

      _startSessionPatterns();
  }

  double _calculateStepProbability() {
    double baseProbability = 0.92;

    if(_consecutiveSteps < 5){
      baseProbability += 0.8;
    }

    double randomVariation = 0.95 + (_random.nextDouble() * 0.1);
    return (baseProbability * randomVariation).clamp(0.0, 1.0);
  }  

  void _startSessionPatterns() {
    _sessionTimer = Timer.periodic(Duration(seconds: 15 + _random.nextInt(30)),
    (timer){
      if (!_isWalking) {
        timer.cancel();
        return;
      }

      if(_random.nextDouble() < 0.2) {
        _stepTimer?.cancel();

        Timer(Duration(seconds: 1 + _random.nextInt(3)), () {
          if (_isWalking) {
            _startStepCountting();
          }
        });
      }

    });
  }

  // calculate metrics like calories and distance
  void _calculateMetrics() {
    _calories = _steps * 0.04;
    _distance = (_steps * 0.762) / 1000;
  }

  String _getDateKey(){
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Future<void> _loadTodaySteps() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getDateKey();
    final _lastDate = prefs.getString('lastDate') ?? '';

    if (_lastDate == today){
      setState(() {
        _todaySteps = prefs.getInt('steps_$today') ?? 0;
        _steps = _todaySteps;
      });
    } else {
      setState(() {
        _todaySteps = 0;
        _steps = 0;
      });
      await prefs.setInt('steps_$today', 0);
      await prefs.setString('lastDate', today);
    }
    _calculateMetrics();
  }

  Future<void>  _saveSteps() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getDateKey();

    await prefs.setInt('steps_$today', _steps);
    await prefs.setString('lastDate', today);
  }

  Future<void> _loadDailyData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyGoal = prefs.getInt('dailyGoal') ?? 10000;
    });
    _loadWeeklyData();
  }

  Future<void> _loadWeeklyData() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> weekData = [];

    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final steps = prefs.getInt('steps_$dateStr') ?? 0;

      weekData.add({
        'date': dateStr,
        'steps': steps,
        'day': DateFormat('E').format(date),
      });
      
    }
    setState(() {
      _weeklyData = weekData;
    });
  }

  void _showGoalDialog() {
    showDialog(context: context, builder: (context){
      final controller = TextEditingController(text: _dailyGoal.toString());
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
                  _dailyGoal = newGoal;
                });

                final prefs = await SharedPreferences.getInstance();
                await prefs.setInt('dailyGoal', newGoal);
                Navigator.pop(context);
                
            },
            child: const Text('Set Goal'),
          ),
        ],
      );
    });
  
  }


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
    final progress = _dailyGoal > 0 ? _steps / _dailyGoal : 0.0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        // Show confirmation dialog before exiting app
        final shouldExit = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
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
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Logo at top
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Image.asset('lib/images/martim.png', height: 50),
                ),

                // Mood Slider
                // Replace the existing Slider with this SliderTheme to match the mockup:
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                            color:
                                isSelected
                                    ? Colors.blue[100]
                                    : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                weekDays[index],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isSelected ? Colors.blue : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dates[index].toString(),
                                style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      isSelected ? Colors.blue : Colors.black,
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
                // Cards for Mental State and Stats
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,

                            children: const [
                              SizedBox(width: 16),
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
                              builder:
                                  (context) => const StatsPage(
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
                          child: Row(
                            children: const [
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: const [
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
                        children: const [
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
                        children: const [
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
        bottomNavigationBar: MyBottomNavBar(
          onTabChange: (index) => navigateBottomBar(index),
        ),
      ),
    );
  }
}
