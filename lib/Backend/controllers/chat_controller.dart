import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
class ChatController extends GetxController {
  var messageText = ''.obs;
  final messageController = TextEditingController();
  // Cloudinary configuration
  final String cloudName =
      'dlut09a3l'; // Replace with your Cloudinary cloud name
  final String uploadPreset =
      'flutter_uploads'; // Replace with your unsigned upload preset
  // Observable for receiver name
  var receiverName = ''.obs;
  // Initialize with sender and receiver ids
  final String senderId;
  final String receiverId;
  ChatController({required this.senderId, required this.receiverId});
  @override
  void onInit() {
    super.onInit();
    fetchReceiverName();
  }
  // Fetch receiver name from Firestore
  Future<void> fetchReceiverName() async {
    try {
      final receiverDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(receiverId)
          .get();
      if (receiverDoc.exists) {
        receiverName.value = receiverDoc['name'] ?? 'Unknown User';
      } else {
        receiverName.value = 'Unknown User';
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch receiver name');
    }
  }
  Future<void> pickAndUploadFile() async {
    try {
      // Open file picker
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        String fileUrl = await uploadFileToCloudinary(file);
        if (fileUrl.isNotEmpty) {
          // Handle file URL (e.g., send message with file link)
          messageText.value = fileUrl;
          sendMessage(); // Use the file URL as the message content
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload file: $e');
      print(e);
    }
  }
  Future<String> uploadFileToCloudinary(File file) async {
    try {
      final url =
          Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/upload');
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', file.path));
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseData);
        return jsonResponse['secure_url']; // Cloudinary file URL
      } else {
        throw Exception(
            'Failed to upload file. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error uploading file to Cloudinary: $e');
    }
  }
  void sendMessage() async {
    if (messageText.value.trim().isNotEmpty) {
      try {
        // Create the message data to be sent to Firestore
        final messageData = {
          'sender_id': senderId,
          'receiver_id': receiverId,
          'text': messageText.value,
          'file_url': messageText.value.contains('http')
              ? messageText.value
              : null, // Check if it's a file URL
          'is_file': messageText.value
              .contains('http'), // Set to true if it's a file URL
          'time': FieldValue.serverTimestamp(), // Set the message timestamp
        };
        // Send the message to Firestore
        await FirebaseFirestore.instance
            .collection('messages')
            .add(messageData);
        // Show success feedback
        Get.snackbar("Success", "Message sent: ${messageText.value}");
        // Clear the input fields
        messageController.clear();
        messageText.value = '';
      } catch (e) {
        // Handle any errors that occur while sending the message
        Get.snackbar("Error", "Failed to send message: $e");
      }
    } else {
      Get.snackbar("Error", "Message cannot be empty");
    }
  }
}
