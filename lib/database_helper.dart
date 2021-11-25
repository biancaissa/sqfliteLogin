import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  final _databaseName = "ExemploDB.db";
  final _databaseVersion = 1;
  final table = 'user';
  final columnId = '_id';
  final columnName = 'name';
  final columnPassword = 'password';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnName TEXT NOT NULL,
            $columnPassword TEXT NOT NULL
          )
          ''');
    await db.execute('''
          INSERT INTO $table (
            $columnName,
            $columnPassword
          ) VALUES (
            'admin',
            'admin'
          )
          ''');
  }

  Future<int> login(String name, String password) async {
    var db = await database;
    var count = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(1) FROM $table WHERE $columnName = ? AND $columnPassword = ?',
        [name, password]));
    return count ?? 0;
  }
}
