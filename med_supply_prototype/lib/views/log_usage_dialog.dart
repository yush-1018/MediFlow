import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/stock.dart';
import '../services/inventory_service.dart';
import '../controllers/auth_controller.dart';

class LogUsageDialog extends StatefulWidget {
  final Stock stock;
  const LogUsageDialog({super.key, required this.stock});

  @override
  State<LogUsageDialog> createState() => _LogUsageDialogState();
}

class _LogUsageDialogState extends State<LogUsageDialog> {
  final _countController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _submit(WidgetRef ref) async {
    final count = int.tryParse(_countController.text);
    if (count == null || count <= 0) {
      setState(() => _error = "Enter a valid quantity");
      return;
    }

    if (count > widget.stock.qtyRemaining) {
      setState(() => _error = "Insufficient stock available");
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = ref.read(userProfileProvider).value;
      if (user?.facilityId == null) throw Exception("User facility not found");

      await InventoryService().logUsage(
        user!.facilityId!,
        widget.stock.id, 
        count, 
        user.displayName // Step 3 rename
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        "Log Usage: ${widget.stock.medicineName}",
        style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Available: ${widget.stock.qtyRemaining} ${widget.stock.unit}",
            style: GoogleFonts.outfit(color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _countController,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              labelText: "Quantity Used",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              errorText: _error,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text("Cancel", style: GoogleFonts.outfit(color: Colors.grey)),
        ),
        Consumer(
          builder: (context, ref, child) => ElevatedButton(
            onPressed: _isLoading ? null : () => _submit(ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981), // Emerald Medical Theme
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text("Log Consumption", style: GoogleFonts.outfit()),
          ),
        ),
      ],
    );
  }
}
