import 'package:flutter/material.dart';

import 'package:main/screens/home_login.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Twitter Clone',
      theme: ThemeData(
          primaryColor: Colors.white,
          primaryColorDark: Colors.white,
          //accentColor: Color(0xff1CA1F1),
          colorScheme:
              ColorScheme.fromSwatch().copyWith(secondary: Colors.white),
          iconTheme: IconThemeData(color: Colors.white)),
      //   home: HomePage(),\
      home: LoginPage(),
    );
  }
}
