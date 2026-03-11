import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
  final String? initialCustomCategoryId; // Ссылка на созданную кастомную категорию

  const AddExpenseScreen({
    super.key,
    this.initialCategory,
    this.initialCustomCategoryId,
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

  ParsedExpenseInputModel? _parsed;
  ReceiptParsedDataModel? _receiptParsedData;
  AddExpenseSourceMode _sourceMode = AddExpenseSourceMode.smartText;

  DateTime _selectedDate = DateTime.now();

  ExpenseCategory? _selectedCategory;
  String? _selectedCustomCategoryId;

  bool _isVoiceLoading = false;
  bool _isVoiceListening = false;
  String _voicePreviewText = '';
  List<LocaleName> _availableLocales = const [];
  String? _selectedLocaleId;

  bool _isReceiptLoading = false;
  String _receiptPreviewText = '';
  XFile? _pickedReceiptFile;

  @override
  void initState() {
    super.initState();

    // Если передали Свою категорию
    if (widget.initialCustomCategoryId != null) {
      _selectedCategory = ExpenseCategory.custom;
      _selectedCustomCategoryId = widget.initialCustomCategoryId;

      _parsed = ParsedExpenseInputModel(
        amount: null,
        currency: 'KGS',
        category: ExpenseCategory.custom,
        merchant: null,
        rawText: '',
      );
    } else {
      // Если передали системную категорию (или ничего)
      _selectedCategory = widget.initialCategory;
      if (widget.initialCategory != null) {
        _parsed = ParsedExpenseInputModel(
          amount: null,
          currency: 'KGS',
          category: widget.initialCategory,
          merchant: null,
          rawText: '',
        );
      }
    }

    _initVoice();
  }

  Future<void> _initVoice() async {
    final result = await _voiceInputService.initialize();
    if (!mounted) return;

    if (result.isAvailable) {
      final locales = await _voiceInputService.locales();
      if (!mounted) return;

      setState(() {
        _availableLocales = locales;
        _selectedLocaleId = _pickPreferredLocale(locales);
      });
    }
  }

  String? _pickPreferredLocale(List<LocaleName> locales) {
    for (final locale in locales) {
      if (locale.localeId.toLowerCase().startsWith('ru')) return locale.localeId;
    }
    for (final locale in locales) {
      if (locale.localeId.toLowerCase().startsWith('en')) return locale.localeId;
    }
    return locales.isNotEmpty ? locales.first.localeId : null;
  }

  @override
  void dispose() {
    _smartInputController.dispose();
    _voiceInputService.cancelListening();
    _receiptScanService.dispose();
    super.dispose();
  }

  void _parseInput() {
    final parsed = _parser.parse(_smartInputController.text);
    setState(() {
      _parsed = ParsedExpenseInputModel(
        amount: parsed.amount,
        currency: parsed.currency,
        category: _selectedCategory ?? parsed.category ?? widget.initialCategory ?? ExpenseCategory.other,
        merchant: parsed.merchant,
        rawText: parsed.rawText,
      );
    });
  }

  void _parseVoiceText(String text) {
    final parsed = _parser.parse(text);
    setState(() {
      _voicePreviewText = text;
      _parsed = ParsedExpenseInputModel(
        amount: parsed.amount,
        currency: parsed.currency,
        category: _selectedCategory ?? parsed.category ?? widget.initialCategory ?? ExpenseCategory.other,
        merchant: parsed.merchant,
        rawText: text,
      );
    });
  }

  void _parseReceiptText(String text) {
    final parsedReceipt = _receiptParserService.parse(text);
    setState(() {
      _receiptPreviewText = text;
      _receiptParsedData = parsedReceipt;
      _parsed = ParsedExpenseInputModel(
        amount: parsedReceipt.amount,
        currency: parsedReceipt.currency,
        category: _selectedCategory ?? parsedReceipt.category ?? widget.initialCategory ?? ExpenseCategory.other,
        merchant: parsedReceipt.merchant,
        rawText: text.replaceAll('\n', ' '),
      );
    });
  }

  // Выбор системной категории
  void _selectSystemCategory(ExpenseCategory cat) {
    setState(() {
      _selectedCategory = cat;
      _selectedCustomCategoryId = null; // Сбрасываем кастомную
      if (_parsed != null) {
        _parsed = ParsedExpenseInputModel(
          amount: _parsed!.amount, currency: _parsed!.currency, category: cat, merchant: _parsed!.merchant, rawText: _parsed!.rawText,
        );
      } else {
        _parsed = ParsedExpenseInputModel(amount: null, currency: 'KGS', category: cat, merchant: null, rawText: '');
      }
    });
  }

  // Выбор кастомной категории
  void _selectCustomCategory(String id) {
    setState(() {
      _selectedCategory = ExpenseCategory.custom;
      _selectedCustomCategoryId = id;
      if (_parsed != null) {
        _parsed = ParsedExpenseInputModel(
          amount: _parsed!.amount, currency: _parsed!.currency, category: ExpenseCategory.custom, merchant: _parsed!.merchant, rawText: _parsed!.rawText,
        );
      } else {
        _parsed = ParsedExpenseInputModel(amount: null, currency: 'KGS', category: ExpenseCategory.custom, merchant: null, rawText: '');
      }
    });
  }

  void _showDatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 280,
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          top: false,
          child: CupertinoDatePicker(
            initialDateTime: _selectedDate,
            mode: CupertinoDatePickerMode.dateAndTime,
            use24hFormat: true,
            maximumDate: DateTime.now().add(const Duration(days: 1)),
            onDateTimeChanged: (val) => setState(() => _selectedDate = val),
          ),
        ),
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }

  Future<void> _handleVoiceTap(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    if (_isVoiceListening) {
      setState(() => _isVoiceLoading = true);
      final result = await _voiceInputService.stopListening();
      if (!mounted) return;
      setState(() {
        _isVoiceLoading = false;
        _isVoiceListening = false;
      });
      if (result.hasText) _parseVoiceText(result.recognizedText);
      else if (result.errorMessage != null) _showSnack(context, l10n.voiceErrorMessage(result.errorMessage!));
      return;
    }
    setState(() => _isVoiceLoading = true);
    final result = await _voiceInputService.startListening(localeId: _selectedLocaleId ?? '');
    if (!mounted) return;
    setState(() {
      _isVoiceLoading = false;
      _isVoiceListening = result.isAvailable;
    });
    if (!result.isAvailable) _showSnack(context, l10n.voiceUnavailableMessage);
  }

  Future<void> _scanPickedFile(BuildContext context, XFile file) async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _isReceiptLoading = true;
      _pickedReceiptFile = file;
    });
    final ReceiptScanResultModel result = await _receiptScanService.scanFile(file);
    if (!mounted) return;
    setState(() => _isReceiptLoading = false);

    if (!result.isSuccess) {
      _showSnack(context, l10n.receiptScanErrorMessage(result.errorMessage ?? l10n.notAvailableShort));
      return;
    }
    if (!result.hasText) {
      _showSnack(context, l10n.receiptNoTextFoundMessage);
      return;
    }

    _parseReceiptText(result.recognizedText);
    if (_receiptParsedData == null) return;

    final review = await Navigator.of(context).push<ReceiptReviewModel>(
      CupertinoPageRoute(builder: (_) => ReceiptReviewScreen(parsedData: _receiptParsedData!)),
    );

    if (!mounted || review == null) return;
    setState(() {
      _parsed = ParsedExpenseInputModel(
        amount: review.amount, currency: review.currency, category: review.category, merchant: review.merchant, rawText: review.rawText,
      );
      _receiptPreviewText = review.rawText;
    });
  }

  Future<void> _handleReceiptCameraTap(BuildContext context) async {
    final file = await _receiptScanService.pickFromCamera();
    if (file == null || !mounted) return;
    await _scanPickedFile(context, file);
  }

  Future<void> _handleReceiptGalleryTap(BuildContext context) async {
    final file = await _receiptScanService.pickFromGallery();
    if (file == null || !mounted) return;
    await _scanPickedFile(context, file);
  }

  Future<void> _saveExpense(BuildContext context) async {
    final parsed = _parsed;
    if (parsed == null || !parsed.isValid) return;

    final provider = context.read<HomeProvider>();
    await provider.addExpense(
      ExpenseModel(
        id: const Uuid().v4(),
        amount: parsed.amount!,
        currency: parsed.currency ?? 'KGS',
        category: _selectedCategory ?? parsed.category ?? ExpenseCategory.other,
        customCategoryId: _selectedCustomCategoryId, // Сохраняем ID своей категории!
        merchant: parsed.merchant ?? '',
        note: parsed.rawText.isEmpty ? null : parsed.rawText,
        date: _selectedDate,
        sourceType: _mapSourceModeToType(_sourceMode),
        isRecurring: false,
        recurringGroupId: null,
        createdAt: DateTime.now(),
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
    if (isToday) return 'Today, $time';
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}, $time';
  }

  String _categoryLabel(BuildContext context, ExpenseCategory category) {
    final l10n = AppLocalizations.of(context);
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

  bool get _canSave => _parsed != null && _parsed!.isValid;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.black : const Color(0xFFF2F2F7);

    final provider = context.watch<HomeProvider>();
    final customCategories = provider.customCategories;
    final systemCategories = ExpenseCategory.values.where((c) => c != ExpenseCategory.custom).toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CupertinoNavigationBar(
        backgroundColor: backgroundColor.withOpacity(0.8),
        middle: Text(l10n.addExpense, style: TextStyle(color: theme.colorScheme.onSurface)),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Text(l10n.cancelButton ?? 'Cancel', style: TextStyle(color: theme.colorScheme.primary)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _canSave ? () => _saveExpense(context) : null,
          child: Text(
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

            const SizedBox(height: 32),

            // 1. HERO AMOUNT AREA
            Column(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    _parsed?.amount != null ? _formatNumber(_parsed!.amount!) : '0',
                    key: ValueKey(_parsed?.amount),
                    style: TextStyle(
                      fontSize: 64, fontWeight: FontWeight.w800, letterSpacing: -2.5,
                      color: theme.colorScheme.onSurface, height: 1.1,
                    ),
                  ),
                ),
                Text(
                  _parsed?.currency ?? 'KGS',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                ),
              ],
            ),

            const SizedBox(height: 24),

            if (_sourceMode == AddExpenseSourceMode.smartText) _buildSmartTextSection(context),
            if (_sourceMode == AddExpenseSourceMode.voice) _buildVoiceSection(context),
            if (_sourceMode == AddExpenseSourceMode.receipt) _buildReceiptSection(context),

            const SizedBox(height: 32),

            // 3. ЕДИНАЯ КАРУСЕЛЬ КАТЕГОРИЙ (Системные + Кастомные + Кнопка New)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: Responsive.cardPadding(context)),
              child: Row(
                children: [
                  // СИСТЕМНЫЕ КАТЕГОРИИ
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
                            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isSelected ? Colors.transparent : theme.colorScheme.surfaceVariant),
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

                  // КАСТОМНЫЕ КАТЕГОРИИ ПОЛЬЗОВАТЕЛЯ
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
                            border: Border.all(color: isSelected ? Colors.transparent : theme.colorScheme.surfaceVariant),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                IconData(cat.iconCodePoint, fontFamily: 'CupertinoIcons', fontPackage: CupertinoIcons.iconFontPackage),
                                size: 16,
                                color: isSelected ? Colors.white : catColor,
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

                  // КНОПКА СОЗДАНИЯ НОВОЙ КАТЕГОРИИ
                  GestureDetector(
                    onTap: () async {
                      final newCat = await CustomCategorySheet.show(context);
                      if (newCat != null) {
                        _selectCustomCategory(newCat.id);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.15),
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

            // 4. СВОЙСТВА ТРАНЗАКЦИИ
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
                      title: 'Date',
                      value: _formatDate(_selectedDate),
                      onTap: _showDatePicker,
                    ),
                    _SettingsRow(
                      icon: CupertinoIcons.building_2_fill,
                      iconColor: CupertinoColors.systemBlue,
                      title: l10n.previewMerchant,
                      value: _parsed?.merchant?.isNotEmpty == true ? _parsed!.merchant! : 'Optional',
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

  Widget _buildSmartTextSection(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.cardPadding(context)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Theme.of(context).colorScheme.surfaceVariant),
        ),
        child: TextField(
          controller: _smartInputController,
          autofocus: true,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: widget.initialCategory == null ? l10n.smartInputExample : '500 for taxi',
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
          ),
          onChanged: (_) => _parseInput(),
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
                        color: (_isVoiceListening ? CupertinoColors.destructiveRed : Theme.of(context).colorScheme.primary).withOpacity(0.4),
                        blurRadius: 30, spreadRadius: _isVoiceListening ? 10 : 0,
                      )
                    ]
                ),
                child: Icon(
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
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
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
                  label: 'Camera',
                  onTap: _isReceiptLoading ? null : () => _handleReceiptCameraTap(context),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ReceiptButton(
                  icon: CupertinoIcons.photo_fill_on_rectangle_fill,
                  label: 'Gallery',
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

// Вспомогательный виджет для свойств транзакции (Apple List)
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
                      style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))
                  ),
                  const SizedBox(width: 8),
                  Icon(CupertinoIcons.chevron_forward, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3), size: 18),
                ],
              ),
            ),
            if (!isLast) Padding(
              padding: const EdgeInsets.only(left: 56),
              child: Divider(height: 1, color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5)),
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