import 'package:flutter/foundation.dart';

import '../../data/models/expense_category.dart';
import '../../data/models/parsed_expense_input_model.dart';

class SmartExpenseParser {
  static final Map<ExpenseCategory, List<String>> _keywords = {
    ExpenseCategory.food: [
      'кофе',
      'coffee',
      'cafe',
      'кафе',
      'бургер',
      'burger',
      'еда',
      'food',
      'pizza',
      'пицца',
      'обед',
      'ужин',
      'завтрак',
    ],
    ExpenseCategory.transport: [
      'taxi',
      'такси',
      'uber',
      'yandex',
      'bus',
      'metro',
      'маршрутка',
      'бензин',
      'fuel',
    ],
    ExpenseCategory.subscriptions: [
      'netflix',
      'spotify',
      'icloud',
      'youtube premium',
      'chatgpt',
      'vpn',
      'subscription',
      'подписка',
    ],
    ExpenseCategory.entertainment: [
      'cinema',
      'movie',
      'кино',
      'game',
      'steam',
      'psn',
    ],
    ExpenseCategory.shopping: [
      'одежда',
      'clothes',
      'shop',
      'shopping',
      'wb',
      'ozon',
    ],
    ExpenseCategory.health: [
      'аптека',
      'pharmacy',
      'doctor',
      'врач',
      'medicine',
    ],
    ExpenseCategory.bills: [
      'internet',
      'wifi',
      'свет',
      'коммунал',
      'electricity',
      'water',
    ],
  };

  ParsedExpenseInputModel parse(String input) {
    final text = input.trim().toLowerCase();

    final amountMatch = RegExp(r'(\d+[.,]?\d{0,2})').firstMatch(text);
    final amount = amountMatch != null
        ? double.tryParse(amountMatch.group(1)!.replaceAll(',', '.'))
        : null;

    final currency = _detectCurrency(text);
    final category = _detectCategory(text);
    final merchant = _detectMerchant(text);

    return ParsedExpenseInputModel(
      amount: amount,
      currency: currency,
      category: category,
      merchant: merchant,
      rawText: input,
    );
  }

  String _detectCurrency(String text) {
    if (text.contains('\$') || text.contains('usd')) return 'USD';
    if (text.contains('сом') || text.contains('kgs')) return 'KGS';
    if (text.contains('₽') || text.contains('rub')) return 'RUB';
    return 'KGS';
  }

  ExpenseCategory? _detectCategory(String text) {
    for (final entry in _keywords.entries) {
      for (final keyword in entry.value) {
        if (text.contains(keyword)) {
          return entry.key;
        }
      }
    }
    return ExpenseCategory.other;
  }

  String? _detectMerchant(String text) {
    final words = text.split(' ');
    final cleaned = words.where(
          (w) => double.tryParse(w.replaceAll(',', '.')) == null,
    );
    if (cleaned.isEmpty) return null;
    return cleaned.join(' ').trim();
  }

  @visibleForTesting
  ExpenseCategory? detectCategoryForTest(String text) => _detectCategory(text);
}