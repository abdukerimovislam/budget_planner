import 'package:flutter/material.dart';

import '../../../core/utils/category_extension.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/expense_category.dart';
import '../../../data/models/receipt_parsed_data_model.dart';
import '../../../data/models/receipt_review_model.dart';
import '../../../l10n/app_localizations.dart';

class ReceiptReviewScreen extends StatefulWidget {
  final ReceiptParsedDataModel parsedData;

  const ReceiptReviewScreen({super.key, required this.parsedData});

  @override
  State<ReceiptReviewScreen> createState() => _ReceiptReviewScreenState();
}

class _ReceiptReviewScreenState extends State<ReceiptReviewScreen> {
  late final TextEditingController _amountController;
  late final TextEditingController _merchantController;
  late ExpenseCategory _category;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.parsedData.amount?.toString() ?? '',
    );
    _merchantController = TextEditingController(
      text: widget.parsedData.merchant ?? '',
    );
    _category = widget.parsedData.category ?? ExpenseCategory.other;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    super.dispose();
  }

  void _save() {
    final amount = double.tryParse(
      _amountController.text.trim().replaceAll(',', '.'),
    );

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).validationEnterValidAmount),
        ),
      );
      return;
    }

    final review = ReceiptReviewModel(
      amount: amount,
      currency: widget.parsedData.currency ?? 'KGS',
      category: _category,
      merchant: _merchantController.text.trim(),
      rawText: widget.parsedData.rawText,
      receiptDate: DateTime.now(), // <-- ИСПРАВЛЕНИЕ: ДОБАВЛЕНА ДАТА ЧЕКА
    );

    Navigator.of(context).pop(review);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final availableCategories = ExpenseCategory.values.where((c) => c != ExpenseCategory.custom).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.receiptReviewTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(Responsive.cardPadding(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.receiptReviewSubtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: l10n.previewAmount,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _merchantController,
                decoration: InputDecoration(
                  labelText: l10n.previewMerchant,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ExpenseCategory>(
                value: _category,
                items: availableCategories
                    .map(
                      (c) => DropdownMenuItem(
                    value: c,
                    child: Text(c.localizedName(context)),
                  ),
                )
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _category = val;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: l10n.previewCategory,
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: _save,
                child: Text(l10n.saveButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}