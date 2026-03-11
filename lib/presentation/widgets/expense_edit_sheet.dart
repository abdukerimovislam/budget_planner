import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../core/utils/category_extension.dart';
import '../../data/models/expense_category.dart';
import '../../data/models/expense_model.dart';
import '../../l10n/app_localizations.dart';

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
    // Очищаем лишние нули из суммы для красоты (например, 500.0 -> 500)
    _amountController = TextEditingController(
        text: widget.expense.amount.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')
    );
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

  // Хелпер для безопасного перевода
  String _t(String en, String ru) {
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    return isRu ? ru : en;
  }

  Future<void> _pickDate() async {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 280,
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          top: false,
          child: CupertinoDatePicker(
            initialDateTime: _date,
            mode: CupertinoDatePickerMode.dateAndTime,
            use24hFormat: true,
            maximumDate: DateTime.now().add(const Duration(days: 365)),
            onDateTimeChanged: (val) => setState(() => _date = val),
          ),
        ),
      ),
    );
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

  // УМНЫЕ КАТЕГОРИИ: меняют названия в зависимости от Расход/Доход
  String _categoryLabel(ExpenseCategory category) {
    final l10n = AppLocalizations.of(context);

    if (widget.expense.isIncome) {
      switch (category) {
        case ExpenseCategory.other: return '💼 ${_t('Salary / Income', 'Зарплата / Доход')}';
        case ExpenseCategory.gifts: return '🎁 ${_t('Gift / Transfer', 'Подарок / Перевод')}';
        case ExpenseCategory.custom: return '✨ ${_t('Custom Category', 'Своя категория')}';
        default: return '📦 ${_t('Other', 'Другое')}';
      }
    }

    switch (category) {
      case ExpenseCategory.food: return '🍔 ${l10n.categoryFood}';
      case ExpenseCategory.transport: return '🚕 ${l10n.categoryTransport}';
      case ExpenseCategory.subscriptions: return '💳 ${l10n.categorySubscriptions}';
      case ExpenseCategory.entertainment: return '🍿 ${l10n.categoryEntertainment}';
      case ExpenseCategory.shopping: return '🛍️ ${l10n.categoryShopping}';
      case ExpenseCategory.health: return '💊 ${l10n.categoryHealth}';
      case ExpenseCategory.bills: return '📄 ${l10n.categoryBills}';
      case ExpenseCategory.education: return '📚 ${l10n.categoryEducation}';
      case ExpenseCategory.gifts: return '🎁 ${l10n.categoryGifts}';
      case ExpenseCategory.travel: return '✈️ ${l10n.categoryTravel}';
      case ExpenseCategory.custom: return '✨ ${_t('Custom Category', 'Своя категория')}';
      case ExpenseCategory.other: return '📦 ${l10n.categoryOther}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // ИСПРАВЛЕНИЕ ЛОВУШКИ: Динамический список категорий + сохранение Custom
    List<ExpenseCategory> availableCategories = widget.expense.isIncome
        ? [ExpenseCategory.other, ExpenseCategory.gifts]
        : ExpenseCategory.values.where((c) => c != ExpenseCategory.custom).toList();

    // Защита от краша Dropdown: если транзакция была "Своей категорией", мы обязаны добавить её в список
    if (widget.expense.category == ExpenseCategory.custom && !availableCategories.contains(ExpenseCategory.custom)) {
      availableCategories.insert(0, ExpenseCategory.custom);
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ПОЛЗУНОК
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ЗАГОЛОВОК
            Text(
              widget.expense.isIncome ? _t('Edit Income', 'Редактировать доход') : l10n.expenseEditTitle,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // СУММА
            _buildTextField(
              controller: _amountController,
              label: l10n.previewAmount,
              icon: CupertinoIcons.money_dollar,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              color: widget.expense.isIncome ? CupertinoColors.systemGreen : theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),

            // ИСТОЧНИК / ПРОДАВЕЦ
            _buildTextField(
              controller: _merchantController,
              label: widget.expense.isIncome ? _t('Source', 'Источник') : l10n.previewMerchant,
              icon: CupertinoIcons.building_2_fill,
            ),
            const SizedBox(height: 16),

            // ЗАМЕТКА
            _buildTextField(
              controller: _noteController,
              label: l10n.expenseNoteLabel,
              icon: CupertinoIcons.text_alignleft,
            ),
            const SizedBox(height: 16),

            // ВЫПАДАЮЩИЙ СПИСОК КАТЕГОРИЙ
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.surfaceVariant),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<ExpenseCategory>(
                  value: _category,
                  isExpanded: true,
                  icon: Icon(CupertinoIcons.chevron_down, color: theme.colorScheme.primary, size: 20),
                  items: availableCategories.map((category) => DropdownMenuItem(
                    value: category,
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.tag_fill, size: 18, color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        Text(_categoryLabel(category), style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                      ],
                    ),
                  )).toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _category = value);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ДАТА И ВРЕМЯ
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.surfaceVariant),
                ),
                child: Row(
                  children: [
                    Icon(CupertinoIcons.calendar, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      l10n.expenseEditDateValue(
                        '${_date.day.toString().padLeft(2, '0')}.'
                            '${_date.month.toString().padLeft(2, '0')}.'
                            '${_date.year}',
                      ),
                      style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // КНОПКА СОХРАНИТЬ
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                backgroundColor: widget.expense.isIncome ? CupertinoColors.systemGreen : theme.colorScheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                l10n.saveButton,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.surfaceVariant),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: effectiveColor),
          labelText: label,
          labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}