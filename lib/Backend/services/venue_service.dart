import 'package:cloud_firestore/cloud_firestore.dart';

class VenueService {
  // Method to get details of an owner by ownerId
  Future<Map<String, dynamic>> getOwnerDetails(String ownerId) async {
    // Retrieve the document of the owner using the ownerId from Firestore
    var ownerDoc = await FirebaseFirestore.instance
        .collection('users') // Access the 'users' collection in Firestore
        .doc(ownerId) // Access the document with the provided ownerId
        .get(); // Fetch the document

    // Return the data of the document if it exists
    return ownerDoc.data() ?? {}; // Return null (an empty map) if no data found
  }
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to get the venues of a specific owner by their ownerId
    Stream<QuerySnapshot> getOwnerVenues(String ownerId) {
    return _firestore
        .collection('venues') // Access the 'venues' collection in Firestore
        .where('ownerId', isEqualTo: ownerId) // Filter venues by ownerId
        .snapshots(); // Return a stream of the snapshot, so it can be observed for real-time updates
  }

  Stream<QuerySnapshot> getReservations(String venueId) {
    return _firestore
        .collection('venues')
        .doc(venueId)
        .collection('reservations')
        .snapshots();
  }

Future<void> addVenue({
  required String ownerId,
  required String name,
  required String price,
  required String description,
  required double latitude,
  required double longitude,
}) async {
  await _firestore.collection('venues').add({
    'ownerId': ownerId,
    'name': name,
    'price': price,
    'description': description,
    'createdAt': DateTime.now().toIso8601String(),
    'latitude': latitude,
    'longitude': longitude,
  });
}

}
