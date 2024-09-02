import 'package:flutter/material.dart';

class MailPage extends StatelessWidget {
  final List<Map<String, String>> emails = [
    {'sender': 'John Doe', 'subject': 'Meeting Reminder', 'body': 'Don\'t forget about the meeting tomorrow at 10 AM.'},
    {'sender': 'Jane Smith', 'subject': 'Project Update', 'body': 'The project is progressing well. Let\'s review the details.'},
    {'sender': 'Alice Johnson', 'subject': 'Holiday Party', 'body': 'You\'re invited to the holiday party next week. RSVP by Friday.'},
     {'sender': 'John Doe', 'subject': 'Meeting Reminder', 'body': 'Don\'t forget about the meeting tomorrow at 10 AM.'},
    {'sender': 'Jane Smith', 'subject': 'Project Update', 'body': 'The project is progressing well. Let\'s review the details.'},
    {'sender': 'Alice Johnson', 'subject': 'Holiday Party', 'body': 'You\'re invited to the holiday party next week. RSVP by Friday.'},
    // Add more emails here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: ListView.builder(
        itemCount: emails.length,
        itemBuilder: (context, index) {
          final email = emails[index];
          return ListTile(
            contentPadding: EdgeInsets.all(16.0),
            title: Text(email['subject'] ?? 'No Subject'),
            subtitle: Text('From: ${email['sender'] ?? 'Unknown Sender'}\n${email['body'] ?? 'No Content'}'),
            leading: Icon(Icons.mail, color: Colors.blueAccent),
            tileColor: Colors.grey[200],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            // You can add onTap or other interactions here
          );
        },
      ),
      drawer: Drawer(
        child: Container(
          color: Theme.of(context).primaryColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 40.0, 0.0, 8.0),
                child: InkWell(
                  onTap: () {
                    // Add action for profile navigation
                  },
                  child: Container(
                    width: 75.0,
                    height: 75.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.fitHeight,
                        image: AssetImage('assets/images/face1.jpeg'),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'User Name',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  '@username',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                color: Colors.grey,
                height: 0.5,
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        title: Text(
                          'Inbox',
                          style: TextStyle(color: Colors.black),
                        ),
                        leading: Icon(
                          Icons.inbox,
                          color: Colors.grey,
                        ),
                        onTap: () {
                          // Add action for Inbox
                        },
                      ),
                      Container(
                        width: double.infinity,
                        color: Colors.grey,
                        height: 0.5,
                      ),
                      ListTile(
                        title: Text(
                          'Sent',
                          style: TextStyle(color: Colors.black),
                        ),
                        onTap: () {
                          // Add action for Sent
                        },
                      ),
                      ListTile(
                        title: Text(
                          'Drafts',
                          style: TextStyle(color: Colors.black),
                        ),
                        onTap: () {
                          // Add action for Drafts
                        },
                      ),
                      ListTile(
                        title: Text(
                          'Trash',
                          style: TextStyle(color: Colors.black),
                        ),
                        onTap: () {
                          // Add action for Trash
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                color: Colors.grey,
                height: 0.5,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    SizedBox(
                      height: 30.0,
                      width: 30.0,
                      child: IconButton(
                        padding: EdgeInsets.all(0.0),
                        icon: Icon(
                          Icons.settings,
                          size: 32.0,
                        ),
                        onPressed: () {
                          // Add action for settings
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
