class MentalState{
  final int id;
  final double state;
  final DateTime date;
  final Set<String>? emotions;
  final Set<String>? factors;

  const MentalState({
    required this.id,
    required this.state,
    required this.date,
    this.emotions,
    this.factors,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'state': state,
      'date': date.toIso8601String(),
      'emotions': emotions?.join(','),
      'factors': factors?.join(','),
    };
  }

  @override
  String toString() {
    return 'MentalState{id: $id, state: $state, date: $date, emotions: $emotions, factors: $factors}';
  }

  factory MentalState.fromMap(Map<String, dynamic> map) {
    return MentalState(
      id: map['id'],
      state: map['state'].toDouble(),
      date: DateTime.parse(map['date']),
      emotions: map['emotions'] != null
          ? Set<String>.from(map['emotions'].split(',').map((e) => e.trim()))
          : {},
      factors: map['factors'] != null
          ? Set<String>.from(map['factors'].split(',').map((e) => e.trim()))
          : {},
    );
  }

  static double _convertStateToDouble(String state) {
    switch (state.toLowerCase()) {
      case 'unpleasant':
        return 0.0;
      case 'neutral':
        return 1.0;
      case 'pleasant':
        return 2.0;
      default:
        return 1.0; // Default to neutral
    }
  }
}