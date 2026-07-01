/// Domain model for a product row in SQLite.
///
/// [id] is null only before the first insert; SQLite assigns it via AUTOINCREMENT.
class ProductModel {
  final int? id;
  final String name;
  final double price;
  final int stock;
  final String category;
  final String supplier;
  final String? imageUrl;
  final String? barcode;

  const ProductModel({
    this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.category,
    required this.supplier,
    this.imageUrl,
    this.barcode,
  });

  /// Human-readable SKU label for the UI (e.g. "SKU-0001").
  String get skuLabel {
    if (id == null) return 'Draft';
    return 'SKU-${id!.toString().padLeft(4, '0')}';
  }

  ProductModel copyWith({
    int? id,
    String? name,
    double? price,
    int? stock,
    String? category,
    String? supplier,
    String? imageUrl,
    String? barcode,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      category: category ?? this.category,
      supplier: supplier ?? this.supplier,
      imageUrl: imageUrl ?? this.imageUrl,
      barcode: barcode ?? this.barcode,
    );
  }

  /// Converts this model into a map for SQLite insert/update.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'price': price,
      'stock': stock,
      'category': category,
      'supplier': supplier,
      'imageUrl': imageUrl ?? '',
      'barcode': barcode ?? '',
    };
  }

  /// Builds a model from a SQLite query row.
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      stock: map['stock'] as int,
      category: map['category'] as String,
      supplier: map['supplier'] as String,
      imageUrl: map['imageUrl'] as String?,
      barcode: map['barcode'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductModel &&
        other.id == id &&
        other.name == name &&
        other.price == price &&
        other.stock == stock &&
        other.category == category &&
        other.supplier == supplier &&
        other.imageUrl == imageUrl &&
        other.barcode == barcode;
  }

  @override
  int get hashCode => Object.hash(id, name, price, stock, category, supplier, imageUrl, barcode);
}
