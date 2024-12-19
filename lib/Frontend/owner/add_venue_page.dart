import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import '../../Backend/controllers/venue_controller.dart';
import 'Location_Page.dart'; // Import the LocationSelectionPage

class AddVenuePage extends StatefulWidget {
  @override
  _AddVenuePageState createState() => _AddVenuePageState();
}

class _AddVenuePageState extends State<AddVenuePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  LatLng? venueLocation; // Selected venue location

  final VenueController _venueController = Get.find();

  Future<void> _saveVenue() async {
    if (_formKey.currentState!.validate() && venueLocation != null) {
      String ownerId = FirebaseAuth.instance.currentUser!.uid;

      await _venueController.addNewVenue(
        ownerId: ownerId,
        name: _nameController.text,
        price: _priceController.text,
        description: _descriptionController.text,
        latitude: venueLocation!.latitude,
        longitude: venueLocation!.longitude,
      );

      Get.back();
      Get.snackbar('Success', 'Venue added successfully');
    } else {
      Get.snackbar('Error', 'Please select a venue location');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Venue')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Venue Name'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter a name' : null,
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter a price' : null,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter a description' : null,
                ),
                SizedBox(height: 16.0),
                // Display the selected location if available
                ListTile(
                  title: Text(venueLocation == null
                      ? 'No location selected'
                      : 'Location: ${venueLocation!.latitude}, ${venueLocation!.longitude}'),
                  trailing: IconButton(
                    icon: Icon(Icons.map),
                    onPressed: () async {
                      // Navigate to the location selection screen
                      LatLng? selected = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LocationSelectionPage(),
                        ),
                      );

                      if (selected != null) {
                        setState(() {
                          venueLocation = selected; // Set the selected location
                        });
                      }
                    },
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _saveVenue,
                  child: Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
