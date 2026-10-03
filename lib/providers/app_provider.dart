import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/localization_service.dart';

class AppProvider extends ChangeNotifier {
  bool _isDarkMode = true;
  String _language = 'en';
  String _farmerName = '';

  bool get isDarkMode => _isDarkMode;
  String get language => _language;
  String get farmerName => _farmerName;

  AppProvider() {
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('dark_mode') ?? true;
    _language = prefs.getString('app_language') ?? 'en';
    L.setLanguage(_language);
    _farmerName = prefs.getString('farmer_name') ?? '';
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', _isDarkMode);
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    L.setLanguage(lang);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', lang);
    notifyListeners();
  }

  Future<void> refreshFarmerName() async {
    final prefs = await SharedPreferences.getInstance();
    _farmerName = prefs.getString('farmer_name') ?? '';
    notifyListeners();
  }

  // ── Theme data ──────────────────────────────────────────────────────────────

  ThemeData get themeData {
    if (_isDarkMode) {
      return ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2DBD6E),
          surface: Color(0xFF161B22),
          onSurface: Colors.white,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      );
    } else {
      return ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF0F4F0),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF1A8A4A),
          surface: Colors.white,
          onSurface: Color(0xFF1A1A1A),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      );
    }
  }

  // ── Color helpers ───────────────────────────────────────────────────────────

  Color get bgColor =>
      _isDarkMode ? const Color(0xFF0D1117) : const Color(0xFFF0F4F0);
  Color get cardColor =>
      _isDarkMode ? const Color(0xFF161B22) : Colors.white;
  Color get textColor => _isDarkMode ? Colors.white : const Color(0xFF1A1A1A);
  Color get subTextColor =>
      _isDarkMode ? Colors.white54 : const Color(0xFF666666);
  Color get borderColor => _isDarkMode
      ? Colors.white.withOpacity(0.07)
      : Colors.black.withOpacity(0.08);
  Color get accentGreen => const Color(0xFF2DBD6E);
}