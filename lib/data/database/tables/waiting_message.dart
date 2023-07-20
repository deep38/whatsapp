import 'package:whatsapp/data/database/database_data_types.dart';
import 'package:whatsapp/data/database/query.dart';
import 'package:whatsapp/utils/enums.dart';
import 'package:whatsapp/utils/global.dart';

class WaitingMessageTable {

  static const id = "id";
  static const data = "data";
  static const senderId = "sender_id";
  static const time = "time";
  static const state = "state";
  static const chatId = "chat_id";

  final _table = "waiting_messages";
  final _wherId = "${WaitingMessageTable.id} = ?";

  WaitingMessageTable() {
    
    db.execute(
      Query.createTable(
        _table,
        {
          id: SqliteDataTypes.text,
          senderId: SqliteDataTypes.text,
          data: SqliteDataTypes.text,
          time: SqliteDataTypes.unsignedInt,
          state: SqliteDataTypes.eNum(state, MessageStatus.values.map((messageState) => messageState.name).toList()),
          chatId: SqliteDataTypes.text,
        }
      )
    );
  }

  Future<int> insert(Map<String, dynamic> row) async { 
    return await db.insert(_table, row);
  }

  Future<List<Map<String,dynamic>>> getAll() async {
    return await db.query(_table);
  }

  Future<List<Map<String,dynamic>>> getAllForChat(String chatId) async {
    return await db.query(
      _table,
      where: "${WaitingMessageTable.chatId} = ?",
      whereArgs: [chatId]
    );
  }

  Future<int> delete(String id) async {
    return await db.delete(_table, where: _wherId, whereArgs: [id]);
  }

  Future<int> deleteMessages(String chatId) async {
    return db.delete(
      _table,
      where: "${WaitingMessageTable.chatId} = ?",
      whereArgs: [chatId]
    );
  }

  Future<int> update(Map<String, dynamic> data) async {
    return await db.update(_table, data, where: _wherId, whereArgs: [data['id']]);
  }

  Future<int> updateState(String id, String state) async {
    return await db.update(
      _table,
      {
        WaitingMessageTable.state: state,
      },
      where: _wherId,
      whereArgs: [id]
    );
  }

  Future<int> updateData(String id, String data) async {
    return db.update(
      _table,
      {
        WaitingMessageTable.data: data,
      },
      where: _wherId,
      whereArgs: [id],
    );
  }

  Future<int> updateChatId(String oldChatId, String newChatId) {
    return db.update(
      _table,
      {
        WaitingMessageTable.chatId: newChatId
      },
      where: "${WaitingMessageTable.chatId} = ?",
      whereArgs: [newChatId]
    );
  }
}