import 'package:cloud_firestore/cloud_firestore.dart';

class IndentRequest {
  final String id;
  final String fromFacilityId;
  final String toFacilityId; // Can be null for pending global redistribution
  final String medicineName;
  final int qtyRequested;
  final String status; // pending, approved, rejected
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? resolvedBy;

  IndentRequest({
    required this.id,
    required this.fromFacilityId,
    required this.toFacilityId,
    required this.medicineName,
    required this.qtyRequested,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
    this.resolvedBy,
  });

  factory IndentRequest.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return IndentRequest(
      id: doc.id,
      fromFacilityId: data['fromFacilityId'] ?? '',
      toFacilityId: data['toFacilityId'] ?? '',
      medicineName: data['medicineName'] ?? '',
      qtyRequested: data['qtyRequested'] ?? 0,
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      resolvedAt: data['resolvedAt'] != null 
        ? (data['resolvedAt'] as Timestamp).toDate() 
        : null,
      resolvedBy: data['resolvedBy'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'fromFacilityId': fromFacilityId,
      'toFacilityId': toFacilityId,
      'medicineName': medicineName,
      'qtyRequested': qtyRequested,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      'resolvedBy': resolvedBy,
    };
  }
}

/**
 * Example Document:
 * {
 *   "fromFacilityId": "facility_a",
 *   "toFacilityId": "facility_b",
 *   "medicineName": "Amoxicillin 250mg",
 *   "qtyRequested": 500,
 *   "status": "pending",
 *   "createdAt": Timestamp.now(),
 *   "resolvedAt": null,
 *   "resolvedBy": null
 * }
 */
