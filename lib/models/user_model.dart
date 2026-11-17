import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String name;
  final String email;
  final String kelas;
  final Timestamp? createdAt;
  final String foto;
  final String role; // 'siswa' | 'admin'

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.kelas,
    this.createdAt,
    required this.foto,
    this.role = 'siswa',
  });

  bool get isAdmin => role == 'admin';

  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    return UserModel(
      userId: map['user_id'] ?? docId,
      name: map['name'] ?? 'Siswa RPL',
      email: map['email'] ?? '',
      kelas: map['kelas'] ?? 'XI RPL',
      createdAt: map['created_at'] as Timestamp?,
      foto: map['foto'] ??
          'https://ui-avatars.com/api/?name=${Uri.encodeComponent(map['name'] ?? 'User')}&background=0D9488&color=FFFFFF&bold=true&size=128',
      role: map['role'] ?? 'siswa',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'kelas': kelas,
      'created_at': createdAt ?? FieldValue.serverTimestamp(),
      'foto': foto,
      'role': role,
    };
  }
}
