import 'dart:io';
import 'package:welltrack/models/journal_entry.dart';
import 'package:welltrack/services/database_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class JournalService {
  final _db = DatabaseHelper.instance;

  Future<int> createJournalEntry(JournalEntry entry) async {
    return await _db.insertJournalEntry(entry.toMap());
  }

  Future<List<JournalEntry>> getJournalEntriesForDate(DateTime date) async {
    final results = await _db.queryJournalEntriesByDate(date);
    return results.map((row) => JournalEntry.fromMap(row)).toList();
  }

  Future<List<JournalEntry>> getAllJournalEntries() async {
    final results = await _db.queryAllJournalEntries();
    return results.map((row) => JournalEntry.fromMap(row)).toList();
  }

  Future<JournalEntry?> getJournalEntry(int id) async {
    final result = await _db.queryJournalEntry(id);
    return result != null ? JournalEntry.fromMap(result) : null;
  }

  Future<int> updateJournalEntry(JournalEntry entry) async {
    if (entry.id == null) {
      throw ArgumentError('Journal entry must have an ID to be updated');
    }
    
    final updatedEntry = entry.copyWith(
      updatedAt: DateTime.now(),
    );
    
    return await _db.updateJournalEntry(updatedEntry.toMap());
  }

  Future<int> deleteJournalEntry(int id) async {
    // Also delete associated files if they exist
    final entry = await getJournalEntry(id);
    if (entry != null) {
      if (entry.photoPath != null) {
        await _deleteFile(entry.photoPath!);
      }
      if (entry.audioPath != null) {
        await _deleteFile(entry.audioPath!);
      }
    }
    
    return await _db.deleteJournalEntry(id);
  }

  Future<void> _deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Log error but don't throw - file might already be deleted
      print('Error deleting file: $e');
    }
  }

  Future<String> savePhotoFile(File photo) async {
    final appDir = await getApplicationDocumentsDirectory();
    final journalDir = Directory(path.join(appDir.path, 'journal_photos'));
    
    if (!await journalDir.exists()) {
      await journalDir.create(recursive: true);
    }
    
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(photo.path)}';
    final savedPath = path.join(journalDir.path, fileName);
    
    await photo.copy(savedPath);
    return savedPath;
  }

  Future<String> saveAudioFile(String audioPath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final journalDir = Directory(path.join(appDir.path, 'journal_audio'));
    
    if (!await journalDir.exists()) {
      await journalDir.create(recursive: true);
    }
    
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.m4a';
    final savedPath = path.join(journalDir.path, fileName);
    
    await File(audioPath).copy(savedPath);
    return savedPath;
  }

  Future<Map<JournalType, int>> getJournalStats() async {
    final entries = await getAllJournalEntries();
    final stats = <JournalType, int>{};
    
    for (final type in JournalType.values) {
      stats[type] = entries.where((e) => e.type == type).length;
    }
    
    return stats;
  }

  Future<List<JournalEntry>> getJournalEntriesInRange(DateTime start, DateTime end) async {
    final entries = await getAllJournalEntries();
    return entries.where((entry) {
      return entry.date.isAfter(start.subtract(const Duration(days: 1))) &&
             entry.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }
}