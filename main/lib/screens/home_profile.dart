import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final String profileImage = 'assets/images/face1.jpeg'; // Profile image path
  final String name = 'Stella Sydney'; // User's name
  final String username = '@stellasydney'; // User's username
  final String bio = 'Flutter Developer | Tech Enthusiast | Coffee Lover'; // User's bio

  final List<String> posts = [
    'Just completed a new Flutter project! Excited to share it soon.',
    'Learning about state management in Flutter, so much to explore!',
    'Starting my day with a cup of coffee and some coding. #Productivity',
    'Attended a great tech meetup today, met some amazing people.',
    'Working on a new app idea, can’t wait to get started!',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 40.0,
                    backgroundImage: AssetImage(profileImage),
                  ),
                  SizedBox(width: 16.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        username,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                bio,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                ),
              ),
            ),
            Divider(
              height: 20.0,
              color: Colors.grey,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Recent Posts',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Card(
                    color: Colors.white,
                    elevation: 2.0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        posts[index],
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
