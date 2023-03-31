import 'package:whatsapp/data/database/database_data_types.dart';
import 'package:whatsapp/data/database/query.dart';
import 'package:whatsapp/utils/enums.dart';
import 'package:whatsapp/utils/global.dart';

class UserTable {

  static const uid = "uid";
  static const name = "name";
  static const phone = "phone";
  static const profileUrl = "profile_url";

  final _table = "users";

  final _wherId = "${UserTable.uid} = ?";

  UserTable() {
    
    db.execute(
      Query.createTable(
        _table,
        {
          uid: SqliteDataTypes.text,
          name: SqliteDataTypes.varChar(25),
          phone: SqliteDataTypes.varChar(15),
          profileUrl: SqliteDataTypes.varChar(2048),
        }
      )
    );
  }

  Future<int> insert(Map<String, dynamic> row) async { 
    return await db.insert(_table, row);
  }

  Future<bool> exists(String id) async {
    return (await db.query(_table, where: _wherId, whereArgs: [id])).isNotEmpty;
  }

  Future<List<Map<String,dynamic>>> getAll() async {
    return await db.query(_table);
  }

  Future<List<Map<String,dynamic>>> getById(String id) async {
    return await db.query(
      _table,
      where: _wherId,
      whereArgs: [id],
    );
  }

  Future<int> update(Map<String, dynamic> data) async {
    return await db.update(_table, data, where: _wherId, whereArgs: [data['uid']]);
  }

  Future<int> updateName(String id, String name) async {
    return await db.update(
      _table,
      {
        UserTable.name: name,
      },
      where: _wherId,
      whereArgs: [id]
    );
  }

  Future<int> updatePhoneNumber(String id, String phoneNo) async {
    return await db.update(
      _table,
      {
        UserTable.phone: phoneNo,
      },
      where: _wherId,
      whereArgs: [id]
    );
  }

  Future<int> updateProfileUrl(String id, String profileUrl) async {
    return await db.update(
      _table,
      {
        UserTable.profileUrl: profileUrl,
      },
      where: _wherId,
      whereArgs: [id]
    );
  }

  Future<int> deleteUser(String id) async {
    return db.delete(
      _table,
      where: _wherId,
      whereArgs: [id]
    );
  }
}