import 'package:flutter/material.dart';
import 'package:app/screens/home_body.dart';
import 'package:app/screens/home_login.dart';
import 'package:app/screens/home_publish.dart';
import 'package:app/screens/profile.dart';
import 'package:app/screens/home_search.dart'; // Import your search page
import 'package:app/screens/home_notifications.dart'; // Rename to Notification
import 'package:app/screens/home_mail.dart';
import 'package:app/screens/home_invest.dart';
import 'package:app/screens/home_settings.dart';
import 'package:app/screens/home_help.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    TwitterBody(), // Replace with your Home page widget
    HomeSearchPage(), // Replace with your Search page widget
    NotificationPage(), // Updated to use Notification instead of NotificationPage
    MailPage()
    // Add other pages here
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('assets/images/face1.jpeg'),
                  ),
                ),
              ),
            ),
          ),
        ),
        // backgroundColor: Theme.of(context).primaryColorDark,
        title: Text('Home'),
      ),
      body: _pages[_selectedIndex],
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(),
                      ),
                    );
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
                      'Carol Danvers',
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
                  '@dan_carol',
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
                          'Profile',
                          style: TextStyle(color: Colors.black),
                        ),
                        leading: Icon(
                          Icons.person,
                          color: Colors.grey,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfilePage()),
                          );
                        },
                      ),
                      ListTile(
                        title: Text(
                          'Publish',
                          style: TextStyle(color: Colors.black),
                        ),
                        leading: Icon(
                          Icons.public,
                          color: Colors.grey,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PublishPage()),
                          );
                        },
                      ),
                      ListTile(
                        title: Text(
                          'Invest',
                          style: TextStyle(color: Colors.black),
                        ),
                        leading: Icon(
                          Icons.upload,
                          color: Colors.grey,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => InvestPage()),
                          );
                        },
                      ),
                      ListTile(
                        title: Text(
                          'Logout',
                          style: TextStyle(color: Colors.black),
                        ),
                        leading: Icon(
                          Icons.logout,
                          color: Colors.grey,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                          );
                        },
                      ),
                      Container(
                        width: double.infinity,
                        color: Colors.grey,
                        height: 0.5,
                      ),
                      ListTile(
                        title: Text(
                          'Settings and Privacy',
                          style: TextStyle(color: Colors.black),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SettingsPrivacyPage()),
                          );
                        },
                      ),
                      ListTile(
                        title: Text(
                          'Help center',
                          style: TextStyle(color: Colors.black),
                        ),  onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HelpCenterPage()),
                          );
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
                          Icons.wb_sunny,
                          size: 32.0,
                        ),
                        onPressed: () {},
                      ),
                    ),
                    SizedBox(
                      height: 30.0,
                      width: 30.0,
                      child: IconButton(
                        padding: EdgeInsets.all(0.0),
                        icon: Icon(
                          Icons.camera_alt,
                          size: 32.0,
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
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail),
            label: 'Messages',
          ),
        ],
        backgroundColor:
            Colors.transparent, // Set the background color to transparent
        elevation: 0, // Remove the shadow
        currentIndex: _selectedIndex,
        // selectedItemColor: Theme.of(context).colorScheme.primary, // Adjust as needed
        // unselectedItemColor: Theme.of(context).colorScheme.onSurface, // Adjust as needed
        // selectedLabelStyle: TextStyle(color: Theme.of(context).colorScheme.primary), // Adjust as needed
        // unselectedLabelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface), // Adjust as needed
        onTap: _onItemTapped,
      ),
    );
  }
}
