import 'package:welltrack/services/database_helper.dart';

import '../models/mental_state.dart';

class MentalStateService {
  final _db = DatabaseHelper.instance;

  Future<void> saveMentalState({
    required DateTime date,
    required double moodValue,
    required Set<String> emotions,
    required Set<String> impacts,
  }) async {
    final entry = MentalState(
      id: 0,
      state: moodValue,
      date: date,
      emotions: emotions,
      factors: impacts,
    );

    await _db.insertMentalState(entry.toMap());
  }

  Future<List<MentalState>> getMentalStatesForDate(DateTime date) async {
    final results = await _db.queryAllMentalStates();
    final filtered = results.where((row) {
      // Compare dates ignoring time
      final rowDate = DateTime.parse(row['date']).toLocal();
      return rowDate.year == date.year &&
             rowDate.month == date.month &&
             rowDate.day == date.day;
    }).toList(); // Convert filtered results to a list

    return filtered.map((row) => MentalState.fromMap(row)).toList();
  }

  Future<List<MentalState>> getAllMentalStates() async {
    final results = await _db.queryAllMentalStates();
    return results.map((row) => MentalState.fromMap(row)).toList();
  }

  Future<void> deleteMentalState(int id) async {
    await _db.deleteMentalState(id);
  }
}