import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqlite_api.dart';
import 'package:zxzc9992/services/local_db/tables.dart';

const decksToSync = 'decksToSync';
const cardsToSync = 'cardsToSync';

class DBHelper {
  // TODO: Standarize column names in tables
  // TODO: Error handling
  //static late String databaseName = Auth.auth.user()!.id;
  // TODO: Remove static keywords
  static late String databaseName = kReleaseMode ? 'sqlite' : 'sqlite-prod';

  static Future<Database> database() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();

    final String path = p.join(documentsDirectory.path, "$databaseName.db");

    return sql.openDatabase(
      path,
      version: kReleaseMode ? 2 : 4,
      onCreate: (db, version) async {
        await _onCreate(db);
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        await _onUpgrade(db, oldVersion, newVersion);
      },
    );
  }

  static Future _onCreate(Database db) {
    return db.transaction((Transaction txn) async {
      txn.execute(tables_decks);
      txn.execute(tables_cards);
      txn.execute(tables_decksToSync);
      txn.execute(tables_cardsToSync);
    });
  }

  static Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (newVersion > oldVersion) {
      // TODO: Remove lastReviewied column: https://stackoverflow.com/questions/8442147/how-to-delete-or-add-column-in-sqlite
      // Change lastPlayed2 to lastPlayed

      if (!kReleaseMode) {
 
        return;
      }

      if (kReleaseMode) {}

      // if (!kReleaseMode) {
      //   db.execute(
      //       'alter table decks add column lastPlayed INTEGER DEFAULT null;');
      //   // db.execute(
      //   //     'alter table decks add column createdAt INTEGER DEFAULT $now;');
      //   return;
      // }

      // //db.execute('alter table cards add column backImg INTEGER DEFAULT null;');
      // // db.execute('alter table decks add column lastReviewed INTEGER DEFAULT 0;');

      // // if (kReleaseMode) {
      // //   // 2:
      // //   db.execute(
      // //       'alter table decks add column lastPlayed INTEGER DEFAULT null;');
      // //   db.execute(
      // //       'alter table decks add column createdAt INTEGER DEFAULT $now;');
      // // }
    }
  }

  static Future<List<Map<String, dynamic>>> fetch(
    String table, {
    String where = '',
    String orderBy = '',
  }) async {
    final whereClause = where != '' ? where : null;
    final orderByClause = orderBy != '' ? orderBy : null;

    final db = await DBHelper.database();
    return db.query(table, where: whereClause, orderBy: orderByClause);
  }

  static Future<void> insert(String table, Map<String, Object?> data) async {
    final db = await DBHelper.database();
    try {
      db.insert(
        table,
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print(e);
    }
  }

  // TODO: Create update function
  static Future<void> update({
    required String table,
    required Map<String, Object> data,
    required String? deckId,
  }) async {
    final db = await DBHelper.database();

    db.update(table, data, where: 'id = ?', whereArgs: [deckId]);

    // db.insert(
    //   table,
    //   data,
    //   conflictAlgorithm: ConflictAlgorithm.replace,
    // );
  }

  static Future<void> delete(
    String table,
    String columnName,
    String id,
  ) async {
    final db = await DBHelper.database();

    db.delete(table, where: '$columnName = ?', whereArgs: [id]);
  }

  static Future<List<Map<String, dynamic>>> rawQuery(String query) async {
    final db = await DBHelper.database();

    final data = await db.rawQuery(query);
    return data;
  }
}
