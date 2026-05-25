enum UserRole {
  employee,
  admin;

  static UserRole fromString(String value) {
    return switch (value.toLowerCase()) {
      'admin' => UserRole.admin,
      _ => UserRole.employee,
    };
  }

  String get value => switch (this) {
    UserRole.employee => 'employee',
    UserRole.admin => 'admin',
  };
}

/// Authenticated employee/admin profile loaded from `/users/{uid}`.
class AppUser {
  const AppUser({
    required this.userId,
    required this.nik,
    required this.name,
    required this.email,
    required this.role,
    required this.department,
    required this.position,
    required this.shiftStart,
    required this.shiftEnd,
    required this.isActive,
    this.phone,
    this.photoUrl,
    this.createdAt,
    this.updatedAt,
  });

  final String userId;
  final String nik;
  final String name;
  final String email;
  final UserRole role;
  final String department;
  final String position;
  final String? phone;
  final String? photoUrl;
  final String shiftStart;
  final String shiftEnd;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isAdmin => role == UserRole.admin;
}
