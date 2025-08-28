import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../strings.dart';

class MapPickerPage extends StatefulWidget {
  final LatLng initialLocation;

  const MapPickerPage({Key? key, required this.initialLocation})
    : super(key: key);

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  late LatLng pickedLocation;

  @override
  void initState() {
    super.initState();
    pickedLocation = widget.initialLocation;
  }

  void _onTap(LatLng latlng) {
    setState(() {
      pickedLocation = latlng;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF408000),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, pickedLocation);
            },
            child: const Text(
              Strings.confirm,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: pickedLocation,
          initialZoom: 15.0,
          onTap: (tapPosition, point) => _onTap(point),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 40,
                height: 40,
                point: pickedLocation,
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
