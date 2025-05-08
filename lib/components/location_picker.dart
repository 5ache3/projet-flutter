import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class PickLocationBox extends StatefulWidget {
  final Function(String) onLocationPicked;

  const PickLocationBox({Key? key, required this.onLocationPicked}) : super(key: key);

  @override
  State<PickLocationBox> createState() => _PickLocationBoxState();
}

class _PickLocationBoxState extends State<PickLocationBox> {
  LatLng? pickedLocation;
  final MapController _mapController = MapController();

  void _onTap(TapPosition tapPosition, LatLng location) {
    setState(() {
      pickedLocation = location;
    });
    final long=location.longitude;
    final lat =location.latitude;
    widget.onLocationPicked('${lat};${long}');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            center: LatLng(18.1606801, -15.9889051),
            zoom: 15.0,
            onTap: _onTap,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.projet',
            ),
            if (pickedLocation != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: pickedLocation!,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
