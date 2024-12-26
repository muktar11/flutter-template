import 'package:flutter/material.dart';
import 'package:main/screens/home_login.dart';
import 'package:main/screens/home_settings.dart';
import 'package:provider/provider.dart';
import './theme/theme_provider.dart';


void main() => runApp(
   ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child:  MyApp(),
    ),
  );

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LinkIt',
      theme: themeProvider.currentTheme,
      home: LoginPage(),
    );
  }
}
