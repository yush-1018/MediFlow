import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';
import 'inventory_map_view.dart';

class CMSDashboardScreen extends ConsumerWidget {
  const CMSDashboardScreen({super.key});

  @override
  Widget build(Widget context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(
          'MedSupply CMS | Global Command Center',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Colors.blue[900]),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
          const SizedBox(width: 16),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Row(
        children: [
          // CMS Sidebar
          Container(
            width: 280,
            color: Colors.indigo[900],
            child: Column(
              children: [
                const SizedBox(height: 32),
                _buildCMSNavItem(Icons.map, "Supply Map", true),
                _buildCMSNavItem(Icons.sync_alt, "Redistributions", false),
                _buildCMSNavItem(Icons.account_balance, "Facilities", false),
                _buildCMSNavItem(Icons.settings, "Network Settings", false),
                const Spacer(),
                const Divider(color: Colors.white24),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      const CircleAvatar(radius: 20, backgroundColor: Colors.white24, child: Icon(Icons.person, color: Colors.white)),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Central Admin", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                          Text("HQ Level Access", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Content
          const Expanded(
            child: InventoryMapView(),
          ),
        ],
      ),
    );
  }

  Widget _buildCMSNavItem(IconData icon, String label, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          label,
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: isActive ? FontWeight.bold : FontWeight.normal),
        ),
        onTap: () {},
      ),
    );
  }
}
