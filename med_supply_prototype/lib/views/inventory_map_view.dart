import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/facility.dart';
import '../services/cms_service.dart';

class InventoryMapView extends StatefulWidget {
  const InventoryMapView({super.key});

  @override
  State<InventoryMapView> createState() => _InventoryMapViewState();
}

class _InventoryMapViewState extends State<InventoryMapView> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};

  // Initial Camera Position (India - for demo)
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(28.6139, 77.2090),
    zoom: 12,
  );

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Facility>>(
      stream: CMSService().streamFacilities(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _updateMarkers(snapshot.data!);
        }

        return Stack(
          children: [
            GoogleMap(
              initialCameraPosition: _initialPosition,
              onMapCreated: _onMapCreated,
              markers: _markers,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true,
              mapType: MapType.normal,
              style: _mapStyle, // Custom map styling for premium look
            ),
            
            // Map Overlay Legend/Status
            Positioned(
              top: 24,
              right: 24,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Facility Health", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildLegendItem(Colors.green, "Optimum Stock"),
                    _buildLegendItem(Colors.orange, "Low Stock Alert"),
                    _buildLegendItem(Colors.red, "Critical Scarcity"),
                  ],
                ),
              ),
            ),

            // Bottom HUD
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
                ),
                child: Row(
                  children: [
                    _buildHUDStat("Active Nodes", "24"),
                    _buildHUDStat("Total Indents", "12"),
                    _buildHUDStat("Redistributions", "8"),
                    _buildHUDStat("Avg Demand", "85%", isLast: true),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _updateMarkers(List<Facility> facilities) {
    setState(() {
      _markers.clear();
      for (final f in facilities) {
        _markers.add(
          Marker(
            markerId: MarkerId(f.id),
            position: LatLng(f.latitude, f.longitude),
            infoWindow: InfoWindow(
              title: f.name,
              snippet: "Health Index: ${f.healthScore}%",
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              f.healthScore > 80 ? BitmapDescriptor.hueGreen : 
              f.healthScore > 40 ? BitmapDescriptor.hueOrange : BitmapDescriptor.hueRed
            ),
          ),
        );
      }
    });
  }

  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.outfit(fontSize: 12, color: Colors.blueGrey[800])),
        ],
      ),
    );
  }

  Widget _buildHUDStat(String label, String value, {bool isLast = false}) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: isLast ? null : Border(right: BorderSide(color: Colors.grey[200]!)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo[900])),
            Text(label, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  // Modern Silver/Healthcare Map Style (JSON)
  static const String _mapStyle = '''[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e9e9e9"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  }
]''';
}
