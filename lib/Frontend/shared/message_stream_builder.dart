import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

final _fireStore = FirebaseFirestore.instance;

class MessageStreamBuilder extends StatelessWidget {
  final String senderId;
  final String receiverId;
  final String receiverName;

  const MessageStreamBuilder({
    super.key,
    required this.senderId,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _fireStore
          .collection('messages')
          .where('sender_id', whereIn: [senderId, receiverId])
          .where('receiver_id', whereIn: [senderId, receiverId])
          .orderBy('time', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          debugPrint("Error: ${snapshot.error}");
          return const Center(child: Text("Error loading messages."));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No messages yet."));
        }

        final messages = snapshot.data!.docs;
        List<MessageLine> messageWidgets = messages.map((message) {
          final messageText = message.get('text');
          final messageSender = message.get('sender_id');

          // Safely access the 'file_url' and 'file_name'
          final messageData = message.data()
              as Map<String, dynamic>?; // Cast to Map<String, dynamic>
          final fileUrl = messageData?['file_url']; // Use null-aware operator
          final fileName = messageData?['file_name']; // Use null-aware operator
          final isFile =
              messageData?['is_file'] ?? false; // Use null-aware operator
          final isMe = senderId == messageSender;

          return MessageLine(
            sender: isMe ? "You" : receiverName,
            text: messageText,
            fileUrl: fileUrl,
            fileName: fileName,
            isFile: isFile,
            isMe: isMe,
          );
        }).toList();

        return ListView(
          reverse: true,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          children: messageWidgets,
        );
      },
    );
  }
}

class MessageLine extends StatelessWidget {
  final String sender;
  final String? text;
  final String? fileUrl;
  final String? fileName;
  final bool isFile;
  final bool isMe;

  const MessageLine({
    super.key,
    required this.sender,
    this.text,
    this.fileUrl,
    this.fileName,
    required this.isFile,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: const TextStyle(fontSize: 12, color: Colors.black45),
          ),
          Material(
            borderRadius: isMe
                ? const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  )
                : const BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
            elevation: 5,
            color: isMe
                ? Colors.blue[800]
                : const Color.fromARGB(255, 234, 224, 224),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: isFile && fileUrl != null
                  ? fileUrl!.endsWith(".png") ||
                          fileUrl!.endsWith(".jpg") ||
                          fileUrl!.endsWith(".jpeg") ||
                          fileUrl!.endsWith(".gif")
                      ? Image.network(
                          fileUrl!) // Display image if it's an image URL
                      : GestureDetector(
                          onTap: () async {
                            if (await canLaunchUrl(Uri.parse(fileUrl!))) {
                              await launchUrl(Uri.parse(fileUrl!));
                            } else {
                              print("Could not launch the URL: $fileUrl");
                            }
                          },
                          child: Text(
                            fileName ?? 'File: Tap to open',
                            style: TextStyle(
                              fontSize: 15,
                              color: isMe ? Colors.white : Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        )
                  : Text(
                      text ?? '',
                      style: TextStyle(
                        fontSize: 15,
                        color: isMe ? Colors.white : Colors.black,
                      ),
                    ),
            ),
          )
        ],
      ),
    );
  }
}
