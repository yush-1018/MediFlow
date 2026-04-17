import 'package:cloud_firestore/cloud_firestore.dart';

class UsageLog {
  final String id;
  final String stockId;
  final String medicineName;
  final int qtyUsed;
  final String loggedBy;
  final DateTime loggedAt;
  final String notes;

  UsageLog({
    required this.id,
    required this.stockId,
    required this.medicineName,
    required this.qtyUsed,
    required this.loggedBy,
    required this.loggedAt,
    required this.notes,
  });

  factory UsageLog.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return UsageLog(
      id: doc.id,
      stockId: data['stockId'] ?? '',
      medicineName: data['medicineName'] ?? '',
      qtyUsed: data['qtyUsed'] ?? 0,
      loggedBy: data['loggedBy'] ?? '',
      loggedAt: (data['loggedAt'] as Timestamp).toDate(),
      notes: data['notes'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'stockId': stockId,
      'medicineName': medicineName,
      'qtyUsed': qtyUsed,
      'loggedBy': loggedBy,
      'loggedAt': Timestamp.fromDate(loggedAt),
      'notes': notes,
    };
  }
}

/**
 * Example Document (Subcollection of facilities):
 * {
 *   "stockId": "stock_abc_123",
 *   "medicineName": "Paracetamol 500mg",
 *   "qtyUsed": 20,
 *   "loggedBy": "Aarush (Facility Head)",
 *   "loggedAt": Timestamp.now(),
 *   "notes": "Daily clinic distribution"
 * }
 */
