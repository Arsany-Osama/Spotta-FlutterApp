import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future<User?> getCurrentUser() async {
    try {
      return _auth.currentUser;
    } catch (e) {
      throw Exception("Error getting current user: $e");
    }
  }

  Future<String?> fetchReceiverName(String receiverId) async {
    try {
      final receiverDoc =
          await _fireStore.collection('users').doc(receiverId).get();
      if (receiverDoc.exists) {
        return receiverDoc['name'];
      }
      return null;
    } catch (e) {
      throw Exception("Error fetching receiver name: $e");
    }
  }

  Future<void> sendMessage(
    String senderId,
    String receiverId,
    String content, {
    bool isFile = false,
    String? fileName,
  }) async {
    try {
      await _fireStore.collection('messages').add({
        'sender_id': senderId,
        'receiver_id': receiverId,
        'text': isFile ? null : content,
        'file_url': isFile ? content : null,
        'file_name': isFile ? fileName : null,
        'is_file': isFile,
        'time': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Error sending message: $e");
    }
  }

  Future<String?> fetchUserRole(String senderId) async {
    try {
      final userDoc = await _fireStore.collection('users').doc(senderId).get();
      if (userDoc.exists) {
        return userDoc['role'];
      }
      return null;
    } catch (e) {
      throw Exception("Error fetching user role: $e");
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception("Error logging out: $e");
    }
  }
}
