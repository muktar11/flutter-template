import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  final List<Map<String, String>> notifications = [
    {'title': 'New Comment', 'description': 'You have a new comment on your post.'},
    {'title': 'Update Available', 'description': 'A new update is available for the app.'},
    {'title': 'Message Received', 'description': 'You have received a new message from a friend.'},
    {'title': 'Update Available', 'description': 'A new update is available for the app.'},
    {'title': 'Message Received', 'description': 'You have received a new message from a friend.'},
    {'title': 'Update Available', 'description': 'A new update is available for the app.'},
    {'title': 'Message Received', 'description': 'You have received a new message from a friend.'},
    
    // Add more notifications here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return ListTile(
            contentPadding: EdgeInsets.all(16.0),
            title: Text(notification['title'] ?? 'No Title'),
            subtitle: Text(notification['description'] ?? 'No Description'),
            leading: Icon(Icons.notifications, color: Colors.blueAccent),
            tileColor: Colors.grey[200],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            // You can add onTap or other interactions here
          );
        },
      ),
    );
  }
}
