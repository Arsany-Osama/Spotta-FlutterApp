import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Backend/controllers/phone_auth_controller.dart';  // Import the PhoneAuthService


class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final PhoneAuthService _phoneAuthService = PhoneAuthService();
  String? verificationId;
  bool isPhoneValid = false;

  // Send OTP
  Future<void> _sendOTP() async {
    String phoneNumber = _phoneController.text.trim();

    // Validate phone number format
    if (phoneNumber.length != 13 || !phoneNumber.startsWith('+20')) {
      Get.snackbar('Invalid Phone Number', 'Please enter a valid Egyptian phone number.');
      return;
    }

    try {
      // Send OTP
      _phoneAuthService.sendOTP(phoneNumber, (verificationId) {
        setState(() {
          this.verificationId = verificationId;
          isPhoneValid = true;
        });
      });

      Get.snackbar('OTP Sent', 'OTP has been sent to your phone.');
    } catch (e) {
      Get.snackbar('Error', 'Failed to send OTP. Please check the phone number and try again.');
    }
  }

// Verify OTP
Future<void> _verifyOTP() async {
  String otp = _otpController.text.trim();
  if (verificationId != null && otp.isNotEmpty) {
    try {
      await _phoneAuthService.verifyOTP(verificationId!, otp);
    } catch (e) {
      // Show error message and stay on the current screen
      Get.snackbar('OTP Error', 'Incorrect OTP. Please try again.');
    }
  } else {
    // Show error message for invalid OTP input
    Get.snackbar('Error', 'Please enter a valid OTP.');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone Number (+20)'),
              keyboardType: TextInputType.phone,
            ),
            if (isPhoneValid)
              Column(
                children: [
                  TextField(
                    controller: _otpController,
                    decoration: InputDecoration(labelText: 'Enter OTP'),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _verifyOTP,
                    child: Text('Verify OTP'),
                  ),
                ],
              ),
            if (!isPhoneValid)
              ElevatedButton(
                onPressed: _sendOTP,
                child: Text('Send OTP'),
              ),
          ],
        ),
      ),
    );
  }
}
