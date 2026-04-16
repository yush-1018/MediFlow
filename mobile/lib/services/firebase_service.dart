import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  late DatabaseReference _dbRef;

  Future<void> init() async {
    await Firebase.initializeApp();
    _dbRef = FirebaseDatabase.instance.ref();
  }

  // Listen to inventory changes for a specific facility
  Stream<DatabaseEvent> getInventoryStream(String facilityId) {
    return _dbRef.child('inventory').child(facilityId).onValue;
  }

  // Update inventory after a vision scan
  Future<void> updateInventory(String facilityId, String itemId, Map<String, dynamic> data) async {
    await _dbRef.child('inventory').child(facilityId).child(itemId).set(data);
  }

  // List all available surplus from other facilities (Marketplace)
  Stream<DatabaseEvent> getMarketplaceStream() {
    return _dbRef.child('surplus').onValue;
  }
}
