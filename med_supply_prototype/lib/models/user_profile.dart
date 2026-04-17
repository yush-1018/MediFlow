import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  facilityHead('facility_head'),
  cmsAdmin('cms_admin');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String val) {
    return UserRole.values.firstWhere(
      (e) => e.value == val.toLowerCase(),
      orElse: () => UserRole.facilityHead,
    );
  }
}

class UserProfile {
  final String uid;
  final String email;
  final UserRole role; // Updated back to Enum for logic
  final String? facilityId;
  final String? facilityName; // Restored for UI
  final String displayName; // Step 3 rename

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
      facilityName: data['facilityName'],
      displayName: data['displayName'] ?? data['name'] ?? 'Unknown User',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'role': role.value,
      'facilityId': facilityId,
      'facilityName': facilityName,
      'displayName': displayName,
    };
  }
}
