import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme() {
    const primaryColor = Color(0xFF1976D2); // Blue
    const secondaryColor = Color(0xFF03DAC6); // Teal
    const backgroundColor = Color(0xFFFAFAFA);
    const surfaceColor = Colors.white;
    const errorColor = Color(0xFFD32F2F);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        onPrimary: Colors.white,
        secondary: secondaryColor,
        onSecondary: Colors.black,
        error: errorColor,
        onError: Colors.white,
        surface: surfaceColor,
        onSurface: Colors.black87,
        outline: Colors.black26,
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // Text Theme
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(fontSize: 32.sp, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.poppins(fontSize: 28.sp, fontWeight: FontWeight.bold),
        displaySmall: GoogleFonts.poppins(fontSize: 24.sp, fontWeight: FontWeight.bold),
        headlineLarge: GoogleFonts.poppins(fontSize: 22.sp, fontWeight: FontWeight.w600),
        headlineMedium: GoogleFonts.poppins(fontSize: 20.sp, fontWeight: FontWeight.w600),
        headlineSmall: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w500),
        titleSmall: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w500),
        bodyLarge: GoogleFonts.poppins(fontSize: 16.sp),
        bodyMedium: GoogleFonts.poppins(fontSize: 14.sp),
        bodySmall: GoogleFonts.poppins(fontSize: 12.sp),
        labelLarge: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w500),
        labelMedium: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w500),
        labelSmall: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w500),
      ),

      // Card Theme
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          side: const BorderSide(width: 1.5),
          textStyle: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: errorColor, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        labelStyle: GoogleFonts.poppins(
          fontSize: 14.sp,
          color: Colors.black54,
        ),
        hintStyle: GoogleFonts.poppins(
          fontSize: 14.sp,
          color: Colors.black38,
        ),
      ),

      // Scaffold Background
      scaffoldBackgroundColor: backgroundColor,

      // Divider Theme
      dividerTheme: const DividerThemeData(
        thickness: 1,
        color: Colors.black12,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey.shade100,
        selectedColor: primaryColor.withValues( alpha: 0.2),
        checkmarkColor: primaryColor,
        deleteIconColor: Colors.black54,
        labelStyle: GoogleFonts.poppins(
          fontSize: 12.sp,
          color: Colors.black87,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
    );
  }

  static ThemeData darkTheme() {
    const primaryColor = Color(0xFF90CAF9); // Light Blue
    const secondaryColor = Color(0xFF03DAC6); // Teal
    const backgroundColor = Color(0xFF121212);
    const surfaceColor = Color(0xFF1E1E1E);
    const errorColor = Color(0xFFEF5350);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        onPrimary: Colors.black,
        secondary: secondaryColor,
        onSecondary: Colors.black,
        error: errorColor,
        onError: Colors.white,
        surface: surfaceColor,
        onSurface: Colors.white70,
        outline: Colors.white24,
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // Text Theme
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.poppins(fontSize: 32.sp, fontWeight: FontWeight.bold, color: Colors.white),
        displayMedium: GoogleFonts.poppins(fontSize: 28.sp, fontWeight: FontWeight.bold, color: Colors.white),
        displaySmall: GoogleFonts.poppins(fontSize: 24.sp, fontWeight: FontWeight.bold, color: Colors.white),
        headlineLarge: GoogleFonts.poppins(fontSize: 22.sp, fontWeight: FontWeight.w600, color: Colors.white),
        headlineMedium: GoogleFonts.poppins(fontSize: 20.sp, fontWeight: FontWeight.w600, color: Colors.white),
        headlineSmall: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w600, color: Colors.white),
        titleLarge: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white),
        titleMedium: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.white),
        titleSmall: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w500, color: Colors.white),
        bodyLarge: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.white),
        bodyMedium: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.white),
        bodySmall: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.white70),
        labelLarge: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.white),
        labelMedium: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w500, color: Colors.white),
        labelSmall: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w500, color: Colors.white70),
      ),

      // Card Theme
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        color: surfaceColor,
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          side: const BorderSide(width: 1.5),
          textStyle: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues( alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: errorColor, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        labelStyle: GoogleFonts.poppins(
          fontSize: 14.sp,
          color: Colors.white70,
        ),
        hintStyle: GoogleFonts.poppins(
          fontSize: 14.sp,
          color: Colors.white38,
        ),
      ),

      // Scaffold Background
      scaffoldBackgroundColor: backgroundColor,

      // Divider Theme
      dividerTheme: const DividerThemeData(
        thickness: 1,
        color: Colors.white12,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withValues( alpha: 0.1),
        selectedColor: primaryColor.withValues( alpha: 0.2),
        checkmarkColor: primaryColor,
        deleteIconColor: Colors.white70,
        labelStyle: GoogleFonts.poppins(
          fontSize: 12.sp,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
    );
  }
}