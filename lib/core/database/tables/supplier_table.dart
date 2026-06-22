class SupplierTable {
  static const tableName = 'suppliers';

  static const id = 'id';
  static const name = 'name';
  static const email = 'email';
  static const phone = 'phone';
  static const address = 'address';
  static const status = 'status';

  static const createTable = '''
CREATE TABLE $tableName (
  $id TEXT PRIMARY KEY,
  $name TEXT NOT NULL,
  $email TEXT,
  $phone TEXT,
  $address TEXT,
  $status TEXT
)
''';
}
