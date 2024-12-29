import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReservationController {
  //Firebase Authentication
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
//Display a dynamic list of venues
//Automatically updates data from the database
  Stream<QuerySnapshot> getVenues() {
    return FirebaseFirestore.instance.collection('venues').snapshots();
  }

//check if venue is reserved or not
//returns boolean value: true or false
  Future<bool> isReserved(String venueId) async {
    //Get uid of the currently logged-in user using Firebase Authentication
    // '!' --> access uid only if not null
    // '_' --> private variable
    String clientId = _firebaseAuth.currentUser!.uid;

    var reservations = await FirebaseFirestore.instance
        .collection('venues') // Access the "venues" collection in Firestore
        .doc(venueId)  // Locate the document corresponding to the given venue ID
        .collection('reservations')  // Access "reservations" within that venue's document
        .where('clientId', isEqualTo: clientId) // Query "reservations" where clientId matche current user's ID
        .get(); // Execute the query

    // If there is at least one document, return true , else false
    return reservations.docs.isNotEmpty;
  }

  // Create reservation by user for specific venue
  Future<void> makeReservation(String venueId) async {
    //Get uid of the currently logged-in user using Firebase Authentication
    // '!' --> access uid only if not null
    // '_' --> private variable
    String clientId = _firebaseAuth.currentUser!.uid;
    String clientName = (await FirebaseFirestore.instance
            .collection('users') // Access the "users" collection in Firestore
            .doc(clientId)  // Locate the document corresponding to the uid
            .get()) // Retrieve the document data
        .data()?['name'] ?? //Extract name field using uid
        'Anonymous'; // Anonymus if name field is null

    await FirebaseFirestore.instance
        .collection('venues') // Access the "venues" collection in Firestore
        .doc(venueId)  // Locate the document corresponding to the given venue ID
        .collection('reservations') // Access the "reservations"  within that venue's document
        .add({ // Add a new reservation document that includes:
      'clientId': clientId, // Client ID
      'clientName': clientName, // Client Name
      'time': DateTime.now().toIso8601String(),  // Current time
    });
  }

  // Get Owner Name
Future<String> getOwnerName() async {
  try {
    // Get current user ID
    String ownerId = _firebaseAuth.currentUser!.uid;

    // Fetch owner document from Firestore
    DocumentSnapshot ownerDoc = await FirebaseFirestore.instance
        .collection('users') // Access the "users" collection in Firestore
        .doc(ownerId) // Locate the document corresponding to the logged-in user
        .get();

    // Cast data() to Map<String, dynamic>
    Map<String, dynamic>? ownerData = ownerDoc.data() as Map<String, dynamic>?;

    // Return the name field if it exists, otherwise return "Owner"
    return ownerData?['name'] ?? "Owner";
  } catch (e) {
    print("Error fetching owner name: $e");
    return "Error";
  }
}

}
