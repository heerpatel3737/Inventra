import 'dart:convert';

class RoleModel {
  final String id;
  final String name;
  final String description;
  final List<String> permissions;

  const RoleModel({
    required this.id,
    required this.name,
    required this.description,
    required this.permissions,
  });

  RoleModel copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? permissions,
  }) {
    return RoleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      permissions: permissions ?? this.permissions,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'permissions': jsonEncode(permissions),
    };
  }

  factory RoleModel.fromMap(Map<String, dynamic> map) {
    final rawPermissions = map['permissions'];
    return RoleModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      permissions: rawPermissions is String
          ? (jsonDecode(rawPermissions) as List<dynamic>).cast<String>()
          : (rawPermissions as List<dynamic>).cast<String>(),
    );
  }
}
