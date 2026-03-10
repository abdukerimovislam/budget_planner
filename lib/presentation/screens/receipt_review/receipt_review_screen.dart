import 'package:flutter/material.dart';

import '../../../core/utils/responsive.dart';
import '../../../data/models/expense_category.dart';
import '../../../data/models/receipt_candidate_amount_view.dart';
import '../../../data/models/receipt_parsed_data_model.dart';
import '../../../data/models/receipt_review_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/adaptive_page_padding.dart';

class ReceiptReviewScreen extends StatefulWidget {
  final ReceiptParsedDataModel parsedData;

  const ReceiptReviewScreen({
    super.key,
    required this.parsedData,
  });

  @override
  State<ReceiptReviewScreen> createState() => _ReceiptReviewScreenState();
}

class _ReceiptReviewScreenState extends State<ReceiptReviewScreen> {
  late final TextEditingController _amountController;
  late final TextEditingController _currencyController;
  late final TextEditingController _merchantController;

  late ExpenseCategory _selectedCategory;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();

    _amountController = TextEditingController(
      text: widget.parsedData.amount?.toString() ?? '',
    );
    _currencyController = TextEditingController(
      text: widget.parsedData.currency ?? 'KGS',
    );
    _merchantController = TextEditingController(
      text: widget.parsedData.merchant ?? '',
    );

    _selectedCategory = widget.parsedData.category ?? ExpenseCategory.other;
    _selectedDate = widget.parsedData.receiptDate;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _currencyController.dispose();
    _merchantController.dispose();
    super.dispose();
  }

  String _categoryLabel(BuildContext context, ExpenseCategory category) {
    final l10n = AppLocalizations.of(context);

    switch (category) {
      case ExpenseCategory.food:
        return l10n.categoryFood;
      case ExpenseCategory.transport:
        return l10n.categoryTransport;
      case ExpenseCategory.subscriptions:
        return l10n.categorySubscriptions;
      case ExpenseCategory.entertainment:
        return l10n.categoryEntertainment;
      case ExpenseCategory.shopping:
        return l10n.categoryShopping;
      case ExpenseCategory.health:
        return l10n.categoryHealth;
      case ExpenseCategory.bills:
        return l10n.categoryBills;
      case ExpenseCategory.education:
        return l10n.categoryEducation;
      case ExpenseCategory.gifts:
        return l10n.categoryGifts;
      case ExpenseCategory.travel:
        return l10n.categoryTravel;
      case ExpenseCategory.other:
        return l10n.categoryOther;
    }
  }

  String _formatConfidence(BuildContext context, double value) {
    final l10n = AppLocalizations.of(context);
    return l10n.receiptConfidenceLabel((value * 100).toStringAsFixed(0));
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _applyCandidate(ReceiptCandidateAmountModel candidate) {
    setState(() {
      _amountController.text = candidate.value.toString();
    });
  }

  void _confirm() {
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));

    final review = ReceiptReviewModel(
      amount: amount,
      currency: _currencyController.text.trim().isEmpty
          ? 'KGS'
          : _currencyController.text.trim(),
      merchant: _merchantController.text.trim(),
      category: _selectedCategory,
      receiptDate: _selectedDate,
      rawText: widget.parsedData.rawText,
    );

    Navigator.of(context).pop(review);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final parsed = widget.parsedData;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.receiptReviewTitle),
      ),
      body: AdaptivePagePadding(
        addBottomSafeArea: true,
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(Responsive.cardPadding(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.receiptFieldConfidenceTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.receiptAmountConfidence(
                        _formatConfidence(context, parsed.fieldConfidence.amount),
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.receiptMerchantConfidence(
                        _formatConfidence(context, parsed.fieldConfidence.merchant),
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.receiptDateConfidence(
                        _formatConfidence(context, parsed.fieldConfidence.date),
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            if (parsed.amountCandidates.isNotEmpty) ...[
              SizedBox(height: Responsive.sectionGap(context)),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(Responsive.cardPadding(context)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.receiptCandidateAmountsTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      ...parsed.amountCandidates.map(
                            (candidate) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: OutlinedButton(
                            onPressed: () => _applyCandidate(candidate),
                            child: Text(
                              '${candidate.value} • ${candidate.sourceLine}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            SizedBox(height: Responsive.sectionGap(context)),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.previewAmount,
              ),
            ),
            SizedBox(height: Responsive.itemGap(context)),
            TextField(
              controller: _currencyController,
              decoration: InputDecoration(
                labelText: l10n.previewCurrency,
              ),
            ),
            SizedBox(height: Responsive.itemGap(context)),
            TextField(
              controller: _merchantController,
              decoration: InputDecoration(
                labelText: l10n.previewMerchant,
              ),
            ),
            SizedBox(height: Responsive.itemGap(context)),
            DropdownButtonFormField<ExpenseCategory>(
              value: _selectedCategory,
              items: ExpenseCategory.values
                  .map(
                    (category) => DropdownMenuItem(
                  value: category,
                  child: Text(_categoryLabel(context, category)),
                ),
              )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedCategory = value;
                });
              },
              decoration: InputDecoration(
                labelText: l10n.previewCategory,
              ),
            ),
            SizedBox(height: Responsive.itemGap(context)),
            OutlinedButton(
              onPressed: () => _pickDate(context),
              child: Text(
                _selectedDate == null
                    ? l10n.receiptPickDateButton
                    : l10n.receiptPickedDateButton(
                  '${_selectedDate!.day.toString().padLeft(2, '0')}.'
                      '${_selectedDate!.month.toString().padLeft(2, '0')}.'
                      '${_selectedDate!.year}',
                ),
              ),
            ),
            SizedBox(height: Responsive.sectionGap(context)),
            FilledButton(
              onPressed: _confirm,
              child: Text(l10n.receiptConfirmParsedButton),
            ),
          ],
        ),
      ),
    );
  }
}