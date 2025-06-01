import 'package:injectable/injectable.dart';

// Model for mental state data
class MentalStateData {
  final DateTime date;
  final double moodValue;
  final Set<String> emotions;
  final Set<String> impacts;

  MentalStateData({
    required this.date,
    required this.moodValue,
    required this.emotions,
    required this.impacts,
  });
}

// Abstract interface for data repository
abstract class MentalStateRepository {
  Future<void> saveMentalState(MentalStateData data);
  Future<List<MentalStateData>> getMentalStates();
  Future<MentalStateData?> getMentalStateByDate(DateTime date);
}

// Concrete implementation using local storage
@Injectable(as: MentalStateRepository)
class LocalMentalStateRepository implements MentalStateRepository {
  // In a real app, this would use SQLite, SharedPreferences, etc.
  final List<MentalStateData> _localData = [];

  @override
  Future<void> saveMentalState(MentalStateData data) async {
    // Remove existing data for the same date
    _localData.removeWhere((item) => 
        item.date.year == data.date.year &&
        item.date.month == data.date.month &&
        item.date.day == data.date.day);
    
    // Add new data
    _localData.add(data);
  }

  @override
  Future<List<MentalStateData>> getMentalStates() async {
    return List.from(_localData);
  }

  @override
  Future<MentalStateData?> getMentalStateByDate(DateTime date) async {
    try {
      return _localData.firstWhere((item) => 
          item.date.year == date.year &&
          item.date.month == date.month &&
          item.date.day == date.day);
    } catch (e) {
      return null;
    }
  }
}

// Service that uses the repository
@Injectable()
class MentalStateService {
  final MentalStateRepository _repository;

  // Dependency injection through constructor
  MentalStateService(this._repository);

  Future<void> saveMentalState({
    required DateTime date,
    required double moodValue,
    required Set<String> emotions,
    required Set<String> impacts,
  }) async {
    final data = MentalStateData(
      date: date,
      moodValue: moodValue,
      emotions: emotions,
      impacts: impacts,
    );
    
    await _repository.saveMentalState(data);
  }

  Future<List<MentalStateData>> getAllMentalStates() async {
    return await _repository.getMentalStates();
  }

  Future<MentalStateData?> getMentalStateForDate(DateTime date) async {
    return await _repository.getMentalStateByDate(date);
  }

  Future<double> getAverageMoodForWeek(DateTime weekStart) async {
    final states = await _repository.getMentalStates();
    final weekStates = states.where((state) {
      final difference = state.date.difference(weekStart).inDays;
      return difference >= 0 && difference < 7;
    }).toList();

    if (weekStates.isEmpty) return 1.0; // neutral

    final sum = weekStates.map((s) => s.moodValue).reduce((a, b) => a + b);
    return sum / weekStates.length;
  }
} 