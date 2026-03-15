import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/storage_keys.dart';

class CurrencyConversionService {
  /// Конвертирует сумму из одной валюты в другую.
  /// При наличии интернета скачивает свежий курс и сохраняет в память.
  /// В авиарежиме мгновенно достает последний сохраненный курс.
  Future<double?> convert({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    if (fromCurrency == toCurrency) return amount;

    final box = Hive.box<dynamic>(StorageKeys.appBox);
    final cacheKey = 'currency_cache_$fromCurrency';

    try {
      final url = Uri.parse('https://open.er-api.com/v6/latest/$fromCurrency');

      // ИСПРАВЛЕНИЕ: Таймаут уменьшен до 3 секунд. Если интернет слабый - не мучаем юзера, идем в кэш.
      final request = await HttpClient().getUrl(url).timeout(const Duration(seconds: 3));
      final response = await request.close().timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final data = json.decode(responseBody);

        if (data['result'] == 'success') {
          final rates = data['rates'] as Map<String, dynamic>;

          // СОХРАНЯЕМ В ОФФЛАЙН-КЭШ
          await box.put(cacheKey, json.encode({
            'timestamp': DateTime.now().toIso8601String(),
            'rates': rates,
          }));

          final rate = rates[toCurrency];
          if (rate != null) {
            return amount * (rate as num).toDouble();
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Network error, falling back to cache. Error: $e');
      }
    }

    // --- ОФФЛАЙН ФОЛБЭК (РЕЗЕРВНЫЙ ПУТЬ) ---
    try {
      final cachedData = box.get(cacheKey) as String?;
      if (cachedData != null) {
        final data = json.decode(cachedData) as Map<String, dynamic>;
        final rates = data['rates'] as Map<String, dynamic>;
        final rate = rates[toCurrency];

        if (rate != null) {
          if (kDebugMode) {
            debugPrint('Using cached rate from: ${data['timestamp']}');
          }
          return amount * (rate as num).toDouble();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Cache read error: $e');
      }
    }

    return null;
  }
}