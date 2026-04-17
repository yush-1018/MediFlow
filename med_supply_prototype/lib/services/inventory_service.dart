import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/stock.dart';
import '../models/request.dart';

class InventoryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream of stocks for a specific facility
  Stream<List<Stock>> streamStocks(String facilityId) {
    return _db
        .collection('stocks')
        .where('facilityId', isEqualTo: facilityId)
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => Stock.fromFirestore(doc)).toList());
  }

  // Stream of pending requests for a specific facility
  Stream<List<IndentRequest>> streamPendingRequests(String facilityId) {
    return _db
        .collection('requests')
        .where('destinationFacilityId', isEqualTo: facilityId)
        .where('status', isEqualTo: 'PENDING')
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => IndentRequest.fromFirestore(doc)).toList());
  }

  // --- WRITE OPERATIONS ---

  Future<void> logUsage(String stockId, int count, String loggedBy) async {
    final stockRef = _db.collection('stocks').doc(stockId);
    final logRef = _db.collection('usage_logs').doc();

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(stockRef);
      if (!snapshot.exists) throw Exception("Stock not found");

      final current = snapshot.data()?['currentStock'] ?? 0;
      if (current < count) throw Exception("Insufficient stock");

      // Update Stock
      transaction.update(stockRef, {'currentStock': current - count, 'updatedAt': FieldValue.serverTimestamp()});

      // Create Log
      transaction.set(logRef, {
        'stockId': stockId,
        'medicineName': snapshot.data()?['medicineName'],
        'quantityUsed': count,
        'loggedBy': loggedBy,
        'timestamp': FieldValue.serverTimestamp(),
        'facilityId': snapshot.data()?['facilityId'],
      });
    });
  }

  Future<void> addStock(Stock stock) async {
    await _db.collection('stocks').add(stock.toFirestore());
  }

  Future<void> updateStock(String stockId, Map<String, dynamic> data) async {
    await _db.collection('stocks').doc(stockId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
