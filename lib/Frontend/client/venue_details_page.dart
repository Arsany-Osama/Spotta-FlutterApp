import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spotta/Frontend/shared/chatScreen.dart';
import './view_location_page.dart';
import '../../Backend/services/venue_service.dart';
import 'package:google_fonts/google_fonts.dart';

String clientId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';

class VenueDetailsPage extends StatelessWidget {
  final String venueId;
  final Map<String, dynamic> venue;

  VenueDetailsPage({required this.venueId, required this.venue});

  final VenueService _venueService = VenueService();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          venue['name'] ?? 'Venue Details',
          style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Owner Details
                Text(
                  'Owner Name: ${owner['name'] ?? 'Unknown'}',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Owner Phone: ${owner['phone'] ?? 'N/A'}',
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
                SizedBox(height: 16),

                // Venue Details
                Text(
                  'Venue Name: ${venue['name'] ?? 'Unknown'}',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Price: ${venue['price'] ?? 'N/A'}',
                  style: GoogleFonts.poppins(fontSize: 16, fontStyle: FontStyle.italic),
                ),
                SizedBox(height: 8),
                Text(
                  'Description: ${venue['description'] ?? 'No description available.'}',
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Created At: ${createdAt.toLocal()}',
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
                SizedBox(height: 16),

                // Buttons
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
                  child: Text(
                    'View Location',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 88, 39, 6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: Size(screenWidth * 0.8, 50),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Get.to(
                      ChatScreen(
                        senderId: clientId,
                        receiverId: venue['ownerId'],
                      ),
                    );
                  },
                  child: Text(
                    'Chat with Owner',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 88, 39, 6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: Size(screenWidth * 0.8, 50),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
