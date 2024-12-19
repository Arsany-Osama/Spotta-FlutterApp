import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../Frontend/shared/settings_screen.dart';  // Import the Settings Screen
import '../../Frontend/client/client_page.dart';
import '../../Frontend/owner/owner_page.dart';

class PhoneAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Method to send OTP
  Future<void> sendOTP(String phoneNumber, Function(String verificationId) onCodeSent) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Automatically signs in when verification is completed
          await _firebaseAuth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          // Handle errors here
          Get.snackbar('Error', 'Failed to send OTP: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId); // Trigger the callback when code is sent
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Handle auto-retrieval timeout
          Get.snackbar('Timeout', 'OTP retrieval timeout');
        },
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to send OTP: $e');
    }
  }

  // Method to verify OTP
  Future<void> verifyOTP(String verificationId, String otp) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      // Sign in with the OTP
      await _firebaseAuth.signInWithCredential(credential);

      // Get the phone number of the current user
      String phoneNumber = _firebaseAuth.currentUser!.phoneNumber!;

      // Check if the phone number exists in Firestore
      bool phoneExists = await _checkIfPhoneNumberExistsInDatabase(phoneNumber);

      if (phoneExists) {
        // If phone number exists, check the user's role from Firestore
        var userDoc = await FirebaseFirestore.instance.collection('users').where('phone', isEqualTo: phoneNumber).get();
        
        // Check if the query returns any documents
        if (userDoc.docs.isNotEmpty) {
          // Get the role from the first document (if there are any)
          String role = userDoc.docs.first['role'];

          // Navigate based on the role
          if (role == "owner") {
            Get.to(() => OwnerPage());  // Navigate to Owner page
          } else if (role == "client") {
            Get.to(() => ClientPage());  // Navigate to Client page
          } else {
            // Handle case where the role is missing or invalid
            Get.snackbar('Error', 'Role not found for this user.');
          }
        }
      } else {
        // If phone number doesn't exist, navigate to SettingsScreen to complete profile
        Get.to(() => SettingsScreen());  // Navigate to Settings/Complete Profile screen
      }
    } catch (e) {
      // If OTP verification fails
      Get.snackbar('Error', 'Incorrect OTP');
    }
  }

  // Method to check if the phone number exists in Firestore
  Future<bool> _checkIfPhoneNumberExistsInDatabase(String phoneNumber) async {
    try {
      // Query Firestore to check if any user document contains this phone number
      var userDocs = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: phoneNumber)
          .get();

      return userDocs.docs.isNotEmpty;  // Return true if at least one document exists with this phone number
    } catch (e) {
      print('Error checking phone number in Firestore: $e');
      return false;  // Return false if any error occurs
    }
  }
}
