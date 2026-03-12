import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart'; // ИСПРАВЛЕН ИМПОРТ

class CurrencyConversionService {
  /// Конвертирует сумму из одной валюты в другую по актуальному курсу из сети
  Future<double?> convert({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    if (fromCurrency == toCurrency) return amount;

    try {
      final url = Uri.parse('https://open.er-api.com/v6/latest/$fromCurrency');

      // ИСПРАВЛЕНИЕ БАГА: ДОБАВЛЕН ТАЙМАУТ ДЛЯ ЗАЩИТЫ ОТ ЗАВИСАНИЙ
      final request = await HttpClient().getUrl(url).timeout(const Duration(seconds: 10));
      final response = await request.close().timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final data = json.decode(responseBody);

        if (data['result'] == 'success') {
          final rates = data['rates'] as Map<String, dynamic>;
          final rate = rates[toCurrency];

          if (rate != null) {
            return amount * (rate as num).toDouble();
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Currency conversion error: $e');
      }
    }

    return null;
  }
}