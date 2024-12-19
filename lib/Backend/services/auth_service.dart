import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Verify Phone Number
  Future<void> verifyPhone(String phoneNumber) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _firebaseAuth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        throw e.message!;
      },
      codeSent: (String verificationId, int? resendToken) {
        // Save the verificationId to use later for verifying OTP
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // Verify OTP and sign in
  Future<void> verifyOtp(String otp, String verificationId) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );

    await _firebaseAuth.signInWithCredential(credential);
  }

  // Create user in Firestore
  Future<void> createUser(UserModel user) async {
    await FirebaseFirestore.instance.collection('users').add({
      'name': user.name,
      'role': user.role,
      'phone': _firebaseAuth.currentUser!.phoneNumber,
    });
  }

  // Delete the user from Firestore
  Future<void> deleteUser(String userId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).delete();
  }
}
