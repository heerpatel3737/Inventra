class ProductTable {
  static const tableName = 'products';

  static const id = 'id';
  static const name = 'name';
  static const description = 'description';
  static const price = 'price';
  static const stock = 'stock';
  static const categoryId = 'categoryId';
  static const supplierId = 'supplierId';
  static const createdAt = 'createdAt';

  static const createTable = '''
CREATE TABLE $tableName (
  $id TEXT PRIMARY KEY,
  $name TEXT NOT NULL,
  $description TEXT,
  $price REAL NOT NULL,
  $stock INTEGER NOT NULL,
  $categoryId TEXT NOT NULL,
  $supplierId TEXT NOT NULL,
  $createdAt TEXT NOT NULL
)
''';
}
