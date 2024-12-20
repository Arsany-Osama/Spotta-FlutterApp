import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:spotta/Frontend/shared/chatScreen.dart';
//import 'package:geolocator/geolocator.dart'; // For accessing client location
import './view_location_page.dart';
import '../../Backend/services/venue_service.dart';

String clientId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';

class VenueDetailsPage extends StatelessWidget {
  final String venueId;
  final Map<String, dynamic> venue;

  VenueDetailsPage({required this.venueId, required this.venue});

  final VenueService _venueService = VenueService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(venue['name'] ?? 'Venue Details')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _venueService.getOwnerDetails(venue['ownerId']),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Owner details not found.'));
          }

          var owner = snapshot.data!;
          DateTime createdAt = (venue['createdAt'] as Timestamp).toDate();
          double latitude = venue['latitude'] ?? 0.0;
          double longitude = venue['longitude'] ?? 0.0;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Text(
                  'Owner Name: ${owner['name'] ?? 'Unknown'}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Owner Phone: ${owner['phone'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                Text(
                  'Venue Name: ${venue['name'] ?? 'Unknown'}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Price: ${venue['price'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 16, fontStyle:FontStyle.italic),
                ),
                SizedBox(height: 8),
                Text(
                  'Description: ${venue['description'] ?? 'No description available.'}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Created At: ${createdAt.toLocal()}',
                  style: TextStyle(fontSize: 16),
                ),
                
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LocationPage(
                          venueLatitude: latitude,
                          venueLongitude: longitude,
                          venueName: venue['name'],
                        ),
                      ),
                    );
                  },
                  child: Text('View Location'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {// //MARK : CLIENT Want to CHAT WITH THE OWNER BY OWNER ID HERE
                    Get.to(
                      ChatScreen(
                        senderId: clientId,
                        receiverId: venue['ownerId'],
                      )
                    );
                  },
                  child: Text('Chat with Owner'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
