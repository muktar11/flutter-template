import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class ChatPage extends StatefulWidget {
  final String chatName;
  final int sid; // Sender ID
  final int rid; // Recipient ID

  ChatPage({
    required this.chatName,
    required this.sid,
    required this.rid,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController messageController = TextEditingController();
  List<Map<String, dynamic>> messages = []; // Adjusted to allow different types
  String? currentMessage;
  bool isRecipientOnline = false;
  late WebSocketChannel channel;

  @override
  void initState() {
    super.initState();
    initializeSocket();
  }

  @override
  void dispose() {
    channel.sink.close(status.goingAway);
    messageController.dispose();
    super.dispose();
  }

  void initializeSocket() {
    final uri = Uri.parse(
        'ws://192.168.1.16:8001/ws/chat/?sid=${widget.sid}&rid=${widget.rid}');
    channel = WebSocketChannel.connect(uri);

    // Listen for incoming messages
    channel.stream.listen((event) {
      final data = jsonDecode(event);

      if (data.containsKey('is_online')) {
        setState(() {
          isRecipientOnline = data['is_online'];
        });
      } else if (data.containsKey('message')) {
        setState(() {
          messages.add({
            'message': data['message'],
            'sender': data['sender'], // Keep this as `int` if received as such
            'time': DateTime.now().toString(),
          });
        });
      }
    }, onError: (error) {
      print('WebSocket Error: $error'); // Add logging for errors
    });
  }

  void sendMessage() {
    if (currentMessage != null && currentMessage!.isNotEmpty) {
      final messageData = {
        'action': 'send_message',
        'sender': widget.sid,
        'recipient': widget.rid,
        'message': currentMessage,
      };

      channel.sink.add(jsonEncode(messageData));
      setState(() {
        messages.add({
          'message': currentMessage!,
          'sender': widget.sid,
          'time': DateTime.now().toString(),
        });
      });
      messageController.clear();
      currentMessage = null; // Clear the current message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            Text(widget.chatName),
            const SizedBox(width: 8),
            if (isRecipientOnline)
              const Icon(
                Icons.circle,
                color: Colors.green,
                size: 12,
              ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Background Image Section
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/chat-background.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Messages List
                ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    bool isSentByMe = message['sender'] == widget.sid;
                    return Align(
                      alignment: isSentByMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: ChatBubble(
                        message: message['message'] ?? '',
                        sender: message['sender'].toString(),
                        time: message['time'] ?? '',
                        isSentByMe: isSentByMe,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Text Input Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
            child: Row(
              children: [
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
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: sendMessage,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Chat bubble widget
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
        crossAxisAlignment:
            isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
            style: TextStyle(
              color: isSentByMe ? Colors.white : Colors.black,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              color: isSentByMe ? Colors.white70 : Colors.black54,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
