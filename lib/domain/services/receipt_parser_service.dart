import '../../data/models/expense_category.dart';
import '../../data/models/receipt_candidate_amount_view.dart';
import '../../data/models/receipt_field_confidence_model.dart';
import '../../data/models/receipt_parsed_data_model.dart';
import 'smart_expense_parser.dart';

class ReceiptParserService {
  final SmartExpenseParser _smartExpenseParser = SmartExpenseParser();

  // РАСШИРЕННЫЙ СЛОВАРЬ КЛЮЧЕВЫХ СЛОВ
  static final List<String> _totalKeywords = [
    'итого', 'итог', 'сумма', 'к оплате', 'оплачено', 'оплата', 'всего', 'итоговая сумма',
    'total', 'amount', 'amount due', 'grand total', 'balance due', 'paid',
    'жыйынтыгы', 'бардыгы', 'сомасы', 'барлығы',
    'suma', 'total a pagar', 'importe', 'total a cobrar',
    'betrag', 'summe', 'gesamt', 'gesamtsumme',
    'montant', 'total à payer', 'solde',
    'totale', 'importo',
    'toplam', 'tutar',
    'kwota', 'razem',
  ];

  static final List<String> _discountKeywords = [
    'скидка', 'дисконт', 'discount', 'rabatt', 'remise', 'descuento', 'indirim', 'жеңилдик'
  ];

  static final List<String> _taxKeywords = [
    'ндс', 'налог', 'tax', 'vat', 'mwst', 'iva', 'tva', 'kdv'
  ];

  static final Map<String, String> _currencyMap = {
    'сом': 'KGS', 'kgs': 'KGS', 'с': 'KGS',
    'руб': 'RUB', '₽': 'RUB',
    'тенге': 'KZT', '₸': 'KZT',
    'сум': 'UZS', 'uzs': 'UZS',
    'грн': 'UAH', '₴': 'UAH',
    'byn': 'BYN', 'бел. руб': 'BYN',
    'usd': 'USD', '\$': 'USD',
    'eur': 'EUR', '€': 'EUR',
    'gbp': 'GBP', '£': 'GBP',
    'jpy': 'JPY', '¥': 'JPY',
    'cny': 'CNY', 'rmb': 'CNY',
    'aed': 'AED', 'try': 'TRY', '₺': 'TRY',
  };

  static final List<String> _knownMerchants = [
    'globus', 'spar', 'frunze', 'narodny', 'magnit', 'pyaterochka', 'fixprice',
    'kfc', 'burger king', 'mcdonalds', 'starbucks', 'yandex', 'yandex.go', 'uber',
    'walmart', 'target', 'tesco', 'carrefour', 'aldi', 'lidl', 'auchan', 'ikea',
    'zara', 'h&m', 'amazon', 'apple'
  ];

  static final List<RegExp> _datePatterns = [
    RegExp(r'\b(\d{1,2})[./-](\d{1,2})[./-](\d{4})\b'),
    RegExp(r'\b(\d{4})[./-](\d{1,2})[./-](\d{1,2})\b'),
    RegExp(r'\b(\d{1,2})[./-](\d{1,2})[./-](\d{2})\b'),
  ];

  ReceiptParsedDataModel parse(String rawText) {
    final cleanedText = _preClean(rawText);

    final lines = cleanedText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    // 1. Ищем кандидатов на сумму с расчетом уверенности (confidence)
    final amountCandidates = _extractAmountCandidates(lines);
    final amount = amountCandidates.isNotEmpty ? amountCandidates.first.value : null;

    // 2. Извлекаем остальные данные
    final merchant = _findMerchant(lines, cleanedText);
    final currency = _detectCurrency(cleanedText);
    final receiptDate = _findDate(cleanedText);
    final category = _detectCategory(cleanedText, merchant);

    // 3. Формируем модель уверенности (Confidence)
    final fieldConfidence = ReceiptFieldConfidenceModel(
      amount: amountCandidates.isNotEmpty ? amountCandidates.first.confidence : 0.0,
      merchant: merchant != null && merchant.isNotEmpty ? 0.8 : 0.2,
      currency: currency != null && currency.isNotEmpty ? 0.9 : 0.2,
      date: receiptDate != null ? 0.85 : 0.1,
    );

    // Общая оценка распознавания (0.0 - 1.0)
    final overallConfidence = (
        fieldConfidence.amount * 0.45 +
            fieldConfidence.merchant * 0.20 +
            fieldConfidence.currency * 0.15 +
            fieldConfidence.date * 0.10 +
            (category != ExpenseCategory.other ? 0.10 : 0.0)
    ).clamp(0.0, 1.0);

    return ReceiptParsedDataModel(
      amount: amount,
      amountCandidates: amountCandidates,
      currency: currency,
      merchant: merchant,
      receiptDate: receiptDate, // Используем правильное имя поля из твоей модели
      category: category,
      confidence: overallConfidence,
      fieldConfidence: fieldConfidence,
      rawText: rawText,
    );
  }

  String _preClean(String text) {
    return text
        .replaceAll('\r', '\n')
        .replaceAll(RegExp(r'[|]'), ' ')
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .trim();
  }

  List<ReceiptCandidateAmountModel> _extractAmountCandidates(List<String> lines) {
    final candidates = <ReceiptCandidateAmountModel>[];
    final priceRegex = RegExp(r'\b(\d{1,3}(?:[.,\s]\d{3})*(?:[.,]\d{1,2})?)\b');

    for (final line in lines) {
      final lower = line.toLowerCase();

      // Пропускаем технический мусор
      if (lower.contains('инн') || lower.contains('inn') || lower.contains('kkm')) continue;
      if (lower.contains('карты') || lower.contains('card') || lower.contains('****')) continue;

      // Базовая уверенность
      double baseConfidence = 0.3;

      // Штрафы за налоги и скидки
      if (_taxKeywords.any((k) => lower.contains(k))) baseConfidence -= 0.5;
      if (_discountKeywords.any((k) => lower.contains(k))) baseConfidence -= 0.5;
      if (lower.contains('%')) baseConfidence -= 0.2;

      // Бонусы за слова "Итого"
      for (var keyword in _totalKeywords) {
        if (lower.contains(keyword)) {
          baseConfidence += 0.45;
          break;
        }
      }
      if (lower.contains('total') || lower.contains('итого')) baseConfidence += 0.15;

      // Извлекаем числа
      final matches = priceRegex.allMatches(line);
      for (final match in matches) {
        final raw = match.group(1);
        if (raw == null || _isGarbageNumber(raw)) continue;

        final value = _cleanAmount(raw);
        if (value != null && value > 0 && value < 9999999) {

          double finalConf = baseConfidence;
          // Большие суммы чаще бывают итогом
          if (value >= 50) finalConf += 0.05;
          if (value >= 500) finalConf += 0.05;

          candidates.add(
            ReceiptCandidateAmountModel(
              value: value,
              sourceLine: line,
              confidence: finalConf.clamp(0.0, 1.0),
            ),
          );
        }
      }
    }

    // Удаляем дубликаты (оставляем кандидата с самой высокой уверенностью)
    final deduped = <double, ReceiptCandidateAmountModel>{};
    for (final candidate in candidates) {
      final existing = deduped[candidate.value];
      if (existing == null || candidate.confidence > existing.confidence) {
        deduped[candidate.value] = candidate;
      }
    }

    final result = deduped.values.toList();
    // Сортируем: сначала самые уверенные, при равной уверенности — бóльшие суммы
    result.sort((a, b) {
      int confCompare = b.confidence.compareTo(a.confidence);
      if (confCompare != 0) return confCompare;
      return b.value.compareTo(a.value);
    });

    return result.take(5).toList(); // Отдаем топ 5 кандидатов
  }

  String? _findMerchant(List<String> lines, String fullText) {
    final lowerText = fullText.toLowerCase();

    for (var merchant in _knownMerchants) {
      if (lowerText.contains(merchant)) {
        return merchant[0].toUpperCase() + merchant.substring(1);
      }
    }

    for (var line in lines.take(6)) {
      final candidate = line.trim();
      final lower = candidate.toLowerCase();

      if (candidate.length < 3) continue;
      if (lower.contains('инн') || lower.contains('inn')) continue;
      if (lower.contains('ккм') || lower.contains('kkm')) continue;
      if (lower.contains('касса') || lower.contains('cash')) continue;
      if (lower.contains('чек') || lower.contains('receipt')) continue;
      if (lower.contains('ooo') || lower.contains('ооо') || lower.contains('ltd')) continue;
      if (RegExp(r'\d{4,}').hasMatch(candidate)) continue;

      return candidate.replaceAll(RegExp(r"[^a-zA-Zа-яА-Я0-9\s\&'\-]"), '').trim();
    }

    return null;
  }

  DateTime? _findDate(String text) {
    final now = DateTime.now();

    for (var pattern in _datePatterns) {
      final match = pattern.firstMatch(text);

      if (match != null) {
        try {
          int p1 = int.parse(match.group(1)!);
          int p2 = int.parse(match.group(2)!);
          int p3 = int.parse(match.group(3)!);

          int year = 0, month = 0, day = 0;

          if (p1 > 1000) {
            year = p1; month = p2; day = p3;
          } else {
            year = p3;
            if (year < 100) year += 2000;

            if (p1 > 12) {
              day = p1; month = p2;
            } else if (p2 > 12) {
              month = p1; day = p2;
            } else {
              day = p1; month = p2;
            }
          }

          if (year > 2000 && year <= now.year + 1 && month >= 1 && month <= 12 && day >= 1 && day <= 31) {
            return DateTime(year, month, day);
          }
        } catch (_) {}
      }
    }
    return null;
  }

  String? _detectCurrency(String text) {
    final lower = text.toLowerCase();
    for (var key in _currencyMap.keys) {
      if (RegExp(r'\b' + RegExp.escape(key) + r'\b').hasMatch(lower) || lower.contains(key)) {
        return _currencyMap[key];
      }
    }
    return null;
  }

  ExpenseCategory? _detectCategory(String text, String? merchant) {
    // Если магазин известен, ИИ парсер определит категорию точнее
    if (_knownMerchants.any((m) => merchant?.toLowerCase().contains(m) ?? false)) {
      return ExpenseCategory.food;
    }

    // Используем SmartExpenseParser для определения категории по тексту чека
    final probe = merchant == null || merchant.isEmpty ? text : '$merchant $text';
    final parsed = _smartExpenseParser.parse(probe);
    return parsed.category ?? ExpenseCategory.other;
  }

  bool _isGarbageNumber(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');

    if (digits.length >= 10) return true;
    if (digits.length > 7) return true;
    if (digits.startsWith('202') && digits.length == 8) return true;

    return false;
  }

  double? _cleanAmount(String raw) {
    try {
      var cleaned = raw.replaceAll(RegExp(r'[\s\u00A0]'), '');

      if (cleaned.contains(',') && cleaned.contains('.')) {
        if (cleaned.indexOf(',') > cleaned.indexOf('.')) {
          cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
        } else {
          cleaned = cleaned.replaceAll(',', '');
        }
      }
      else if (cleaned.contains(',')) {
        cleaned = cleaned.replaceAll(',', '.');
      }

      if (cleaned.indexOf('.') != cleaned.lastIndexOf('.')) {
        final parts = cleaned.split('.');
        final decimals = parts.removeLast();
        cleaned = '${parts.join('')}.$decimals';
      }

      return double.parse(cleaned);
    } catch (_) {
      return null;
    }
  }
}