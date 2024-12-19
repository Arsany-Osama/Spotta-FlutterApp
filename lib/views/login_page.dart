import 'package:flutter/material.dart';
import 'otp_verification_page.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final TextEditingController phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/background_image.jpg', // Replace with your background image
              fit: BoxFit.cover, // This ensures the image covers the entire screen
            ),
          ),
          // Black overlay with transparency to focus attention on the content
          Positioned.fill(
            child: Container(
              color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5), // 30% opacity for a dark effect
            ),
          ),
          // Main content on top of the overlay
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Login Image (logo or illustration)
                  const SizedBox(height: 20),
                  Text(
                    "Login with your phone number",
                    style: GoogleFonts.poppins( // Apply GoogleFonts
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White text for contrast
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Phone number input field
                  TextField(
                    controller: phoneNumberController,
                    keyboardType: TextInputType.phone,
                    style: GoogleFonts.roboto( // Apply GoogleFonts
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      labelStyle: GoogleFonts.roboto( // Apply GoogleFonts
                        color: Colors.white70,
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2), // Light transparent background for the field
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white70),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.phone, color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Login Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 88, 39, 6),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      final phoneNumber = phoneNumberController.text.trim();
                      if (phoneNumber.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                OTPVerificationPage(phoneNumber: phoneNumber),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a valid phone number'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
                    child: Text(
                      'Login',
                      style: GoogleFonts.poppins( // Apply GoogleFonts
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
