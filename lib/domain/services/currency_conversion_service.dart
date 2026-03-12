import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';

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
      final request = await HttpClient().getUrl(url);
      final response = await request.close();

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
      // Тихо ловим ошибку (например, если нет интернета)
      debugPrint('Currency conversion error: $e');
    }

    return null;
  }
}