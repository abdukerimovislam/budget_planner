import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/responsive.dart';
import '../../../data/models/expense_category.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/models/expense_source_type.dart';
import '../../../data/models/receipt_parsed_data_model.dart';
import '../../../data/models/receipt_review_model.dart';
import '../../../domain/services/currency_conversion_service.dart';
import '../../../domain/services/premium_feature.dart';
import '../../../domain/services/receipt_parser_service.dart';
import '../../../domain/services/receipt_scan_service.dart';
import '../../../domain/services/smart_expense_parser.dart';
import '../../../domain/services/voice_input_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/add_expense_source_selector.dart';
import '../../widgets/custom_category_sheet.dart';
import '../premium/premium_screen.dart';
import '../receipt_review/receipt_review_screen.dart';
import '../qr_scanner/qr_scanner_screen.dart';

// ПРОВАЙДЕРЫ
import '../../providers/settings_provider.dart';
import '../../providers/transactions_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  final ExpenseCategory? initialCategory;
  final String? initialCustomCategoryId;
  final bool initialIsIncome;

  const AddExpenseScreen({
    super.key,
    this.initialCategory,
    this.initialCustomCategoryId,
    this.initialIsIncome = false,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final VoiceInputService _voiceInputService = VoiceInputService();
  final ReceiptScanService _receiptScanService = ReceiptScanService();
  final ReceiptParserService _receiptParserService = ReceiptParserService();
  final SmartExpenseParser _parser = SmartExpenseParser();
  final CurrencyConversionService _conversionService = CurrencyConversionService();

  AddExpenseSourceMode _sourceMode = AddExpenseSourceMode.smartText;

  // Состояние ввода
  String _amountString = '0';
  String _noteText = '';
  DateTime _selectedDate = DateTime.now();
  ExpenseCategory? _selectedCategory;
  String? _selectedCustomCategoryId;

  late bool _isIncome;
  late String _userCurrency;
  late String _selectedCurrency;

  final List<String> _availableCurrencies = ['USD', 'EUR', 'GBP', 'RUB', 'KZT', 'KGS', 'UZS', 'UAH', 'BYN'];

  // Статусы UI
  bool _isVoiceLoading = false;
  bool _isVoiceListening = false;
  String? _selectedLocaleId;
  String _voicePreviewText = '';

  bool _isReceiptLoading = false;
  String _receiptPreviewText = '';
  ReceiptParsedDataModel? _receiptParsedData;

  bool _isConverting = false;
  bool _isAiParsing = false;

  @override
  void initState() {
    super.initState();
    _isIncome = widget.initialIsIncome;

    final settings = context.read<SettingsProvider>();
    _userCurrency = settings.activeCurrency;
    _selectedCurrency = _userCurrency;

    if (widget.initialCustomCategoryId != null) {
      _selectedCategory = ExpenseCategory.custom;
      _selectedCustomCategoryId = widget.initialCustomCategoryId;
    } else {
      _selectedCategory = widget.initialCategory;
      if (_isIncome && _selectedCategory == null) {
        _selectedCategory = ExpenseCategory.other;
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initVoice();
  }

  Future<void> _initVoice() async {
    final result = await _voiceInputService.initialize();
    if (!mounted) return;
    if (result.isAvailable) {
      final locales = await _voiceInputService.locales();
      if (!mounted) return;
      setState(() {
        _selectedLocaleId = _pickPreferredLocale(locales, context);
      });
    }
  }

  String? _pickPreferredLocale(List<LocaleName> locales, BuildContext context) {
    if (locales.isEmpty) return null;
    final currentLang = Localizations.localeOf(context).languageCode.toLowerCase();
    for (final locale in locales) {
      if (locale.localeId.toLowerCase().startsWith(currentLang)) return locale.localeId;
    }
    for (final locale in locales) {
      if (locale.localeId.toLowerCase().startsWith('en')) return locale.localeId;
    }
    return locales.first.localeId;
  }

  @override
  void dispose() {
    _voiceInputService.cancelListening();
    _receiptScanService.dispose();
    super.dispose();
  }

  // --- ОБРАБОТЧИК NUMPAD ---
  void _onNumpadTap(String value) {
    HapticFeedback.lightImpact();
    setState(() {
      if (value == 'C') {
        _amountString = '0';
      } else if (value == '<') {
        if (_amountString.length > 1) {
          _amountString = _amountString.substring(0, _amountString.length - 1);
        } else {
          _amountString = '0';
        }
      } else if (value == '.') {
        if (!_amountString.contains('.')) {
          _amountString += '.';
        }
      } else {
        if (_amountString == '0') {
          _amountString = value;
        } else {
          if (_amountString.contains('.')) {
            final parts = _amountString.split('.');
            if (parts[1].length < 2) _amountString += value;
          } else {
            if (_amountString.length < 9) _amountString += value;
          }
        }
      }
    });
  }

  double get _parsedAmount => double.tryParse(_amountString) ?? 0.0;
  bool get _canSave => _parsedAmount > 0 && _selectedCategory != null;

  String _t(String en, String ru) {
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    return isRu ? ru : en;
  }

  // --- ХЕЛПЕР ЗАПОЛНЕНИЯ ИЗ ИИ / СКАНЕРА ---
  void _applyParsedData(double? amount, ExpenseCategory? category, String? merchant, String? currency, String sourceText) {
    final hasPremium = context.read<SettingsProvider>().canUseFeature(PremiumFeature.multiCurrency);
    setState(() {
      if (amount != null) {
        _amountString = amount % 1 == 0 ? amount.toInt().toString() : amount.toString();
      }
      if (category != null) _selectedCategory = category;
      if (merchant != null && merchant.isNotEmpty) _noteText = merchant;
      if (currency != null && hasPremium) _selectedCurrency = currency;

      if (_sourceMode == AddExpenseSourceMode.voice) _voicePreviewText = sourceText;
      if (_sourceMode == AddExpenseSourceMode.receipt) _receiptPreviewText = sourceText;
    });
  }

  // --- ГОЛОС ---
  Future<void> _handleVoiceTap(BuildContext context) async {
    HapticFeedback.lightImpact();
    if (_isVoiceListening) {
      setState(() => _isVoiceLoading = true);
      final result = await _voiceInputService.stopListening();
      if (!mounted) return;
      setState(() { _isVoiceLoading = false; _isVoiceListening = false; });

      if (result.hasText) {
        setState(() { _voicePreviewText = result.recognizedText; _isAiParsing = true; });
        final aiParsed = await _parser.parseWithAI(result.recognizedText, _selectedCurrency);
        if (!mounted) return;
        setState(() => _isAiParsing = false);
        _applyParsedData(aiParsed.amount, aiParsed.category, aiParsed.merchant, aiParsed.currency, result.recognizedText);
      } else if (result.errorMessage != null) {
        _showSnack(context, result.errorMessage!);
      }
      return;
    }

    setState(() => _isVoiceLoading = true);
    final result = await _voiceInputService.startListening(localeId: _selectedLocaleId ?? '');
    if (!mounted) return;
    setState(() { _isVoiceLoading = false; _isVoiceListening = result.isAvailable; });
  }

  // --- ЧЕКИ И QR ---
  Future<void> _handleQrScannerTap(BuildContext context) async {
    HapticFeedback.lightImpact();
    final qrResult = await Navigator.of(context).push<String>(
        CupertinoPageRoute(builder: (_) => const QrScannerScreen())
    );
    if (qrResult == null || !mounted) return;

    setState(() => _isReceiptLoading = true);
    final parsedData = _receiptScanService.parseQrData(qrResult);
    setState(() => _isReceiptLoading = false);

    if (parsedData == null || parsedData['amount'] == null) {
      _showSnack(context, 'Нестандартный QR-код');
      return;
    }

    _selectedDate = parsedData['date'] as DateTime;
    _applyParsedData(parsedData['amount'] as double, _selectedCategory ?? ExpenseCategory.other, null, _selectedCurrency, 'QR: ${parsedData['rawText']}');
  }

  Future<void> _scanPickedFile(BuildContext context, XFile file) async {
    setState(() => _isReceiptLoading = true);
    final result = await _receiptScanService.scanFile(file);
    if (!mounted) return;
    setState(() => _isReceiptLoading = false);

    if (!result.isSuccess) {
      _showSnack(context, result.errorMessage ?? 'Ошибка сканирования');
      return;
    }

    final parsedReceipt = _receiptParserService.parse(result.recognizedText);
    _receiptParsedData = parsedReceipt;

    final review = await Navigator.of(context).push<ReceiptReviewModel>(
        CupertinoPageRoute(builder: (_) => ReceiptReviewScreen(parsedData: _receiptParsedData!))
    );
    if (!mounted || review == null) return;

    _applyParsedData(review.amount, review.category, review.merchant, review.currency, review.rawText);
  }

  Future<void> _handleReceiptCameraTap(BuildContext context) async {
    HapticFeedback.lightImpact();
    final file = await _receiptScanService.pickFromCamera();
    if (file == null || !mounted) return;
    await _scanPickedFile(context, file);
  }

  Future<void> _handleReceiptGalleryTap(BuildContext context) async {
    HapticFeedback.lightImpact();
    final file = await _receiptScanService.pickFromGallery();
    if (file == null || !mounted) return;
    await _scanPickedFile(context, file);
  }

  // --- СОХРАНЕНИЕ ---
  Future<void> _saveExpense(BuildContext context) async {
    if (!_canSave) return;
    HapticFeedback.heavyImpact();

    final settings = context.read<SettingsProvider>();
    final transactions = context.read<TransactionsProvider>();
    final hasPremium = settings.canUseFeature(PremiumFeature.multiCurrency);

    await transactions.addExpense(
      ExpenseModel(
        id: const Uuid().v4(),
        amount: _parsedAmount,
        currency: hasPremium ? _selectedCurrency : _userCurrency,
        category: _selectedCategory!,
        customCategoryId: _selectedCustomCategoryId,
        merchant: _noteText.isEmpty ? (_isIncome ? 'Доход' : 'Расход') : _noteText,
        note: _noteText.isEmpty ? null : _noteText,
        date: _selectedDate,
        sourceType: _mapSourceModeToType(_sourceMode),
        isRecurring: false,
        recurringGroupId: null,
        createdAt: DateTime.now(),
        isIncome: _isIncome,
      ),
    );

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  ExpenseSourceType _mapSourceModeToType(AddExpenseSourceMode mode) {
    switch (mode) {
      case AddExpenseSourceMode.smartText: return ExpenseSourceType.smartText;
      case AddExpenseSourceMode.voice: return ExpenseSourceType.voice;
      case AddExpenseSourceMode.receipt: return ExpenseSourceType.receipt;
    }
  }

  // --- КАТЕГОРИИ И UI-ХЕЛПЕРЫ ---
  void _selectSystemCategory(ExpenseCategory cat) {
    HapticFeedback.selectionClick();
    setState(() { _selectedCategory = cat; _selectedCustomCategoryId = null; });
  }

  void _selectCustomCategory(String id) {
    HapticFeedback.selectionClick();
    setState(() { _selectedCategory = ExpenseCategory.custom; _selectedCustomCategoryId = id; });
  }

  void _handleCurrencyTap() {
    final settings = context.read<SettingsProvider>();
    if (!settings.canUseFeature(PremiumFeature.multiCurrency)) {
      Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const PremiumScreen()));
      return;
    }

    HapticFeedback.lightImpact();
    int initialIndex = _availableCurrencies.indexOf(_selectedCurrency);
    if (initialIndex == -1) initialIndex = 0;

    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250, color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          top: false,
          child: CupertinoPicker(
            itemExtent: 40,
            scrollController: FixedExtentScrollController(initialItem: initialIndex),
            onSelectedItemChanged: (index) {
              HapticFeedback.selectionClick();
              setState(() => _selectedCurrency = _availableCurrencies[index]);
            },
            children: _availableCurrencies.map((c) => Center(
              child: Text(c, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600)),
            )).toList(),
          ),
        ),
      ),
    );
  }

  void _showDatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 280, color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          top: false,
          child: CupertinoDatePicker(
            initialDateTime: _selectedDate, mode: CupertinoDatePickerMode.dateAndTime, use24hFormat: true, maximumDate: DateTime.now(),
            onDateTimeChanged: (val) => setState(() => _selectedDate = val),
          ),
        ),
      ),
    );
  }

  String _formatDateShort(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) return _t('Today', 'Сегодня');
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}';
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }

  String _categoryLabel(ExpenseCategory category) {
    final l10n = AppLocalizations.of(context);
    if (_isIncome) {
      switch (category) {
        case ExpenseCategory.other: return '💼 ${_t('Salary', 'Зарплата')}';
        case ExpenseCategory.gifts: return '🎁 ${_t('Transfer', 'Перевод')}';
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
      case ExpenseCategory.custom: return 'Custom';
      case ExpenseCategory.other: return '📦 ${l10n.categoryOther}';
    }
  }

  // --- BUILD ---
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(theme),

            Expanded(
              flex: 4,
              child: _buildAmountDisplay(theme),
            ),

            if (_sourceMode != AddExpenseSourceMode.smartText)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _sourceMode == AddExpenseSourceMode.voice ? _buildVoiceSection() : _buildReceiptSection(),
              ),

            _buildCategorySelector(theme, settings),
            const SizedBox(height: 16),

            Expanded(
              flex: 6,
              child: _buildNumpad(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: Icon(CupertinoIcons.xmark_circle_fill, color: theme.colorScheme.onSurface.withValues(alpha: 0.2), size: 28),
            onPressed: () => Navigator.of(context).pop(),
          ),

          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                _buildTypeTab(_t('Expense', 'Расход'), !_isIncome, theme),
                _buildTypeTab(_t('Income', 'Доход'), _isIncome, theme),
              ],
            ),
          ),

          GestureDetector(
            onTap: _handleCurrencyTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(_selectedCurrency, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeTab(String title, bool isActive, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _isIncome = title == 'Доход' || title == 'Income';
          _selectedCategory = null;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? (_isIncome ? CupertinoColors.systemGreen : theme.colorScheme.primary) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : theme.colorScheme.onSurface.withValues(alpha: 0.5),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildAmountDisplay(ThemeData theme) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        final result = await showCupertinoDialog<String>(
            context: context,
            builder: (ctx) {
              String tempNote = _noteText;
              return CupertinoAlertDialog(
                title: Text(_t('Add Note', 'Добавить заметку')),
                content: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: CupertinoTextField(
                    placeholder: _t('What was this for?', 'За что платим?'),
                    autofocus: true,
                    controller: TextEditingController(text: _noteText),
                    onChanged: (v) => tempNote = v,
                  ),
                ),
                actions: [
                  CupertinoDialogAction(child: Text(_t('Cancel', 'Отмена')), onPressed: () => Navigator.pop(ctx)),
                  CupertinoDialogAction(child: Text('OK'), isDefaultAction: true, onPressed: () => Navigator.pop(ctx, tempNote)),
                ],
              );
            }
        );
        if (result != null) setState(() => _noteText = result);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _isIncome ? '+' : '-',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: _isIncome ? CupertinoColors.systemGreen : theme.colorScheme.primary),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _amountString,
                style: TextStyle(
                  fontSize: 76,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -2,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (_noteText.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(12)),
              child: Text(_noteText, style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 14, fontWeight: FontWeight.w500)),
            )
          else
            Text(_t('Tap to add note', 'Нажмите, чтобы добавить заметку'), style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.3), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildCategorySelector(ThemeData theme, SettingsProvider settings) {
    final systemCategories = _isIncome
        ? [ExpenseCategory.other, ExpenseCategory.gifts]
        : ExpenseCategory.values.where((c) => c != ExpenseCategory.custom).toList();
    final customCategories = settings.customCategories;

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          ...systemCategories.map((cat) {
            final isSelected = _selectedCustomCategoryId == null && _selectedCategory == cat;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => _selectSystemCategory(cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? (_isIncome ? CupertinoColors.systemGreen : theme.colorScheme.primary) : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isSelected ? Colors.transparent : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
                  ),
                  child: Center(
                    child: Text(
                      _categoryLabel(cat),
                      style: TextStyle(color: isSelected ? Colors.white : theme.colorScheme.onSurface, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, fontSize: 13),
                    ),
                  ),
                ),
              ),
            );
          }),

          ...customCategories.map((cat) {
            final isSelected = _selectedCustomCategoryId == cat.id;
            final catColor = Color(cat.colorValue);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => _selectCustomCategory(cat.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? catColor : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isSelected ? Colors.transparent : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
                  ),
                  child: Center(
                    child: Text(cat.name, style: TextStyle(color: isSelected ? Colors.white : theme.colorScheme.onSurface, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, fontSize: 13)),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNumpad(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildToolButton(CupertinoIcons.calendar, _formatDateShort(_selectedDate), () => _showDatePicker()),
              _buildToolButton(CupertinoIcons.mic_fill, _t('Voice', 'Голос'), () {
                final settings = context.read<SettingsProvider>();
                if (!settings.canUseFeature(PremiumFeature.voiceInput)) {
                  Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const PremiumScreen()));
                  return;
                }
                setState(() => _sourceMode = _sourceMode == AddExpenseSourceMode.voice ? AddExpenseSourceMode.smartText : AddExpenseSourceMode.voice);
              }),
              _buildToolButton(CupertinoIcons.qrcode_viewfinder, _t('Scan', 'Скан'), () {
                final settings = context.read<SettingsProvider>();
                if (!settings.canUseFeature(PremiumFeature.receiptOcr)) {
                  Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const PremiumScreen()));
                  return;
                }
                setState(() => _sourceMode = _sourceMode == AddExpenseSourceMode.receipt ? AddExpenseSourceMode.smartText : AddExpenseSourceMode.receipt);
              }),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _buildNumpadRow(['1', '2', '3']),
                      _buildNumpadRow(['4', '5', '6']),
                      _buildNumpadRow(['7', '8', '9']),
                      _buildNumpadRow(['.', '0', '<']),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _buildNumpadButton('C', color: CupertinoColors.systemRed),
                      const SizedBox(height: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: _canSave ? () => _saveExpense(context) : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: _canSave ? (_isIncome ? CupertinoColors.systemGreen : theme.colorScheme.primary) : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: _canSave ? [BoxShadow(color: (_isIncome ? CupertinoColors.systemGreen : theme.colorScheme.primary).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))] : [],
                            ),
                            child: const Center(
                              child: Icon(CupertinoIcons.checkmark_alt, color: Colors.white, size: 36),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildToolButton(IconData icon, String label, VoidCallback onTap) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface.withValues(alpha: 0.8), fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildNumpadRow(List<String> keys) {
    return Expanded(
      child: Row(
        children: keys.map((k) => Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: _buildNumpadButton(k),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildNumpadButton(String label, {Color? color}) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => _onNumpadTap(label),
      child: Container(
        decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(16)),
        child: Center(
          child: label == '<'
              ? Icon(CupertinoIcons.delete_left_fill, color: theme.colorScheme.onSurface, size: 24)
              : Text(label, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: color ?? theme.colorScheme.onSurface)),
        ),
      ),
    );
  }

  // --- ГОЛОСОВОЙ И СКАНЕР UI ---
  Widget _buildVoiceSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          GestureDetector(
            onTap: _isVoiceLoading ? null : () => _handleVoiceTap(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(shape: BoxShape.circle, color: _isVoiceListening ? CupertinoColors.destructiveRed : Theme.of(context).colorScheme.primary),
              child: _isAiParsing
                  ? const CupertinoActivityIndicator(color: Colors.white)
                  : Icon(_isVoiceListening ? CupertinoIcons.stop_fill : CupertinoIcons.mic_fill, color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(_isAiParsing ? _t('AI is thinking...', 'ИИ анализирует...') : (_isVoiceListening ? _t('Listening...', 'Говорите...') : _voicePreviewText.isNotEmpty ? '"$_voicePreviewText"' : _t('Tap to speak', 'Нажмите для голосового ввода')), style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildReceiptSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _ReceiptButton(icon: CupertinoIcons.camera_fill, label: _t('Camera', 'Камера'), onTap: _isReceiptLoading ? null : () => _handleReceiptCameraTap(context))),
            const SizedBox(width: 12),
            Expanded(child: _ReceiptButton(icon: CupertinoIcons.photo_fill, label: _t('Gallery', 'Галерея'), onTap: _isReceiptLoading ? null : () => _handleReceiptGalleryTap(context))),
            const SizedBox(width: 12),
            Expanded(child: _ReceiptButton(icon: CupertinoIcons.qrcode_viewfinder, label: 'QR', onTap: _isReceiptLoading ? null : () => _handleQrScannerTap(context))),
          ],
        ),
        if (_isReceiptLoading) const Padding(padding: EdgeInsets.only(top: 16), child: CupertinoActivityIndicator()),
        if (_receiptPreviewText.isNotEmpty && !_isReceiptLoading)
          Padding(padding: const EdgeInsets.only(top: 16), child: Text(_receiptPreviewText, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)))),
      ],
    );
  }
}

class _ReceiptButton extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback? onTap;
  const _ReceiptButton({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero, onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHighest)),
        child: Column(children: [Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary), const SizedBox(height: 4), Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600, fontSize: 12))]),
      ),
    );
  }
}