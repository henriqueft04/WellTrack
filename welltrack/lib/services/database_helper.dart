import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final _databaseName = "WellTrack.db";
  static final _databaseVersion = 1;

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
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE mental_states (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        state TEXT NOT NULL,
        date TEXT NOT NULL,
        emotions TEXT,
        factors TEXT
      )
    ''');
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
}