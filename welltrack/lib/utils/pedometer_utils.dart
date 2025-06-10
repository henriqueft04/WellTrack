import 'dart:async';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

double calculateStepProbability(int consecutiveSteps, Random random) {
  double baseProbability = 0.92;

  if (consecutiveSteps < 5) {
    baseProbability += 0.8;
  }

  double randomVariation = 0.95 + (random.nextDouble() * 0.1);
  return (baseProbability * randomVariation).clamp(0.0, 1.0);
}

double calculateCalories(int steps) {
  return steps * 0.04;
}

double calculateDistance(int steps) {
  return (steps * 0.762) / 1000;
}


