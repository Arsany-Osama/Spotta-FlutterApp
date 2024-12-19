import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../services/venue_service.dart';

class VenueController extends GetxController {
  final VenueService _venueService = VenueService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> fetchReservations(String venueId) {
    return _venueService.getReservations(venueId);
  }

  Future<void> addNewVenue({
    required String ownerId,
    required String name,
    required String price,
    required String description,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _firestore.collection('venues').add({
        'ownerId': ownerId,
        'name': name,
        'price': price,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding venue: $e');
    }
  }

   // Fetch venues of a specific owner
  Stream<QuerySnapshot> fetchOwnerVenues(String ownerId) {
    return _firestore
        .collection('venues')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots();
  }

    // Delete a venue by ID
  Future<void> deleteVenue(String venueId) async {
    try {
      await _firestore.collection('venues').doc(venueId).delete();
    } catch (e) {
      print('Error deleting venue: $e');
    }
  }
}
