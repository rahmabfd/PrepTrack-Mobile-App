import 'package:flutter/material.dart';

class ThemeNotifier with ChangeNotifier {
  bool _isDarkMode = false;
  Locale _currentLocale = const Locale('fr');
  final List<String> _supportedLanguages = ['en', 'fr', 'es', 'ar'];

  bool get isDarkMode => _isDarkMode;
  Locale get currentLocale => _currentLocale;
  ThemeMode get currentTheme => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme(bool isOn) {
    _isDarkMode = isOn;
    notifyListeners();
  }

  void setLocale(String languageCode) {
    if (_supportedLanguages.contains(languageCode)) {
      _currentLocale = Locale(languageCode);
      notifyListeners();
    }
  }
}