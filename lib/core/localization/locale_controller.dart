import 'package:flutter/material.dart';

import '../../data/datasources/local/local_storage_service.dart';

class LocaleController extends ChangeNotifier {
  Locale? _locale;
  bool _isInitialized = false;

  Locale? get locale => _locale;
  bool get isInitialized => _isInitialized;

  /// загрузка языка из local storage
  Future<void> load() async {
    final code = LocalStorageService.instance.getLocaleCode();

    if (code != null && code.isNotEmpty) {
      _locale = Locale(code);
    }

    _isInitialized = true;
    notifyListeners();
  }

  /// установка языка
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;

    await LocalStorageService.instance.setLocaleCode(locale.languageCode);

    notifyListeners();
  }

  /// сброс языка (использовать системный)
  Future<void> clearLocale() async {
    _locale = null;

    await LocalStorageService.instance.setLocaleCode(null);

    notifyListeners();
  }
}