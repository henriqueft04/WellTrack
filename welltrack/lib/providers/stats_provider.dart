import 'package:flutter/material.dart';
import '../notifications/noti_service.dart'; // adapta o caminho consoante a tua estrutura

class UserStatsProvider extends ChangeNotifier {
  int dailyGoal = 10000;
  int steps = 0;
  double calories = 0.0;
  double distance = 0.0;

  bool _hasNotified = false;

  void updateSteps(int value) {
    steps = value;
    _checkStepGoal();
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
    _hasNotified = false; // Permitir nova notificação
    _checkStepGoal();     
    notifyListeners();
  }


  void resetDailyStats() {
    steps = 0;
    calories = 0;
    distance = 0;
    _hasNotified = false;
    notifyListeners();
  }

  void _checkStepGoal() {
    if (steps >= dailyGoal && !_hasNotified) {
      NotiService().showNotification(
        title: '🎉 Step Goal Reached!',
        body: 'You have reached your daily step goal! Great job! 💪',
      );
      _hasNotified = true;
    } else if (steps < dailyGoal) {
      _hasNotified = false; // Reset notification flag if goal not reached
    }
  }
}
