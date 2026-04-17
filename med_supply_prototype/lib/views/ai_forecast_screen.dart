import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/ai_service.dart';
import '../models/stock.dart';

class AIForecastScreen extends StatefulWidget {
  final Stock stock;
  const AIForecastScreen({super.key, required this.stock});

  @override
  State<AIForecastScreen> createState() => _AIForecastScreenState();
}

class _AIForecastScreenState extends State<AIForecastScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _forecast;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchForecast();
  }

  Future<void> _fetchForecast() async {
    try {
      final result = await AIService().getDemandForecast(
        widget.stock.id, 
        widget.stock.medicineName
      );
      if (mounted) {
        setState(() {
          _forecast = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          "AI Intelligence | ${widget.stock.medicineName}",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.indigo[900],
      ),
      body: _isLoading 
        ? _buildLoading()
        : _error != null 
          ? _buildError()
          : _buildContent(),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text("Gemini 1.5 Pro is analyzing trends...", style: GoogleFonts.outfit()),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center, style: GoogleFonts.outfit()),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _fetchForecast, child: const Text("Retry")),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final predicted = _forecast?['predictedDemandNext30Days'] ?? 0;
    final confidence = (_forecast?['confidenceScore'] ?? 0.0) * 100;
    final insights = List<String>.from(_forecast?['insights'] ?? []);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroCard(predicted, confidence),
          const SizedBox(height: 24),
          Text("Demand Trend Projection", 
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildChart(),
          const SizedBox(height: 32),
          Text("AI Reasoning & Insights", 
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...insights.map((i) => _buildInsightTile(i)),
          const SizedBox(height: 40),
          _buildActionButtons(predicted),
        ],
      ),
    );
  }

  Widget _buildHeroCard(int predicted, double confidence) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.indigo[900]!, Colors.blue[900]!]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("PREDICTED DEMAND", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12, letterSpacing: 1.2)),
                const SizedBox(height: 8),
                Text("$predicted Units", style: GoogleFonts.outfit(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                Text("next 30 days", style: GoogleFonts.outfit(color: Colors.white60)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
            child: Column(
              children: [
                Text("${confidence.toInt()}%", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                Text("Confidence", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 3), FlSpot(1, 4), FlSpot(2, 3.5), FlSpot(3, 5), FlSpot(4, 4), FlSpot(5, 6),
              ],
              isCurved: true,
              color: Colors.blueAccent,
              barWidth: 4,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: Colors.blueAccent.withOpacity(0.1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightTile(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: GoogleFonts.outfit(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildActionButtons(int predicted) {
    final status = predicted > widget.stock.currentStock ? "Critical" : "Stable";
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_shopping_cart),
            label: Text("Quick Indent Request", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: status == "Critical" ? Colors.orange[800] : Colors.blue[800],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}
