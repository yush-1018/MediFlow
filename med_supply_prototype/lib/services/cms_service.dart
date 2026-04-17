import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/facility.dart';
import '../models/stock.dart';

class CMSService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream all facilities
  Stream<List<Facility>> streamFacilities() {
    return _db
        .collection('facilities')
        .snapshots()
        .map((s) => s.docs.map((d) => Facility.fromFirestore(d)).toList());
  }

  // Stream all stocks (for network-wide monitoring)
  Stream<List<Stock>> streamAllStocks() {
    return _db
        .collection('stocks')
        .snapshots()
        .map((s) => s.docs.map((d) => Stock.fromFirestore(d)).toList());
  }

  // Approve Indent Request (Triggers redistribution logic)
  Future<void> approveIndent(String requestId) async {
    await _db.collection('requests').doc(requestId).update({
      'status': 'APPROVED',
      'updatedAt': FieldValue.serverTimestamp(),
    });
    // Note: The onIndentApproved Cloud Function will handle the stock movement
  }
}
