import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationSelectionPage extends StatefulWidget {
  @override
  _LocationSelectionPageState createState() => _LocationSelectionPageState();
}

class _LocationSelectionPageState extends State<LocationSelectionPage> {
  LatLng? selectedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Venue Location')),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(31.2156, 29.9553), // Default to Alexandria coordinates
          zoom: 15.0,
          onTap: (tapPosition, point) {
            setState(() {
              selectedLocation = point;
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          if (selectedLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  width: 80.0,
                  height: 80.0,
                  point: selectedLocation!,
                  child: Icon(Icons.location_on, color: Colors.red, size: 40.0), // Use 'child' instead of 'builder'
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (selectedLocation != null) {
            Navigator.pop(context, selectedLocation); // Return selected location
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please select a location")));
          }
        },
        child: Icon(Icons.check),
      ),
    );
  }
}
