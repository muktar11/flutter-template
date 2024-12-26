import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:main/screens/home_chat.dart';

class HomeDetailPage extends StatefulWidget {
  final String profileImage;
  final int user_id;
  final int recipient_id;
  final String author;
  final String parent;
  final String organization;
  final String submission_type;
  final String title;
  final String short_description;
  final String key_features_and_goals;
  final String target_audience;
  final String development_stage;
  final String amount_needed;
  final String how_will_funds_will_be_used;
  final String market_overview;
  final String competitors;
  final String potential_user_impact;
  final String uniqueness;
  final String tweet;
  final String replies;
  final String likes;
  final String? image;
  final String? videoUrl;

  HomeDetailPage({
    required this.profileImage,
    required this.user_id,
    required this.recipient_id,
    required this.author,
    required this.parent,
    required this.organization,
    required this.submission_type,
    required this.title,
    required this.short_description,
    required this.key_features_and_goals,
    required this.target_audience,
    required this.development_stage,
    required this.amount_needed,
    required this.how_will_funds_will_be_used,
    required this.market_overview,
    required this.competitors,
    required this.potential_user_impact,
    required this.uniqueness,
    required this.tweet,
    required this.replies,
    required this.likes,
    this.image,
    this.videoUrl,
  });

  @override
  _HomeDetailPageState createState() => _HomeDetailPageState();
}

class _HomeDetailPageState extends State<HomeDetailPage> {
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();

    // Initialize the YouTube player only if the video URL is available.
    if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
      String? videoId = getYoutubeVideoId(widget.videoUrl!);
      if (videoId != null) {
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
          ),
        );
      } else {
        print('Invalid video URL or videoId could not be extracted.');
      }
    }
  }

  @override
  void dispose() {
    // Dispose of the controller when done.
    _youtubeController?.dispose();
    super.dispose();
  }

  String? getYoutubeVideoId(String url) {
    try {
      Uri uri = Uri.parse(url);
      if (uri.host.contains("youtube.com")) {
        return uri.queryParameters['v'];
      } else if (uri.host.contains("youtu.be")) {
        return uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
      }
      return null;
    } catch (e) {
      print('Error extracting video ID: $e');
      return null;
    }
  }

  Widget buildInfoSection(String label, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
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
        title: Text('Tweet Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      widget.author,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      widget.parent,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              widget.tweet,
              style: const TextStyle(fontSize: 16.0, color: Colors.black),
            ),
            // Render both image and video if available
            if (widget.image != null && widget.image!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    widget.image!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            if (widget.videoUrl != null &&
                widget.videoUrl!.isNotEmpty &&
                _youtubeController != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: YoutubePlayer(
                  controller: _youtubeController!,
                  showVideoProgressIndicator: true,
                ),
              ),
            const SizedBox(height: 20),
            buildInfoSection('Organization', widget.organization),
            buildInfoSection('Submission Type', widget.submission_type),
            buildInfoSection('Title', widget.title),
            buildInfoSection('Short Description', widget.short_description),
            buildInfoSection('Target Audience', widget.target_audience),
            buildInfoSection(
                'Key Features and Goals', widget.key_features_and_goals),
            buildInfoSection(
                'Potential User Impact', widget.potential_user_impact),
            buildInfoSection('Development Stage', widget.development_stage),
            buildInfoSection('Amount Needed', widget.amount_needed),
            buildInfoSection('Fund Usage', widget.how_will_funds_will_be_used),
            buildInfoSection('Market Overview', widget.market_overview),
            buildInfoSection('Competitors', widget.competitors),
            buildInfoSection('Uniqueness', widget.uniqueness),
            const SizedBox(height: 10),
            Text(
              'Replies: ${widget.replies}  •  Likes: ${widget.likes}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // Dark color
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChatPage(
                              chatName: 'LinkIt',
                              sid: widget.user_id,
                              rid: widget.recipient_id,
                            )),
                  );
                },
                child: Text(
                  'Chat',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
