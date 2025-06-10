import 'dart:async';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pedometer/pedometer.dart';

String getDateKey() {
  return DateFormat('yyyy-MM-dd').format(DateTime.now());
}

Future<void> saveSteps(int steps) async {
  final prefs = await SharedPreferences.getInstance();
  final today = getDateKey();
  await prefs.setInt('steps_$today', steps);
  await prefs.setString('lastDate', today);
}

Future<int> loadTodaySteps(Function(int) onStepsLoaded) async {
  final prefs = await SharedPreferences.getInstance();
  final today = getDateKey();
  final lastDate = prefs.getString('lastDate') ?? '';

  int steps = 0;

  if (lastDate == today) {
    steps = prefs.getInt('steps_$today') ?? 0;
  } else {
    await prefs.setInt('steps_$today', 0);
    await prefs.setString('lastDate', today);
  }

  onStepsLoaded(steps);
  return steps;
}

Future<List<Map<String, dynamic>>> loadWeeklyData() async {
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

  return weekData;
}

double calculateStepProbability(int consecutiveSteps, Random random) {
  double baseProbability = 0.92;

  if (consecutiveSteps < 5) {
    baseProbability += 0.8;
  }

  double randomVariation = 0.95 + (random.nextDouble() * 0.1);
  return (baseProbability * randomVariation).clamp(0.0, 1.0);
}

Future<PermissionStatus> checkActivityPermission() async {
  return await Permission.activityRecognition.request();
}

double calculateCalories(int steps) {
  return steps * 0.04;
}

double calculateDistance(int steps) {
  return (steps * 0.762) / 1000;
}

Future<StreamSubscription<PedestrianStatus>> setupMovementDetection(
  void Function(String status) onStatusChange,
) async {
  try {
    return Pedometer.pedestrianStatusStream.listen(
      (PedestrianStatus event) {
        onStatusChange(event.status);
      },
      onError: (error) {
        print("Error in pedometer stream: $error");
      },
    );
  } catch (e) {
    print("Error setting up movement detection: $e");
    rethrow;
  }
}
