import 'package:cloud_firestore/cloud_firestore.dart';

class VenueService {
  Future<Map<String, dynamic>> getOwnerDetails(String ownerId) async {
    var ownerDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(ownerId)
        .get();

    return ownerDoc.data() ?? {};
  }
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
    Stream<QuerySnapshot> getOwnerVenues(String ownerId) {
    return _firestore
        .collection('venues')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots();
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
