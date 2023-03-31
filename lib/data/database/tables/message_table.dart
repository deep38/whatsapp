import 'package:whatsapp/data/database/database_data_types.dart';
import 'package:whatsapp/data/database/query.dart';
import 'package:whatsapp/utils/enums.dart';
import 'package:whatsapp/utils/global.dart';

class MessageTable {

  static const id = "id";
  static const data = "data";
  static const senderId = "sender_id";
  static const time = "time";
  static const state = "state";
  static const chatId = "chat_id";

  final _table = "messages";
  final _wherId = "${MessageTable.id} = ?";

  MessageTable() {
    
    db.execute(
      Query.createTable(
        _table,
        {
          id: SqliteDataTypes.text,
          senderId: SqliteDataTypes.text,
          data: SqliteDataTypes.text,
          time: SqliteDataTypes.unsignedInt,
          state: SqliteDataTypes.eNum(state, MessageState.values.map((messageState) => messageState.name).toList()),
          chatId: SqliteDataTypes.text,
        }
      )
    );
  }

  Future<int> insert(Map<String, dynamic> row) async { 
    return await db.insert(_table, row);
  }

  Future<bool> exists(String id) async {
    return (await db.query(_table, where: "${MessageTable.id} = ?", whereArgs: [id])).isNotEmpty;
  }

  Future<List<Map<String,dynamic>>> getAll() async {
    return await db.query(_table);
  }

  Future<List<Map<String,dynamic>>> getAllForChat(String chatId) async {
    return await db.query(
      _table,
      where: "${MessageTable.chatId} = ?",
      whereArgs: [chatId],
      orderBy: MessageTable.time,
    );
  }

  Future<int> update(Map<String, dynamic> data) async {
    return await db.update(_table, data, where: _wherId, whereArgs: [data['id']]);
  }

  Future<int> updateState(String id, String state) async {
    return await db.update(
      _table,
      {
        MessageTable.state: state,
      },
      where: _wherId,
      whereArgs: [id]
    );
  }

  Future<int> updateData(String id, String data) async {
    return db.update(
      _table,
      {
        MessageTable.data: data,
      },
      where: _wherId,
      whereArgs: [id],
    );
  }

  Future<int> updateChatId(String oldChatId, String newChatId) {
    return db.update(
      _table,
      {
        MessageTable.chatId: newChatId
      },
      where: "${MessageTable.chatId} = ?",
      whereArgs: [newChatId]
    );
  }

  Future<int> deleteMessages(String chatId) async {
    return db.delete(
      _table,
      where: "${MessageTable.chatId} = ?",
      whereArgs: [chatId]
    );
  }
}