import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

final _fireStore = FirebaseFirestore.instance;

class ChatController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late User signedInUser;
  var messageText = ''.obs;
  var receiverName = ''.obs;

  final TextEditingController messageController = TextEditingController();

  String senderId;
  String receiverId;

  ChatController({required this.senderId, required this.receiverId});

  @override
  void onInit() {
    super.onInit();
    _getCurrentUser();
    _fetchReceiverName();
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }

  void _getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        signedInUser = user;
        update();
      }
    } catch (e) {
      debugPrint("Error getting current user: $e");
    }
  }

  void _fetchReceiverName() async {
    try {
      final receiverDoc = await _fireStore.collection('users').doc(receiverId).get();
      if (receiverDoc.exists) {
        receiverName.value = receiverDoc['name'];
      }
    } catch (e) {
      debugPrint("Error fetching receiver name: $e");
    }
  }

  void sendMessage() {
    if (messageText.value.trim().isNotEmpty) {
      try {
        _fireStore.collection('messages').add({
          'sender_id': senderId,
          'receiver_id': receiverId,
          'text': messageText.value,
          'time': FieldValue.serverTimestamp(),
        });
        messageController.clear();
        messageText.value = '';
      } catch (e) {
        Get.snackbar("Error", "Error sending message: $e");
      }
    } else {
      Get.snackbar("Error", "Message cannot be empty");
    }
  }

  void logout() async {
    try {
      final userDoc = await _fireStore.collection('users').doc(senderId).get();
      if (userDoc.exists) {
        final role = userDoc['role'];
        if (role == 'client') {
          Get.offNamed('../client/venue_details_page');
        } else if (role == 'owner') {
          Get.offNamed('../owner/owner_page');
        }
      }
      await _auth.signOut();
    } catch (e) {
      debugPrint("Error logging out: $e");
    }
  }
}

class ChatScreen extends StatelessWidget {
  final String senderId;
  final String receiverId;

  const ChatScreen({
    super.key,
    required this.senderId,
    required this.receiverId,
  });

  @override
  Widget build(BuildContext context) {
    final ChatController controller = Get.put(ChatController(senderId: senderId, receiverId: receiverId));

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Obx(() => Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 17, 87, 145),
        title: Row(
          children: [
            Image.asset('images/spotta.png', height: 50),
            SizedBox(width: screenWidth * 0.02),  // Adding some space
            Text(
              controller.receiverName.value.isNotEmpty
                  ? controller.receiverName.value
                  : "Spotta Chat",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: isPortrait ? 18 : 20, // Adjust font size based on orientation
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: MessageStreamBuilder(
                senderId: senderId,
                receiverId: receiverId,
                receiverName: controller.receiverName.value, // Pass receiverName here
              ),
            ),
            _buildMessageInput(controller, screenWidth),
          ],
        ),
      ),
    ));
  }

  Widget _buildMessageInput(ChatController controller, double screenWidth) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey, width: 2),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.messageController,
                onChanged: (value) => controller.messageText.value = value,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  hintText: "Write your message...",
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              onPressed: controller.sendMessage,
              icon: const Icon(Icons.send),
              color: const Color.fromARGB(255, 17, 87, 145),
            ),
          ],
        ),
      ),
    );
  }
}

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
          final isMe = senderId == messageSender;

          return MessageLine(
            sender: isMe ? "You" : receiverName,
            text: messageText,
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
  final String text;
  final bool isMe;

  const MessageLine({
    super.key,
    required this.sender,
    required this.text,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
            color: isMe ? Colors.blue[800] : const Color.fromARGB(255, 234, 224, 224),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: screenWidth * 0.05),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15 * MediaQuery.of(context).textScaleFactor, // Scale the text
                  color: isMe ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
