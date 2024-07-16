import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'todo.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute(
      '''
      CREATE TABLE todos (
        id INTEGER PRIMARY KEY,
        title TEXT,
        description TEXT
      )
      '''
    );
  }
Future<int> insert(Map<String, dynamic> row) async {
    final db = await database;
    return db.insert('todos', row);
  }

  Future<List<Map<String, dynamic>>> queryAll() async {
    final db = await database;
    return db.query('todos');
  }

  Future<int> update(Map<String, dynamic> row) async {
    final db = await database;
    int id = row['id'];
    return db.update('todos', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    final db = await database;
    return db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }
}
