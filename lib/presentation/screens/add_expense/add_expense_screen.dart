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
import '../../../data/models/parsed_expense_input_model.dart';
import '../../../data/models/receipt_parsed_data_model.dart';
import '../../../data/models/receipt_review_model.dart';
import '../../../data/models/receipt_scan_result_model.dart';
import '../../../domain/services/currency_conversion_service.dart';
import '../../../domain/services/premium_feature.dart';
import '../../../domain/services/receipt_parser_service.dart';
import '../../../domain/services/receipt_scan_service.dart';
import '../../../domain/services/smart_expense_parser.dart';
import '../../../domain/services/voice_input_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/home_provider.dart';
import '../../widgets/adaptive_page_padding.dart';
import '../../widgets/add_expense_source_selector.dart';
import '../../widgets/custom_category_sheet.dart';
import '../premium/premium_screen.dart';
import '../receipt_review/receipt_review_screen.dart';

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
  final TextEditingController _smartInputController = TextEditingController();
  final SmartExpenseParser _parser = SmartExpenseParser();
  final VoiceInputService _voiceInputService = VoiceInputService();
  final ReceiptScanService _receiptScanService = ReceiptScanService();
  final ReceiptParserService _receiptParserService = ReceiptParserService();

  final CurrencyConversionService _conversionService = CurrencyConversionService();

  ParsedExpenseInputModel? _parsed;
  ReceiptParsedDataModel? _receiptParsedData;
  AddExpenseSourceMode _sourceMode = AddExpenseSourceMode.smartText;

  DateTime _selectedDate = DateTime.now();
  ExpenseCategory? _selectedCategory;
  String? _selectedCustomCategoryId;

  late bool _isIncome;
  late String _userCurrency;
  late String _selectedCurrency;

  final List<String> _availableCurrencies = ['USD', 'EUR', 'GBP', 'RUB', 'KZT', 'KGS', 'UZS', 'UAH', 'BYN'];

  bool _isVoiceLoading = false;
  bool _isVoiceListening = false;
  String _voicePreviewText = '';
  String? _selectedLocaleId;

  bool _isReceiptLoading = false;
  String _receiptPreviewText = '';

  bool _isConverting = false;

  bool _isAiParsing = false;
  Timer? _debounceTimer;

  Timer? _typewriterTimer;
  String _currentHint = '';
  int _hintIndex = 0;
  int _charIndex = 0;
  bool _isTypingForward = true;

  late final List<String> _expenseHints;
  late final List<String> _incomeHints;

  @override
  void initState() {
    super.initState();
    _isIncome = widget.initialIsIncome;

    final provider = context.read<HomeProvider>();
    _userCurrency = provider.activeCurrency;

    if (provider.canUseFeature(PremiumFeature.multiCurrency)) {
      _selectedCurrency = _userCurrency;
    } else {
      _selectedCurrency = _userCurrency;
    }

    if (widget.initialCustomCategoryId != null) {
      _selectedCategory = ExpenseCategory.custom;
      _selectedCustomCategoryId = widget.initialCustomCategoryId;
      _parsed = ParsedExpenseInputModel(amount: null, currency: _selectedCurrency, category: ExpenseCategory.custom, merchant: null, rawText: '');
    } else {
      _selectedCategory = widget.initialCategory;
      if (widget.initialCategory != null) {
        _parsed = ParsedExpenseInputModel(amount: null, currency: _selectedCurrency, category: widget.initialCategory, merchant: null, rawText: '');
      } else if (_isIncome) {
        _selectedCategory = ExpenseCategory.other;
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initVoice();

    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    _expenseHints = isRu
        ? ['Кофе 150', 'Такси домой 500', 'Продукты в Ашане 2500', 'Кино с друзьями 800', 'Подписка Netflix 15 USD']
        : ['Coffee 5', 'Uber to home 15', 'Groceries at Target 120', 'Movie tickets 25', 'Netflix subscription 15'];

    _incomeHints = isRu
        ? ['Зарплата 100000', 'Вернули долг 5000', 'Продал телефон 30000']
        : ['Salary 5000', 'Refund 50', 'Sold old phone 300'];

    _startTypewriterAnimation();
  }

  void _startTypewriterAnimation() {
    _typewriterTimer?.cancel();
    final activeHints = _isIncome ? _incomeHints : _expenseHints;
    if (activeHints.isEmpty) return;

    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      // ИСПРАВЛЕНИЕ: Гарантированно убиваем таймер, если юзер печатает (Memory Leak fix)
      if (_smartInputController.text.isNotEmpty) {
        setState(() => _currentHint = '');
        timer.cancel();
        return;
      }

      final targetWord = activeHints[_hintIndex];

      setState(() {
        if (_isTypingForward) {
          if (_charIndex < targetWord.length) {
            _charIndex++;
            _currentHint = targetWord.substring(0, _charIndex);
          } else {
            _isTypingForward = false;
            _typewriterTimer?.cancel();
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted && _smartInputController.text.isEmpty) _startTypewriterAnimation();
            });
          }
        } else {
          if (_charIndex > 0) {
            _charIndex--;
            _currentHint = targetWord.substring(0, _charIndex);
            _typewriterTimer?.cancel();
            _typewriterTimer = Timer.periodic(const Duration(milliseconds: 50), (t) => _startTypewriterAnimation());
          } else {
            _isTypingForward = true;
            _hintIndex = (_hintIndex + 1) % activeHints.length;
            _typewriterTimer?.cancel();
            _typewriterTimer = Timer.periodic(const Duration(milliseconds: 100), (t) => _startTypewriterAnimation());
          }
        }
      });
    });
  }

  String _t(String en, String ru) {
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    return isRu ? ru : en;
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
    _typewriterTimer?.cancel();
    _debounceTimer?.cancel();
    _smartInputController.dispose();
    _voiceInputService.cancelListening();
    _receiptScanService.dispose();
    super.dispose();
  }

  void _parseInput() {
    final text = _smartInputController.text;

    if (text.isEmpty && _currentHint.isEmpty) {
      _hintIndex = 0;
      _charIndex = 0;
      _isTypingForward = true;
      _startTypewriterAnimation();
    }

    final localParsed = _parser.parse(text);
    setState(() {
      final hasPremium = context.read<HomeProvider>().canUseFeature(PremiumFeature.multiCurrency);
      if (localParsed.currency != null && hasPremium) {
        _selectedCurrency = localParsed.currency!;
      }

      _parsed = ParsedExpenseInputModel(
        amount: localParsed.amount,
        currency: hasPremium ? (localParsed.currency ?? _selectedCurrency) : _userCurrency,
        category: _selectedCategory ?? localParsed.category ?? widget.initialCategory ?? ExpenseCategory.other,
        merchant: localParsed.merchant,
        rawText: localParsed.rawText,
      );
    });

    _debounceTimer?.cancel();

    final hasLetters = RegExp(r'[a-zA-Zа-яА-Я]').hasMatch(text);

    if (text.trim().length > 3 && hasLetters) {
      _debounceTimer = Timer(const Duration(milliseconds: 1500), () async {
        if (!mounted) return;

        setState(() => _isAiParsing = true);

        final aiParsed = await _parser.parseWithAI(text, _selectedCurrency);

        if (!mounted) return;

        setState(() {
          _isAiParsing = false;
          final hasPremium = context.read<HomeProvider>().canUseFeature(PremiumFeature.multiCurrency);

          if (aiParsed.currency != null && hasPremium) {
            _selectedCurrency = aiParsed.currency!;
          }

          _parsed = ParsedExpenseInputModel(
            amount: aiParsed.amount ?? _parsed?.amount,
            currency: hasPremium ? (aiParsed.currency ?? _selectedCurrency) : _userCurrency,
            category: _selectedCategory != null ? _selectedCategory! : (aiParsed.category ?? ExpenseCategory.other),
            merchant: aiParsed.merchant ?? _parsed?.merchant,
            rawText: aiParsed.rawText,
          );
        });
      });
    } else {
      if (_isAiParsing) {
        setState(() => _isAiParsing = false);
      }
    }
  }

  Future<void> _parseVoiceText(String text) async {
    setState(() {
      _voicePreviewText = text;
      _isAiParsing = true;
    });

    final aiParsed = await _parser.parseWithAI(text, _selectedCurrency);

    if (!mounted) return;

    final hasPremium = context.read<HomeProvider>().canUseFeature(PremiumFeature.multiCurrency);

    setState(() {
      _isAiParsing = false;
      if (aiParsed.currency != null && hasPremium) _selectedCurrency = aiParsed.currency!;

      _parsed = ParsedExpenseInputModel(
        amount: aiParsed.amount,
        currency: hasPremium ? (aiParsed.currency ?? _selectedCurrency) : _userCurrency,
        category: _selectedCategory ?? aiParsed.category ?? widget.initialCategory ?? ExpenseCategory.other,
        merchant: aiParsed.merchant,
        rawText: text,
      );
    });
  }

  void _parseReceiptText(String text) {
    final parsedReceipt = _receiptParserService.parse(text);
    final hasPremium = context.read<HomeProvider>().canUseFeature(PremiumFeature.multiCurrency);

    setState(() {
      _receiptPreviewText = text;
      _receiptParsedData = parsedReceipt;
      if (parsedReceipt.currency != null && hasPremium) _selectedCurrency = parsedReceipt.currency!;
      _parsed = ParsedExpenseInputModel(
        amount: parsedReceipt.amount,
        currency: hasPremium ? (parsedReceipt.currency ?? _selectedCurrency) : _userCurrency,
        category: _selectedCategory ?? parsedReceipt.category ?? widget.initialCategory ?? ExpenseCategory.other,
        merchant: parsedReceipt.merchant,
        rawText: text.replaceAll('\n', ' '),
      );
    });
  }

  void _selectSystemCategory(ExpenseCategory cat) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedCategory = cat;
      _selectedCustomCategoryId = null;
      if (_parsed != null) {
        _parsed = ParsedExpenseInputModel(amount: _parsed!.amount, currency: _selectedCurrency, category: cat, merchant: _parsed!.merchant, rawText: _parsed!.rawText);
      } else {
        _parsed = ParsedExpenseInputModel(amount: null, currency: _selectedCurrency, category: cat, merchant: null, rawText: '');
      }
    });
  }

  void _selectCustomCategory(String id) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedCategory = ExpenseCategory.custom;
      _selectedCustomCategoryId = id;
      if (_parsed != null) {
        _parsed = ParsedExpenseInputModel(amount: _parsed!.amount, currency: _selectedCurrency, category: ExpenseCategory.custom, merchant: _parsed!.merchant, rawText: _parsed!.rawText);
      } else {
        _parsed = ParsedExpenseInputModel(amount: null, currency: _selectedCurrency, category: ExpenseCategory.custom, merchant: null, rawText: '');
      }
    });
  }

  void _showDatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 280, color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          top: false,
          child: CupertinoDatePicker(
            initialDateTime: _selectedDate,
            mode: CupertinoDatePickerMode.dateAndTime,
            use24hFormat: true,
            maximumDate: DateTime.now().add(const Duration(days: 365)),
            onDateTimeChanged: (val) => setState(() => _selectedDate = val),
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
                if (_parsed != null) {
                  _parsed = ParsedExpenseInputModel(
                    amount: _parsed!.amount, currency: _selectedCurrency, category: _parsed!.category, merchant: _parsed!.merchant, rawText: _parsed!.rawText,
                  );
                }
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

  Future<void> _handleAutoConvert() async {
    final provider = context.read<HomeProvider>();
    if (!provider.canUseFeature(PremiumFeature.multiCurrency)) {
      Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const PremiumScreen()));
      return;
    }

    if (_parsed == null || _parsed!.amount == null) return;

    setState(() {
      _isConverting = true;
    });

    final convertedAmount = await _conversionService.convert(
      amount: _parsed!.amount!,
      fromCurrency: _selectedCurrency,
      toCurrency: _userCurrency,
    );

    if (!mounted) return;

    setState(() {
      _isConverting = false;
    });

    if (convertedAmount != null) {
      HapticFeedback.mediumImpact();
      setState(() {
        _selectedCurrency = _userCurrency;
        _parsed = ParsedExpenseInputModel(
          amount: convertedAmount,
          currency: _userCurrency,
          category: _parsed!.category,
          merchant: _parsed!.merchant,
          rawText: _parsed!.rawText,
        );
      });
    } else {
      HapticFeedback.heavyImpact();
      _showSnack(context, _t('Failed to fetch exchange rates', 'Не удалось получить курс валют. Проверьте интернет.'));
    }
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }

  Future<void> _handleVoiceTap(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    HapticFeedback.lightImpact();

    if (_isVoiceListening) {
      setState(() => _isVoiceLoading = true);
      final result = await _voiceInputService.stopListening();

      if (!mounted) return;

      setState(() { _isVoiceLoading = false; _isVoiceListening = false; });
      if (result.hasText) {
        await _parseVoiceText(result.recognizedText);
      }
      else if (result.errorMessage != null) {
        _showSnack(context, l10n.voiceErrorMessage(result.errorMessage!));
      }
      return;
    }

    setState(() => _isVoiceLoading = true);
    final result = await _voiceInputService.startListening(localeId: _selectedLocaleId ?? '');

    if (!mounted) return;

    setState(() { _isVoiceLoading = false; _isVoiceListening = result.isAvailable; });
    if (!result.isAvailable) _showSnack(context, l10n.voiceUnavailableMessage);
  }

  Future<void> _scanPickedFile(BuildContext context, XFile file) async {
    final l10n = AppLocalizations.of(context);
    setState(() { _isReceiptLoading = true; });
    final result = await _receiptScanService.scanFile(file);

    if (!mounted) return;
    setState(() => _isReceiptLoading = false);

    if (!result.isSuccess) {
      _showSnack(context, l10n.receiptScanErrorMessage(result.errorMessage ?? l10n.notAvailableShort));
      return;
    }

    _parseReceiptText(result.recognizedText);
    if (_receiptParsedData == null) return;

    final review = await Navigator.of(context).push<ReceiptReviewModel>(
        CupertinoPageRoute(builder: (_) => ReceiptReviewScreen(parsedData: _receiptParsedData!))
    );

    if (!mounted || review == null) return;

    final hasPremium = context.read<HomeProvider>().canUseFeature(PremiumFeature.multiCurrency);

    setState(() {
      if (hasPremium && review.currency != null) _selectedCurrency = review.currency!;
      _parsed = ParsedExpenseInputModel(
          amount: review.amount,
          currency: hasPremium ? _selectedCurrency : _userCurrency,
          category: review.category,
          merchant: review.merchant,
          rawText: review.rawText
      );
      _receiptPreviewText = review.rawText;
    });
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

  Future<void> _saveExpense(BuildContext context) async {
    final parsed = _parsed;
    if (parsed == null || !parsed.isValid) return;

    HapticFeedback.mediumImpact();

    final provider = context.read<HomeProvider>();
    final hasPremium = provider.canUseFeature(PremiumFeature.multiCurrency);

    await provider.addExpense(
      ExpenseModel(
        id: const Uuid().v4(),
        amount: parsed.amount!,
        currency: hasPremium ? _selectedCurrency : _userCurrency,
        category: _selectedCategory ?? parsed.category ?? ExpenseCategory.other,
        customCategoryId: _selectedCustomCategoryId,
        merchant: parsed.merchant ?? '',
        note: parsed.rawText.isEmpty ? null : parsed.rawText,
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

  String _formatNumber(num value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    final time = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    if (isToday) return '${_t('Today', 'Сегодня')}, $time';
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}, $time';
  }

  String _categoryLabel(BuildContext context, ExpenseCategory category) {
    final l10n = AppLocalizations.of(context);

    if (_isIncome) {
      switch (category) {
        case ExpenseCategory.other: return '💼 ${_t('Salary / Income', 'Зарплата / Доход')}';
        case ExpenseCategory.gifts: return '🎁 ${_t('Gift / Transfer', 'Подарок / Перевод')}';
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

  // ИСПРАВЛЕНИЕ: Убрали блокировку !_isAiParsing, чтобы юзер мог сохранить мгновенно локальный парсинг
  bool get _canSave => _parsed != null && _parsed!.isValid;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.black : const Color(0xFFF2F2F7);

    final provider = context.watch<HomeProvider>();
    final customCategories = provider.customCategories;

    final systemCategories = _isIncome
        ? [ExpenseCategory.other, ExpenseCategory.gifts]
        : ExpenseCategory.values.where((c) => c != ExpenseCategory.custom).toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CupertinoNavigationBar(
        backgroundColor: backgroundColor.withValues(alpha: 0.8),
        middle: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
              _isIncome ? _t('Add Income', 'Добавить Доход') : l10n.addExpense,
              key: ValueKey(_isIncome),
              style: TextStyle(color: theme.colorScheme.onSurface)
          ),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Text(l10n.cancelButton ?? 'Cancel', style: TextStyle(color: theme.colorScheme.primary)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _canSave ? () => _saveExpense(context) : null,
          child: _isAiParsing && !_canSave
              ? CupertinoActivityIndicator(radius: 10, color: theme.colorScheme.primary)
              : Text(
            l10n.saveExpenseButton,
            style: TextStyle(fontWeight: FontWeight.w700, color: _canSave ? theme.colorScheme.primary : CupertinoColors.systemGrey),
          ),
        ),
      ),
      body: AdaptivePagePadding(
        addBottomSafeArea: true,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const BouncingScrollPhysics(),
          children: [
            const SizedBox(height: 16),

            AddExpenseSourceSelector(
              value: _sourceMode,
              onChanged: (mode) {
                if (mode == AddExpenseSourceMode.voice && !provider.canUseFeature(PremiumFeature.voiceInput)) {
                  Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const PremiumScreen()));
                  return;
                }
                if (mode == AddExpenseSourceMode.receipt && !provider.canUseFeature(PremiumFeature.receiptOcr)) {
                  Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const PremiumScreen()));
                  return;
                }
                setState(() => _sourceMode = mode);
              },
            ),

            const SizedBox(height: 24),

            _buildTypeToggle(theme),

            const SizedBox(height: 32),

            Column(
              children: [
                SizedBox(
                  height: 80,
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return ScaleTransition(scale: animation, child: child);
                        },
                        child: Text(
                          '${_isIncome && _parsed?.amount != null ? '+' : ''}${_parsed?.amount != null ? _formatNumber(_parsed!.amount!) : '0'}',
                          key: ValueKey('${_parsed?.amount}_$_isIncome'),
                          style: TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -2.5,
                            color: _isIncome ? CupertinoColors.systemGreen : theme.colorScheme.onSurface,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: _handleCurrencyTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!provider.canUseFeature(PremiumFeature.multiCurrency)) ...[
                          Icon(CupertinoIcons.lock_fill, size: 12, color: CupertinoColors.systemYellow),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          _selectedCurrency,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface),
                        ),
                        const SizedBox(width: 4),
                        Icon(CupertinoIcons.chevron_down, size: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                      ],
                    ),
                  ),
                ),

                if (_selectedCurrency != _userCurrency && (_parsed?.amount ?? 0) > 0) ...[
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _isConverting ? null : _handleAutoConvert,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: CupertinoColors.activeOrange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: CupertinoColors.activeOrange.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
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
                          const SizedBox(width: 6),
                          Text(
                            _t('Convert to $_userCurrency', 'В $_userCurrency'),
                            style: const TextStyle(fontWeight: FontWeight.w700, color: CupertinoColors.activeOrange),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 24),

            if (_sourceMode == AddExpenseSourceMode.smartText) _buildSmartTextSection(context),
            if (_sourceMode == AddExpenseSourceMode.voice) _buildVoiceSection(context),
            if (_sourceMode == AddExpenseSourceMode.receipt) _buildReceiptSection(context),

            const SizedBox(height: 32),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: Responsive.cardPadding(context)),
              child: Row(
                children: [
                  ...systemCategories.map((cat) {
                    final isSelected = _selectedCustomCategoryId == null && (_selectedCategory ?? _parsed?.category ?? widget.initialCategory ?? ExpenseCategory.other) == cat;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => _selectSystemCategory(cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? (_isIncome ? CupertinoColors.systemGreen : theme.colorScheme.primary) : theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isSelected ? Colors.transparent : theme.colorScheme.surfaceContainerHighest),
                          ),
                          child: Text(
                            _categoryLabel(context, cat),
                            style: TextStyle(
                              color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? catColor : theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isSelected ? Colors.transparent : theme.colorScheme.surfaceContainerHighest),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                IconData(cat.iconCodePoint, fontFamily: 'CupertinoIcons', fontPackage: CupertinoIcons.iconFontPackage),
                                size: 16, color: isSelected ? Colors.white : catColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                cat.name,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  GestureDetector(
                    onTap: () async {
                      final newCat = await CustomCategorySheet.show(context);
                      if (newCat != null) _selectCustomCategory(newCat.id);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.add, size: 16, color: theme.colorScheme.primary),
                          const SizedBox(width: 4),
                          Text('New', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.cardPadding(context)),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _SettingsRow(
                      icon: CupertinoIcons.calendar,
                      iconColor: CupertinoColors.systemRed,
                      title: _t('Date', 'Дата'),
                      value: _formatDate(_selectedDate),
                      onTap: _showDatePicker,
                    ),
                    _SettingsRow(
                      icon: CupertinoIcons.building_2_fill,
                      iconColor: CupertinoColors.systemBlue,
                      title: _isIncome ? _t('Source', 'Источник') : l10n.previewMerchant,
                      value: _parsed?.merchant?.isNotEmpty == true ? _parsed!.merchant! : _t('Optional', 'Необязательно'),
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom + 100),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeToggle(ThemeData theme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Responsive.cardPadding(context)),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_isIncome) {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _isIncome = false;
                    _hintIndex = 0;
                    _charIndex = 0;
                    _isTypingForward = true;
                    _startTypewriterAnimation();

                    if (_selectedCategory == ExpenseCategory.other || _selectedCategory == ExpenseCategory.gifts) {
                      _selectedCategory = widget.initialCategory ?? ExpenseCategory.food;
                    }
                  });
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !_isIncome ? theme.colorScheme.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: !_isIncome ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))] : [],
                ),
                child: Center(
                  child: Text(
                    _t('Expense', 'Расход'),
                    style: TextStyle(
                      fontWeight: !_isIncome ? FontWeight.w700 : FontWeight.w500,
                      color: !_isIncome ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
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
                    _hintIndex = 0;
                    _charIndex = 0;
                    _isTypingForward = true;
                    _startTypewriterAnimation();

                    if (_selectedCustomCategoryId == null) {
                      _selectedCategory = ExpenseCategory.other;
                    }
                  });
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _isIncome ? CupertinoColors.systemGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _isIncome ? [BoxShadow(color: CupertinoColors.systemGreen.withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2))] : [],
                ),
                child: Center(
                  child: Text(
                    _t('Income', 'Доход'),
                    style: TextStyle(
                      fontWeight: _isIncome ? FontWeight.w700 : FontWeight.w500,
                      color: _isIncome ? Colors.white : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartTextSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.cardPadding(context)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHighest),
        ),
        child: Row(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_smartInputController.text.isEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentHint,
                          style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                              fontWeight: FontWeight.w500
                          ),
                        ),
                        AnimatedOpacity(
                          opacity: _isTypingForward ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            width: 2, height: 20,
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                            margin: const EdgeInsets.only(left: 2),
                          ),
                        ),
                      ],
                    ),

                  TextField(
                    controller: _smartInputController,
                    autofocus: true,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '',
                    ),
                    onChanged: (_) => _parseInput(),
                  ),
                ],
              ),
            ),
            if (_isAiParsing)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: CupertinoActivityIndicator(color: Theme.of(context).colorScheme.primary),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceSection(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
            onTap: _isVoiceLoading ? null : () => _handleVoiceTap(context),
            child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 100, width: 100,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isVoiceListening ? CupertinoColors.destructiveRed : Theme.of(context).colorScheme.primary,
                    boxShadow: [
                      BoxShadow(
                        color: (_isVoiceListening ? CupertinoColors.destructiveRed : Theme.of(context).colorScheme.primary).withValues(alpha: 0.4),
                        blurRadius: 30, spreadRadius: _isVoiceListening ? 10 : 0,
                      )
                    ]
                ),
                child: _isAiParsing
                    ? const CupertinoActivityIndicator(color: Colors.white, radius: 16)
                    : Icon(
                  _isVoiceListening ? CupertinoIcons.stop_fill : CupertinoIcons.mic_fill,
                  size: 42, color: Colors.white,
                )
            )
        ),
        if (_voicePreviewText.isNotEmpty) ...[
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              '"$_voicePreviewText"',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildReceiptSection(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.cardPadding(context)),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _ReceiptButton(
                  icon: CupertinoIcons.camera_fill,
                  label: _t('Camera', 'Камера'),
                  onTap: _isReceiptLoading ? null : () => _handleReceiptCameraTap(context),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ReceiptButton(
                  icon: CupertinoIcons.photo_fill_on_rectangle_fill,
                  label: _t('Gallery', 'Галерея'),
                  onTap: _isReceiptLoading ? null : () => _handleReceiptGalleryTap(context),
                ),
              ),
            ],
          ),
          if (_isReceiptLoading) const Padding(padding: EdgeInsets.only(top: 24), child: CupertinoActivityIndicator(radius: 14)),
          if (_receiptPreviewText.isNotEmpty && !_isReceiptLoading) ...[
            const SizedBox(height: 24),
            Text(
              l10n.receiptParsedSummaryTitle,
              style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
            ),
          ]
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final VoidCallback? onTap;
  final bool isLast;

  const _SettingsRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: iconColor, borderRadius: BorderRadius.circular(8)),
                    child: Icon(icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Text(title, style: TextStyle(fontSize: 17, color: Theme.of(context).colorScheme.onSurface)),
                  const Spacer(),
                  Text(
                      value,
                      style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))
                  ),
                  const SizedBox(width: 8),
                  Icon(CupertinoIcons.chevron_forward, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3), size: 18),
                ],
              ),
            ),
            if (!isLast) Padding(
              padding: const EdgeInsets.only(left: 56),
              child: Divider(height: 1, color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ReceiptButton({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}