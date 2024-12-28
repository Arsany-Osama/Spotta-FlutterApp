import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:spotta/Frontend/shared/chatScreen.dart';
import '../../Backend/controllers/venue_controller.dart';
import '../views/sign_screen.dart';
import 'add_venue_page.dart';
import 'package:google_fonts/google_fonts.dart';

class OwnerPage extends StatelessWidget {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final VenueController _venueController = Get.put(VenueController());

  void _logout() async {
    await _firebaseAuth.signOut();
    Get.offAll(SignUpScreen());
  }

  void _addVenue() {
    Get.to(AddVenuePage());
  }

  @override
  Widget build(BuildContext context) {
    String ownerId = _firebaseAuth.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          "Owner Page",
          style: GoogleFonts.lato(
              color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 88, 39, 6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person,
                        size: 50, color: Color.fromARGB(255, 88, 39, 6)),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Owner Name",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Profile'),
              onTap: () {
                // Navigate to profile
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                // Navigate to settings
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _venueController.fetchOwnerVenues(ownerId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No venues added.'));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              var venue = doc.data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.all(8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: ExpansionTile(
                  title: Text(venue['name'] ?? 'No Name', 
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      )),
                  subtitle: Text(
                    'Price: ${venue['price']}\n${venue['description'] ?? ''}',
                    style: GoogleFonts.poppins(color: Colors.black54),
                  ),
                  children: [
                    StreamBuilder<QuerySnapshot>(
                      stream: _venueController.fetchReservations(doc.id),
                      builder: (context, reservationsSnapshot) {
                        if (reservationsSnapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }

                        if (!reservationsSnapshot.hasData || reservationsSnapshot.data!.docs.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('No reservations yet.'),
                          );
                        }

                        return Column(
                          children: reservationsSnapshot.data!.docs.map((reservationDoc) {
                            var reservation = reservationDoc.data() as Map<String, dynamic>;

                            return ListTile(
                              title: Text(reservation['clientName'] ?? 'Unknown Client'),
                              subtitle: Text('Reserved on: ${reservation['time']}'),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  Get.to(
                                    ChatScreen(
                                      senderId: ownerId,
                                      receiverId: reservation['clientId'],
                                    ),
                                  );
                                },
                                child: Text('Chat'),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white, backgroundColor: Color.fromARGB(255, 88, 39, 6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    // Delete Button
                    ListTile(
                      title: Text('Delete Venue'),
                      leading: Icon(Icons.delete, color: Colors.red),
                      onTap: () async {
                        await _venueController.deleteVenue(doc.id);
                        Get.snackbar('Deleted', 'Venue has been deleted.',
                            snackPosition: SnackPosition.BOTTOM);
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addVenue,
        child: Icon(Icons.add),
        backgroundColor: Color.fromARGB(255, 88, 39, 6),
      ),
    );
  }
}
