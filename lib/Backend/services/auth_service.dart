import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
//Authenticate users from Firebase Authentication using phone numbers and OTP


class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Verify Phone Number
  Future<void> verifyPhone(String phoneNumber) async {
     // Initiates phone number verification process.
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber, // The phone number to verify
      verificationCompleted: (PhoneAuthCredential credential) async { // called when the verification is successful
      // Firebase automatically signs the user in.
        await _firebaseAuth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) { //called if the verification fails (like wrong phone number)
        throw e.message!;
      },
     // triggered when  OTP is sent to the user's phone.
      codeSent: (String verificationId, int? resendToken) {
        // Save the verificationId to use later for verifying OTP
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
      // called when OTP auto-retrieval times out
    );
  }

  // Verify OTP and sign in
  Future<void> verifyOtp(String otp, String verificationId) async {
    // Create a PhoneAuthCredential using the verificationId and OTP entered by the user.
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId, // The verificationId from the codeSent
      smsCode: otp, // The OTP entered by the user
    );
    // Sign the user in using the provided OTP.
    await _firebaseAuth.signInWithCredential(credential);// Sign in with the credentials.
  }

  // Create user in Firestore
  Future<void> createUser(UserModel user) async {
    // Add a new user document in Firestore collection 'users'
    await FirebaseFirestore.instance.collection('users').add({
      'name': user.name, // User name
      'role': user.role, //User role
      'phone': _firebaseAuth.currentUser!.phoneNumber, // User phone number (From Firebase)
    });
  }

  // Delete the user from Firestore
  Future<void> deleteUser(String userId) async {
    // Delete the user document from Firestore by userId.
    await FirebaseFirestore.instance.collection('users').doc(userId).delete();
  }
}
