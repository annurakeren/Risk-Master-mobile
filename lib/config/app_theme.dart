// lib/config/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────

class AppColors {
  // Primary — Institutional Blue
  static const primary = Color(0xFF004AC6);
  static const primaryContainer = Color(0xFF2563EB);
  static const primaryLight = Color(0xFF3B82F6);
  static const onPrimary = Colors.white;
  static const onPrimaryContainer = Colors.white;

  // Secondary
  static const secondary = Color(0xFF1E40AF);
  static const secondaryContainer = Color(0xFFDBEAFE);
  static const onSecondary = Colors.white;
  static const onSecondaryContainer = Color(0xFF1E3A8A);

  // Tertiary
  static const tertiary = Color(0xFF0EA5E9);
  static const tertiaryContainer = Color(0xFFE0F2FE);
  static const onTertiary = Colors.white;
  static const onTertiaryContainer = Color(0xFF0C4A6E);

  // Surface
  static const background = Color(0xFFF8FAFF);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF1F5F9);
  static const surfaceContainerLow = Color(0xFFEFF6FF);
  static const surfaceContainerHigh = Color(0xFFE2E8F0);
  static const onBackground = Color(0xFF0F172A);
  static const onSurface = Color(0xFF0F172A);
  static const onSurfaceVariant = Color(0xFF475569);

  // Outline
  static const outline = Color(0xFFCBD5E1);
  static const outlineVariant = Color(0xFFE2E8F0);

  // Error
  static const error = Color(0xFFDC2626);
  static const errorContainer = Color(0xFFFEE2E2);
  static const onError = Colors.white;
  static const onErrorContainer = Color(0xFF7F1D1D);

  // Status
  static const success = Color(0xFF059669);
  static const successContainer = Color(0xFFD1FAE5);
  static const warning = Color(0xFFD97706);
  static const warningContainer = Color(0xFFFEF3C7);

  // Text
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF475569);
  static const textTertiary = Color(0xFF94A3B8);
  static const textDisabled = Color(0xFFCBD5E1);
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double full = 999;
}

// ─── Theme Builder ─────────────────────────────────────────────────────────────

class AppTheme {
  static ThemeData get theme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.secondaryContainer,
      onPrimaryContainer: AppColors.onSecondaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.onTertiaryContainer,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      surfaceContainerHighest: AppColors.surfaceVariant,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
    );

    final textTheme = GoogleFonts.interTextTheme(
      TextTheme(
        displayLarge: const TextStyle(fontSize: 57, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
        displayMedium: const TextStyle(fontSize: 45, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
        displaySmall: const TextStyle(fontSize: 36, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
        headlineLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        headlineMedium: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        headlineSmall: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        titleLarge: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        titleSmall: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        bodyLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
        bodyMedium: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
        bodySmall: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textTertiary),
        labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        labelMedium: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: AppColors.textSecondary),
        labelSmall: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: AppColors.textTertiary),
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.background,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        shape: const Border(
          bottom: BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: const BorderSide(color: AppColors.outlineVariant),
        ),
        margin: EdgeInsets.zero,
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        labelStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
        hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textTertiary),
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
      ),

      // FilledButton
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.outlineVariant,
          disabledForegroundColor: AppColors.textTertiary,
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
          minimumSize: const Size(double.infinity, 48),
        ),
      ),

      // OutlinedButton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
          minimumSize: const Size(double.infinity, 48),
        ),
      ),

      // TextButton
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // FloatingActionButton
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        elevation: 2,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.outlineVariant,
        thickness: 1,
        space: 0,
      ),

      // BottomSheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
        elevation: 8,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        elevation: 4,
        titleTextStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        contentTextStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: GoogleFonts.inter(fontSize: 14, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
      ),

      // ListTile
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        minVerticalPadding: 0,
      ),

      // Icon
      iconTheme: const IconThemeData(color: AppColors.textSecondary, size: 20),

      // Chip
      chipTheme: ChipThemeData(
        labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.full)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        side: BorderSide.none,
      ),
    );
  }
}
