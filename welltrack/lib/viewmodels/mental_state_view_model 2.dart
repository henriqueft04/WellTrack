import 'package:flutter/material.dart';
import 'package:welltrack/models/mental_state.dart';
import 'package:welltrack/services/mental_state_service.dart';

class MentalStateViewModel extends ChangeNotifier {

  final _service = MentalStateService();
  
  MentalState? _mentalState;
  bool _loading = false;

  MentalState? get mentalState => _mentalState;
  bool get isLoading => _loading;

  Future<void> loadMentalState(DateTime date) async {
    _loading = true;
    notifyListeners(); // notifies UI widgets
    _mentalState = await _service.getMentalStateForDate(date);
    _loading = false;
    notifyListeners();
  }

  Future<void> saveMentalState({
    required DateTime date,
    required double moodValue,
    required Set<String> emotions,
    required Set<String> impacts,
  }) async {
    await _service.saveMentalState(
      date: date,
      moodValue: moodValue,
      emotions: emotions,
      impacts: impacts,
    );
    await loadMentalState(date); // refresh after saving
  }

  void clear() {
    _mentalState = null;
    notifyListeners();
  }
}