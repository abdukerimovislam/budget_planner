import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../app/app_state.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/utils/month_key.dart';
import '../../../data/models/budget_model.dart';
import '../../../data/models/income_profile_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/home_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const int _totalSteps = 3;
  final PageController _pageController = PageController();

  // Step 1: Money
  final TextEditingController _incomeController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();

  // НОВОЕ ПОЛЕ: Выбранная валюта
  String _selectedCurrency = 'USD';
  final List<String> _availableCurrencies = ['USD', 'EUR', 'GBP', 'RUB', 'KZT', 'KGS', 'UZS', 'UAH', 'BYN'];

  // Step 2: Life (Archetype)
  IncomeType _selectedType = IncomeType.salary;
  final TextEditingController _workDaysController = TextEditingController(text: '20');
  final TextEditingController _workHoursController = TextEditingController(text: '8');
  final TextEditingController _hourlyRateController = TextEditingController();
  final TextEditingController _hoursPerWeekController = TextEditingController(text: '40');

  int _pageIndex = 0;
  bool _isSubmitting = false;
  bool _showValidation = false;

  @override
  void initState() {
    super.initState();
    _incomeController.addListener(_onFieldsChanged);
    _budgetController.addListener(_onFieldsChanged);
    _workDaysController.addListener(_onFieldsChanged);
    _workHoursController.addListener(_onFieldsChanged);
    _hourlyRateController.addListener(_onFieldsChanged);
    _hoursPerWeekController.addListener(_onFieldsChanged);
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _budgetController.dispose();
    _workDaysController.dispose();
    _workHoursController.dispose();
    _hourlyRateController.dispose();
    _hoursPerWeekController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onFieldsChanged() {
    if (!mounted) return;
    setState(() {});
  }

  String _t(String en, String ru) {
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    return isRu ? ru : en;
  }

  double? _parseDouble(String value) => double.tryParse(value.trim().replaceAll(',', '.'));
  int? _parseInt(String value) => int.tryParse(value.trim());

  bool get _isWelcomeStep => _pageIndex == 0;
  bool get _isMoneyStep => _pageIndex == 1;
  bool get _isLifeStep => _pageIndex == 2;

  bool get _isMoneyStepValid {
    final income = _parseDouble(_incomeController.text);
    final budget = _parseDouble(_budgetController.text);
    return income != null && income > 0 && budget != null && budget > 0;
  }

  bool get _isLifeStepValid {
    switch (_selectedType) {
      case IncomeType.salary:
        final d = _parseInt(_workDaysController.text);
        final h = _parseInt(_workHoursController.text);
        return d != null && d > 0 && d <= 31 && h != null && h > 0 && h <= 24;
      case IncomeType.freelance:
        final r = _parseDouble(_hourlyRateController.text);
        return r != null && r > 0;
      case IncomeType.business:
        final hw = _parseInt(_hoursPerWeekController.text);
        return hw != null && hw > 0 && hw <= 168;
      default:
        return false;
    }
  }

  void _selectArchetype(IncomeType type) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedType = type;
      _showValidation = false;
    });
  }

  // НОВЫЙ МЕТОД: Показ барабана выбора валюты
  void _showCurrencyPicker() {
    HapticFeedback.lightImpact();
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          top: false,
          child: CupertinoPicker(
            itemExtent: 40,
            scrollController: FixedExtentScrollController(
              initialItem: _availableCurrencies.indexOf(_selectedCurrency),
            ),
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

  Future<void> _goToStep(int index) async {
    await _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _nextStep() async {
    if (_pageIndex >= _totalSteps - 1) return;
    await _goToStep(_pageIndex + 1);
  }

  Future<void> _previousStep() async {
    if (_pageIndex <= 0) return;
    await _goToStep(_pageIndex - 1);
  }

  Future<void> _completeOnboarding(BuildContext context) async {
    final income = _parseDouble(_incomeController.text) ?? 0;
    final budget = _parseDouble(_budgetController.text) ?? 0;

    setState(() => _isSubmitting = true);

    final provider = context.read<HomeProvider>();
    final now = DateTime.now();

    try {
      final profile = IncomeProfileModel(
        expectedMonthlyIncome: income,
        incomeType: _selectedType,
        workingDaysPerMonth: _selectedType == IncomeType.salary ? _parseInt(_workDaysController.text) : null,
        workingHoursPerDay: _selectedType == IncomeType.salary ? _parseInt(_workHoursController.text) : null,
        hourlyRate: _selectedType == IncomeType.freelance ? _parseDouble(_hourlyRateController.text) : null,
        workingHoursPerWeek: _selectedType == IncomeType.business ? _parseInt(_hoursPerWeekController.text) : null,
        currency: _selectedCurrency, // <-- СОХРАНЯЕМ ВЫБРАННУЮ ВАЛЮТУ!
      );

      await provider.setIncomeProfile(profile);

      await provider.setBudget(
        BudgetModel(
          monthKey: buildMonthKey(now),
          totalBudget: budget,
          currency: _selectedCurrency, // <-- ИСПРАВЛЕНИЕ: Передали валюту в бюджет!
          categoryBudgets: const {},
        ),
      );

      await context.read<AppState>().completeOnboarding();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handlePrimaryAction(BuildContext context) async {
    HapticFeedback.lightImpact();

    if (_isSubmitting) return;

    if (_isWelcomeStep) {
      setState(() => _showValidation = false);
      await _nextStep();
      return;
    }

    if (_isMoneyStep) {
      if (!_isMoneyStepValid) {
        setState(() => _showValidation = true);
        HapticFeedback.vibrate();
        return;
      }
      setState(() => _showValidation = false);
      await _nextStep();
      return;
    }

    if (_isLifeStep) {
      if (!_isLifeStepValid) {
        setState(() => _showValidation = true);
        HapticFeedback.vibrate();
        return;
      }
      await _completeOnboarding(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Expanded(child: Text(l10n.onboardingStepCounter(_pageIndex + 1, _totalSteps), style: theme.textTheme.bodyMedium)),
                  TextButton(onPressed: _pageIndex == 0 || _isSubmitting ? null : _previousStep, child: Text(l10n.backButton)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: _StepProgress(currentStep: _pageIndex, totalSteps: _totalSteps),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() { _pageIndex = index; _showValidation = false; }),
                children: [
                  const _WelcomeStep(),

                  // MONEY STEP
                  _FormStep(
                    title: l10n.onboardingMoneyTitle,
                    subtitle: l10n.onboardingMoneySubtitle,
                    child: Column(
                      children: [
                        // ВИДЖЕТ ВЫБОРА ВАЛЮТЫ
                        GestureDetector(
                          onTap: _showCurrencyPicker,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(CupertinoIcons.money_dollar_circle, color: theme.colorScheme.primary),
                                const SizedBox(width: 12),
                                Text(_t('Currency', 'Валюта'), style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w600)),
                                const Spacer(),
                                Text(_selectedCurrency, style: TextStyle(color: theme.colorScheme.primary, fontSize: 18, fontWeight: FontWeight.w800)),
                                const SizedBox(width: 8),
                                Icon(CupertinoIcons.chevron_up_chevron_down, size: 16, color: theme.colorScheme.primary),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        _CustomTextField(
                          controller: _incomeController,
                          label: l10n.monthlyIncomeLabel,
                          icon: CupertinoIcons.money_dollar_circle_fill,
                          isError: _showValidation && _parseDouble(_incomeController.text) == null,
                        ),
                        const SizedBox(height: 16),
                        _CustomTextField(
                          controller: _budgetController,
                          label: l10n.monthlyBudgetLabel,
                          icon: CupertinoIcons.chart_pie_fill,
                          isError: _showValidation && _parseDouble(_budgetController.text) == null,
                        ),
                      ],
                    ),
                  ),

                  // LIFE & WORK ARCHETYPE STEP
                  _FormStep(
                    title: l10n.onboardingLifeTitle,
                    subtitle: _t('Choose your lifestyle to calculate the real value of your time.', 'Выберите стиль жизни, чтобы узнать реальную стоимость вашего времени.'),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _ArchetypeCard(title: _t('Office', 'Офис'), icon: CupertinoIcons.building_2_fill, isSelected: _selectedType == IncomeType.salary, onTap: () => _selectArchetype(IncomeType.salary))),
                            const SizedBox(width: 8),
                            Expanded(child: _ArchetypeCard(title: _t('Freelance', 'Фриланс'), icon: CupertinoIcons.device_laptop, isSelected: _selectedType == IncomeType.freelance, onTap: () => _selectArchetype(IncomeType.freelance))),
                            const SizedBox(width: 8),
                            Expanded(child: _ArchetypeCard(title: _t('Business', 'Бизнес'), icon: CupertinoIcons.briefcase_fill, isSelected: _selectedType == IncomeType.business, onTap: () => _selectArchetype(IncomeType.business))),
                          ],
                        ),
                        const SizedBox(height: 32),

                        if (_selectedType == IncomeType.salary) ...[
                          _CustomTextField(controller: _workDaysController, label: l10n.workDaysPerMonthLabel, icon: CupertinoIcons.calendar, isError: _showValidation && _parseInt(_workDaysController.text) == null),
                          const SizedBox(height: 16),
                          _CustomTextField(controller: _workHoursController, label: l10n.workHoursPerDayLabel, icon: CupertinoIcons.clock_fill, isError: _showValidation && _parseInt(_workHoursController.text) == null),
                        ] else if (_selectedType == IncomeType.freelance) ...[
                          _CustomTextField(controller: _hourlyRateController, label: _t('Hourly Rate (e.g. 50)', 'Ставка в час (напр. 500)'), icon: CupertinoIcons.money_dollar, isError: _showValidation && _parseDouble(_hourlyRateController.text) == null),
                        ] else if (_selectedType == IncomeType.business) ...[
                          _CustomTextField(controller: _hoursPerWeekController, label: _t('Hours spent per week', 'Часов работы в неделю'), icon: CupertinoIcons.time, isError: _showValidation && _parseInt(_hoursPerWeekController.text) == null),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(context).padding.bottom > 0 ? 16 : 24),
              child: FilledButton(
                onPressed: () => _handlePrimaryAction(context),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isSubmitting
                    ? const CupertinoActivityIndicator(color: Colors.white)
                    : Text(_isLifeStep ? l10n.finishButton : l10n.continueButton, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isError;

  const _CustomTextField({required this.controller, required this.label, required this.icon, this.isError = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isError ? CupertinoColors.systemRed : theme.colorScheme.surfaceVariant, width: isError ? 2 : 1),
      ),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: theme.colorScheme.primary),
          labelText: label,
          labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}

class _ArchetypeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ArchetypeCard({required this.title, required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surfaceVariant),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.5), size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: isSelected ? Colors.white : theme.colorScheme.onSurface
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeController = context.watch<LocaleController>();
    final currentCode = localeController.locale?.languageCode;

    return _AdaptiveStepLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.onboardingWelcomeTitle, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Text(l10n.onboardingWelcomeSubtitle, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 32),
          _FeatureCard(icon: CupertinoIcons.bolt_fill, title: l10n.onboardingFeatureFastTitle, subtitle: l10n.onboardingFeatureFastSubtitle),
          const SizedBox(height: 16),
          _FeatureCard(icon: CupertinoIcons.chart_pie_fill, title: l10n.onboardingFeatureForecastTitle, subtitle: l10n.onboardingFeatureForecastSubtitle),
          const SizedBox(height: 16),
          _FeatureCard(icon: CupertinoIcons.clock_fill, title: l10n.onboardingFeatureLifeTitle, subtitle: l10n.onboardingFeatureLifeSubtitle),
          const SizedBox(height: 32),
          Text(l10n.language, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _LanguageButton(label: l10n.english, isSelected: currentCode == 'en', onTap: () { HapticFeedback.selectionClick(); context.read<LocaleController>().setLocale(const Locale('en')); })),
              const SizedBox(width: 12),
              Expanded(child: _LanguageButton(label: l10n.russian, isSelected: currentCode == 'ru', onTap: () { HapticFeedback.selectionClick(); context.read<LocaleController>().setLocale(const Locale('ru')); })),
            ],
          ),
        ],
      ),
    );
  }
}

class _FormStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _FormStep({required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return _AdaptiveStepLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 32),
          child,
        ],
      ),
    );
  }
}

class _AdaptiveStepLayout extends StatelessWidget {
  final Widget child;
  const _AdaptiveStepLayout({required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(constraints: BoxConstraints(minHeight: constraints.maxHeight), child: Align(alignment: Alignment.topLeft, child: child)),
        );
      },
    );
  }
}

class _StepProgress extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _StepProgress({required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: List.generate(totalSteps, (index) {
        final isActive = index <= currentStep;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 6,
            margin: EdgeInsets.only(right: index == totalSteps - 1 ? 0 : 8),
            decoration: BoxDecoration(color: isActive ? colorScheme.primary : colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(999)),
          ),
        );
      }),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureCard({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: colorScheme.primary.withOpacity(0.15), shape: BoxShape.circle), child: Icon(icon, color: colorScheme.primary)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.6))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageButton({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? colorScheme.primary.withOpacity(0.1) : null,
        side: BorderSide(color: isSelected ? colorScheme.primary : colorScheme.outlineVariant, width: isSelected ? 2 : 1),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label, style: TextStyle(color: isSelected ? colorScheme.primary : colorScheme.onSurface, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
    );
  }
}