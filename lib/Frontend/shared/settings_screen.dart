import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../owner/owner_page.dart';
import '../client/client_page.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController nameController = TextEditingController();
  String selectedRole = "client";  // Default role is client
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
        Get.to(() => OwnerPage());  // Redirect to the Owner page
      } else {
        Get.to(() => ClientPage());  // Redirect to the Client page
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Complete Your Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Enter Your Name'),
            ),
            SizedBox(height: 20),
            Text("Select Your Role:"),
            Row(
              children: [
                Radio<String>(
                  value: "client",
                  groupValue: selectedRole,
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value!;
                    });
                  },
                ),
                Text("Client"),
                Radio<String>(
                  value: "owner",
                  groupValue: selectedRole,
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value!;
                    });
                  },
                ),
                Text("Owner"),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String name = nameController.text.trim();
                if (name.isNotEmpty) {
                  saveUserToDatabase(name, selectedRole);
                } else {
                  Get.snackbar("Error", "Please enter your name.");
                }
              },
              child: Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
