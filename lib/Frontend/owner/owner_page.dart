import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:spotta/Frontend/shared/chatScreen.dart';
import '../../Backend/controllers/venue_controller.dart';
import '../views/sign_screen.dart';
import 'add_venue_page.dart';

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
      appBar: AppBar(title: Text("Owner Page")),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(height: 30,),
            ListTile(
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
                child: ExpansionTile(
                  title: Text(venue['name'] ?? 'No Name'),
                  subtitle: Text('Price: ${venue['price']}\n${venue['description'] ?? ''}'),
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
                                  // //MARK : OWNER CHAT WITH THE CLIENT BY CLIENT ID HERE
                                  Get.to(
                                    ChatScreen(
                                      senderId: ownerId ,
                                      receiverId: reservation['clientId'],
                                      )
                                    );
                                },
                                child: Text('Chat'),
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
                        Get.snackbar('Deleted', 'Venue has been deleted.');
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
        backgroundColor: Colors.blue,
      ),
    );
  }
}
