import 'package:flutter/material.dart';

class UserStatsProvider extends ChangeNotifier {
  int dailyGoal = 10000;
  int steps = 0;
  double calories = 0.0;
  double distance = 0.0;

  void updateSteps(int value) {
    steps = value;
    notifyListeners();
  }

  void updateCalories(double value) {
    calories = value;
    notifyListeners();
  }

  void updateDistance(double value) {
    distance = value;
    notifyListeners();
  }

  void setDailyGoal(int goal) {
    dailyGoal = goal;
    notifyListeners();
  }
}
