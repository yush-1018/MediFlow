import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class SeedDataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> runSeed() async {
    print("🚀 Starting Production Schema Seeding...");

    // 1. Create Facilities (Top-level)
    final facilities = [
      {
        'id': 'f1',
        'name': 'AIIMS Delhi',
        'district': 'South Delhi',
        'adminEmail': 'admin.aiims@hospital.org',
        'latitude': 28.5672,
        'longitude': 77.2100,
      },
      {
        'id': 'f2',
        'name': 'Safdarjung Hospital',
        'district': 'South Delhi',
        'adminEmail': 'admin.safdar@hospital.org',
        'latitude': 28.5665,
        'longitude': 77.2065,
      },
      {
        'id': 'f3',
        'name': 'Max Super Speciality',
        'district': 'South East Delhi',
        'adminEmail': 'admin.max@hospital.org',
        'latitude': 28.5284,
        'longitude': 77.2188,
      },
    ];

    for (var f in facilities) {
      final facilityRef = _db.collection('facilities').doc(f['id'] as String);
      
      await facilityRef.set({
        'name': f['name'],
        'district': f['district'],
        'adminEmail': f['adminEmail'],
        'location': GeoPoint(f['latitude'] as double, f['longitude'] as double),
        'latitude': f['latitude'], // Added for easier map coordinate access
        'longitude': f['longitude'],
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // 2. Add Stocks (Subcollection of each facility)
      // Step 3 Schema: medicineName, genericName, batchNumber, qtyRemaining, qtyTotal, unit, expiryDate, category, reorderLevel, updatedAt
      final medicines = [
        {'name': 'Paracetamol 500mg', 'generic': 'Acetaminophen', 'cat': 'Analgesic', 'unit': 'Strips'},
        {'name': 'Amoxicillin 250mg', 'generic': 'Amoxicillin', 'cat': 'Antibiotic', 'unit': 'Vials'},
        {'name': 'Insulin Glargine', 'generic': 'Insulin', 'cat': 'Endocrine', 'unit': 'Cartridges'},
        {'name': 'Dexamethasone', 'generic': 'Steriod', 'cat': 'Anti-inflammatory', 'unit': 'Tablets'},
      ];

      for (var med in medicines) {
        await facilityRef.collection('stocks').add({
          'medicineName': med['name'],
          'genericName': med['generic'],
          'batchNumber': 'BATCH-${Random().nextInt(99999)}',
          'qtyRemaining': Random().nextInt(500) + 10,
          'qtyTotal': 1000,
          'unit': med['unit'],
          'expiryDate': Timestamp.fromDate(DateTime.now().add(Duration(days: 100 + Random().nextInt(500)))),
          'category': med['cat'],
          'reorderLevel': 100,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // 3. Add Usage Logs (Subcollection of each facility)
      // Step 3 Schema: stockId, medicineName, qtyUsed, loggedBy, loggedAt, notes
      await facilityRef.collection('usage_logs').add({
        'stockId': 'demo_stock_id',
        'medicineName': 'Paracetamol 500mg',
        'qtyUsed': 50,
        'loggedBy': 'demo_facility_head',
        'loggedAt': FieldValue.serverTimestamp(),
        'notes': 'Daily outpatient distribution',
      });
    }

    // 4. Create Users (Step 3 fields)
    // uid, email, role, facilityId, displayName
    
    // Facility Head
    await _db.collection('users').doc('demo_facility_head').set({
      'email': 'facility@medsupply.com',
      'role': 'facility_head',
      'facilityId': 'f1',
      'displayName': 'Dr. Aarush Yadav',
    });

    // CMS Admin
    await _db.collection('users').doc('demo_cms_admin').set({
      'email': 'admin@medsupply.com',
      'role': 'cms_admin',
      'displayName': 'Network Administrator',
    });

    // 5. Create Requests (Step 3 fields)
    // fromFacilityId, toFacilityId, medicineName, qtyRequested, status, createdAt, resolvedAt, resolvedBy
    await _db.collection('requests').add({
      'fromFacilityId': 'f2',
      'toFacilityId': 'f1',
      'medicineName': 'Amoxicillin 250mg',
      'qtyRequested': 150,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'resolvedAt': null,
      'resolvedBy': null,
    });

    // 6. Create Auth Credentials
    final auth = FirebaseAuth.instance;
    final demoUsers = [
      {'email': 'facility@medsupply.com', 'password': 'password123'},
      {'email': 'admin@medsupply.com', 'password': 'password123'},
    ];

    for (var user in demoUsers) {
      try {
        await auth.createUserWithEmailAndPassword(
          email: user['email']!, 
          password: user['password']!
        );
      } catch (e) {
        print("Auth account already exists for ${user['email']}");
      }
    }

    print("✅ Production Schema Seeding Complete!");
  }
}
