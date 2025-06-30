import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF3A416F), // Deep Indigo
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF81A1C1),   // Frosty Blue
      secondary: Color(0xFFB48EAD), // Muted Purple
      surface: Color(0xFF2E3440),   // Dark Grey-Blue (Nord-like)
      background: Color(0xFF242833), // Darker Grey-Blue
      error: Color(0xFFBF616A),     // Muted Red
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFFECEFF4),   // Off-white
      onBackground: Color(0xFFECEFF4),
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFF242833),
    cardColor: const Color(0xFF2E3440),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF3B4252),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      labelStyle: const TextStyle(color: Color(0xFFD8DEE9)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF81A1C1), // Frosty Blue
        foregroundColor: const Color(0xFF2E3440), // Dark text on button
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2E3440),
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Color(0xFFECEFF4),
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFECEFF4)),
      bodyMedium: TextStyle(color: Color(0xFFD8DEE9)),
      titleLarge: TextStyle(color: Color(0xFFECEFF4), fontWeight: FontWeight.bold),
    ),
  );

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF1976D2), // Classic Blue
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF1976D2),
      secondary: Color(0xFF009688), // Teal accent
      surface: Color(0xFFFFFFFF),
      background: Color(0xFFF4F6F8), // Light grey background
      error: Color(0xFFD32F2F),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black87,
      onBackground: Colors.black87,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFFF4F6F8),
    cardColor: Colors.white,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2.0),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 1,
      iconTheme: IconThemeData(color: Colors.black87),
      titleTextStyle: TextStyle(
        color: Colors.black87,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}
