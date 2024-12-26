import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class HomeMessagePage extends StatefulWidget {
  @override
  _HomeMessagePageState createState() => _HomeMessagePageState();
}

class _HomeMessagePageState extends State<HomeMessagePage> {
  late WebSocketChannel channel;
  List<Map<String, dynamic>> channels = [];

  @override
  void initState() {
    super.initState();
    // Initialize WebSocket connection
    channel = WebSocketChannel.connect(
      Uri.parse('ws://192.168.1.16:8001/ws/chat/?sid=1&rid=2'),
    );

    // Listen for incoming messages
    channel.stream.listen((message) {
      final data = jsonDecode(message);
      setState(() {
        channels = List<Map<String, dynamic>>.from(data['channels']);
      });
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Messages'),
      centerTitle: true,
    ),
    body: channels.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: channels.length,
            itemBuilder: (context, index) {
              final channel = channels[index];
              final lastMessage = channel['messages'].isNotEmpty
                  ? channel['messages'].last
                  : null;

              // Assuming the sender in the first message is the desired sender
              final senderName = lastMessage != null ? lastMessage['sender'] : 'No sender';

              return MessageBox(
                senderId: channel['channel_id'],
                senderName: senderName, // Use sender from the API
                profilePhoto: 'assets/images/default_avatar.png', // Default avatar
                lastMessage: lastMessage != null
                    ? lastMessage['content']
                    : 'No messages yet',
                time: lastMessage != null
                    ? _formatTime(lastMessage['timestamp'])
                    : '',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPage(
                        chatName: senderName,
                        senderId: channel['channel_id'],
                        messages: List<Map<String, dynamic>>.from(
                            channel['messages']),
                      ),
                    ),
                  );
                },
              );
            },
          ),
  );
}

  String _formatTime(String timestamp) {
    final time = DateTime.parse(timestamp);
    return "${time.hour}:${time.minute.toString().padLeft(2, '0')} ${time.hour < 12 ? 'AM' : 'PM'}";
  }
}

class MessageBox extends StatelessWidget {
  final int senderId;
  final String senderName;
  final String profilePhoto;
  final String lastMessage;
  final String time;
  final VoidCallback onTap;

  const MessageBox({
    required this.senderId,
    required this.senderName,
    required this.profilePhoto,
    required this.lastMessage,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: AssetImage(profilePhoto),
        ),
        title: Text(
          senderName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(lastMessage),
        trailing: Text(
          time,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        onTap: onTap,
      ),
    );
  }
}
class DetailPage extends StatefulWidget {
  final String chatName;
  final int senderId;
  final List<Map<String, dynamic>> messages;

  const DetailPage({
    required this.chatName,
    required this.senderId,
    required this.messages,
  });

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final TextEditingController messageController = TextEditingController();
  late WebSocketChannel channel;
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    messages = widget.messages;
    channel = WebSocketChannel.connect(
      Uri.parse('ws://192.168.142.100:8001/ws/chat/?sid=${widget.senderId}&rid=receiver_id'),
    );

    channel.stream.listen((event) {
      final data = jsonDecode(event);
      if (data.containsKey('message')) {
        setState(() {
          messages.add({
            'content': data['message'],
            'sender': data['sender'],
            'timestamp': DateTime.now().toIso8601String(),
          });
        });
      }
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    messageController.dispose();
    super.dispose();
  }

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isNotEmpty) {
      final messageData = {
        'action': 'send_message',
        'sender': widget.senderId,
        'recipient': 'receiver_id', // Replace with actual recipient ID
        'message': text,
      };

      channel.sink.add(jsonEncode(messageData));
      setState(() {
        messages.add({
          'content': text,
          'sender': widget.senderId,
          'timestamp': DateTime.now().toIso8601String(),
        });
      });
      messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatName),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isSentByMe = message['sender'] == widget.senderId;
                return ChatBubble(
                  message: message['content'],
                  senderId: widget.senderId,
                  isSentByMe: isSentByMe,
                  time: _formatTime(message['timestamp']),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
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

  String _formatTime(String timestamp) {
    final time = DateTime.parse(timestamp);
    return "${time.hour}:${time.minute.toString().padLeft(2, '0')} ${time.hour < 12 ? 'AM' : 'PM'}";
  }
}


class ChatBubble extends StatelessWidget {
  final String message;
  final int senderId;
  final bool isSentByMe;
  final String time;

  const ChatBubble({
    required this.message,
    required this.senderId,
    required this.isSentByMe,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSentByMe ? Colors.blue : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment:
              isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
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
      ),
    );
  }
}
