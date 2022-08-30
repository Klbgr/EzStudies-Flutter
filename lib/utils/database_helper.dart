import 'package:sqflite/sqflite.dart';

import '../agenda/agenda_cell_data.dart';

class DatabaseHelper {
  static const String agenda = "agenda";
  static const String backup = "backup";

  late Database database;

  Future<void> open() async {
    database = await openDatabase("database.db", version: 1,
        onCreate: (db, version) async {
      await _createTables(db);
    }, onUpgrade: (db, oldVersion, newVersion) async {
      await _createTables(db);
    });
  }

  Future<void> _createTables(Database db) async {
    await db.execute(
        "CREATE TABLE IF NOT EXISTS $agenda(id TEXT PRIMARY KEY, description TEXT, start INTEGER, end INTEGER, added INTEGER, edited INTEGER, trashed INTEGER)");
    await db.execute(
        "CREATE TABLE IF NOT EXISTS $backup(id TEXT PRIMARY KEY, description TEXT, start INTEGER, end INTEGER, added INTEGER, edited INTEGER, trashed INTEGER)");
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

  Future<void> deleteAll() async {
    await database.delete(agenda);
    await database.delete(backup);
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
        description: maps[i]["description"],
        start: maps[i]["start"],
        end: maps[i]["end"],
        added: maps[i]["added"],
        edited: maps[i]["edited"],
        trashed: maps[i]["trashed"],
      );
    });
  }

  Future<void> insertAll(List<AgendaCellData> data) async {
    List<AgendaCellData> list = await get(agenda);
    list.removeWhere((element) =>
        element.added == 0 && element.edited == 0 && element.trashed == 0);
    await database.delete(agenda, where: "added = 0");
    await database.delete(backup);
    for (AgendaCellData d in data) {
      for (AgendaCellData l in list) {
        if (d.id == l.id) {
          if (l.edited == 1) {
            await insertOrReplace(backup, d);
            d = l;
          } else if (l.trashed == 1) {
            d.trashed = 1;
          }
          list.remove(l);
          break;
        }
      }
      await insert(agenda, d);
    }
  }
}
