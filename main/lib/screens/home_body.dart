import 'package:flutter/material.dart';
import 'package:main/screens/home_detail.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:main/screens/home_search.dart';

class TwitterBody extends StatelessWidget {
  final profileimages = [
    'assets/images/face1.jpeg',
    'assets/images/face2.jpeg',
    'assets/images/face3.jpeg',
    'assets/images/face4.jpeg',
    'assets/images/face5.jpeg',
    'assets/images/face5.jpeg',
  ];

  final names = ['apple', 'orange', 'banana', 'guava', 'papaya', 'strawberry'];
  final usernames = [
    '@apple',
    '@orange',
    '@banana',
    '@guava',
    '@papaya',
    '@strawberry'
  ];
  final images = [
    null,
    'assets/images/image1.jpeg',
    null,
    'assets/images/face4.jpeg',
    null,
    'assets/images/image2.jpeg',
  ];
  final videos = [
    null,
    'https://www.youtube.com/watch?v=taqWvJnX6u0',
    'https://www.youtube.com/watch?v=taqWvJnX6u0',
    null,
    null,
    null,
  ];
  final tweets = [
    'Create the highest, grandest vision possible for your life, because you become what you believe.',
    'When you can’t find the sunshine, be the sunshine',
    'The grass is greener where you water it',
    'Wherever life plants you, bloom with grace',
    'So, what if, instead of thinking about solving your whole life, you just think about adding additional good things. One at a time. Just let your pile of good things grow',
    'Little by little, day by day, what is meant for you WILL find its way',
  ];
  final replies = ['1', '15', '10', '19', '69', '3'];
  // final retweets = ['10', '1k', '1', '9', '6', '30'];
  final likes = ['50', '10', '70', '2', '5', '10'];

  Widget getList() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) => GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeDetailPage(
                profileImage: profileimages[index],
                name: names[index],
                username: usernames[index],
                tweet: tweets[index],
                replies: replies[index],
                //         retweets: retweets[index],
                likes: likes[index],
                image: images[index],
                video: videos[index], // Pass video to the detail page
              ),
            ),
          );
        },
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 40.0,
                    height: 40.0,
                    decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.fitHeight,
                        image: AssetImage(profileimages[index]),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Text(
                                  names[index],
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    usernames[index],
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: Colors.grey,
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 0.0, bottom: 8.0, right: 28.0),
                          child: Text(
                            tweets[index],
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        if (images[index] != null)
                          Container(
                            width: double.infinity,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.asset(images[index]!),
                            ),
                          ),
                        if (videos[index] != null)
                          Container(
                            width: double.infinity,
                            height: 200.0,
                            child: YoutubePlayerWidget(videos[index]!),
                          ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(
                                    height: 10.0,
                                    width: 18.0,
                                    child: IconButton(
                                      padding: new EdgeInsets.all(0.0),
                                      icon: Icon(
                                        Icons.chat_bubble_outline,
                                        size: 18.0,
                                        color: Colors.black,
                                      ),
                                      onPressed: () {},
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                    width: 18.0,
                                    child: Text(
                                      replies[index],
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(
                                    height: 10.0,
                                    width: 18.0,
                                    child: IconButton(
                                      padding: new EdgeInsets.all(0.0),
                                      icon: Icon(
                                        Icons.favorite_border,
                                        size: 18.0,
                                        color: Colors.black,
                                      ),
                                      onPressed: () {},
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                    width: 18.0,
                                    child: Text(
                                      likes[index],
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10.0,
                                width: 10.0,
                                child: IconButton(
                                  padding: new EdgeInsets.all(0.0),
                                  icon: Icon(
                                    Icons.share,
                                    size: 18.0,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {},
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
            //  padding: const EdgeInsets.only(top: 15),
              child: Container(
                width: double.infinity,
               
                color: Colors.grey[300], // Slightly whiter color
                height: 5.0, // Thicker line
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
    
      color: Colors.white, // Change the background color to white
      child: getList(),
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
      onReady: () {},
    );
  }
}
