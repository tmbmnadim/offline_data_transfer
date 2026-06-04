import 'package:flutter/material.dart';

class TextStyles {
  TextStyles._();

  // 1. CHANGE THIS to your font name defined in pubspec.yaml
  //    or leave null to use the default system font (Roboto/San Francisco).
  static const String? fontFamily = null; 

  static TextStyle get _baseStyle => TextStyle(
    fontFamily: fontFamily,
    color: const Color(0xFF262621), // Default generic text color
  );

  static TextStyle get regular => _baseStyle.copyWith(
    fontWeight: FontWeight.w400,
    fontSize: 14,
  );

  static TextStyle get medium => _baseStyle.copyWith(
    fontWeight: FontWeight.w500,
    fontSize: 16,
  );

  static TextStyle get semiBold => _baseStyle.copyWith(
    fontWeight: FontWeight.w600,
    fontSize: 16,
  );

  static TextStyle get bold => _baseStyle.copyWith(
    fontWeight: FontWeight.w700,
    fontSize: 20,
  );

  static TextStyle get h1 => _baseStyle.copyWith(
    fontWeight: FontWeight.w800,
    fontSize: 32,
  );
}