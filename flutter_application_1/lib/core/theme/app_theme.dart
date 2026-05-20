import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    fontFamily: "Inter",
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.cardLight,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.primary,
      onError: Colors.white,
    ),
    dividerColor: AppColors.borderLight,
    cardTheme: CardThemeData(
      color: AppColors.cardLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: AppColors.accentEnd,
          width: 1.5,
        ),
      ),
      labelStyle: const TextStyle(color: AppColors.secondary),
      hintStyle: const TextStyle(color: AppColors.secondaryTextDark),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
        disabledForegroundColor: Colors.white.withValues(alpha: 0.6),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accentTextOnLight,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      contentTextStyle: TextStyle(color: Colors.white),
      backgroundColor: AppColors.primary,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.backgroundLight,
      labelStyle: const TextStyle(color: AppColors.primary),
      side: const BorderSide(color: AppColors.borderLight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.accentEnd,
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColors.primary),
      displayMedium: TextStyle(color: AppColors.primary),
      displaySmall: TextStyle(color: AppColors.primary),
      headlineLarge: TextStyle(color: AppColors.primary),
      headlineMedium: TextStyle(color: AppColors.primary),
      headlineSmall: TextStyle(color: AppColors.primary),
      titleLarge: TextStyle(color: AppColors.primary),
      titleMedium: TextStyle(color: AppColors.primary),
      titleSmall: TextStyle(color: AppColors.secondary),
      bodyLarge: TextStyle(color: AppColors.primary),
      bodyMedium: TextStyle(color: AppColors.secondary),
      bodySmall: TextStyle(color: AppColors.secondary),
      labelLarge: TextStyle(color: AppColors.primary),
      labelMedium: TextStyle(color: AppColors.secondary),
      labelSmall: TextStyle(color: AppColors.secondary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.cardLight,
      selectedItemColor: AppColors.accentEnd,
      unselectedItemColor: AppColors.secondary,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.accentEnd,
      linearTrackColor: AppColors.borderLight,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.cardLight,
      surfaceTintColor: Colors.transparent,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.borderLight,
      thickness: 1,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    fontFamily: "Inter",
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accentDark,
      secondary: AppColors.accentDarkSecondary,
      surface: AppColors.cardDark,
      onSurface: AppColors.primaryTextDark,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      error: AppColors.errorDark,
      onError: Colors.white,
    ),
    dividerColor: AppColors.dividerDark,
    cardTheme: CardThemeData(
      color: AppColors.cardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cardElevated,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: AppColors.accentDark,
          width: 1.5,
        ),
      ),
      labelStyle: const TextStyle(color: AppColors.primaryTextDark),
      hintStyle: const TextStyle(color: AppColors.tertiaryTextDark),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accentDark,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.accentDark.withValues(alpha: 0.4),
        disabledForegroundColor: Colors.white.withValues(alpha: 0.4),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accentDark,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.accentDark,
        side: const BorderSide(color: AppColors.accentDark),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      contentTextStyle: TextStyle(color: Colors.white),
      backgroundColor: AppColors.cardElevated,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.cardElevated,
      labelStyle: const TextStyle(color: AppColors.primaryTextDark),
      side: const BorderSide(color: AppColors.borderDark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundDark,
      foregroundColor: AppColors.primaryTextDark,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.accentDark,
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColors.primaryTextDark),
      displayMedium: TextStyle(color: AppColors.primaryTextDark),
      displaySmall: TextStyle(color: AppColors.primaryTextDark),
      headlineLarge: TextStyle(color: AppColors.primaryTextDark),
      headlineMedium: TextStyle(color: AppColors.primaryTextDark),
      headlineSmall: TextStyle(color: AppColors.primaryTextDark),
      titleLarge: TextStyle(color: AppColors.primaryTextDark),
      titleMedium: TextStyle(color: AppColors.primaryTextDark),
      titleSmall: TextStyle(color: AppColors.secondaryTextDark),
      bodyLarge: TextStyle(color: AppColors.primaryTextDark),
      bodyMedium: TextStyle(color: AppColors.secondaryTextDark),
      bodySmall: TextStyle(color: AppColors.tertiaryTextDark),
      labelLarge: TextStyle(color: AppColors.primaryTextDark),
      labelMedium: TextStyle(color: AppColors.secondaryTextDark),
      labelSmall: TextStyle(color: AppColors.tertiaryTextDark),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.cardDark,
      selectedItemColor: AppColors.accentDark,
      unselectedItemColor: AppColors.secondaryTextDark,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.accentDark,
      linearTrackColor: AppColors.borderDark,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.cardElevated,
      surfaceTintColor: Colors.transparent,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.dividerDark,
      thickness: 1,
    ),
    popupMenuTheme: const PopupMenuThemeData(
      color: AppColors.cardElevated,
      surfaceTintColor: Colors.transparent,
    ),
    dropdownMenuTheme: const DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
        fillColor: AppColors.cardElevated,
      ),
    ),
    timePickerTheme: const TimePickerThemeData(
      backgroundColor: AppColors.cardElevated,
      dialBackgroundColor: AppColors.cardDark,
      dialHandColor: AppColors.accentDark,
      entryModeIconColor: AppColors.accentDark,
      hourMinuteColor: AppColors.cardDark,
      dayPeriodColor: AppColors.cardDark,
      hourMinuteTextColor: AppColors.primaryTextDark,
      dayPeriodTextColor: AppColors.primaryTextDark,
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: AppColors.cardElevated,
      surfaceTintColor: Colors.transparent,
      headerBackgroundColor: AppColors.accentDark,
      headerForegroundColor: Colors.white,
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        return AppColors.primaryTextDark;
      }),
      dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.accentDark;
        }
        return Colors.transparent;
      }),
    ),
  );
}