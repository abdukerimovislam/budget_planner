import 'package:flutter/material.dart';
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
import '../premium/premium_screen.dart';
import '../receipt_review/receipt_review_screen.dart';

class AddExpenseScreen extends StatefulWidget {
  final ExpenseCategory? initialCategory;

  const AddExpenseScreen({
    super.key,
    this.initialCategory,
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

    if (widget.initialCategory != null) {
      _parsed = ParsedExpenseInputModel(
        amount: null,
        currency: 'KGS',
        category: widget.initialCategory,
        merchant: null,
        rawText: '',
      );
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
      if (locale.localeId.toLowerCase().startsWith('ru')) {
        return locale.localeId;
      }
    }
    for (final locale in locales) {
      if (locale.localeId.toLowerCase().startsWith('en')) {
        return locale.localeId;
      }
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
        category:
        parsed.category ?? widget.initialCategory ?? ExpenseCategory.other,
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
        category:
        parsed.category ?? widget.initialCategory ?? ExpenseCategory.other,
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
        category:
        parsedReceipt.category ?? widget.initialCategory ?? ExpenseCategory.other,
        merchant: parsedReceipt.merchant,
        rawText: text.replaceAll('\n', ' '),
      );
    });
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _handleVoiceTap(BuildContext context) async {
    final l10n = AppLocalizations.of(context);

    if (_isVoiceListening) {
      setState(() {
        _isVoiceLoading = true;
      });

      final result = await _voiceInputService.stopListening();

      if (!mounted) return;

      setState(() {
        _isVoiceLoading = false;
        _isVoiceListening = false;
      });

      if (result.hasText) {
        _parseVoiceText(result.recognizedText);
      } else if (result.errorMessage != null) {
        _showSnack(context, l10n.voiceErrorMessage(result.errorMessage!));
      }

      return;
    }

    setState(() {
      _isVoiceLoading = true;
    });

    final result = await _voiceInputService.startListening(
      localeId: _selectedLocaleId ?? '',
    );

    if (!mounted) return;

    setState(() {
      _isVoiceLoading = false;
      _isVoiceListening = result.isAvailable;
    });

    if (!result.isAvailable) {
      _showSnack(
        context,
        l10n.voiceUnavailableMessage,
      );
    }
  }

  Future<void> _scanPickedFile(BuildContext context, XFile file) async {
    final l10n = AppLocalizations.of(context);

    setState(() {
      _isReceiptLoading = true;
      _pickedReceiptFile = file;
    });

    final ReceiptScanResultModel result = await _receiptScanService.scanFile(file);

    if (!mounted) return;

    setState(() {
      _isReceiptLoading = false;
    });

    if (!result.isSuccess) {
      _showSnack(
        context,
        l10n.receiptScanErrorMessage(
          result.errorMessage ?? l10n.notAvailableShort,
        ),
      );
      return;
    }

    if (!result.hasText) {
      _showSnack(context, l10n.receiptNoTextFoundMessage);
      return;
    }

    _parseReceiptText(result.recognizedText);

    if (_receiptParsedData == null) return;

    final review = await Navigator.of(context).push<ReceiptReviewModel>(
      MaterialPageRoute(
        builder: (_) => ReceiptReviewScreen(parsedData: _receiptParsedData!),
      ),
    );

    if (!mounted || review == null) return;

    setState(() {
      _parsed = ParsedExpenseInputModel(
        amount: review.amount,
        currency: review.currency,
        category: review.category,
        merchant: review.merchant,
        rawText: review.rawText,
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
        category: parsed.category ?? ExpenseCategory.other,
        merchant: parsed.merchant ?? '',
        note: parsed.rawText.isEmpty ? null : parsed.rawText,
        date: DateTime.now(),
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
      case AddExpenseSourceMode.smartText:
        return ExpenseSourceType.smartText;
      case AddExpenseSourceMode.voice:
        return ExpenseSourceType.voice;
      case AddExpenseSourceMode.receipt:
        return ExpenseSourceType.receipt;
    }
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

  Widget _buildParsedPreview(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final parsed = _parsed;

    if (parsed == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(Responsive.cardPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PreviewRow(
              label: l10n.previewAmount,
              value: parsed.amount?.toString() ?? l10n.notAvailableShort,
            ),
            const SizedBox(height: 8),
            _PreviewRow(
              label: l10n.previewCurrency,
              value: parsed.currency ?? l10n.notAvailableShort,
            ),
            const SizedBox(height: 8),
            _PreviewRow(
              label: l10n.previewCategory,
              value: parsed.category == null
                  ? l10n.notAvailableShort
                  : _categoryLabel(context, parsed.category!),
            ),
            const SizedBox(height: 8),
            _PreviewRow(
              label: l10n.previewMerchant,
              value: parsed.merchant?.isNotEmpty == true
                  ? parsed.merchant!
                  : l10n.notAvailableShort,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartTextSection(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.smartInputHint,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        SizedBox(height: Responsive.itemGap(context)),
        TextField(
          controller: _smartInputController,
          decoration: InputDecoration(
            hintText: widget.initialCategory == null
                ? l10n.smartInputExample
                : l10n.smartInputExampleWithCategory(
              _categoryLabel(context, widget.initialCategory!),
            ),
          ),
          onChanged: (_) => _parseInput(),
        ),
        SizedBox(height: Responsive.sectionGap(context)),
        _buildParsedPreview(context),
      ],
    );
  }

  Widget _buildVoiceSection(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: EdgeInsets.all(Responsive.cardPadding(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.voiceInputTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.voiceInputSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (_availableLocales.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedLocaleId,
                    items: _availableLocales
                        .map(
                          (locale) => DropdownMenuItem<String>(
                        value: locale.localeId,
                        child: Text(locale.name),
                      ),
                    )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLocaleId = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: l10n.voiceLanguageLabel,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed:
                  _isVoiceLoading ? null : () => _handleVoiceTap(context),
                  icon: Icon(
                    _isVoiceListening ? Icons.stop_rounded : Icons.mic_rounded,
                  ),
                  label: Text(
                    _isVoiceListening
                        ? l10n.stopVoiceInputButton
                        : l10n.startVoiceInputButton,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_voicePreviewText.trim().isNotEmpty) ...[
          SizedBox(height: Responsive.sectionGap(context)),
          Card(
            child: Padding(
              padding: EdgeInsets.all(Responsive.cardPadding(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.voiceRecognizedTextTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _voicePreviewText,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: Responsive.sectionGap(context)),
          _buildParsedPreview(context),
        ],
      ],
    );
  }

  Widget _buildReceiptSection(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: EdgeInsets.all(Responsive.cardPadding(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.receiptScanTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.receiptScanSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: _isReceiptLoading
                          ? null
                          : () => _handleReceiptCameraTap(context),
                      icon: const Icon(Icons.camera_alt_rounded),
                      label: Text(l10n.scanReceiptButton),
                    ),
                    OutlinedButton.icon(
                      onPressed: _isReceiptLoading
                          ? null
                          : () => _handleReceiptGalleryTap(context),
                      icon: const Icon(Icons.photo_library_rounded),
                      label: Text(l10n.pickReceiptFromGalleryButton),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (_isReceiptLoading) ...[
          SizedBox(height: Responsive.sectionGap(context)),
          const Center(
            child: CircularProgressIndicator(),
          ),
        ],
        if (_pickedReceiptFile != null && !_isReceiptLoading) ...[
          SizedBox(height: Responsive.sectionGap(context)),
          Card(
            child: Padding(
              padding: EdgeInsets.all(Responsive.cardPadding(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.receiptRecognizedTextTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _receiptPreviewText.isEmpty
                        ? l10n.notAvailableShort
                        : _receiptPreviewText,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          if (_receiptParsedData != null) ...[
            SizedBox(height: Responsive.itemGap(context)),
            Card(
              child: Padding(
                padding: EdgeInsets.all(Responsive.cardPadding(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.receiptParsedSummaryTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.receiptConfidenceLabel(
                        (_receiptParsedData!.confidence * 100)
                            .toStringAsFixed(0),
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
          SizedBox(height: Responsive.sectionGap(context)),
          _buildParsedPreview(context),
        ],
      ],
    );
  }

  bool get _canSave => _parsed != null && _parsed!.isValid;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addExpense),
      ),
      body: AdaptivePagePadding(
        addBottomSafeArea: true,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            AddExpenseSourceSelector(
              value: _sourceMode,
              onChanged: (mode) {
                if (mode == AddExpenseSourceMode.voice &&
                    !context
                        .read<HomeProvider>()
                        .canUseFeature(PremiumFeature.voiceInput)) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PremiumScreen(),
                    ),
                  );
                  return;
                }

                if (mode == AddExpenseSourceMode.receipt &&
                    !context
                        .read<HomeProvider>()
                        .canUseFeature(PremiumFeature.receiptOcr)) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PremiumScreen(),
                    ),
                  );
                  return;
                }

                setState(() {
                  _sourceMode = mode;
                });
              },
            ),
            SizedBox(height: Responsive.sectionGap(context)),
            if (_sourceMode == AddExpenseSourceMode.smartText)
              _buildSmartTextSection(context),
            if (_sourceMode == AddExpenseSourceMode.voice)
              _buildVoiceSection(context),
            if (_sourceMode == AddExpenseSourceMode.receipt)
              _buildReceiptSection(context),
            SizedBox(height: Responsive.sectionGap(context)),
            FilledButton(
              onPressed: _canSave ? () => _saveExpense(context) : null,
              child: Text(l10n.saveExpenseButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _PreviewRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyMedium,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}