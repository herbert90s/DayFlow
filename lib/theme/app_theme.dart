import 'package:flutter/material.dart';

import '../models/task.dart';

abstract final class AppColors {
  static const blue700 = Color(0xFF1456CC);
  static const blue = Color(0xFF1F6FEB);
  static const blue100 = Color(0xFFE8F1FF);
  static const blue50 = Color(0xFFF5F9FF);
  static const ink = Color(0xFF16233A);
  static const muted = Color(0xFF6C788B);
  static const line = Color(0xFFE5EAF1);
  static const background = Color(0xFFF3F6FA);
  static const red = Color(0xFFD7473F);
  static const redSoft = Color(0xFFFFF0EF);
  static const amber = Color(0xFFD98B19);
  static const amberSoft = Color(0xFFFFF7E8);
  static const green = Color(0xFF168866);
  static const greenSoft = Color(0xFFE9F7F2);

  static Color priority(TaskPriority priority) => switch (priority) {
    TaskPriority.low => green,
    TaskPriority.medium => amber,
    TaskPriority.high => red,
  };

  static Color priorityBackground(TaskPriority priority) => switch (priority) {
    TaskPriority.low => greenSoft,
    TaskPriority.medium => amberSoft,
    TaskPriority.high => redSoft,
  };
}

ThemeData buildAppTheme() {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(13),
    borderSide: const BorderSide(color: AppColors.line),
  );
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.blue,
      primary: AppColors.blue,
      surface: Colors.white,
      onSurface: AppColors.ink,
      error: AppColors.red,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.ink,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      toolbarHeight: 74,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: 'Roboto',
        color: AppColors.ink,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      shape: Border(bottom: BorderSide(color: AppColors.line)),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.ink, fontSize: 14),
      titleLarge: TextStyle(
        color: AppColors.ink,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.7,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
      hintStyle: const TextStyle(color: Color(0xFF9BA5B3), fontSize: 14),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.blue, width: 1.5),
      ),
      errorBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.red),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.blue,
        backgroundColor: Colors.white,
        minimumSize: const Size(0, 48),
        side: const BorderSide(color: AppColors.blue),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        textStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.blue,
        textStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.blue,
      foregroundColor: Colors.white,
      elevation: 7,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    dividerTheme: const DividerThemeData(color: AppColors.line, space: 1),
  );
}
