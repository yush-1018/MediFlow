import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/stock.dart';
import '../models/request.dart';
import '../services/inventory_service.dart';
import 'auth_controller.dart';

// Stream of all stocks for the current user's facility
final stocksStreamProvider = StreamProvider<List<Stock>>((ref) {
  final profile = ref.watch(userProfileProvider).value;
  if (profile?.facilityId == null) return const Stream.empty();
  return InventoryService().streamStocks(profile!.facilityId!);
});

// Stream of pending requests for the current user's facility
final pendingRequestsStreamProvider = StreamProvider<List<IndentRequest>>((ref) {
  final profile = ref.watch(userProfileProvider).value;
  if (profile?.facilityId == null) return const Stream.empty();
  return InventoryService().streamPendingRequests(profile!.facilityId!);
});

// StateProvider for search query
final stockSearchQueryProvider = StateProvider<String>((ref) => '');

// Provider for filtered stocks based on search query
final filteredStocksProvider = Provider<List<Stock>>((ref) {
  final stocks = ref.watch(stocksStreamProvider).value ?? [];
  final query = ref.watch(stockSearchQueryProvider).toLowerCase();
  
  if (query.isEmpty) return stocks;
  return stocks.where((s) => 
    s.medicineName.toLowerCase().contains(query) || 
    s.genericName.toLowerCase().contains(query) ||
    s.category.toLowerCase().contains(query)
  ).toList();
});

// Provider for dashboard metrics
class DashboardMetrics {
  final int totalMedicines;
  final int lowStockItems;
  final int expiringSoon; // < 90 days
  final int pendingRequests;

  DashboardMetrics({
    required this.totalMedicines,
    required this.lowStockItems,
    required this.expiringSoon,
    required this.pendingRequests,
  });
}

final dashboardMetricsProvider = Provider<DashboardMetrics>((ref) {
  final stocks = ref.watch(stocksStreamProvider).value ?? [];
  final requests = ref.watch(pendingRequestsStreamProvider).value ?? [];

  return DashboardMetrics(
    totalMedicines: stocks.length,
    lowStockItems: stocks.where((s) => s.isLowStock).length,
    expiringSoon: stocks.where((s) => s.daysUntilExpiry < 90).length,
    pendingRequests: requests.length,
  );
});
