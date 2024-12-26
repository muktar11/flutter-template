import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:main/screens/home_detail.dart';
import 'package:main/screens/home_detail_invest.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../theme/theme.dart';

class TwitterBody extends StatefulWidget {
  @override
  _TwitterBodyState createState() => _TwitterBodyState();
}

class _TwitterBodyState extends State<TwitterBody> {
  List<dynamic> combinedFeed = [];
  bool isLoading = true;
  int? userId;
  int? hoveredRating;
  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetchFeed();
  }

  Future<void> _loadUserIdAndFetchFeed() async {
    await _loadUserId();
    if (userId != null && userId != 0) {
      await fetchUserFeed();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found in cache')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('userId') ?? 0;
    });
  }

  Future<void> fetchUserFeed() async {
    // Retrieve userId from SharedPreferences
    setState(() {
      isLoading = true;
    });
    final response = await http
        .get(Uri.parse('http://192.168.1.16:8000/api/user/feed/$userId/'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        combinedFeed = [
          ...data['publish']
              .map((item) =>
                  Map<String, dynamic>.from(item)..['type'] = 'publish')
              .toList(),
          ...data['invest']
              .map((item) =>
                  Map<String, dynamic>.from(item)..['type'] = 'invest')
              .toList(),
        ];
        combinedFeed.forEach((item) {
          if (item['videos_detail'] != null &&
              item['videos_detail'].isNotEmpty) {
            final videoUrl = item['videos_detail'][0]['video_url'];
            final videoId = YoutubePlayer.convertUrlToId(videoUrl);
            item['videos_detail'][0]['video_id'] =
                videoId; // Store video ID if valid
          }
          item['isLiked'] = false; // Track like status
          item['rating'] = 0; // Track user rating
        });
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      // Handle error here
    }
  }

  Future<void> toggleLike(Map<String, dynamic> item) async {
    if (userId == null) return;
    final itemId = item['_id'];
    final isLiked = item['isLiked'];
    final response = await http.post(
      Uri.parse('http://192.168.1.16:8000/api/like/$userId/$itemId/'),
      body: jsonEncode({'like': !isLiked}),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      setState(() {
        item['isLiked'] = !isLiked;
      });
    }
  }

  Future<void> rateItem(Map<String, dynamic> item, int rating) async {
    final itemId = item['_id'];
    final response = await http.post(
      Uri.parse('http://192.168.1.16:8000/api/rate/$userId/$itemId/'),
      body: jsonEncode({'no_of_rating': rating}),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      setState(() {
        item['no_of_rating'] = rating;
      });
    } else {
      // Handle error here
    }
  }

  String? getYoutubeVideoId(String url) {
    // Check if the URL contains the video ID in standard formats
    Uri uri = Uri.parse(url);
    if (uri.host.contains("youtube.com")) {
      return uri.queryParameters['v'];
    } else if (uri.host.contains("youtu.be")) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightColorScheme.background,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: combinedFeed.length,
              itemBuilder: (context, index) {
                final item = combinedFeed[index];
                return item['type'] == 'publish'
                    ? _buildPublishItem(item)
                    : _buildInvestItem(item);
              },
            ),
    );
  }

  Widget _buildPublishItem(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeDetailPage(
              profileImage: 'assets/images/face1.jpeg',
              user_id: item['_id'] ?? "",
              recipient_id: item['parent'] ?? "",
              author: item['author'] ?? 'No Name',
              parent: item["parent"].toString(), // Convert to String
              organization: item['organization'] ?? 'No Organization',
              submission_type: item['submission_type'] ?? 'No submission type',
              title: item['title'] ?? 'title',
              short_description:
                  item['short_description'] ?? "short description",
              key_features_and_goals:
                  item['key_features_and_goals'] ?? "key_features_and_goals",
              target_audience: item['target_audience'] ?? "target_audience",
              development_stage:
                  item['development_stage'] ?? "development_stage",
              amount_needed: item['amount_needed'] ?? "amount_needed",
              how_will_funds_will_be_used:
                  item['how_will_funds_will_be_used'] ??
                      "how_will_funds_will_be_used",
              market_overview: item['market_overview'] ?? "market_overview",
              competitors: item['competitors'] ?? "competitors",
              potential_user_impact:
                  item['potential_user_impact'] ?? "impact not specified",
              uniqueness: item["uniqueness"] ?? "uniqueness",

              tweet: item['short_description'] ?? 'No Description',

              replies: '0',
              likes: '0',
              image: item['photos_detail'] != null &&
                      item['photos_detail'].isNotEmpty
                  ? item['photos_detail'][0]['image_url']
                  : null,

              videoUrl: item['videos_detail'] != null &&
                      item['videos_detail'].isNotEmpty &&
                      item['videos_detail'][0]['video_url'] != null
                  ? item['videos_detail'][0]['video_url'] as String
                  : null,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
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
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/imagebackgroundIms/Linkit.jpg'),
                    radius: 25,
                  ),
                  const SizedBox(width: 10.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['author'] ?? 'No author',
                        style: TextStyle(
                          color: lightColorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        item['organization'] ?? 'No Organization',
                        style: const TextStyle(
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              Text(
                item['short_description'] ?? 'No Description',
                style: TextStyle(
                  color: lightColorScheme.onSurface,
                ),
              ),
              // Display photo or video if available

              // Helper function to extract video ID from YouTube URL

              if (item['photos_detail'] != null &&
                  item['photos_detail'].isNotEmpty)
                Image.network(
                  item['photos_detail'][0]['image_url'],
                  fit: BoxFit.cover,
                ),
              if (item['videos_detail'] != null &&
                  item['videos_detail'].isNotEmpty &&
                  item['videos_detail'][0]['video_url'] != null)
                YoutubePlayer(
                  controller: YoutubePlayerController(
                    initialVideoId: getYoutubeVideoId(
                            item['videos_detail'][0]['video_url']) ??
                        '',
                    flags: YoutubePlayerFlags(
                      autoPlay: false,
                      mute: false,
                    ),
                  ),
                  showVideoProgressIndicator: true,
                ),
              const SizedBox(height: 10.0),
              Row(
                key: ValueKey<int>(hoveredRating ?? item['rating'] ?? 0),
                children: [
                  IconButton(
                    icon: Icon(
                      item['isLiked'] ? Icons.favorite : Icons.favorite_border,
                      color: item['isLiked'] ? Colors.red : Colors.grey,
                    ),
                    onPressed: () => toggleLike(item),
                  ),
                  const SizedBox(height: 10.0),
                  const SizedBox(width: 2),
                  ...List.generate(5, (i) {
                    return GestureDetector(
                      onTap: () =>
                          rateItem(item, i + 1), // Handle tap to set the rating
                      onTapDown: (_) => setState(() => hoveredRating =
                          i + 1), // Set "hovered" rating on tap down
                      onTapCancel: () => setState(() =>
                          hoveredRating = null), // Clear "hover" if canceled
                      onTapUp: (_) => setState(() => hoveredRating =
                          null), // Clear "hover" after tap is complete
                      child: Icon(
                        i < (hoveredRating ?? item['rating'] ?? 0)
                            ? Icons.star
                            : Icons.star_border,
                        color: i < (hoveredRating ?? item['rating'] ?? 0)
                            ? Colors.blue
                            : Colors.yellow,
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvestItem(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeInvestDetailPage(
              title: item['title'] ?? 'No Title',
              budget: item['parent'] ?? 'Invest Organization',
              description: item['description'] ?? 'No Description',
              investment_type: item['organization'] ?? 'No Description',
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
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
              Text(
                item['title'] ?? 'No Title',
                style: TextStyle(
                  color: lightColorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5.0),
              Text(
                'Budget: ${item['budget'] ?? 'N/A'}',
                style: TextStyle(
                  color: lightColorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 5.0),
              Text(
                item['description'] ?? 'No Description',
                style: TextStyle(
                  color: lightColorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
