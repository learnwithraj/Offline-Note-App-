// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ThemeProvider with ChangeNotifier {
//   bool _isDarkMode = false;

//   bool get isDarkMode => _isDarkMode;

//   ThemeProvider() {
//     _loadTheme();
//   }

//   Future<void> _loadTheme() async {
//     final prefs = await SharedPreferences.getInstance();
//     _isDarkMode = prefs.getBool('isDarkMode') ?? false;
//     notifyListeners();
//   }

//   Future<void> toggleTheme() async {
//     _isDarkMode = !_isDarkMode;
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('isDarkMode', _isDarkMode);
//     notifyListeners();
//   }
// }

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool _isManualToggle = false; // To track if the theme is manually toggled

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _isManualToggle = prefs.getBool('isManualToggle') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    _isManualToggle = true; // Mark as manual toggle
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setBool('isManualToggle', _isManualToggle);
    notifyListeners();
  }

  Future<void> setSystemTheme(Brightness brightness) async {
    if (!_isManualToggle) {
      // Only apply system theme if manual toggle hasn't been used
      _isDarkMode = brightness == Brightness.dark;
      notifyListeners();
    }
  }
}
