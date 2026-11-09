import 'package:flutter/material.dart';

class AppTheme {
  static const _semilla = Color(0xFFFF8A1F);
  static ThemeData get claro =>
      ThemeData(useMaterial3: true, brightness: Brightness.light, colorSchemeSeed: _semilla);
  static ThemeData get oscuro =>
      ThemeData(useMaterial3: true, brightness: Brightness.dark, colorSchemeSeed: _semilla);
}
