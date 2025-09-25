// lib/pages/map_picker_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import '../models/report.dart';

class MapPickerPage extends StatefulWidget {
  final List<Report> reports;
  MapPickerPage({this.reports = const []});
  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  final MapController _mapController = MapController();
  LatLng? selected;
  late List<Marker> markers;

  @override
  void initState() {
    super.initState();
    markers = widget.reports
        .where((r) => r.latitude != null && r.longitude != null)
        .map((r) => Marker(
              point: LatLng(r.latitude!, r.longitude!),
              width: 40,
              height: 40,
              child: Icon(Icons.location_on, size: 36, color: Colors.redAccent),
            ))
        .toList();
  }

  void _onTapMap(TapPosition tapPosition, LatLng latlng) {
    setState(() {
      selected = latlng;
      markers.add(Marker(
        point: latlng,
        width: 44,
        height: 44,
        child: Icon(Icons.location_pin, size: 40, color: Theme.of(context).colorScheme.primary),
      ));
    });
    // optional: pass selected back via Navigator.pop(context, selected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Peta Laporan'),
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: widget.reports.firstWhere(
                    (r) => r.latitude != null && r.longitude != null,
                    orElse: () => Report(
                      id: 'center',
                      title: '-',
                      description: '-',
                      category: '-',
                    ),
                  ).latitude != null
              ? LatLng(
                  widget.reports.firstWhere((r) => r.latitude != null && r.longitude != null).latitude!,
                  widget.reports.firstWhere((r) => r.latitude != null && r.longitude != null).longitude!,
                )
              : LatLng(-2.5489, 118.0149),
          zoom: 13.0,
          onTap: _onTapMap,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
            userAgentPackageName: 'dev.sorot.app',
          ),
          MarkerClusterLayerWidget(
            options: MarkerClusterLayerOptions(
              maxClusterRadius: 120,
              size: const Size(40, 40),
              alignment: Alignment.center,
              markers: widget.reports
                  .where((r) => r.latitude != null && r.longitude != null)
                  .map((r) => Marker(
                        point: LatLng(r.latitude!, r.longitude!),
                        width: 40,
                        height: 40,
                        child: Icon(Icons.location_on, color: Colors.red),
                      ))
                  .toList(),
              builder: (context, markers) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(markers.length.toString(), style: const TextStyle(color: Colors.white)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomSheet: selected == null
          ? null
          : Container(
              padding: EdgeInsets.all(12),
              color: Colors.white,
              child: Row(
                children: [
                  Icon(Icons.location_pin, color: Theme.of(context).colorScheme.primary),
                  SizedBox(width: 8),
                  Expanded(child: Text('Lokasi terpilih: ${selected!.latitude.toStringAsFixed(6)}, ${selected!.longitude.toStringAsFixed(6)}')),
                  ElevatedButton(
                    onPressed: () {
                      // gunakan lokasi ini untuk membuat laporan (kirim ke form/new report)
                      Navigator.pop(context, selected);
                    },
                    child: Text('Gunakan'),
                  )
                ],
              ),
            ),
    );
  }
}
