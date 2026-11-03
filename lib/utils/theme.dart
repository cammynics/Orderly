import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/order_status.dart';

class OrderlyTheme {
  static const Color primary = Color(0xFFF06292);
  static const Color primaryDark = Color(0xFFD81B60);
  static const Color background = Color(0xFFFFF5F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color text = Color(0xFF4A2C3A);
  static const Color secondaryText = Color(0xFF805F70);
  static const Color border = Color(0xFFF0DCE4);
  static const Color highlight = Color(0xFFFCE4EC);
  static const Color softPink = Color(0xFFFFF1F4);
  static const Color splashBadgeBase = Color(0xFFFFE4EC);
  static const Color splashShadow = Color(0x33F06292);
  static const Color transparent = Colors.transparent;
  static const Color pending = Color(0xFFFFB74D);
  static const Color processing = Color(0xFF64B5F6);
  static const Color completed = Color(0xFF81C784);
  static const Color cancelled = Color(0xFFE57373);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF9A9E), Color(0xFFFAD0C4), Color(0xFFFBC2EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFF06292), Color(0xFFEC407A), Color(0xFFD81B60)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient totalGradient = LinearGradient(
    colors: [Color(0xFFFFE6EC), Color(0xFFFFF0F3)],
  );
  static const LinearGradient emptyStateGradient = LinearGradient(
    colors: [highlight, softPink],
  );
  static const LinearGradient splashFillGradient = LinearGradient(
    colors: [Color(0xFFFFA4B8), primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient splashBackgroundGradient = LinearGradient(
    colors: [background, splashBadgeBase],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static Color statusColor(OrderStatus status) => switch (status) {
    OrderStatus.pending => pending,
    OrderStatus.processing => processing,
    OrderStatus.completed => completed,
    OrderStatus.cancelled => cancelled,
  };

  static ThemeData get light {
    final textTheme = GoogleFonts.poppinsTextTheme().apply(
      bodyColor: text,
      displayColor: text,
    );
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primaryDark,
        surface: surface,
        error: cancelled,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: text,
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: textTheme.bodyMedium?.copyWith(color: secondaryText),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: highlight,
        labelTextStyle: WidgetStatePropertyAll(
          textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryDark,
        foregroundColor: surface,
        shape: CircleBorder(),
      ),
    );
  }
}
