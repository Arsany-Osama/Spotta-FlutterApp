import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../Frontend/shared/settings_screen.dart';  // Import the Settings Screen
import '../../Frontend/client/client_page.dart';
import '../../Frontend/owner/owner_page.dart';
//Handle phone number authentication,
//verify OTP
// manage user roles by checking the Firestore database
// navigating to the appropriate screens based on their role

class PhoneAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Method to send OTP
  Future<void> sendOTP(String phoneNumber, Function(String verificationId) onCodeSent) async {
    try {
      // Create a PhoneAuthCredential using verificationId and OTP
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber, // Phone number where OTP is sent
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Automatically signs in when verification is completed
          await _firebaseAuth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          // If the verification fails, display an error message
          Get.snackbar('Error', 'Failed to send OTP: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId); // Trigger when OTP is sent
        },
        codeAutoRetrievalTimeout: (String verificationId) {
      // called when OTP auto-retrieval times out
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
      // Create a PhoneAuthCredential using the verificationId and OTP
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId, // The verification ID from the previous method
        smsCode: otp, // The OTP code entered by the user
      );

      // Sign in with the credentials (verification ID , OTP)
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
          .collection('users') // Access the "users" collection in Firestore
          .where('phone', isEqualTo: phoneNumber) // Check if phone number matches any in the Firestore
          .get();

      return userDocs.docs.isNotEmpty;  // Return true if at least one document exists with this phone number
    } catch (e) {
      print('Error checking phone number in Firestore: $e');
      return false;  // Return false if any error occurs
    }
  }
}
