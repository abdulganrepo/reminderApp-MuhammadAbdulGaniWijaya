import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ReminderService {
  late Database database;
  Future<Database> myDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'reminder.db');

    database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
          'CREATE TABLE reminder_tb (id INTEGER PRIMARY KEY, name VARCHAT, description VARCHAR, time VARCHAR)');
    });

    // await deleteDatabase(path);

    return database;
  }

  getAllData() async {
    final db = await myDatabase();
    final rows = await db.rawQuery('SELECT * FROM reminder_tb');
    return rows;
  }

  insertData(String name, String description, String time) async {
    await database.insert(
      'reminder_tb',
      {
        'id': null,
        'name': name,
        'description': description,
        'time': time,
      },
    );
  }

  deleteData(int id) async {
    await database.delete(
      'reminder_tb',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

class HomeDataModel {
  int id;
  String name;
  String description;
  String time;

  HomeDataModel({
    required this.id,
    required this.name,
    required this.description,
    required this.time,
  });
}

class ManageDataModel {
  int id;
  String name;
  String description;
  String time;

  ManageDataModel({
    required this.id,
    required this.name,
    required this.description,
    required this.time,
  });
}
