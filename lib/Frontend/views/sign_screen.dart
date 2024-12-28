import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Backend/controllers/phone_auth_controller.dart'; // Ensure this is implemented

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _phoneController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
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
    String otp = _otpControllers.map((controller) => controller.text).join();
    if (verificationId != null && otp.length == 6) {
      try {
        await _phoneAuthService.verifyOTP(verificationId!, otp);
        Get.snackbar('Success', 'Phone number verified successfully!');
      } catch (e) {
        Get.snackbar('OTP Error', 'Incorrect OTP. Please try again.');
      }
    } else {
      Get.snackbar('Error', 'Please enter a valid 6-digit OTP.');
    }
  }

  @override
 Widget build(BuildContext context) {
  final screenHeight = MediaQuery.of(context).size.height;
  final screenWidth = MediaQuery.of(context).size.width;

  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        isPhoneValid ? 'Phone Verification' : 'Continue with Phone',
        style: GoogleFonts.lato(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Illustration
          Center(
            child: Image.asset(
              'images/otp_image.png',
              height: screenHeight * 0.25,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 24),
          if (!isPhoneValid)
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Enter Your Phone Number',
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        labelStyle: GoogleFonts.poppins(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _sendOTP,
                      child: Text(
                        'Send OTP',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 88, 39, 6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: Size(screenWidth * 0.8, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (isPhoneValid)
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Enter the 6-digit OTP sent to ${_phoneController.text}',
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (index) {
                        return Container(
                          width: 45,
                          height: 55,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[400]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _otpControllers[index],
                            maxLength: 1,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              counterText: '',
                              border: InputBorder.none,
                            ),
                            style: GoogleFonts.poppins(fontSize: 18),
                            onChanged: (value) {
                              if (value.length == 1 && index < 5) {
                                FocusScope.of(context).nextFocus();
                              } else if (value.isEmpty && index > 0) {
                                FocusScope.of(context).previousFocus();
                              }
                            },
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Get.snackbar('Resending OTP', 'Please wait...');
                      },
                      child: Text(
                        'Didn’t receive code? Request again',
                        style: GoogleFonts.poppins(color: Color.fromARGB(255, 88, 39, 6)),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        Get.snackbar('Call Requested', 'You will receive a call with the OTP.');
                      },
                      child: Text(
                        'Get via Call',
                        style: GoogleFonts.poppins(color: Color.fromARGB(255, 88, 39, 6)),
                      ),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _verifyOTP,
                      child: Text(
                        'Verify and Proceed',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 88, 39, 6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: Size(screenWidth * 0.8, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
    backgroundColor: Color.fromARGB(243, 252, 247, 246),
  );
}
}
