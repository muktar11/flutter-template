import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatPage extends StatefulWidget {
  final String chatName;
  final String userId; // Pass user ID
  final String recipientId; // Pass recipient ID

  ChatPage({
    required this.chatName,
    required this.userId,
    required this.recipientId,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController messageController = TextEditingController();
  List<Map<String, String>> messages = []; // Temporary message list to simulate chat
  String? currentMessage;
  bool isRecipientOnline = false;

  @override
  void initState() {
    super.initState();
    requestConnection();
    checkRecipientOnline();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            Text(widget.chatName),
            const SizedBox(width: 8),
            // Show blue dot if recipient is online
            if (isRecipientOnline)
              Icon(
                Icons.circle,
                color: Colors.blue,
                size: 12,
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Chat message list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                bool isSentByMe = message['sender'] == 'me';
                return Align(
                  alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: ChatBubble(
                    message: message['message']!,
                    sender: message['sender']!,
                    time: message['time']!,
                    isSentByMe: isSentByMe,
                  ),
                );
              },
            ),
          ),
          // Message input field and send button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                // Message text field
                Expanded(
                  child: TextField(
                    controller: messageController,
                    onChanged: (value) {
                      setState(() {
                        currentMessage = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Send button
                ElevatedButton(
                  onPressed: () {
                    if (currentMessage != null && currentMessage!.trim().isNotEmpty) {
                      sendMessage();
                    }
                  },
                  child: const Icon(Icons.send),
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(), backgroundColor: Colors.blue,
                    padding: const EdgeInsets.all(16), // Button background color
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Request connection by passing user_id
  Future<void> requestConnection() async {
    final url = Uri.parse('ws://192.168.96.243:8001/ws/chat/');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'sid': widget.userId,
      },
    );

    if (response.statusCode == 200) {
      print("Connected successfully");
    } else {
      print("Connection failed");
    }
  }

  // Check if the recipient is online
  Future<void> checkRecipientOnline() async {
    final url = Uri.parse('ws://192.168.96.243:8001/ws/chat/');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'rid': widget.recipientId,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        isRecipientOnline = data['online'];
      });
    } else {
      print("Failed to check recipient status");
    }
  }

  // Function to send a message
  void sendMessage() {
    setState(() {
      messages.add({
        'sender': 'me',
        'message': currentMessage!,
        'time': TimeOfDay.now().format(context),
      });
      messageController.clear();
      currentMessage = null;
    });
  }
}

// Chat bubble widget to format message display
class ChatBubble extends StatelessWidget {
  final String message;
  final String sender;
  final String time;
  final bool isSentByMe;

  ChatBubble({
    required this.message,
    required this.sender,
    required this.time,
    required this.isSentByMe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSentByMe ? Colors.blue : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isSentByMe)
            Text(
              sender,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
