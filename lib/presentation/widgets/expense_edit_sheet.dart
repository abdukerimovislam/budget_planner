import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/utils/category_extension.dart';
import '../../data/models/expense_category.dart';
import '../../data/models/expense_model.dart';
import '../../domain/services/curency_conversion_service.dart';
import '../../domain/services/premium_feature.dart';
import '../../l10n/app_localizations.dart';
import '../providers/home_provider.dart';
import '../screens/premium/premium_screen.dart';

class ExpenseEditResult {
  final double amount;
  final String merchant;
  final String note;
  final ExpenseCategory category;
  final DateTime date;
  final bool isIncome;
  final String currency;

  const ExpenseEditResult({
    required this.amount,
    required this.merchant,
    required this.note,
    required this.category,
    required this.date,
    required this.isIncome,
    required this.currency,
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
  late bool _isIncome;
  late String _selectedCurrency;
  late String _userCurrency; // Базовая валюта

  final CurrencyConversionService _conversionService = CurrencyConversionService();
  bool _isConverting = false;

  final List<String> _availableCurrencies = ['USD', 'EUR', 'GBP', 'RUB', 'KZT', 'KGS', 'UZS', 'UAH', 'BYN'];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
        text: widget.expense.amount.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')
    );
    _merchantController = TextEditingController(text: widget.expense.merchant);
    _noteController = TextEditingController(text: widget.expense.note ?? '');
    _category = widget.expense.category;
    _date = widget.expense.date;
    _isIncome = widget.expense.isIncome;
    _selectedCurrency = widget.expense.currency;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userCurrency = context.read<HomeProvider>().activeCurrency;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    _noteController.dispose();
    super.dispose();
  }

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

  void _handleCurrencyTap() {
    final provider = context.read<HomeProvider>();
    if (!provider.canUseFeature(PremiumFeature.multiCurrency)) {
      Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const PremiumScreen()));
      return;
    }

    HapticFeedback.lightImpact();
    int initialIndex = _availableCurrencies.indexOf(_selectedCurrency);
    if (initialIndex == -1) initialIndex = 0;

    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          top: false,
          child: CupertinoPicker(
            itemExtent: 40,
            scrollController: FixedExtentScrollController(initialItem: initialIndex),
            onSelectedItemChanged: (index) {
              HapticFeedback.selectionClick();
              setState(() {
                _selectedCurrency = _availableCurrencies[index];
              });
            },
            children: _availableCurrencies.map((c) => Center(
              child: Text(c, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600)),
            )).toList(),
          ),
        ),
      ),
    );
  }

  // НОВОЕ: ЛОГИКА АВТОКОНВЕРТАЦИИ В РЕДАКТИРОВАНИИ
  // НОВОЕ: ЛОГИКА АВТОКОНВЕРТАЦИИ В РЕДАКТИРОВАНИИ
  Future<void> _handleAutoConvert() async {
    final provider = context.read<HomeProvider>();
    if (!provider.canUseFeature(PremiumFeature.multiCurrency)) {
      Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const PremiumScreen()));
      return;
    }

    final amount = double.tryParse(_amountController.text.trim().replaceAll(',', '.'));
    if (amount == null || amount <= 0) return;

    setState(() {
      _isConverting = true;
    });

    final convertedAmount = await _conversionService.convert(
      amount: amount,
      fromCurrency: _selectedCurrency,
      toCurrency: _userCurrency,
    );

    if (!mounted) return;

    setState(() {
      _isConverting = false;
    });

    if (convertedAmount != null) {
      HapticFeedback.mediumImpact(); // ИСПРАВЛЕНО
      setState(() {
        _selectedCurrency = _userCurrency;
        _amountController.text = convertedAmount.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '');
      });
    } else {
      HapticFeedback.heavyImpact(); // ИСПРАВЛЕНО
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t('Failed to fetch exchange rates', 'Не удалось получить курс валют. Проверьте интернет.'))),
      );
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
        isIncome: _isIncome,
        currency: _selectedCurrency,
      ),
    );
  }

  String _categoryLabel(ExpenseCategory category) {
    final l10n = AppLocalizations.of(context);

    if (_isIncome) {
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
    final provider = context.watch<HomeProvider>();

    List<ExpenseCategory> availableCategories = _isIncome
        ? [ExpenseCategory.other, ExpenseCategory.gifts]
        : ExpenseCategory.values.where((c) => c != ExpenseCategory.custom).toList();

    if (_category == ExpenseCategory.custom && !availableCategories.contains(ExpenseCategory.custom)) {
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
            Center(
              child: Container(
                width: 48, height: 4, decoration: BoxDecoration(color: theme.colorScheme.onSurface.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              _isIncome ? _t('Edit Income', 'Редактировать доход') : l10n.expenseEditTitle,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: theme.colorScheme.surfaceVariant.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (_isIncome) {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _isIncome = false;
                            if (_category == ExpenseCategory.other || _category == ExpenseCategory.gifts) _category = ExpenseCategory.food;
                          });
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(color: !_isIncome ? theme.colorScheme.surface : Colors.transparent, borderRadius: BorderRadius.circular(10), boxShadow: !_isIncome ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))] : []),
                        child: Center(child: Text(_t('Expense', 'Расход'), style: TextStyle(fontWeight: !_isIncome ? FontWeight.w700 : FontWeight.w500, color: !_isIncome ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withOpacity(0.5)))),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (!_isIncome) {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _isIncome = true;
                            if (_category != ExpenseCategory.custom) _category = ExpenseCategory.other;
                          });
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(color: _isIncome ? CupertinoColors.systemGreen : Colors.transparent, borderRadius: BorderRadius.circular(10), boxShadow: _isIncome ? [BoxShadow(color: CupertinoColors.systemGreen.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))] : []),
                        child: Center(child: Text(_t('Income', 'Доход'), style: TextStyle(fontWeight: _isIncome ? FontWeight.w700 : FontWeight.w500, color: _isIncome ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.5)))),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // СУММА И ВАЛЮТА
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildTextField(
                    controller: _amountController, label: l10n.previewAmount, icon: CupertinoIcons.money_dollar,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true), color: _isIncome ? CupertinoColors.systemGreen : theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: _handleCurrencyTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!provider.canUseFeature(PremiumFeature.multiCurrency)) ...[
                            const Icon(CupertinoIcons.lock_fill, size: 12, color: CupertinoColors.systemYellow),
                            const SizedBox(width: 4),
                          ],
                          Text(_selectedCurrency, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: theme.colorScheme.primary)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // КНОПКА КОНВЕРТАЦИИ
            if (_selectedCurrency != _userCurrency) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _isConverting ? null : _handleAutoConvert,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: CupertinoColors.activeOrange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: CupertinoColors.activeOrange.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isConverting)
                        const CupertinoActivityIndicator(radius: 8)
                      else ...[
                        if (!provider.canUseFeature(PremiumFeature.multiCurrency)) ...[
                          const Icon(CupertinoIcons.lock_fill, size: 12, color: CupertinoColors.activeOrange),
                          const SizedBox(width: 4),
                        ],
                        const Icon(CupertinoIcons.arrow_right_arrow_left, size: 14, color: CupertinoColors.activeOrange),
                      ],
                      const SizedBox(width: 8),
                      Text(
                        _t('Convert to $_userCurrency', 'В $_userCurrency'),
                        style: const TextStyle(fontWeight: FontWeight.w700, color: CupertinoColors.activeOrange),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),

            _buildTextField(controller: _merchantController, label: _isIncome ? _t('Source', 'Источник') : l10n.previewMerchant, icon: CupertinoIcons.building_2_fill),
            const SizedBox(height: 16),
            _buildTextField(controller: _noteController, label: l10n.expenseNoteLabel, icon: CupertinoIcons.text_alignleft),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(color: theme.colorScheme.surfaceVariant.withOpacity(0.3), borderRadius: BorderRadius.circular(16), border: Border.all(color: theme.colorScheme.surfaceVariant)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<ExpenseCategory>(
                  value: _category, isExpanded: true, icon: Icon(CupertinoIcons.chevron_down, color: theme.colorScheme.primary, size: 20),
                  items: availableCategories.map((category) => DropdownMenuItem(value: category, child: Row(children: [Icon(CupertinoIcons.tag_fill, size: 18, color: theme.colorScheme.primary), const SizedBox(width: 12), Text(_categoryLabel(category), style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface))]))).toList(),
                  onChanged: (value) { if (value != null) setState(() => _category = value); },
                ),
              ),
            ),
            const SizedBox(height: 16),

            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(color: theme.colorScheme.surfaceVariant.withOpacity(0.3), borderRadius: BorderRadius.circular(16), border: Border.all(color: theme.colorScheme.surfaceVariant)),
                child: Row(children: [
                  Icon(CupertinoIcons.calendar, color: theme.colorScheme.primary), const SizedBox(width: 12),
                  Text(l10n.expenseEditDateValue('${_date.day.toString().padLeft(2, '0')}.${_date.month.toString().padLeft(2, '0')}.${_date.year}'), style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface, fontSize: 16)),
                ]),
              ),
            ),
            const SizedBox(height: 32),

            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56), backgroundColor: _isIncome ? CupertinoColors.systemGreen : theme.colorScheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: Text(l10n.saveButton, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, TextInputType keyboardType = TextInputType.text, Color? color}) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;
    return Container(
      decoration: BoxDecoration(color: theme.colorScheme.surfaceVariant.withOpacity(0.3), borderRadius: BorderRadius.circular(16), border: Border.all(color: theme.colorScheme.surfaceVariant)),
      child: TextField(
        controller: controller, keyboardType: keyboardType, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
        decoration: InputDecoration(prefixIcon: Icon(icon, color: effectiveColor), labelText: label, labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
      ),
    );
  }
}