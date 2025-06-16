import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class DatabaseUtil {
  static Database? _db;

  static Future<void> init() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    String dbPath = join(await getDatabasesPath(), 'zoocare.sqlite');
    _db = await databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE animals (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT,
              species TEXT
            )
          ''');
          await db.execute('''
            CREATE TABLE tasks (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              animal_id INTEGER,
              description TEXT,
              done INTEGER DEFAULT 0,
              FOREIGN KEY (animal_id) REFERENCES animals(id) ON DELETE CASCADE
            )
          ''');
        },
      ),
    );
  }

  static Database get _database {
    if (_db == null) {
      throw Exception("Database not initialized. Call init() first.");
    }
    return _db!;
  }

  // Animal operations
  static Future<List<Map<String, dynamic>>> getAllEntries() async {
    return await _database.query('animals');
  }

  static Future<Map<String, dynamic>> insertOrUpdateEntry(
    Map<String, dynamic> animal,
  ) async {
    int id;
    if (animal.containsKey('id')) {
      id = await _database.insert(
        'animals',
        animal,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      id = await _database.insert('animals', {
        'name': animal['name'],
        'species': animal['species'],
      });
    }
    animal['id'] = id;
    return animal;
  }

  static Future<void> deleteEntry(Map<String, dynamic> animal) async {
    await _database.delete(
      'animals',
      where: 'id = ?',
      whereArgs: [animal['id']],
    );
  }

  // Task operations
  static Future<List<Map<String, dynamic>>> getTasks(int animalId) async {
    return await _database.query(
      'tasks',
      where: 'animal_id = ?',
      whereArgs: [animalId],
    );
  }

  static Future<int> insertTask(Map<String, dynamic> task) async {
    return await _database.insert('tasks', task);
  }

  static Future<int> updateTask(Map<String, dynamic> task) async {
    return await _database.update(
      'tasks',
      task,
      where: 'id = ?',
      whereArgs: [task['id']],
    );
  }

  static Future<void> deleteTask(int taskId) async {
    await _database.delete('tasks', where: 'id = ?', whereArgs: [taskId]);
  }
}
