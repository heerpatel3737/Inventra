class UserProfileModel {
  final String name;
  final String email;
  final String role;
  final String phone;
  final String department;
  final String? photoUrl;

  const UserProfileModel({
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    required this.department,
    this.photoUrl,
  });

  UserProfileModel copyWith({
    String? name,
    String? email,
    String? role,
    String? phone,
    String? department,
    String? photoUrl,
  }) {
    return UserProfileModel(
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'department': department,
      'photoUrl': photoUrl ?? '',
    };
  }

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      name: map['name'] as String,
      email: map['email'] as String,
      role: map['role'] as String,
      phone: map['phone'] as String,
      department: map['department'] as String,
      photoUrl: map['photoUrl'] as String?,
    );
  }
}
