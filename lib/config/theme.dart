import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryLight = Color(0xFF3F51B5); // Indigo
  static const Color primaryDark = Color(0xFF303F9F); // Darker Indigo
  static const Color accentLight = Color(0xFFFF4081); // Pink
  static const Color accentDark = Color(0xFFF50057); // Darker Pink
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  
  // Game board colors
  static const Color boardGreen = Color(0xFF1B5E20); // Dark Green
  static const Color boardBorder = Color(0xFF2E7D32); // Slightly lighter green
  static const Color blackPiece = Color(0xFF212121); // Almost black
  static const Color whitePiece = Color(0xFFF5F5F5); // Almost white
  
  // Light theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primaryLight,
      primaryContainer: primaryLight.withOpacity(0.8),
      secondary: accentLight,
      secondaryContainer: accentLight.withOpacity(0.8),
      background: backgroundLight,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: backgroundLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryLight,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryLight,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryLight,
      ),
    ),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
    ),
  );
  
  // Dark theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: primaryDark,
      primaryContainer: primaryDark.withOpacity(0.8),
      secondary: accentDark,
      secondaryContainer: accentDark.withOpacity(0.8),
      background: backgroundDark,
      surface: const Color(0xFF1E1E1E),
    ),
    scaffoldBackgroundColor: backgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accentDark,
      ),
    ),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      color: const Color(0xFF2C2C2C),
    ),
  );
}