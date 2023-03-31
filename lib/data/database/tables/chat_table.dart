import 'package:sqflite/sqflite.dart';
import 'package:whatsapp/data/database/database_data_types.dart';
import 'package:whatsapp/data/database/query.dart';
import 'package:whatsapp/utils/global.dart';

class ChatTable {

  final String _table = "chats";

  static const String id = "id";
  static const String type = "type";

  ChatTable() {
    db.execute(
      Query.createTable(
        _table,
        {
          id: SqliteDataTypes.text,
          type: SqliteDataTypes.varChar(10),
        }
      )
    );
  }

  Future<int> insert(Map<String, dynamic> row) async {
    return await db.insert(_table, row);
  }

  Future<bool> contains(String chatId) async {
    return (await db.query(_table, where: "$id = ?", whereArgs: [chatId])).isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    return await db.query(_table);
  }

  Future<int> getUnsentCount() async {
    return Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM $_table")) ?? 0;
  }

  Future<int> update(Map<String, dynamic> data) async {
    return await db.update(
      _table,
      data,
      where: "${ChatTable.id} = ?",
      whereArgs: [data[id]],
    );
  }

  Future<int> updateId(String id, String newId) async {
    return await db.update(
      _table, 
      {
        ChatTable.id: newId,
      },
      where: "${ChatTable.id} = ?",
      whereArgs: [id],

    );
  }
  
  Future<int> delete(String id) async {
    return await db.delete(
      _table,
      where: "${ChatTable.id} = ?",
      whereArgs: [id],
    );
  }
}