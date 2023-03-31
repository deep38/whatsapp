class SqliteDataTypes {

  static const String text = "TEXT";
  static const String unsignedInt = "UNSIGNEDBIGINT";

  static String tinyInt(int length) {
    return "TINYINT($length)";
  }

  static String varChar(int length) {
    return "VARCHAR($length)";
  }

  static String eNum(String columnName, List<String> values) {
    return "TEXT CHECK($columnName IN ('${values.join('\',\'')}'))";
  }
}