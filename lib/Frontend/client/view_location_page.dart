import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class LocationPage extends StatefulWidget {
  final double venueLatitude;
  final double venueLongitude;
  final String venueName;

  LocationPage({
    required this.venueLatitude,
    required this.venueLongitude,
    required this.venueName,
  });

  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  LatLng? clientLocation;
  late LatLng venueLocation;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    venueLocation = LatLng(widget.venueLatitude, widget.venueLongitude);
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Request location permission if not granted
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      // Retrieve the client's location
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        clientLocation = LatLng(position.latitude, position.longitude);
        isLoading = false; // Stop loading once location is retrieved
      });
    } catch (e) {
      setState(() {
        isLoading = false; // Stop loading even if an error occurs
      });
      print("Error retrieving client location: $e");
      _showErrorDialog(
          "Failed to get your location. Please enable location services.");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Route to ${widget.venueName}")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : clientLocation == null
              ? Center(
                  child: Text(
                    "Unable to retrieve your location.",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                )
              : FlutterMap(
                  options: MapOptions(
                    center: clientLocation ?? venueLocation, // Fallback to venue if no client location
                    zoom: 12,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: [
                        if (clientLocation != null) // Only show client location if available
                          Marker(
                            point: clientLocation!,
                            width: 30,
                            height: 30,
                            alignment: Alignment.center, // Correct usage for the marker's alignment
                            child: Icon(
                              Icons.location_pin,
                              color: Colors.blue,
                              size: 30,
                            ),
                          ),
                        Marker(
                          point: venueLocation,
                          width: 30,
                          height: 30,
                          alignment: Alignment.center, // Correct usage for the marker's alignment
                          child: Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 30,
                          ),
                        ),
                      ],
                    ),


                    if (clientLocation != null) // Only show route if client location is available
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: [clientLocation!, venueLocation],
                            color: Colors.blue,
                            strokeWidth: 4,
                          ),
                        ],
                      ),
                  ],
                ),
    );
  }
}
