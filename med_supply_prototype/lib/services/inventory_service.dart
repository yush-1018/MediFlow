import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/stock.dart';
import '../models/request.dart';

class InventoryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream of stocks for a specific facility (Subcollection)
  Stream<List<Stock>> streamStocks(String facilityId) {
    return _db
        .collection('facilities')
        .doc(facilityId)
        .collection('stocks')
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => Stock.fromFirestore(doc)).toList());
  }

  // Stream of pending requests for a specific facility
  Stream<List<IndentRequest>> streamPendingRequests(String facilityId) {
    return _db
        .collection('requests')
        .where('toFacilityId', isEqualTo: facilityId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => IndentRequest.fromFirestore(doc)).toList());
  }

  // --- WRITE OPERATIONS ---

  Future<void> logUsage(String facilityId, String stockId, int count, String loggedBy) async {
    final stockRef = _db.collection('facilities').doc(facilityId).collection('stocks').doc(stockId);
    final logRef = _db.collection('facilities').doc(facilityId).collection('usage_logs').doc();

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(stockRef);
      if (!snapshot.exists) throw Exception("Stock not found");

      final current = (snapshot.data()?['qtyRemaining'] ?? 0) as int;
      if (current < count) throw Exception("Insufficient stock");

      // Update Stock (Qty Remaining)
      transaction.update(stockRef, {
        'qtyRemaining': current - count, 
        'updatedAt': FieldValue.serverTimestamp()
      });

      // Create Usage Log (Step 3 Schema)
      transaction.set(logRef, {
        'stockId': stockId,
        'medicineName': snapshot.data()?['medicineName'],
        'qtyUsed': count,
        'loggedBy': loggedBy,
        'loggedAt': FieldValue.serverTimestamp(),
        'notes': 'Recorded via app',
      });
    });
  }

  Future<void> addStock(String facilityId, Stock stock) async {
    await _db
        .collection('facilities')
        .doc(facilityId)
        .collection('stocks')
        .add(stock.toFirestore());
  }
}
