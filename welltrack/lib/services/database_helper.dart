import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final _databaseName = "WellTrack.db";
  static final _databaseVersion = 4;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    return _database ??= await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE mental_states (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        state REAL NOT NULL,
        date TEXT NOT NULL,
        emotions TEXT,
        factors TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE journal_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        text_content TEXT,
        photo_path TEXT,
        audio_path TEXT,
        caption TEXT,
        transcription TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migrate state column from TEXT to REAL
      // This is a simplified migration. A more robust migration might involve
      // preserving data if possible or handling potential errors.
      await db.execute('''
        ALTER TABLE mental_states
        ADD COLUMN state_new REAL;
      ''');
      await db.execute('''
        UPDATE mental_states
        SET state_new = CAST(state AS REAL)
        WHERE state IS NOT NULL;
      ''');
      await db.execute('''
        CREATE TEMPORARY TABLE mental_states_backup (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          state REAL NOT NULL,
          date TEXT NOT NULL,
          emotions TEXT,
          factors TEXT
        );
      ''');
      await db.execute('''
        INSERT INTO mental_states_backup (id, state, date, emotions, factors)
        SELECT id, state_new, date, emotions, factors FROM mental_states;
      ''');
      await db.execute('DROP TABLE mental_states;');
      await db.execute('ALTER TABLE mental_states_backup RENAME TO mental_states;');
    }
    
    if (oldVersion < 3) {
      // Add journal_entries table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS journal_entries (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER,
          date TEXT NOT NULL,
          type TEXT NOT NULL,
          text_content TEXT,
          photo_path TEXT,
          audio_path TEXT,
          caption TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT
        )
      ''');
    }
    
    if (oldVersion < 4) {
      // Add transcription column to journal_entries
      await db.execute('''
        ALTER TABLE journal_entries ADD COLUMN transcription TEXT
      ''');
    }
  }

  Future<int> insertMentalState(Map<String, dynamic> row) async {
    final db = await database;
    if (row.containsKey('id') && row['id'] == 0) {
      row.remove('id');
    }
    return await db.insert('mental_states', row);
  }

  Future<List<Map<String, dynamic>>> queryAllMentalStates() async {
    final db = await database;
    return await db.query('mental_states');
  }

  Future<int> deleteMentalState(int id) async {
    final db = await database;
    return await db.delete('mental_states', where: 'id = ?', whereArgs: [id]);
  }

  // Journal Entry methods
  Future<int> insertJournalEntry(Map<String, dynamic> row) async {
    final db = await database;
    if (row.containsKey('id') && row['id'] == null) {
      row.remove('id');
    }
    return await db.insert('journal_entries', row);
  }

  Future<List<Map<String, dynamic>>> queryJournalEntriesByDate(DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];
    return await db.query(
      'journal_entries',
      where: "date(date) = date(?)",
      whereArgs: [dateStr],
      orderBy: 'created_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> queryAllJournalEntries() async {
    final db = await database;
    return await db.query('journal_entries', orderBy: 'created_at DESC');
  }

  Future<Map<String, dynamic>?> queryJournalEntry(int id) async {
    final db = await database;
    final results = await db.query('journal_entries', where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateJournalEntry(Map<String, dynamic> row) async {
    final db = await database;
    final id = row['id'];
    return await db.update('journal_entries', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteJournalEntry(int id) async {
    final db = await database;
    return await db.delete('journal_entries', where: 'id = ?', whereArgs: [id]);
  }
}