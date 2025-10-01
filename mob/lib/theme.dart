import 'package:flutter/material.dart';

class AppTheme {
  // Legacy color fields for backward compatibility
  static const Color trustBlue = Color.fromARGB(255, 0, 0, 0); // Black as before
  static const Color calmGreen = Color(0xFF2ECC71); // Green as before
  // Primary colors as specified in requirements
  // Stylish, modern color palette
  static const Color primary = Color(0xFF4F8EF7); // Soft blue
  static const Color accent = Color(0xFF6DD5FA); // Light blue gradient
  static const Color background = Color(0xFFF7F9FB); // Off-white
  static const Color card = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF222B45); // Deep blue-gray
  static const Color textSecondary = Color(0xFF8F9BB3); // Muted gray
  static const Color divider = Color(0xFFE4E9F2);
  static const Color warning = Color(0xFFFFA726); // Orange
  static const Color success = Color(0xFF43E97B); // Green
  static const Color error = Color(0xFFEF5350); // Red

  // Dark mode colors
  static const Color darkBackground = Color(0xFF181A20);
  static const Color darkCard = Color(0xFF222B45);
  static const Color darkTextPrimary = Color(0xFFF7F9FB);
  static const Color darkTextSecondary = Color(0xFF8F9BB3);

  // Text styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: 0.5,
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: 0.2,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    color: textPrimary,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 14,
    color: textSecondary,
    fontWeight: FontWeight.w400,
  );

  // Button styles
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 2,
    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  );

  static ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: accent,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: primary),
    ),
    elevation: 0,
    textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
  );

  // Card decoration
  static BoxDecoration cardDecoration = BoxDecoration(
    color: card,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: primary.withOpacity(0.08),
        blurRadius: 16,
        offset: const Offset(0, 8),
      ),
    ],
  );

  // Input decoration
  static InputDecoration inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: textSecondary),
      filled: true,
      fillColor: accent.withOpacity(0.08),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    );
  }

  // Create app theme data
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primary,
    scaffoldBackgroundColor: background,
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: primaryButtonStyle),
    textTheme: const TextTheme(
      headlineLarge: headingStyle,
      headlineMedium: subheadingStyle,
      bodyLarge: bodyStyle,
      bodyMedium: captionStyle,
    ),
    colorScheme: ColorScheme.light(
      primary: primary,
      secondary: accent,
      background: background,
      surface: card,
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: textPrimary,
      onSurface: textPrimary,
      onError: Colors.white,
      brightness: Brightness.light,
    ),
    cardColor: card,
    dividerColor: divider,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: accent.withOpacity(0.08),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primary, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      hintStyle: TextStyle(color: textSecondary),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primary,
    scaffoldBackgroundColor: darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: darkCard,
      foregroundColor: darkTextPrimary,
      elevation: 0,
      iconTheme: IconThemeData(color: darkTextPrimary),
      titleTextStyle: TextStyle(
        color: darkTextPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: primaryButtonStyle),
    textTheme: const TextTheme(
      headlineLarge: headingStyle,
      headlineMedium: subheadingStyle,
      bodyLarge: bodyStyle,
      bodyMedium: captionStyle,
    ),
    colorScheme: ColorScheme.dark(
      primary: primary,
      secondary: accent,
      background: darkBackground,
      surface: darkCard,
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: darkTextPrimary,
      onSurface: darkTextPrimary,
      onError: Colors.white,
      brightness: Brightness.dark,
    ),
    cardColor: darkCard,
    dividerColor: divider,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: accent, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      hintStyle: TextStyle(color: darkTextSecondary),
    ),
  );
}
