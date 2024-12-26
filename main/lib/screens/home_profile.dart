import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:main/theme/theme.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:main/screens/buildInfoSection.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> userData = {};
  Map<String, dynamic> userProfile = {};
  bool isLoading = true;
  String errorMessage = '';

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
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    setState(() {
      isLoading = true; // Start loading
    });

    try {
      final results = await Future.wait([
        fetchUserData(),
        fetchUserProfile(),
      ]);

      setState(() {
        userData = results[0]; // First result is user data
        userProfile = results[1]; // Second result is user profile
        isLoading = false; // Stop loading
      });
    } catch (error) {
      setState(() {
        errorMessage = 'Error fetching user data: $error';
        isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> fetchUserData() async {
    const url = 'http://192.168.1.16:8000/api/user/activity/7/';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      print('Error fetching data: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> fetchUserProfile() async {
    const url = 'http://192.168.1.16:8000/api/profiles/7/';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load user profile');
      }
    } catch (e) {
      print('Error fetching data: $e');
      throw e;
    }
  }

  void onEditItem(String type, Map<String, dynamic> item) {
    // Implement edit functionality here
    print('Editing $type item: ${item['id']}');
  }

  void onDeleteItem(String type, Map<String, dynamic> item) {
    // Implement delete functionality here
    print('Deleting $type item: ${item['id']}');
  }

    void saveToApi(String field, String newValue, String itemId) async {
      try {
        final response = await http.put(
          Uri.parse('https://your-api-endpoint.com/items/$itemId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer YOUR_API_TOKEN',
          },
          body: jsonEncode({field: newValue}),
        );

        if (response.statusCode == 200) {
          print('Update successful');
        } else {
          print('Failed to update: ${response.body}');
        }
      } catch (e) {
        print('Error: $e');
      }
    }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    errorMessage,
                    style: TextStyle(fontSize: 16.0, color: Colors.red),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _buildProfileHeader(),
                      Divider(height: 20.0, color: Colors.grey),
                      _buildTabView(),
                    ],
                  ),
                ),
    );
  }
Widget _buildProfileHeader() {
  // Provide default values
  final String defaultProfileImageUrl = 'https://via.placeholder.com/150';
  final String defaultName = 'Anonymous';
  final String defaultUsername = 'unknown_user';
  final String defaultBio = 'This user prefers to keep their bio private.';

  // Use userProfile data if available, otherwise fall back to defaults
  final String profileImageUrl =
      userProfile['image_url'] ?? defaultProfileImageUrl;
  final String displayName =
      '${userProfile['first_name'] ?? ''} ${userProfile['last_name'] ?? ''}'
          .trim();
  final String displayUsername = userProfile['email'] ?? defaultUsername;
    final String displayBio = userProfile['phone'] ?? defaultBio;

  void showEditDialog(String field, String currentValue) {
    final TextEditingController controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $field'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: field,
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                saveToApi(field, controller.text, userProfile['id'].toString());
                setState(() {
                  // Update locally to reflect changes immediately
                  userProfile[field] = controller.text;
                });
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CircleAvatar(
          radius: 40.0,
          backgroundImage: profileImageUrl.startsWith('http')
              ? NetworkImage(profileImageUrl)
              : AssetImage(profileImageUrl) as ImageProvider,
        ),
        SizedBox(width: 16.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                onTap: () => showEditDialog('first_name', userProfile['first_name'] ?? ''),
                child: Text(
                  displayName,
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 4.0),
              GestureDetector(
                onTap: () => showEditDialog('email', displayUsername),
                child: Text(
                  displayUsername,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey,
                  ),
                ),
              ),
              SizedBox(height: 8.0),
              GestureDetector(
                onTap: () => showEditDialog('phone', displayBio),
                child: Text(
                  displayBio,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
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
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
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

  Widget _buildTabView() {
    return DefaultTabController(
      length: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            labelColor: Colors.lightBlue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.lightBlue,
            tabs: [
              Tab(text: 'Publishes'),
              Tab(text: 'Investments'),
              Tab(text: 'Likes'),
              Tab(text: 'Ratings'),
            ],
          ),
          SizedBox(
            height: 400, // Adjust the height as needed
            child: TabBarView(
              children: [
                _buildList(userData['publishes'], 'Publishes'),
                _buildList(userData['investments'], 'Investments'),
                _buildList(userData['likes'], 'Likes'),
                _buildList(userData['ratings'], 'Ratings'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<dynamic>? items, String type) {
    if (items == null || items.isEmpty) {
      return Center(
        child: Text(
          'No $type available.',
          style: TextStyle(fontSize: 16.0, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Card(
            color: Colors.white,
            elevation: 2.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row with Title and Overflow Menu
                
                  const SizedBox(height: 8.0),
                  // Content Section
                  if (type == 'Publishes') ...[
                  
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
                    const SizedBox(height: 20),
                    EditableInfoSection(
                      label: 'Organization',
                      content: item['orgnaization'] ?? 'No Organization',
                      onSave: (newContent) {
                        saveToApi('organization', newContent, item['id']);
                      },
                    ),
                    EditableInfoSection(
                        label: 'Submission Type',
                        content: item['submission_type'] ?? 'Submission Type',
                        onSave: (newContent) {
                          saveToApi('submission_type', newContent, item['id']);
                        },
                      ),
                      EditableInfoSection(
                        label: 'Short Description',
                        content: item['short_description'] ?? 'Short Description',
                        onSave: (newContent) {
                          saveToApi('short_description', newContent, item['id']);
                        },
                      ),

                      EditableInfoSection(
                        label: 'Target Audience',
                        content: item['target_audience'] ?? 'Target Audience',
                        onSave: (newContent) {
                          saveToApi('target_audience', newContent, item['id']);
                        },
                      ),

                      EditableInfoSection(
                      label: 'Key Features and Goals',
                      content: item['short_description'] ?? 'No Description',
                      onSave: (newContent) {
                        saveToApi('short_description', newContent, item['id']);
                      },
                    ),
                    EditableInfoSection(
                        label: 'Potential No User Impact',
                        content: item['potential_user_impact'] ?? 'No Potential User Impact',
                        onSave: (newContent) {
                          saveToApi('potential_user_impact', newContent, item['id']);
                        },
                      ),
                      EditableInfoSection(
                        label: 'Amount Needed',
                        content: item['amount_needed'] ?? 'No Amount Needed',
                        onSave: (newContent) {
                          saveToApi('amount_needed', newContent, item['id']);
                        },
                      ),

                      EditableInfoSection(
                        label: 'Fund Usage',
                        content: item['how_will_funds_will_be_used'] ?? 'N/A',
                        onSave: (newContent) {
                          saveToApi('how_will_funds_will_be_used', newContent, item['id']);
                        },
                      ),

                               EditableInfoSection(
                      label: 'Market Overview',
                      content: item['market_overview'] ?? 'N/A',
                      onSave: (newContent) {
                        saveToApi('market_overview', newContent, item['id']);
                      },
                    ),
                    EditableInfoSection(
                        label: 'Competitors',
                        content: item['competitors'] ?? 'No Competitors',
                        onSave: (newContent) {
                          saveToApi('competitors', newContent, item['id']);
                        },
                      ),
                    

                   

      
         /*



                    buildInfoSection(
                        'Organization', item['organization'] ?? 'N/A'),
                    buildInfoSection(
                        'Submission Type', item['submission_type'] ?? 'N/A'),
                    buildInfoSection('Title', item['title'] ?? 'N/A'),
                    buildInfoSection('Short Description',
                        item['short_description'] ?? 'N/A'),
                    buildInfoSection(
                        'Target Audience', item['target_audience'] ?? 'N/A'),
                    buildInfoSection('Key Features and Goals',
                        item['key_features_and_goals'] ?? 'N/A'),
                    buildInfoSection('Potential User Impact',
                        item['potential_user_impact'] ?? 'N/A'),
                    buildInfoSection('Development Stage',
                        item['development_stage'] ?? 'N/A'),
                    buildInfoSection(
                        'Amount Needed', item['amount_needed'] ?? 'N/A'),
                    buildInfoSection('Fund Usage',
                        item['how_will_funds_will_be_used'] ?? 'N/A'),
                    buildInfoSection(
                        'Market Overview', item['market_overview'] ?? 'N/A'),
                    buildInfoSection(
                        'Competitors', item['competitors'] ?? 'N/A'),
                    buildInfoSection('Uniqueness', item['uniqueness'] ?? 'N/A'),
                   */
                    const SizedBox(height: 10),
                    Text(
                      'Rating: ${userData['average_rating'] ?? 0}  •  Likes: ${userData['like_count'] ?? 0}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (type == 'Investments') ...[
                       EditableInfoSection(
                        label: 'Title',
                        content: item['title'] ?? 'No Title',
                        onSave: (newContent) {
                          saveToApi('title', newContent, item['id']);
                        },
                      ),
                         EditableInfoSection(
                        label: 'Budget',
                        content: item['budget'] ?? 'N/A',
                        onSave: (newContent) {
                          saveToApi('budget', newContent, item['id']);
                        },
                      ),
                         EditableInfoSection(
                        label: 'Category',
                        content: item['category'] ?? 'N/A',
                        onSave: (newContent) {
                          saveToApi('category', newContent, item['id']);
                        },
                      ),
                         EditableInfoSection(
                        label: 'Investment Type',
                        content: item['investment_type'] ?? 'N/A',
                        onSave: (newContent) {
                          saveToApi('investment_type', newContent, item['id']);
                        },
                      ),
                         EditableInfoSection(
                        label: 'Description',
                        content: item['description'] ?? 'N/A',
                        onSave: (newContent) {
                          saveToApi('description', newContent, item['id']);
                        },
                      ),
      
                  ],
                 if (type == 'Likes' || type == 'Ratings') ...[
  if (item['photos_detail'] != null && item['photos_detail'].isNotEmpty)
    Image.network(
      item['photos_detail'][0]['image_url'],
      fit: BoxFit.cover,
    ),
  if (item['videos_detail'] != null &&
      item['videos_detail'].isNotEmpty &&
      item['videos_detail'][0]['video_url'] != null)
    YoutubePlayer(
      controller: YoutubePlayerController(
        initialVideoId:
            getYoutubeVideoId(item['videos_detail'][0]['video_url']) ?? '',
        flags: YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
        ),
      ),
      showVideoProgressIndicator: true,
    ),
  const SizedBox(height: 20),
  InfoSection(
    label: 'Organization',
    content: item['orgnaization'] ?? 'No Organization',
  ),
  InfoSection(
    label: 'Submission Type',
    content: item['submission_type'] ?? 'Submission Type',
  ),
  InfoSection(
    label: 'Short Description',
    content: item['short_description'] ?? 'Short Description',
  ),
  InfoSection(
    label: 'Target Audience',
    content: item['target_audience'] ?? 'Target Audience',
  ),
  InfoSection(
    label: 'Key Features and Goals',
    content: item['short_description'] ?? 'No Description',
  ),
  InfoSection(
    label: 'Potential No User Impact',
    content: item['potential_user_impact'] ?? 'No Potential User Impact',
  ),
  InfoSection(
    label: 'Amount Needed',
    content: item['amount_needed'] ?? 'No Amount Needed',
  ),
  InfoSection(
    label: 'Fund Usage',
    content: item['how_will_funds_will_be_used'] ?? 'N/A',
  ),
  InfoSection(
    label: 'Market Overview',
    content: item['market_overview'] ?? 'N/A',
  ),
  InfoSection(
    label: 'Competitors',
    content: item['competitors'] ?? 'No Competitors',
  ),
  const SizedBox(height: 10),
  Text(
    'Rating: ${userData['average_rating'] ?? 0}  •  Likes: ${userData['like_count'] ?? 0}',
    style: const TextStyle(color: Colors.grey),
  ),
  const SizedBox(height: 20),
],

                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
