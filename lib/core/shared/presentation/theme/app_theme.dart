import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';

class AppTheme {
  AppTheme._();

  static const Color primaryColor = Color(0xFF0FA4AF);
  static const Color secondaryColor = Color(0xFF6366F1);
  static const Color accentColor = Color(0xFF14B8A6);

  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8);

  static const Color errorColor = Color.fromARGB(235, 212, 62, 62);
  static const Color warningColor = Color(0xFFD97706);
  static const Color successColor = Color(0xE108C388);

  static const Color expiredColor = Color(0xFFDC2626);
  static const Color nearExpiryColor = Color(0xFFD97706);
  static const Color validColor = Color(0xFF059669);

  /// الثيم الفاتح
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppConstants.fontFamily,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        error: Color(0xCFFF4F4F),
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: textTertiary,
        ),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        actionsPadding: EdgeInsets.symmetric(horizontal: 5),
      ),
      cardTheme: CardThemeData(
        shadowColor: const Color.fromARGB(141, 255, 255, 255),
        elevation: 1.2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dividerTheme: DividerThemeData(color: Colors.grey[300]),
      listTileTheme: ListTileThemeData(
        tileColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        circularTrackColor: Colors.white,
        strokeWidth: 2,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbVisibility: const MaterialStatePropertyAll(false),
        trackVisibility: const MaterialStatePropertyAll(false),
        thickness: const MaterialStatePropertyAll(6),
        interactive: true,
        radius: const Radius.circular(12),
        thumbColor:
            WidgetStatePropertyAll(AppTheme.primaryColor.withOpacity(0.6)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          iconSize: 24,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shadowColor: AppTheme.primaryColor.withOpacity(0.35),
          padding: const EdgeInsets.all(7),
          fixedSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      iconTheme: IconThemeData(
        size: 24,
        shadows: [
          BoxShadow(
            color: AppTheme.accentColor.withOpacity(0.08),
            blurRadius: 5,
            spreadRadius: 2,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        errorStyle: const TextStyle(fontSize: 12, height: 2),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
