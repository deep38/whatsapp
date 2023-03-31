class Query {
  static String createTable(String tableName, Map<String,String> columns) {
    String columnsString = "";
    columns.forEach((key, value) {
      columnsString += "$key $value, ";
    });
    columnsString = columnsString.substring(0, columnsString.length - 2);
    
    return '''CREATE TABLE IF NOT EXISTS $tableName ($columnsString)''';
  }
}