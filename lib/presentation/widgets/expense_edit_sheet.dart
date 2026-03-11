import 'package:flutter/material.dart';

import '../../core/utils/category_extension.dart';
import '../../data/models/expense_category.dart';
import '../../data/models/expense_model.dart';
import '../../l10n/app_localizations.dart';

// ВОТ ЗДЕСЬ ДОЛЖЕН БЫТЬ ЭТОТ КЛАСС:
class ExpenseEditResult {
  final double amount;
  final String merchant;
  final String note;
  final ExpenseCategory category;
  final DateTime date;

  const ExpenseEditResult({
    required this.amount,
    required this.merchant,
    required this.note,
    required this.category,
    required this.date,
  });
}

class ExpenseEditSheet extends StatefulWidget {
  final ExpenseModel expense;

  const ExpenseEditSheet({
    super.key,
    required this.expense,
  });

  @override
  State<ExpenseEditSheet> createState() => _ExpenseEditSheetState();
}

class _ExpenseEditSheetState extends State<ExpenseEditSheet> {
  late final TextEditingController _amountController;
  late final TextEditingController _merchantController;
  late final TextEditingController _noteController;

  late ExpenseCategory _category;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.expense.amount.toString());
    _merchantController = TextEditingController(text: widget.expense.merchant);
    _noteController = TextEditingController(text: widget.expense.note ?? '');
    _category = widget.expense.category;
    _date = widget.expense.date;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _date = picked;
      });
    }
  }

  void _save() {
    final amount = double.tryParse(_amountController.text.trim().replaceAll(',', '.'));
    if (amount == null || amount <= 0) return;

    Navigator.of(context).pop(
      ExpenseEditResult(
        amount: amount,
        merchant: _merchantController.text.trim(),
        note: _noteController.text.trim(),
        category: _category,
        date: _date,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final availableCategories = ExpenseCategory.values.where((c) => c != ExpenseCategory.custom).toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.expenseEditTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: l10n.previewAmount,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _merchantController,
                decoration: InputDecoration(
                  labelText: l10n.previewMerchant,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: l10n.expenseNoteLabel,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ExpenseCategory>(
                value: _category == ExpenseCategory.custom ? ExpenseCategory.other : _category,
                items: availableCategories
                    .map(
                      (category) => DropdownMenuItem(
                    value: category,
                    child: Text(category.localizedName(context)),
                  ),
                )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _category = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: l10n.previewCategory,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _pickDate,
                child: Text(
                  l10n.expenseEditDateValue(
                    '${_date.day.toString().padLeft(2, '0')}.'
                        '${_date.month.toString().padLeft(2, '0')}.'
                        '${_date.year}',
                  ),
                ),
              ),
              const SizedBox(height: 16),
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