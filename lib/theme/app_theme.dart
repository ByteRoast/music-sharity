import 'package:flutter/material.dart';

class AppTheme {
  static const Color electricBlue = Color(0xFF00A8FF);
  static const Color youtubeRed = Color(0xFFFF0000);
  static const Color deepBlack = Color(0xFF0A0A0A);
  static const Color darkGrey = Color(0xFF1A1A1A);
  static const Color mediumGrey = Color(0xFF2A2A2A);
  static const Color lightGrey = Color(0xFFB0B0B0);

  static ColorScheme get darkColorScheme => ColorScheme.fromSeed(
    seedColor: electricBlue,
    brightness: Brightness.dark,
    primary: electricBlue,
    secondary: youtubeRed,
    surface: darkGrey,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: lightGrey,
    error: youtubeRed,
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: darkColorScheme,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: deepBlack,

    appBarTheme: AppBarTheme(
      backgroundColor: darkGrey,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
  
    cardTheme: CardThemeData(
      color: mediumGrey,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: electricBlue,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: mediumGrey,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: electricBlue, width: 2),
      ),
    ),
  );
}
