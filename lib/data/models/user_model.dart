import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/app_user.dart';

class UserModel extends AppUser {
  const UserModel({
    required super.userId,
    required super.nik,
    required super.name,
    required super.email,
    required super.role,
    required super.department,
    required super.position,
    required super.shiftStart,
    required super.shiftEnd,
    required super.isActive,
    super.phone,
    super.photoUrl,
    super.createdAt,
    super.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return UserModel.fromJson({...data, 'userId': data['userId'] ?? doc.id});
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final createdAt = _dateFromJson(json['createdAt']);
    final updatedAt = _dateFromJson(json['updatedAt']);

    return UserModel(
      userId: (json['userId'] as String?) ?? '',
      nik: (json['nik'] as String?) ?? '',
      name: (json['name'] as String?) ?? 'HSIL Employee',
      email: (json['email'] as String?) ?? '',
      role: UserRole.fromString((json['role'] as String?) ?? 'employee'),
      department: (json['department'] as String?) ?? 'Production',
      position: (json['position'] as String?) ?? 'Operator',
      phone: json['phone'] as String?,
      photoUrl: json['photoUrl'] as String?,
      shiftStart: (json['shiftStart'] as String?) ?? '08:00',
      shiftEnd: (json['shiftEnd'] as String?) ?? '17:00',
      isActive: (json['isActive'] as bool?) ?? true,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'nik': nik,
      'name': name,
      'email': email,
      'role': role.value,
      'department': department,
      'position': position,
      'phone': phone,
      'photoUrl': photoUrl,
      'shiftStart': shiftStart,
      'shiftEnd': shiftEnd,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static DateTime? _dateFromJson(Object? value) {
    return switch (value) {
      Timestamp timestamp => timestamp.toDate(),
      String raw => DateTime.tryParse(raw),
      DateTime date => date,
      _ => null,
    };
  }
}
