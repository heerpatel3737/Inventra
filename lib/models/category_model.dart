class CategoryModel {
  final String id;
  final String name;
  final String description;
  final int totalProducts;

  const CategoryModel({
    required this.id,
    required this.name,
    this.description = '',
    this.totalProducts = 0,
  });

  CategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    int? totalProducts,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      totalProducts: totalProducts ?? this.totalProducts,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'totalProducts': totalProducts,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      totalProducts: map['totalProducts'] as int? ?? 0,
    );
  }
}
