import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';
import '../controllers/inventory_controller.dart';
import '../models/stock.dart';

class FacilityDashboardScreen extends ConsumerWidget {
  const FacilityDashboardScreen({super.key});

  @override
  Widget build(Widget context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).value;
    final metrics = ref.watch(dashboardMetricsProvider);
    final filteredStocks = ref.watch(filteredStocksProvider);
    final searchQuery = ref.watch(stockSearchQueryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'MedSupply | ${profile?.facilityName ?? "Facility Dash"}',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Colors.indigo[900]),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.blueGrey),
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
          const SizedBox(width: 16),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Row(
        children: [
          // Sidebar (Simplified for MVP)
          Container(
            width: 250,
            color: Colors.white,
            child: Column(
              children: [
                _buildNavItem(Icons.dashboard, "Inventory", true),
                _buildNavItem(Icons.analytics, "AI Forecasting", false),
                _buildNavItem(Icons.swap_horiz, "Redistribution", false),
                _buildNavItem(Icons.history, "Usage Logs", false),
                const Spacer(),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "v1.0.0-MVP",
                    style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          
          // Main Content
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Header & KPIs
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Inventory Overview",
                          style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            _KPICard(
                              label: "Total Items",
                              value: metrics.totalMedicines.toString(),
                              icon: Icons.inventory_2,
                              color: Colors.blue,
                            ),
                            _KPICard(
                              label: "Low Stock",
                              value: metrics.lowStockItems.toString(),
                              icon: Icons.warning_amber_rounded,
                              color: Colors.orange,
                              isCritical: metrics.lowStockItems > 0,
                            ),
                            _KPICard(
                              label: "Expiring Soon",
                              value: metrics.expiringSoon.toString(),
                              icon: Icons.date_range,
                              color: Colors.red,
                              isCritical: metrics.expiringSoon > 0,
                            ),
                            _KPICard(
                              label: "Pending Indents",
                              value: metrics.pendingRequests.toString(),
                              icon: Icons.call_received,
                              color: Colors.green,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: TextField(
                      onChanged: (val) => ref.read(stockSearchQueryProvider.notifier).state = val,
                      decoration: InputDecoration(
                        hintText: "Search medicine, generic name, or category...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),

                // Stock Grid
                SliverPadding(
                  padding: const EdgeInsets.all(24.0),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 400,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.8,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _StockCard(
                        stock: filteredStocks[index],
                        onTap: () async {
                          final result = await showDialog(
                            context: context,
                            builder: (context) => LogUsageDialog(stock: filteredStocks[index]),
                          );
                          if (result == true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Usage logged successfully!")),
                            );
                          }
                        },
                      ),
                      childCount: filteredStocks.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: AddStockDialog
        },
        label: Text("Add Stock", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.indigo[900],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return ListTile(
      leading: Icon(icon, color: isActive ? Colors.blue[800] : Colors.grey),
      title: Text(
        label,
        style: GoogleFonts.outfit(
          color: isActive ? Colors.blue[800] : Colors.grey[700],
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isActive,
      onTap: () {},
    );
  }
}

class _KPICard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isCritical;

  const _KPICard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.isCritical = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isCritical ? Border.all(color: color.withOpacity(0.5), width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(value, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(label, style: GoogleFonts.outfit(color: Colors.grey[600])),
        ],
      ),
    );
  }
}

class _StockCard extends StatelessWidget {
  final Stock stock;
  final VoidCallback onTap;
  const _StockCard({required this.stock, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    stock.medicineName,
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildCategoryBadge(stock.category),
              ],
            ),
            Text(stock.genericName, style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 13)),
            const Spacer(),
            Row(
              children: [
                _buildMetric("Stock", "${stock.currentStock} ${stock.unit}"),
                const SizedBox(width: 24),
                _buildMetric("Expiry", "${stock.daysUntilExpiry}d", 
                  isWarning: stock.daysUntilExpiry < 90),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: stock.currentStock / (stock.minStockThreshold * 3), // Visual ratio
              backgroundColor: Colors.grey[200],
              color: stock.isLowStock ? Colors.orange : Colors.blue,
              minHeight: 6,
              borderRadius: BorderRadius.circular(10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.outfit(fontSize: 10, color: Colors.blue[800], fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMetric(String label, String value, {bool isWarning = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey[500])),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 14, 
            fontWeight: FontWeight.w600,
            color: isWarning ? Colors.red : Colors.black87,
          ),
        ),
      ],
    );
  }
}