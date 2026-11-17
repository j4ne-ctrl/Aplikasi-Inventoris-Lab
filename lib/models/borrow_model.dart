import 'package:cloud_firestore/cloud_firestore.dart';

class BorrowModel {
  final String borrowId;
  final String itemId;
  final String itemName;
  final Timestamp? borrowDate;
  final Timestamp? returnDate;
  final String status; // 'Borrowed' | 'Returned'

  BorrowModel({
    required this.borrowId,
    required this.itemId,
    required this.itemName,
    this.borrowDate,
    this.returnDate,
    required this.status,
  });

  factory BorrowModel.fromMap(Map<String, dynamic> map, String docId) {
    return BorrowModel(
      borrowId: map['borrow_id'] ?? docId,
      itemId: map['item_id'] ?? '',
      itemName: map['item_name'] ?? '',
      borrowDate: map['borrow_date'] as Timestamp?,
      returnDate: map['return_date'] as Timestamp?,
      status: map['status'] ?? 'Borrowed',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'borrow_id': borrowId,
      'item_id': itemId,
      'item_name': itemName,
      'borrow_date': borrowDate ?? FieldValue.serverTimestamp(),
      'return_date': returnDate,
      'status': status,
    };
  }
}