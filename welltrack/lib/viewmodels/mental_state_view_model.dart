import 'package:flutter/material.dart';
import 'package:welltrack/models/mental_state.dart';
import 'package:welltrack/services/mental_state_service.dart';

class MentalStateViewModel extends ChangeNotifier {

  final _service = MentalStateService();
  
  MentalState? _mentalState;
  List<MentalState> _allMentalStates = [];
  List<MentalState> _dailyMentalStates = [];
  bool _loading = false;

  MentalState? get mentalState => _mentalState;
  List<MentalState> get allMentalStates => _allMentalStates;
  List<MentalState> get dailyMentalStates => _dailyMentalStates;
  bool get isLoading => _loading;

  Future<void> loadMentalState(DateTime date) async {
    _loading = true;
    notifyListeners();
    // This method now fetches all states for the day, but we only need one for the form.
    // We might need to refine this if we want to support multiple entries per day.
    final statesForDate = await _service.getMentalStatesForDate(date);
    _mentalState = statesForDate.isNotEmpty ? statesForDate.first : null;
    _loading = false;
    notifyListeners();
  }

  Future<void> loadAllMentalStates() async {
    _loading = true;
    notifyListeners();
    _allMentalStates = await _service.getAllMentalStates();
    _loading = false;
    notifyListeners();
  }

  Future<void> loadDailyMentalStates(DateTime date) async {
    _loading = true;
    notifyListeners();
    _dailyMentalStates = await _service.getMentalStatesForDate(date);
    _loading = false;
    notifyListeners();
  }

  Future<void> saveMentalState({
    required DateTime date,
    required double moodValue,
    required Set<String> emotions,
    required Set<String> impacts,
  }) async {
    _loading = true; // Indicate loading while saving
    notifyListeners();
    await _service.saveMentalState(
      date: date,
      moodValue: moodValue,
      emotions: emotions,
      impacts: impacts,
    );
    await loadMentalState(date); // refresh after saving
    await loadAllMentalStates(); // refresh the history list
    await loadDailyMentalStates(date); // refresh the daily list
    _loading = false; // End loading after saving
    notifyListeners();
  }

  void clear() {
    _mentalState = null;
    _allMentalStates = [];
    _dailyMentalStates = [];
    notifyListeners();
  }
}