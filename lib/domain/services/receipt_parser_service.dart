import 'package:budget_planner/domain/services/reciept_candidate_amount.dart';
import 'package:budget_planner/domain/services/reciept_field_confidence.dart';

import '../../data/models/expense_category.dart';
import 'receipt_parsed_data.dart';
import 'smart_expense_parser.dart';

class ReceiptParserService {
  final SmartExpenseParser _smartExpenseParser = SmartExpenseParser();

  ReceiptParsedData parse(String text) {
    final normalized = _normalize(text);

    final merchant = _extractMerchant(normalized);
    final currency = _detectCurrency(normalized);
    final amountCandidates = _extractAmountCandidates(normalized);
    final amount = amountCandidates.isNotEmpty ? amountCandidates.first.value : null;
    final receiptDate = _extractDate(normalized);
    final category = _detectCategory(normalized, merchant);

    final fieldConfidence = ReceiptFieldConfidence(
      amount: amountCandidates.isNotEmpty ? amountCandidates.first.confidence : 0.0,
      merchant: merchant != null && merchant.isNotEmpty ? 0.75 : 0.2,
      currency: currency != null && currency.isNotEmpty ? 0.85 : 0.2,
      date: receiptDate != null ? 0.7 : 0.1,
    );

    final overall = (
        fieldConfidence.amount * 0.45 +
            fieldConfidence.merchant * 0.20 +
            fieldConfidence.currency * 0.15 +
            fieldConfidence.date * 0.10 +
            (category != null ? 0.10 : 0.0)
    ).clamp(0.0, 1.0);

    return ReceiptParsedData(
      amount: amount,
      amountCandidates: amountCandidates,
      currency: currency,
      merchant: merchant,
      receiptDate: receiptDate,
      category: category,
      confidence: overall,
      fieldConfidence: fieldConfidence,
      rawText: normalized,
    );
  }

  String _normalize(String text) {
    return text
        .replaceAll('\r', '\n')
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .trim();
  }

  String? _extractMerchant(String text) {
    final lines = text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (lines.isEmpty) return null;

    for (final line in lines.take(6)) {
      final hasLetters = RegExp(r'[A-Za-zА-Яа-я]').hasMatch(line);
      final looksLikeDate = RegExp(r'\d{1,2}[./-]\d{1,2}[./-]\d{2,4}').hasMatch(line);
      final looksLikePhone = RegExp(r'(\+?\d[\d\s\-()]{7,})').hasMatch(line);
      final looksLikeServiceLine = RegExp(
        r'бин|инн|чек|касса|фиск|receipt|tax|кассир|смена|терминал',
        caseSensitive: false,
      ).hasMatch(line);

      if (hasLetters && !looksLikeDate && !looksLikePhone && !looksLikeServiceLine) {
        return line;
      }
    }

    return null;
  }

  String? _detectCurrency(String text) {
    final lower = text.toLowerCase();

    if (lower.contains('сом') || lower.contains('kgs')) return 'KGS';
    if (lower.contains('\$') || lower.contains('usd')) return 'USD';
    if (lower.contains('₽') || lower.contains('rub')) return 'RUB';
    if (lower.contains('€') || lower.contains('eur')) return 'EUR';

    return 'KGS';
  }

  DateTime? _extractDate(String text) {
    final patterns = [
      RegExp(r'(\d{1,2})[./-](\d{1,2})[./-](\d{4})'),
      RegExp(r'(\d{1,2})[./-](\d{1,2})[./-](\d{2})'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match == null) continue;

      final day = int.tryParse(match.group(1) ?? '');
      final month = int.tryParse(match.group(2) ?? '');
      var year = int.tryParse(match.group(3) ?? '');

      if (day == null || month == null || year == null) continue;

      if (year < 100) {
        year += 2000;
      }

      try {
        return DateTime(year, month, day);
      } catch (_) {
        // ignore
      }
    }

    return null;
  }

  ExpenseCategory? _detectCategory(String text, String? merchant) {
    final probe = merchant == null || merchant.isEmpty ? text : '$merchant $text';
    final parsed = _smartExpenseParser.parse(probe);
    return parsed.category ?? ExpenseCategory.other;
  }

  List<ReceiptCandidateAmount> _extractAmountCandidates(String text) {
    final lines = text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final candidates = <ReceiptCandidateAmount>[];
    final amountRegex = RegExp(r'(\d+[.,]\d{1,2}|\d{2,})');

    for (final line in lines) {
      final lower = line.toLowerCase();
      final priorityBoost = _linePriorityBoost(lower);

      for (final match in amountRegex.allMatches(line)) {
        final raw = match.group(1);
        if (raw == null) continue;

        final parsed = double.tryParse(raw.replaceAll(',', '.'));
        if (parsed == null || parsed <= 0) continue;

        if (_shouldIgnoreAmountLine(lower)) continue;

        var confidence = 0.25 + priorityBoost;

        if (parsed >= 50) confidence += 0.1;
        if (parsed >= 100) confidence += 0.05;

        candidates.add(
          ReceiptCandidateAmount(
            value: parsed,
            sourceLine: line,
            confidence: confidence.clamp(0.0, 1.0),
          ),
        );
      }
    }

    final deduped = <double, ReceiptCandidateAmount>{};
    for (final candidate in candidates) {
      final existing = deduped[candidate.value];
      if (existing == null || candidate.confidence > existing.confidence) {
        deduped[candidate.value] = candidate;
      }
    }

    final result = deduped.values.toList()
      ..sort((a, b) => b.confidence.compareTo(a.confidence));

    return result.take(5).toList();
  }

  double _linePriorityBoost(String lower) {
    if (RegExp(r'итог|итого|сумма|всего|total|amount due', caseSensitive: false)
        .hasMatch(lower)) {
      return 0.55;
    }

    if (RegExp(r'к оплате|оплата|pay|paid', caseSensitive: false).hasMatch(lower)) {
      return 0.35;
    }

    return 0.0;
  }

  bool _shouldIgnoreAmountLine(String lower) {
    return lower.contains('скидки') ||
        lower.contains('discount') ||
        lower.contains('сдача') ||
        lower.contains('change') ||
        lower.contains('бонус') ||
        lower.contains('cashback');
  }
}