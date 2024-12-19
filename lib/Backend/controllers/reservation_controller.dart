import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReservationController {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<QuerySnapshot> getVenues() {
    return FirebaseFirestore.instance.collection('venues').snapshots();
  }

  Future<bool> isReserved(String venueId) async {
    String clientId = _firebaseAuth.currentUser!.uid;

    var reservations = await FirebaseFirestore.instance
        .collection('venues')
        .doc(venueId)
        .collection('reservations')
        .where('clientId', isEqualTo: clientId)
        .get();

    return reservations.docs.isNotEmpty;
  }

  Future<void> makeReservation(String venueId) async {
    String clientId = _firebaseAuth.currentUser!.uid;
    String clientName = (await FirebaseFirestore.instance
            .collection('users')
            .doc(clientId)
            .get())
        .data()?['name'] ??
        'Anonymous';

    await FirebaseFirestore.instance
        .collection('venues')
        .doc(venueId)
        .collection('reservations')
        .add({
      'clientId': clientId,
      'clientName': clientName,
      'time': DateTime.now().toIso8601String(),
    });
  }
}
