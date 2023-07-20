import 'package:sqflite/sqflite.dart';
import 'package:whatsapp/data/database/database_data_types.dart';
import 'package:whatsapp/data/database/query.dart';
import 'package:whatsapp/utils/global.dart';

class ChatUsersTable {

  final String _table = "chat_users";

  static const String chatId = "chatId";
  static const String userId = "userId";

  ChatUsersTable() {
    db.execute(
      Query.createTable(
        _table,
        {
          chatId: SqliteDataTypes.text,
          userId: SqliteDataTypes.text,
        }
      )
    );
  }

  Future<int> insert(Map<String, dynamic> row) async {
    return await db.insert(_table, row);
  }
  
  Future<List<Map<String, dynamic>>> getByUserAndChatId(String chatId, String userId) async {
    return await db.query(_table, where: "${ChatUsersTable.chatId} = ? AND ${ChatUsersTable.userId} = ?", whereArgs: [chatId, userId]);
  }

  Future<List<Map<String, dynamic>>> getUsersByChatId(String id) async {
    return await db.query(_table, where: "$chatId = ?", whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getChatsByUserId(String id) async {
    return await db.query(_table, where: "$userId = ?", whereArgs: [id]);
  }

  // Future<int> update(Map<String, dynamic> data) async {
  //   return await db.update(
  //     _table,
  //     data,
  //     where: "${ChatTable.id} = ?",
  //     whereArgs: [data[id]],
  //   );
  // }

  Future<int> updateChatId(String id, String newId) async {
    return await db.update(
      _table, 
      {
        ChatUsersTable.chatId: newId,
      },
      where: "${ChatUsersTable.chatId} = ?",
      whereArgs: [id],

    );
  }

  Future<int> deleteChat(String chatId) async {
    return await db.delete(
      _table,
      where: "${ChatUsersTable.chatId} = ?",
      whereArgs: [chatId],
    );
  }
  
  Future<int> deleteUserFromChat(String userId, String chatId) async {
    return await db.delete(
      _table,
      where: "${ChatUsersTable.userId} = ? AND ${ChatUsersTable.chatId} = ?",
      whereArgs: [userId, chatId],
    );
  }

  Future<int> deleteChatFromUser(String chatId, String userId) async {
    return await db.delete(
      _table,
      where: "${ChatUsersTable.userId} = ? AND ${ChatUsersTable.chatId} = ?",
      whereArgs: [userId, chatId],
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