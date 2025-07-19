import 'package:flutter/material.dart';

class AppThemes {
  // Custom Colors
  static const Color portsmouthPurple = Color(0xFF1C011C);
  static const Color portsmouthBlue = Color(0xFF00A0FF);
  static const Color lightPortsmouthPurple = Color(0xFF9D7DE5);

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: portsmouthPurple,
    colorScheme: const ColorScheme.light(
      primary: portsmouthPurple, // Dark Purple
      secondary: portsmouthBlue, // Bright Blue
      tertiary: Color(0xFFE5E7EB), // Light Grey
      error: Color(0xFFFF5963), // Red for errors
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: portsmouthPurple, // Dark Purple text for AppBar
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: portsmouthPurple), // Dark Purple icons
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        color: portsmouthPurple, // Dark Purple text for headings
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(
        color: Colors.black, // Black text for body
        fontSize: 16,
      ),
    ),
    buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // Rounded buttons
      ),
      buttonColor: portsmouthPurple, // Dark Purple buttons
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: lightPortsmouthPurple,
    colorScheme: const ColorScheme.dark(
      primary: lightPortsmouthPurple, // Dark Purple
      secondary: portsmouthBlue, // Bright Blue
      tertiary: Color(0xFFE5E7EB), // Light Grey
      error: Color(0xFFFF5963), // Red for errors
      surface: Color(0xFF121212), // Dark background
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E), // Darker AppBar
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white, // White text for AppBar
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.white), // White icons
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        color: Colors.white, // White text for headings
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(
        color: Colors.white, // White text for body
        fontSize: 16,
      ),
    ),
    buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // Rounded buttons
      ),
      buttonColor: lightPortsmouthPurple, // Dark Purple buttons
    ),
  );
}
