import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../services/venue_service.dart';

class VenueController extends GetxController {
  final VenueService _venueService = VenueService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// Method to fetch reservations for a specific venue
// Returns a stream of reservations //Automatically updates data from Firestore
  Stream<QuerySnapshot> fetchReservations(String venueId) {
    return _venueService.getReservations(venueId);
  }

// Method to add a new venue to Firestore
  Future<void> addNewVenue({
    // Data of the new venue
    required String ownerId,
    required String name,
    required String price,
    required String description,
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Adds the new venue data to the Firestore 'venues' collection
      await _firestore.collection('venues').add({
        'ownerId': ownerId, // Owner ID of the venue
        'name': name, // Name of the venue
        'price': price, // Price of the venue
        'description': description, // Description of the venue
        'latitude': latitude, //Latitude of the  venue
        'longitude': longitude, // Longitude of the venue
        'createdAt': FieldValue.serverTimestamp(), // Timestamps when the venues was added
      });
    } catch (e) {
      print('Error adding venue: $e');
    }
  }

  // Method to fetch all venues for a specific owner
  // Returns a stream of reservations //Automatically updates data from Firestore
  Stream<QuerySnapshot> fetchOwnerVenues(String ownerId) {
    return _firestore
        .collection('venues') // Access the "venues" collection
        .where('ownerId', isEqualTo: ownerId) // Filter venues by ownerID
        .snapshots(); //Returns the stream that updates data automatically
  }

  // Method to delete a venue from Firestore by its ID
  Future<void> deleteVenue(String venueId) async {
    try {
      await _firestore.collection('venues').doc(venueId).delete();
    } catch (e) {
      print('Error deleting venue: $e');
    }
  }
}
