import 'package:cloud_firestore/cloud_firestore.dart';

class Stock {
  final String id;
  final String medicineName;
  final String genericName;
  final String batchNumber;
  final int qtyRemaining; // Step 3 rename
  final int qtyTotal;
  final String unit;
  final DateTime expiryDate;
  final String category;
  final int reorderLevel; // Step 3 rename
  final DateTime updatedAt;

  Stock({
    required this.id,
    required this.medicineName,
    required this.genericName,
    required this.batchNumber,
    required this.qtyRemaining,
    required this.qtyTotal,
    required this.unit,
    required this.expiryDate,
    required this.category,
    required this.reorderLevel,
    required this.updatedAt,
  });

  factory Stock.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Stock(
      id: doc.id,
      medicineName: data['medicineName'] ?? '',
      genericName: data['genericName'] ?? '',
      batchNumber: data['batchNumber'] ?? '',
      qtyRemaining: data['qtyRemaining'] ?? data['currentStock'] ?? 0,
      qtyTotal: data['qtyTotal'] ?? 0,
      unit: data['unit'] ?? '',
      expiryDate: (data['expiryDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      category: data['category'] ?? '',
      reorderLevel: data['reorderLevel'] ?? data['minStockThreshold'] ?? 0,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'medicineName': medicineName,
      'genericName': genericName,
      'batchNumber': batchNumber,
      'qtyRemaining': qtyRemaining,
      'qtyTotal': qtyTotal,
      'unit': unit,
      'expiryDate': Timestamp.fromDate(expiryDate),
      'category': category,
      'reorderLevel': reorderLevel,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // UI Helpers
  int get daysUntilExpiry => expiryDate.difference(DateTime.now()).inDays;
  bool get isLowStock => qtyRemaining <= reorderLevel;
}
