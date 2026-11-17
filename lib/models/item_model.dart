import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  final String itemId;
  final String itemName;
  final String category;
  final String code;
  final String status; // 'Available' | 'Borrowed'
  final String image;
  final String spesification;
  final Timestamp? createdAt;

  // Data peminjam (hanya terisi saat status Borrowed)
  final String? borrowedByUid;
  final String? borrowedByName;
  final String? borrowedByKelas;

  ItemModel({
    required this.itemId,
    required this.itemName,
    required this.category,
    required this.code,
    required this.status,
    required this.image,
    required this.spesification,
    this.createdAt,
    this.borrowedByUid,
    this.borrowedByName,
    this.borrowedByKelas,
  });

  factory ItemModel.fromMap(Map<String, dynamic> map, String docId) {
    return ItemModel(
      itemId: map['item_id'] ?? docId,
      itemName: map['item_name'] ?? '',
      category: map['category'] ?? 'Jaringan',
      code: map['code'] ?? '',
      status: map['status'] ?? 'Available',
      image: map['image'] ??
          'https://images.unsplash.com/photo-1544197150-b99a580bb7a8?auto=format&fit=crop&w=700&q=80',
      spesification: map['spesification'] ?? '',
      createdAt: map['created_at'] as Timestamp?,
      borrowedByUid: map['borrowed_by_uid'] as String?,
      borrowedByName: map['borrowed_by_name'] as String?,
      borrowedByKelas: map['borrowed_by_kelas'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'item_id': itemId,
      'item_name': itemName,
      'category': category,
      'code': code,
      'status': status,
      'image': image,
      'spesification': spesification,
      'created_at': createdAt ?? FieldValue.serverTimestamp(),
      if (borrowedByUid != null) 'borrowed_by_uid': borrowedByUid,
      if (borrowedByName != null) 'borrowed_by_name': borrowedByName,
      if (borrowedByKelas != null) 'borrowed_by_kelas': borrowedByKelas,
    };
  }
}
