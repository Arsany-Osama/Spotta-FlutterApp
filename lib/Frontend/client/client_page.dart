import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Backend/controllers/reservation_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../views/sign_screen.dart';
import 'venue_details_page.dart';

class ClientPage extends StatelessWidget {
  final ReservationController _reservationController = ReservationController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void _logout() async {
    await _firebaseAuth.signOut();
    Get.offAll(SignUpScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Client Page")),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(height: 30),
            ListTile(
              title: Text('Logout'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _reservationController.getVenues(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No venues available.'));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              var venue = doc.data() as Map<String, dynamic>;

              return FutureBuilder<bool>(
                future: _reservationController.isReserved(doc.id),
                builder: (context, isReservedSnapshot) {
                  if (isReservedSnapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  bool isReserved = isReservedSnapshot.data ?? false;

                  // Truncate description to fit in a single line
                  String shortDescription = venue['description'] != null
                      ? (venue['description'] as String).length > 100
                          ? (venue['description'] as String).substring(0, 100) + '...'
                          : venue['description'] as String
                      : 'No description available';

                  return Card(
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                      onTap: () {
                        // Navigate to VenueDetailsPage
                        Get.to(VenueDetailsPage(venueId: doc.id, venue: venue));
                      },
                      title: Text(venue['name'] ?? 'No Name'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Price: ${venue['price']}'),
                          Text(shortDescription), // Show truncated description
                          TextButton(
                            onPressed: () {
                              // When "See More" is tapped, navigate to VenueDetailsPage
                              Get.to(VenueDetailsPage(venueId: doc.id, venue: venue));
                            },
                            child: Text("See More", style: TextStyle(color: Colors.blue)),
                          ),
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: isReserved
                            ? null
                            : () {
                                _reservationController.makeReservation(doc.id).then((_) {
                                  Get.forceAppUpdate();
                                });
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isReserved ? Colors.grey : Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(isReserved ? 'Reserved' : 'Reserve'),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
