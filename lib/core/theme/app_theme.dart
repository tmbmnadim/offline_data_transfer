import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'text_styles.dart';

class AppTheme {
  AppTheme._();

  // --- 1. The Palette (Single Source of Truth) ---
  static const Color primary = Color(0xFF0C0C0C);
  static const Color secondary = Color(0xFF3083F9);
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF00C566);
  static const Color warning = Color(0xFFFACC15);

  static const Color textPrimary = Color(0xFF262621);
  static const Color textSecondary = Color(0xFF505050);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color border = Color(0xFFE5E5E5);

  // --- 2. The Light Theme (Active) ---
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: TextStyles.fontFamily,
      scaffoldBackgroundColor: background,
      
      // Standard Color Scheme
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        outline: border,
      ),

      // -----------------------------------------------------------------------
      // CORE UI ELEMENTS
      // -----------------------------------------------------------------------
      
      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyles.bold.copyWith(fontSize: 20, color: textPrimary),
        iconTheme: const IconThemeData(color: textPrimary),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),

      // Icons
      iconTheme: const IconThemeData(color: textSecondary, size: 24),
      
      // Dividers
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),

      // -----------------------------------------------------------------------
      // BUTTONS
      // -----------------------------------------------------------------------
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: TextStyles.medium.copyWith(color: Colors.white),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: TextStyles.medium,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: TextStyles.medium,
        ),
      ),
      
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // -----------------------------------------------------------------------
      // INPUTS & SELECTION CONTROLS
      // -----------------------------------------------------------------------
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
        hintStyle: TextStyles.regular.copyWith(color: textTertiary),
        labelStyle: TextStyles.medium.copyWith(color: textSecondary),
        border: _border(border),
        enabledBorder: _border(border),
        focusedBorder: _border(primary, width: 1.5),
        errorBorder: _border(error),
      ),

      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return null; // Uses default (transparent/grey)
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: textTertiary, width: 1.5),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return textTertiary;
        }),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return border;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // -----------------------------------------------------------------------
      // SURFACES & DIALOGS
      // -----------------------------------------------------------------------
      
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0, // Flat style by default, commonly preferred now
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: TextStyles.bold.copyWith(fontSize: 20),
        contentTextStyle: TextStyles.regular.copyWith(color: textSecondary),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        elevation: 16,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: primary,
        contentTextStyle: TextStyles.medium.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),

      // -----------------------------------------------------------------------
      // NAVIGATION
      // -----------------------------------------------------------------------
      
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 0,
        height: 64,
        indicatorColor: primary.withAlpha(25), // ~10% opacity
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
           if (states.contains(WidgetState.selected)) {
             return TextStyles.medium.copyWith(fontSize: 12, color: primary);
           }
           return TextStyles.medium.copyWith(fontSize: 12, color: textSecondary);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primary);
          }
          return const IconThemeData(color: textSecondary);
        }),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: textSecondary,
        indicatorColor: primary,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: TextStyles.semiBold,
        unselectedLabelStyle: TextStyles.medium,
        dividerColor: Colors.transparent, // Remove line below tabs
      ),
    );
  }

  // Helper for borders to keep code clean
  static OutlineInputBorder _border(Color color, {double width = 1.0}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}