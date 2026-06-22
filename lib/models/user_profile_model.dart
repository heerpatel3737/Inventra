class UserProfileModel {
  final String name;
  final String email;
  final String role;
  final String phone;
  final String department;

  const UserProfileModel({
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    required this.department,
  });

  UserProfileModel copyWith({
    String? name,
    String? email,
    String? role,
    String? phone,
    String? department,
  }) {
    return UserProfileModel(
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      department: department ?? this.department,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': 1,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'department': department,
    };
  }

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      name: map['name'] as String,
      email: map['email'] as String,
      role: map['role'] as String,
      phone: map['phone'] as String,
      department: map['department'] as String,
    );
  }
}
