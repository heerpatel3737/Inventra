class CategoryTable {
  static const tableName = 'categories';

  static const id = 'id';
  static const name = 'name';
  static const description = 'description';

  static const createTable = '''
CREATE TABLE $tableName (
  $id TEXT PRIMARY KEY,
  $name TEXT NOT NULL,
  $description TEXT
)
''';
}
