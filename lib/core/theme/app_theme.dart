import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primaryStart,
          secondary: AppColors.primaryEnd,
          surface: AppColors.lightSurface,
          background: AppColors.lightBackground,
        ),
        scaffoldBackgroundColor: AppColors.lightBackground,
        textTheme: GoogleFonts.cairoTextTheme(ThemeData.light().textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.lightSurface,
          foregroundColor: AppColors.lightTextPrimary,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: AppColors.lightCardBg,
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.lightInputBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide.none,
          ),
          hintStyle: const TextStyle(color: AppColors.lightTextHint),
        ),
        extensions: const [AppThemeExtension.light],
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryStart,
          secondary: AppColors.primaryEnd,
          surface: AppColors.darkSurface,
          background: AppColors.darkBackground,
        ),
        scaffoldBackgroundColor: AppColors.darkBackground,
        textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkSurface,
          foregroundColor: AppColors.darkTextPrimary,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: AppColors.darkCardBg,
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkInputBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide.none,
          ),
          hintStyle: const TextStyle(color: AppColors.darkTextHint),
        ),
        extensions: const [AppThemeExtension.dark],
      );
}

// Custom theme extension for extra colors
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.divider,
    required this.inputBg,
    required this.navBarBg,
  });

  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color divider;
  final Color inputBg;
  final Color navBarBg;

  static const light = AppThemeExtension(
    cardBg: AppColors.lightCardBg,
    textPrimary: AppColors.lightTextPrimary,
    textSecondary: AppColors.lightTextSecondary,
    textHint: AppColors.lightTextHint,
    divider: AppColors.lightDivider,
    inputBg: AppColors.lightInputBg,
    navBarBg: AppColors.lightSurface,
  );

  static const dark = AppThemeExtension(
    cardBg: AppColors.darkCardBg,
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
    textHint: AppColors.darkTextHint,
    divider: AppColors.darkDivider,
    inputBg: AppColors.darkInputBg,
    navBarBg: AppColors.darkSurface,
  );

  @override
  AppThemeExtension copyWith({
    Color? cardBg,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? divider,
    Color? inputBg,
    Color? navBarBg,
  }) {
    return AppThemeExtension(
      cardBg: cardBg ?? this.cardBg,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textHint: textHint ?? this.textHint,
      divider: divider ?? this.divider,
      inputBg: inputBg ?? this.inputBg,
      navBarBg: navBarBg ?? this.navBarBg,
    );
  }

  @override
  AppThemeExtension lerp(AppThemeExtension? other, double t) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      cardBg: Color.lerp(cardBg, other.cardBg, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      inputBg: Color.lerp(inputBg, other.inputBg, t)!,
      navBarBg: Color.lerp(navBarBg, other.navBarBg, t)!,
    );
  }
}
