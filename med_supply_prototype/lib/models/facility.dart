import 'package:cloud_firestore/cloud_firestore.dart';

class Facility {
  final String id;
  final String name;
  final GeoPoint location;
  final String district;
  final String adminEmail;
  final DateTime createdAt;

  Facility({
    required this.id,
    required this.name,
    required this.location,
    required this.district,
    required this.adminEmail,
    required this.createdAt,
  });

  factory Facility.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Facility(
      id: doc.id,
      name: data['name'] ?? '',
      location: data['location'] ?? const GeoPoint(0, 0),
      district: data['district'] ?? '',
      adminEmail: data['adminEmail'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'location': location,
      'district': district,
      'adminEmail': adminEmail,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

/**
 * Example Document:
 * {
 *   "name": "City General Hospital",
 *   "location": GeoPoint(28.6139, 77.2090),
 *   "district": "New Delhi",
 *   "adminEmail": "admin@cityhospital.com",
 *   "createdAt": Timestamp(seconds=1620000000)
 * }
 */
