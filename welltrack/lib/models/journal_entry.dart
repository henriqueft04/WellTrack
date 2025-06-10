import 'dart:convert';

enum JournalType { text, photo, audio }

class JournalEntry {
  final int? id;
  final int? userId;
  final DateTime date;
  final JournalType type;
  final String? textContent;
  final String? photoPath;
  final String? audioPath;
  final String? caption;
  final DateTime createdAt;
  final DateTime? updatedAt;

  JournalEntry({
    this.id,
    this.userId,
    required this.date,
    required this.type,
    this.textContent,
    this.photoPath,
    this.audioPath,
    this.caption,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String(),
      'type': type.toString().split('.').last,
      'text_content': textContent,
      'photo_path': photoPath,
      'audio_path': audioPath,
      'caption': caption,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'],
      userId: map['user_id'],
      date: DateTime.parse(map['date']),
      type: JournalType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
      ),
      textContent: map['text_content'],
      photoPath: map['photo_path'],
      audioPath: map['audio_path'],
      caption: map['caption'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory JournalEntry.fromJson(String source) => JournalEntry.fromMap(json.decode(source));

  JournalEntry copyWith({
    int? id,
    int? userId,
    DateTime? date,
    JournalType? type,
    String? textContent,
    String? photoPath,
    String? audioPath,
    String? caption,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      type: type ?? this.type,
      textContent: textContent ?? this.textContent,
      photoPath: photoPath ?? this.photoPath,
      audioPath: audioPath ?? this.audioPath,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}