import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Frontend/views/sign_screen.dart';  // Import the SignUp Screen
import 'Frontend/client/client_page.dart';  // Import the Client Page
import 'Frontend/owner/owner_page.dart';   // Import the Owner Page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();  // Initialize Firebase

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Function to get the user's role from Firestore
  Future<String> _getUserRole(String uid) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc['role'] ?? 'client';  // Default to 'client' if role is not found
      } else {
        return 'client';  // If user document doesn't exist, default to 'client'
      }
    } catch (e) {
      print('Error fetching role: $e');
      return 'client';  // Default to 'client' on error
    }
  }

  @override
  Widget build(BuildContext context) {
    return 
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<User?>(
        future: _firebaseAuth.currentUser != null
            ? Future.value(_firebaseAuth.currentUser)
            : Future.value(null),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();  // Show loading while checking the user
          }

          if (snapshot.hasData) {
            User user = snapshot.data!;

            // Retrieve user role from Firestore
            return FutureBuilder<String>(
              future: _getUserRole(user.uid),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();  // Show loading while getting role
                }

                if (roleSnapshot.hasData) {
                  String role = roleSnapshot.data!;

                  // Navigate based on role
                  if (role == 'client') {
                    return ClientPage();  // Navigate to the ClientPage if the role is client
                  } else if (role == 'owner') {
                    return OwnerPage();  // Navigate to the OwnerPage if the role is owner
                  } else {
                    return SignUpScreen();  // Default to SignUpScreen if no role is found
                  }
                } else {
                  return SignUpScreen();  // If role retrieval fails, show SignUpScreen
                }
              },
            );
          } else {
            return SignUpScreen();  // If no user is logged in, show SignUpScreen
          }
        },
      ),
    );
  }
}











/*
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
*/
