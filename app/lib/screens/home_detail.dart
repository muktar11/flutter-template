import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:app/screens/home_chat.dart';

class HomeDetailPage extends StatefulWidget {
  final String profileImage;
  final String name;
  final String username;
  final String tweet;
  final String replies;
  final String likes;
  final String? image;
  final String? video;

  // Dummy contact information
  final Map<String, String> contactInfo = {
    'Contact Name': 'John Doe',
    'Email': 'john.doe@example.com',
    'Phone': '+1234567890',
    'Organization': 'Example Org',
  };

  // Dummy submission type and other information
  final String submissionType = 'Product';
  final String title = 'Sample Title';
  final String shortDescription = 'This is a short description.';
  final String keyFeaturesGoals = 'Key feature 1, Key feature 2';
  final String targetAudience = 'Audience type';
  final String developmentStage = 'Prototype';
  final String amountNeeded = '1000 USD';
  final String fundUsage = 'Product development';
  final String marketOverview = 'Market overview details.';
  final String competitors = 'Competitor A, Competitor B';
  final String potentialUsersImpact = 'High potential impact';
  final String uniqueness = 'Unique selling proposition';

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
  _HomeDetailPageState createState() => _HomeDetailPageState();
}

class _HomeDetailPageState extends State<HomeDetailPage> {
  String? selectedOption;
  final List<String> businessOptions = [
    'Offer Shares',
    'Offer Equity',
    'Revenue Sharing',
    'Partnership',
  ];

  final TextEditingController offerDetailsController = TextEditingController();

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
        title: Text('Tweet Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile row
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage(widget.profileImage),
                    radius: 30.0,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        widget.username,
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Tweet text
              Text(
                widget.tweet,
                style: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                ),
              ),
              if (widget.image != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Container(
                      constraints: const BoxConstraints(
                        maxHeight: 200.0,
                      ),
                      child: Image.asset(
                        widget.image!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              if (widget.video != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Container(
                    width: double.infinity,
                    height: 200.0,
                    child: YoutubePlayerWidget(widget.video!),
                  ),
                ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Comments: ${widget.replies}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(
                    'Likes: ${widget.likes}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Extra Information Section
              const Text(
                'Extra Information',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              const SizedBox(height: 10),
              ...widget.contactInfo.entries.map((entry) => _buildInfoRow(entry.key, entry.value)).toList(),
              _buildInfoRow('Submission Type:', widget.submissionType),
              _buildInfoRow('Title:', widget.title),
              _buildInfoRow('Short Description:', widget.shortDescription),
              _buildInfoRow('Key Features/Goals:', widget.keyFeaturesGoals),
              _buildInfoRow('Target Audience:', widget.targetAudience),
              _buildInfoRow('Development Stage:', widget.developmentStage),
              _buildInfoRow('Amount Needed:', widget.amountNeeded),
              _buildInfoRow('Fund Usage:', widget.fundUsage),
              _buildInfoRow('Market Overview:', widget.marketOverview),
              _buildInfoRow('Competitors:', widget.competitors),
              _buildInfoRow('Potential Users Impact:', widget.potentialUsersImpact),
              _buildInfoRow('Uniqueness:', widget.uniqueness),

              const SizedBox(height: 20),
              // Chat button
            ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
        chatName: 'Chat with XYZ',
        userId: '1',
        recipientId: '5',
        ), // Pass the chat name or other parameters
      ),
    );
  },
  child: const Text('Chat'),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 12.0),
  ),
),

              const SizedBox(height: 20),
              // Dropdown
              DropdownButton<String>(
                value: selectedOption,
                hint: const Text('Select Offer Type'),
                items: businessOptions.map((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedOption = newValue;
                  });
                },
                style: const TextStyle(color: Colors.black),
                dropdownColor: Colors.white,
              ),
              if (selectedOption != null) ...[
                const SizedBox(height: 20),
                TextField(
                  controller: offerDetailsController,
                  decoration: InputDecoration(
                    labelText: 'Enter details for $selectedOption',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    String offerDetails = offerDetailsController.text;
                    print('Submitted Offer: $selectedOption');
                    print('Offer Details: $offerDetails');
                    // Submit logic goes here
                  },
                  child: const Text('Submit Offer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
            ),
          ),
        ],
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
      flags: const YoutubePlayerFlags(
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
    );
  }
}
