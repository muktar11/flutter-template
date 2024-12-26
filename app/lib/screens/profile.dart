import 'package:flutter/material.dart';
import '../theme/theme.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // Add this import

class ProfilePage extends StatelessWidget {
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
  final tweets = [
    'Create the highest, grandest vision possible for your life, because you become what you believe.',
    'When you can’t find the sunshine, be the sunshine',
    'The grass is greener where you water it',
    'Wherever life plants you, bloom with grace',
    'So, what if, instead of thinking about solving your whole life, you just think about adding additional good things. One at a time. Just let your pile of good things grow',
    'Little by little, day by day, what is meant for you WILL find its way',
  ];
  final replies = ['1', '15', '10', '19', '69', '3'];
  final retweets = ['10', '1k', '1', '9', '6', '30'];
  final likes = ['50', '10', '70', '2', '5', '10'];

  void showEditProfileModal(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController phoneController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    File? profileImage; // To store profile image

    Future<void> pickImage() async {
      final ImagePicker _picker = ImagePicker();
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        profileImage = File(image.path);
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Edit Profile'),
              content: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    // Profile Picture
                    GestureDetector(
                      onTap: () async {
                        await pickImage();
                        setState(() {}); // Update UI after image is picked
                      },
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: profileImage != null
                            ? FileImage(profileImage!)
                            : AssetImage('assets/default_profile.png')
                                as ImageProvider,
                        child: profileImage == null
                            ? Icon(Icons.camera_alt, size: 30, color: Colors.grey)
                            : null,
                      ),
                    ),
                    SizedBox(height: 20),
                    // Full Name Input
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: "Full Name",
                        hintText: "Enter your full name",
                      ),
                    ),
                    SizedBox(height: 10),
                    // Phone Number Input
                    TextField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: "Phone",
                        hintText: "Enter your phone number",
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 10),
                    // Email Input
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        hintText: "Enter your email",
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text("Save"),
                  onPressed: () {
                    // Save logic here, e.g., save the new profile details
                    print("Name: ${nameController.text}");
                    print("Phone: ${phoneController.text}");
                    print("Email: ${emailController.text}");
                    if (profileImage != null) {
                      print("Profile image selected");
                    }
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      // Dispose of the controllers after use
      nameController.dispose();
      phoneController.dispose();
      emailController.dispose();
    });
  }



  void showEditPostModal(BuildContext context, int index) {
    TextEditingController tweetController = TextEditingController(text: tweets[index]);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Post'),
          content: TextField(
            controller: tweetController,
            decoration: InputDecoration(hintText: "Edit your tweet"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Save"),
              onPressed: () {
                // Save the edited post
                tweets[index] = tweetController.text;
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    ).then((_) => tweetController.dispose()); // Dispose controller after use
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Access the current theme
    final textTheme = theme.textTheme; // Access text styles from the theme
    final primaryColor = theme.colorScheme.primary; // Theme primary color
    final backgroundColor = Colors.white; // Set background color to white
    final buttonColor = Colors.lightBlue; // Light blue color for buttons

    return Scaffold(
      backgroundColor: backgroundColor, // Set scaffold background to white
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 275,
            floating: false,
            pinned: true,
            title: Text('Profile', style: textTheme.titleLarge!.copyWith(color: Colors.black)),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.fitWidth,
                        image: AssetImage('assets/images/image2.jpeg'),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 190,
                    child: GestureDetector(
                      onTap: () => showEditProfileModal(context),
                      child: Container(
                        width: 120.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: buttonColor, width: 2.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Center(
                          child: Text(
                            'Edit Profile',
                            style: textTheme.bodyMedium?.copyWith(
                              color: buttonColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        height: 125,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              width: 100,
                              height: 100,
                              decoration: ShapeDecoration(
                                shape: CircleBorder(),
                                color: backgroundColor, // Profile circle background
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(3.0),
                                child: DecoratedBox(
                                  decoration: ShapeDecoration(
                                    shape: CircleBorder(),
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: AssetImage('assets/images/face1.jpeg'),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          'carol Danvers',
                          style: textTheme.titleMedium?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          '@dan_carol',
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.black.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              centerTitle: true,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Column(
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
                          decoration: BoxDecoration(
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
                                        style: textTheme.bodyLarge?.copyWith(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          usernames[index],
                                          style: textTheme.bodySmall?.copyWith(
                                            color: Colors.black.withOpacity(0.6),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.edit, color: buttonColor), // Light blue color for edit button
                                    onPressed: () => showEditPostModal(context, index),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 0.0, bottom: 8.0),
                                child: Text(
                                  tweets[index],
                                  style: textTheme.bodyMedium?.copyWith(
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
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Icon(Icons.chat_bubble_outline, size: 18, color: theme.iconTheme.color),
                                        SizedBox(width: 4),
                                        Text(
                                          replies[index],
                                          style: textTheme.bodySmall?.copyWith(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Icon(Icons.replay, size: 18, color: theme.iconTheme.color),
                                        SizedBox(width: 4),
                                        Text(
                                          retweets[index],
                                          style: textTheme.bodySmall?.copyWith(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Icon(Icons.favorite_border, size: 18, color: theme.iconTheme.color),
                                        SizedBox(width: 4),
                                        Text(
                                          likes[index],
                                          style: textTheme.bodySmall?.copyWith(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Divider(height: 0),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              childCount: names.length,
            ),
          ),
        ],
      ),
    );
  }
}
