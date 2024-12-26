import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkTheme = false;

  bool get isDarkTheme => _isDarkTheme;

  ThemeData get currentTheme => _isDarkTheme ? _darkTheme : _lightTheme;

  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    notifyListeners();
  }

  final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.white,
    colorScheme: ColorScheme.light(
      primary: Color(0xFF416FDF),
      onPrimary: Color(0xFFFFFFFF),
      secondary: Color(0xFF6EAEE7),
      onSecondary: Color(0xFFFFFFFF),
      error: Color(0xFFBA1A1A),
      onError: Color(0xFFFFFFFF),
      background: Color(0xFFFCFDF6),
      onBackground: Color(0xFF1A1C18),
      shadow: Color(0xFF000000),
      outlineVariant: Color(0xFFC2C8BC),
      surface: Color(0xFFF9FAF3),
      onSurface: Color(0xFF1A1C18),
    ),
  );

  final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.black,
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF416FDF),
      onPrimary: Color(0xFFFFFFFF),
      secondary: Color(0xFF6EAEE7),
      onSecondary: Color(0xFFFFFFFF),
      error: Color(0xFFBA1A1A),
      onError: Color(0xFFFFFFFF),
      background: Color(0xFFFCFDF6),
      onBackground: Color(0xFF1A1C18),
      shadow: Color(0xFF000000),
      outlineVariant: Color(0xFFC2C8BC),
      surface: Color(0xFFF9FAF3),
      onSurface: Color(0xFF1A1C18),
    ),
  );
}
