import 'package:flutter/material.dart';
import 'package:whatsapp/data/database/database_data_types.dart';
import 'package:whatsapp/data/database/query.dart';
import 'package:whatsapp/utils/enums.dart';
import 'package:whatsapp/utils/global.dart';

class MessageTable {

  static const id = "id";
  static const data = "data";
  static const senderId = "senderId";
  static const time = "time";
  static const status = "status";
  static const chatId = "chatId";

  final _table = "messages";
  final _whereId = "${MessageTable.id} = ?";

  MessageTable() {
    
    db.execute(
      Query.createTable(
        _table,
        {
          id: SqliteDataTypes.text,
          senderId: SqliteDataTypes.text,
          data: SqliteDataTypes.text,
          time: SqliteDataTypes.unsignedInt,
          status: SqliteDataTypes.eNum(status, MessageStatus.values.map((messageState) => messageState.name).toList()),
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
    debugPrint("Chats: All messages: ${await getAll()}");
    return await db.query(
      _table,
      where: "${MessageTable.chatId} = ?",
      whereArgs: [chatId],
      orderBy: MessageTable.time,
    );
  }

  Future<int> update(Map<String, dynamic> data) async {
    return await db.update(_table, data, where: _whereId, whereArgs: [data['id']]);
  }

  Future<int> updateStatus(String chatId, String messageId, String status) async {
    debugPrint("MessageTable: Trying to update $messageId from table ");
    return await db.update(
      _table,
      {
        MessageTable.status: status,
      },
      where: _whereId,
      whereArgs: [messageId]
    );
  }

  Future<int> updateData(String id, String data) async {
    return db.update(
      _table,
      {
        MessageTable.data: data,
      },
      where: _whereId,
      whereArgs: [id],
    );
  }

  Future<int> updateId(String oldId, String newId) {
    return db.update(
      _table,
      {
        MessageTable.id: newId
      },
      where: "${MessageTable.id} = ?",
      whereArgs: [oldId]
    );
  }

  Future<int> updateIdAndStatus(String oldId, String newId, String status) async {
    return db.update(
      _table,
      {
        MessageTable.id: newId,
        MessageTable.status: status,
      },
      where: "${MessageTable.id} = ?",
      whereArgs: [oldId]
    );
  }

  Future<int> updateChatId(String oldChatId, String newChatId) {
    return db.update(
      _table,
      {
        MessageTable.chatId: newChatId
      },
      where: "${MessageTable.chatId} = ?",
      whereArgs: [oldChatId]
    );
  }

  Future<int> deleteMessagesWithChatId(String chatId) async {
    return db.delete(
      _table,
      where: "${MessageTable.chatId} = ?",
      whereArgs: [chatId]
    );
  }

  Future<int> deleteMessages(List<String> messages) async {
    return await db.delete(
      _table,
      where: "${MessageTable.id} IN (${messages.join(',')})",
    );
  }


  Future<int> deleteAll() async {
    return await db.delete(
      _table,
      where: "1 = ?",
      whereArgs: [1],
    );
  }
}