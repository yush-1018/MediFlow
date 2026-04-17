import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  facilityHead('facility_head'),
  cmsAdmin('cms_admin');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String val) {
    return UserRole.values.firstWhere(
      (e) => e.value == val,
      orElse: () => UserRole.facilityHead,
    );
  }
}

class UserProfile {
  final String uid;
  final String email;
  final UserRole role;
  final String? facilityId; // Null for CMS Admin
  final String displayName;

  UserProfile({
    required this.uid,
    required this.email,
    required this.role,
    this.facilityId,
    required this.displayName,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      email: data['email'] ?? '',
      role: UserRole.fromString(data['role'] ?? 'facility_head'),
      facilityId: data['facilityId'],
      displayName: data['displayName'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'role': role.value,
      'facilityId': facilityId,
      'displayName': displayName,
    };
  }
}

/**
 * Example Document:
 * {
 *   "email": "aarush@medsupply.com",
 *   "role": "facility_head",
 *   "facilityId": "city_general_hospital",
 *   "displayName": "Aarush Yadav"
 * }
 */
