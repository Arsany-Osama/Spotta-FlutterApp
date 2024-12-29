import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Backend/controllers/chat_controller.dart';
import './message_stream_builder.dart';

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
    // Pass senderId and receiverId to the ChatController
    final ChatController controller =
        Get.put(ChatController(senderId: senderId, receiverId: receiverId));

    return Obx(() => Scaffold(
         appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 17, 87, 145),
            title: Row(
              children: [
                // Scale the image based on screen size
                Image.asset(
                  'images/spotta.png',
                  height: MediaQuery.of(context).size.height *
                      0.05, // Scales image size
                ),
                SizedBox(width: 10),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      controller.receiverName.value.isNotEmpty
                          ? "  ${controller.receiverName.value}"
                          : "Spotta Chat",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
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
                    receiverName: controller.receiverName.value,
                  ),
                ),
                _buildMessageInput(controller, context),
              ],
            ),
          ),
        ));
  }

  Widget _buildMessageInput(ChatController controller, BuildContext context) {
    // Get screen width for responsive design
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey, width: 2),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: controller.pickAndUploadFile,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: screenWidth * 0.05, // Adjust padding based on screen size
              ),
              child: TextField(
                controller: controller.messageController,
                onChanged: (value) => controller.messageText.value = value,
                decoration: const InputDecoration(
                  hintText: "Write your message...",
                  border: InputBorder.none,
                ),
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
    );
  }
}
