import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../owner/owner_page.dart';
import '../client/client_page.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}
class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController nameController = TextEditingController();
  String selectedRole = "client"; // Default role is client
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Save user information to Firestore
  Future<void> saveUserToDatabase(String name, String role) async {
    User? user = _firebaseAuth.currentUser;

    if (user != null) {
      // Save the user data to Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': name,
        'role': role,
        'phone': user.phoneNumber, // Store the phone number
      });

      // Navigate based on the role
      if (role == "owner") {
        Get.to(() => OwnerPage()); // Redirect to the Owner page
      } else {
        Get.to(() => ClientPage()); // Redirect to the Client page
      }
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
          "Complete Your Profile",
          style: GoogleFonts.lato(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Name Input Section
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
                      'Enter Your Name',
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: GoogleFonts.poppins(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.name,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            
            // Top Illustration
            Center(
              child: Image.asset(
                'images/role_selection.png',
                height: screenHeight * 0.25,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Choose Your Role:',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16.0,
              runSpacing: 16.0,
              children: [
                _buildRoleCard(
                  context,
                  "Client",
                  "images/client_icon.png",
                  selectedRole == "client",
                  () {
                    setState(() {
                      selectedRole = "client";
                    });
                  },
                ),
                _buildRoleCard(
                  context,
                  "Owner",
                  "images/owner_icon.png",
                  selectedRole == "owner",
                  () {
                    setState(() {
                      selectedRole = "owner";
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                String name = nameController.text.trim();
                if (name.isNotEmpty) {
                  saveUserToDatabase(name, selectedRole);
                } else {
                  Get.snackbar('Error', 'Please enter your name.');
                }
              },
              child: Text(
                'Submit',
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
      backgroundColor: Color.fromARGB(243, 252, 247, 246),
    );
  }

  Widget _buildRoleCard(BuildContext context, String role, String imagePath, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: isSelected ? 6 : 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: isSelected ? Color.fromARGB(255, 88, 39, 6) : Colors.white,
        child: Container(
          width: 150,
          height: 200,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                height: 80,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 16),
              Text(
                role,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
