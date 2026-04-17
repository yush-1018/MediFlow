import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class SeedDataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> runSeed() async {
    print("Starting seeding process...");

    // 1. Create Facilities
    final facilities = [
      {
        'id': 'f1',
        'name': 'AIIMS Delhi',
        'latitude': 28.5672,
        'longitude': 77.2100,
        'type': 'Hospital',
        'healthScore': 45.0,
      },
      {
        'id': 'f2',
        'name': 'Safdarjung Hospital',
        'latitude': 28.5665,
        'longitude': 77.2065,
        'type': 'Hospital',
        'healthScore': 85.0,
      },
      {
        'id': 'f3',
        'name': 'Max Super Speciality',
        'latitude': 28.5284,
        'longitude': 77.2188,
        'type': 'Private Clinic',
        'healthScore': 92.0,
      },
      {
        'id': 'f4',
        'name': 'Apollo Hospital',
        'latitude': 28.5414,
        'longitude': 77.2842,
        'type': 'Hospital',
        'healthScore': 30.0,
      },
    ];

    for (var f in facilities) {
      await _db.collection('facilities').doc(f['id'] as String).set(f);
      
      // 2. Add Stocks for each facility
      final medicines = [
        {'name': 'Paracetamol', 'generic': 'Acetaminophen', 'cat': 'Analgesic', 'unit': 'Strips'},
        {'name': 'Amoxicillin', 'generic': 'Amoxicillin', 'cat': 'Antibiotic', 'unit': 'Vials'},
        {'name': 'Insulin Glargine', 'generic': 'Insulin', 'cat': 'Endocrine', 'unit': 'Cartridges'},
        {'name': 'Remdesivir', 'generic': 'Antiviral', 'cat': 'Antiviral', 'unit': 'Vials'},
        {'name': 'Dexamethasone', 'generic': 'Steriod', 'cat': 'Anti-inflammatory', 'unit': 'Tablets'},
      ];

      for (var med in medicines) {
        final stock = {
          'facilityId': f['id'],
          'medicineName': med['name'],
          'genericName': med['generic'],
          'category': med['cat'],
          'currentStock': Random().nextInt(500) + 10,
          'minStockThreshold': 100,
          'unit': med['unit'],
          'expiryDate': DateTime.now().add(Duration(days: Random().nextInt(365))).toIso8601String(),
          'updatedAt': FieldValue.serverTimestamp(),
        };
        await _db.collection('stocks').add(stock);
      }
    }

    // 3. Create a Demo User (Facility Head)
    await _db.collection('users').doc('demo_facility_head').set({
      'name': 'Dr. Aarush Yadav',
      'email': 'facility@medsupply.com',
      'role': 'FACILITY_HEAD',
      'facilityId': 'f1',
      'facilityName': 'AIIMS Delhi',
    });

    // 4. Create a CMS Admin
    await _db.collection('users').doc('demo_cms_admin').set({
      'name': 'Network Admin',
      'email': 'admin@medsupply.com',
      'role': 'CMS_ADMIN',
    });

    // 5. Create Pending Requests
    await _db.collection('requests').add({
      'sourceFacilityId': 'f2',
      'sourceFacilityName': 'Safdarjung Hospital',
      'destinationFacilityId': 'f1',
      'destinationFacilityName': 'AIIMS Delhi',
      'medicineName': 'Amoxicillin',
      'quantity': 50,
      'status': 'PENDING',
      'createdAt': FieldValue.serverTimestamp(),
    });

    print("Seeding complete!");
  }
}
