import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/facility.dart';
import '../models/stock.dart';

class CMSService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream all facilities (Top-level)
  Stream<List<Facility>> streamFacilities() {
    return _db
        .collection('facilities')
        .snapshots()
        .map((s) => s.docs.map((d) => Facility.fromFirestore(d)).toList());
  }

  // Stream all stocks across the entire network (Collection Group Query)
  Stream<List<Stock>> streamAllStocks() {
    return _db
        .collectionGroup('stocks') // Step 3 Alignment: Collection Group for monitoring
        .snapshots()
        .map((s) => s.docs.map((d) => Stock.fromFirestore(d)).toList());
  }

  // Approve Indent Request (Step 4 Security: Only CMS Admin can run this)
  Future<void> approveIndent(String requestId, String adminId) async {
    await _db.collection('requests').doc(requestId).update({
      'status': 'approved',
      'resolvedAt': FieldValue.serverTimestamp(),
      'resolvedBy': adminId,
    });
  }
}
