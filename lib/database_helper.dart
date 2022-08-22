import 'package:sqflite/sqflite.dart';

import 'agenda/agenda_cell_data.dart';

class DatabaseHelper {
  static const String agenda = "agenda";
  static const String backup = "backup";

  late Database database;

  Future<void> open() async {
    database = await openDatabase("database.db", version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
          "CREATE TABLE $agenda(id TEXT PRIMARY KEY, title TEXT, description TEXT, start INTEGER, end INTEGER, added INTEGER, edited INTEGER, trashed INTEGER)");
      await db.execute(
          "CREATE TABLE $backup(id TEXT PRIMARY KEY, title TEXT, description TEXT, start INTEGER, end INTEGER, added INTEGER, edited INTEGER, trashed INTEGER)");
    });
  }

  Future<bool> insert(String table, AgendaCellData data) async {
    try {
      await database.insert(table, data.toMap(),
          conflictAlgorithm: ConflictAlgorithm.abort);
    } catch (_) {
      return false;
    }
    return true;
  }

  Future<bool> insertOrReplace(String table, AgendaCellData data) async {
    try {
      await database.insert(table, data.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (_) {
      return false;
    }
    return true;
  }

  Future<int> delete(String table, AgendaCellData data) async {
    return await database.delete(table, where: "id = ?", whereArgs: [data.id]);
  }

  Future<void> reset() async {
    await database
        .delete(agenda, where: "added = 1")
        .then((value) async => await get(backup).then((value) async {
              for (int i = 0; i < value.length; i++) {
                await delete(backup, value[i]);
                await insertOrReplace(agenda, value[i]);
              }
              await database.update(agenda, Map.of({"trashed": 0}),
                  where: "trashed = 1");
            }));
  }

  Future<void> close() async {
    await database.close();
  }

  Future<List<AgendaCellData>> getById(String table, String id) async {
    final List<Map<String, dynamic>> maps =
        await database.query(table, where: 'id = ?', whereArgs: [id]);
    return List.generate(maps.length, (i) {
      return AgendaCellData(
        id: maps[i]["id"],
        title: maps[i]["title"],
        description: maps[i]["description"],
        start: maps[i]["start"],
        end: maps[i]["end"],
        added: maps[i]["added"],
        edited: maps[i]["edited"],
        trashed: maps[i]["trashed"],
      );
    });
  }

  Future<List<AgendaCellData>> get(String table) async {
    final List<Map<String, dynamic>> maps =
        await database.query(table, orderBy: "start");
    return List.generate(maps.length, (i) {
      return AgendaCellData(
        id: maps[i]["id"],
        title: maps[i]["title"],
        description: maps[i]["description"],
        start: maps[i]["start"],
        end: maps[i]["end"],
        added: maps[i]["added"],
        edited: maps[i]["edited"],
        trashed: maps[i]["trashed"],
      );
    });
  }
}
