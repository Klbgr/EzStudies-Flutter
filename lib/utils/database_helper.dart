import 'package:ezstudies/homeworks/homeworks_cell_data.dart';
import 'package:ezstudies/utils/preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../agenda/agenda_cell_data.dart';

class DatabaseHelper {
  static const String agenda = "agenda";
  static const String backup = "backup";
  static const String homeworks = "homeworks";

  late Database database;

  Future<void> open() async {
    database = await openDatabase("database.db",
        version: int.parse(Preferences.packageInfo.buildNumber),
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
    await db.execute(
        "CREATE TABLE IF NOT EXISTS $homeworks(id TEXT PRIMARY KEY, description TEXT, date INTEGER, done INTEGER)");
  }

  Future<bool> insertAgenda(String table, AgendaCellData data) async {
    try {
      await database.insert(table, data.toMap(),
          conflictAlgorithm: ConflictAlgorithm.abort);
    } catch (_) {
      return false;
    }
    return true;
  }

  Future<bool> insertHomeworks(HomeworksCellData data) async {
    try {
      await database.insert(homeworks, data.toMap(),
          conflictAlgorithm: ConflictAlgorithm.abort);
    } catch (_) {
      return false;
    }
    return true;
  }

  Future<bool> insertOrReplaceAgenda(String table, AgendaCellData data) async {
    try {
      await database.insert(table, data.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (_) {
      return false;
    }
    return true;
  }

  Future<bool> insertOrReplaceHomeworks(HomeworksCellData data) async {
    try {
      await database.insert(homeworks, data.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (_) {
      return false;
    }
    return true;
  }

  Future<int> deleteAgenda(String table, AgendaCellData data) async {
    return await database.delete(table, where: "id = ?", whereArgs: [data.id]);
  }

  Future<int> deleteHomeworks(HomeworksCellData data) async {
    return await database
        .delete(homeworks, where: "id = ?", whereArgs: [data.id]);
  }

  Future<void> reset() async {
    await database
        .delete(agenda, where: "added = 1")
        .then((value) async => await getAgenda(backup).then((value) async {
              for (int i = 0; i < value.length; i++) {
                await deleteAgenda(backup, value[i]);
                await insertOrReplaceAgenda(agenda, value[i]);
              }
              await database.update(agenda, Map.of({"trashed": 0}),
                  where: "trashed = 1");
            }));
  }

  Future<void> deleteAll() async {
    await database.delete(agenda);
    await database.delete(backup);
    await database.delete(homeworks);
  }

  Future<void> close() async {
    await database.close();
  }

  Future<List<AgendaCellData>> getByIdAgenda(String table, String id) async {
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

  Future<List<AgendaCellData>> getAgenda(String table) async {
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

  Future<List<HomeworksCellData>> getHomeworks() async {
    final List<Map<String, dynamic>> maps =
        await database.query(homeworks, orderBy: "date");
    return List.generate(maps.length, (i) {
      return HomeworksCellData(
          id: maps[i]["id"],
          description: maps[i]["description"],
          date: maps[i]["date"],
          done: maps[i]["done"]);
    });
  }

  Future<void> insertAll(List<AgendaCellData> data) async {
    List<AgendaCellData> list = await getAgenda(agenda);
    list.removeWhere((element) =>
        element.added == 0 && element.edited == 0 && element.trashed == 0);
    await database.delete(agenda, where: "added = 0");
    await database.delete(backup);
    for (AgendaCellData d in data) {
      for (AgendaCellData l in list) {
        if (d.id == l.id) {
          if (l.edited == 1) {
            await insertOrReplaceAgenda(backup, d);
            d = l;
          } else if (l.trashed == 1) {
            d.trashed = 1;
          }
          list.remove(l);
          break;
        }
      }
      await insertAgenda(agenda, d);
    }
  }
}
