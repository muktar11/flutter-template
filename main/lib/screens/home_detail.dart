import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class HomeDetailPage extends StatelessWidget {
  final String profileImage;
  final String name;
  final String username;
  final String tweet;
  final String replies;
  final String likes;
  final String? image;
  final String? video;

  HomeDetailPage({
    required this.profileImage,
    required this.name,
    required this.username,
    required this.tweet,
    required this.replies,
    required this.likes,
    this.image,
    this.video,
  });

  @override
  Widget build(BuildContext context) {
    String? selectedOption;

    final List<String> businessOptions = [
      'Offer Shares',
      'Offer Equity',
      'Revenue Sharing',
      'Partnership',
    ];

    return Scaffold(
      backgroundColor: Colors.white, // Change background color to white
      appBar: AppBar(
        title: Text(name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(profileImage),
                  radius: 30.0,
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                    Text(
                      username,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              tweet,
              style: TextStyle(fontSize: 16.0),
            ),
            if (image != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: 200.0, // Set the max height for the image
                    ),
                    child: Image.asset(
                      image!,
                      fit: BoxFit.cover, // Ensures the image covers the container
                    ),
                  ),
                ),
              ),
            if (video != null) // Check if a video exists
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Container(
                  width: double.infinity,
                  height: 200.0,
                  child: YoutubePlayerWidget(video!), // Render the video using YoutubePlayerWidget
                ),
              ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Comments: $replies'),
                Text('Rating: $likes'),
              ],
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Add chat functionality here
              },
              child: Text('Chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Button background color
                foregroundColor: Colors.grey, // Text color
              ),
            ),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: selectedOption,
              hint: Text('Select Offer Type'),
              items: businessOptions.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: (String? newValue) {
                // Handle the selection
                selectedOption = newValue;
                print('Selected: $selectedOption');
              },
              style: TextStyle(color: Colors.grey),
              dropdownColor: Colors.white, // Background color of the dropdown menu
            ),
          ],
        ),
      ),
    );
  }
}

class YoutubePlayerWidget extends StatefulWidget {
  final String videoUrl;
  YoutubePlayerWidget(this.videoUrl);

  @override
  _YoutubePlayerWidgetState createState() => _YoutubePlayerWidgetState();
}

class _YoutubePlayerWidgetState extends State<YoutubePlayerWidget> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(widget.videoUrl)!,
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      controller: _controller,
      showVideoProgressIndicator: true,
      progressIndicatorColor: Colors.blueAccent,
    );
  }
}

