import 'package:cloud_firestore/cloud_firestore.dart';

class Facility {
  final String id;
  final String name;
  final GeoPoint location;
  final double latitude;
  final double longitude;
  final double healthScore;
  final String type;
  final String district;
  final String adminEmail;
  final DateTime createdAt;

  Facility({
    required this.id,
    required this.name,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.healthScore,
    required this.type,
    required this.district,
    required this.adminEmail,
    required this.createdAt,
  });

  factory Facility.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    GeoPoint loc = data['location'] ?? const GeoPoint(0, 0);
    return Facility(
      id: doc.id,
      name: data['name'] ?? '',
      location: loc,
      latitude: data['latitude']?.toDouble() ?? loc.latitude,
      longitude: data['longitude']?.toDouble() ?? loc.longitude,
      healthScore: data['healthScore']?.toDouble() ?? 100.0,
      type: data['type'] ?? 'Hospital',
      district: data['district'] ?? '',
      adminEmail: data['adminEmail'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'healthScore': healthScore,
      'type': type,
      'district': district,
      'adminEmail': adminEmail,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
