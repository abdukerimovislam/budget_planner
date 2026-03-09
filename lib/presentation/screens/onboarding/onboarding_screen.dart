import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/app_state.dart';
import '../../../core/localization/locale_controller.dart';
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

  final TextEditingController _incomeController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _workDaysController =
  TextEditingController(text: '22');
  final TextEditingController _workHoursController =
  TextEditingController(text: '8');

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
  }

  @override
  void dispose() {
    _incomeController.removeListener(_onFieldsChanged);
    _budgetController.removeListener(_onFieldsChanged);
    _workDaysController.removeListener(_onFieldsChanged);
    _workHoursController.removeListener(_onFieldsChanged);

    _pageController.dispose();
    _incomeController.dispose();
    _budgetController.dispose();
    _workDaysController.dispose();
    _workHoursController.dispose();
    super.dispose();
  }

  void _onFieldsChanged() {
    if (!mounted) return;
    setState(() {});
  }

  double? _parseDouble(String value) {
    return double.tryParse(value.trim().replaceAll(',', '.'));
  }

  int? _parseInt(String value) {
    return int.tryParse(value.trim());
  }

  bool get _isWelcomeStep => _pageIndex == 0;
  bool get _isMoneyStep => _pageIndex == 1;
  bool get _isLifeStep => _pageIndex == 2;

  bool get _isMoneyStepValid {
    final income = _parseDouble(_incomeController.text);
    final budget = _parseDouble(_budgetController.text);

    return income != null && income > 0 && budget != null && budget > 0;
  }

  bool get _isLifeStepValid {
    final workDays = _parseInt(_workDaysController.text);
    final workHours = _parseDouble(_workHoursController.text);

    return workDays != null &&
        workDays > 0 &&
        workHours != null &&
        workHours > 0;
  }

  String? _incomeError(AppLocalizations l10n) {
    if (!_showValidation || !_isMoneyStep) return null;
    final income = _parseDouble(_incomeController.text);
    if (income == null || income <= 0) {
      return l10n.validationEnterPositiveIncome;
    }
    return null;
  }

  String? _budgetError(AppLocalizations l10n) {
    if (!_showValidation || !_isMoneyStep) return null;
    final budget = _parseDouble(_budgetController.text);
    if (budget == null || budget <= 0) {
      return l10n.validationEnterPositiveBudget;
    }
    return null;
  }

  String? _workDaysError(AppLocalizations l10n) {
    if (!_showValidation || !_isLifeStep) return null;
    final workDays = _parseInt(_workDaysController.text);
    if (workDays == null || workDays <= 0) {
      return l10n.validationEnterPositiveWorkDays;
    }
    return null;
  }

  String? _workHoursError(AppLocalizations l10n) {
    if (!_showValidation || !_isLifeStep) return null;
    final workHours = _parseDouble(_workHoursController.text);
    if (workHours == null || workHours <= 0) {
      return l10n.validationEnterPositiveWorkHours;
    }
    return null;
  }

  Future<void> _goToStep(int index) async {
    await _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 260),
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
    final income = _parseDouble(_incomeController.text);
    final budget = _parseDouble(_budgetController.text);
    final workDays = _parseInt(_workDaysController.text);
    final workHours = _parseDouble(_workHoursController.text);

    if (income == null ||
        income <= 0 ||
        budget == null ||
        budget <= 0 ||
        workDays == null ||
        workDays <= 0 ||
        workHours == null ||
        workHours <= 0) {
      setState(() {
        _showValidation = true;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final provider = context.read<HomeProvider>();
    final now = DateTime.now();

    try {
      await provider.setIncomeProfile(
        IncomeProfileModel(
          monthlyIncome: income,
          workingDaysPerMonth: workDays,
          workingHoursPerDay: workHours,
        ),
      );

      await provider.setBudget(
        BudgetModel(
          monthKey: '${now.year}-${now.month.toString().padLeft(2, '0')}',
          totalBudget: budget,
          categoryBudgets: const {},
        ),
      );

      await context.read<AppState>().completeOnboarding();
    } finally {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _handlePrimaryAction(BuildContext context) async {
    if (_isSubmitting) return;

    if (_isWelcomeStep) {
      setState(() {
        _showValidation = false;
      });
      await _nextStep();
      return;
    }

    if (_isMoneyStep) {
      if (!_isMoneyStepValid) {
        setState(() {
          _showValidation = true;
        });
        return;
      }

      setState(() {
        _showValidation = false;
      });
      await _nextStep();
      return;
    }

    if (_isLifeStep) {
      if (!_isLifeStepValid) {
        setState(() {
          _showValidation = true;
        });
        return;
      }

      await _completeOnboarding(context);
    }
  }

  String _primaryButtonLabel(AppLocalizations l10n) {
    if (_isLifeStep) return l10n.finishButton;
    return l10n.continueButton;
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
                  Expanded(
                    child: Text(
                      l10n.onboardingStepCounter(
                        _pageIndex + 1,
                        _totalSteps,
                      ),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  TextButton(
                    onPressed: _pageIndex == 0 || _isSubmitting
                        ? null
                        : _previousStep,
                    child: Text(l10n.backButton),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: _StepProgress(
                currentStep: _pageIndex,
                totalSteps: _totalSteps,
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _pageIndex = index;
                    _showValidation = false;
                  });
                },
                children: [
                  const _WelcomeStep(),
                  _FormStep(
                    title: l10n.onboardingMoneyTitle,
                    subtitle: l10n.onboardingMoneySubtitle,
                    child: Column(
                      children: [
                        TextField(
                          controller: _incomeController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: l10n.monthlyIncomeLabel,
                            errorText: _incomeError(l10n),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _budgetController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: l10n.monthlyBudgetLabel,
                            errorText: _budgetError(l10n),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _FormStep(
                    title: l10n.onboardingLifeTitle,
                    subtitle: l10n.onboardingLifeSubtitle,
                    child: Column(
                      children: [
                        TextField(
                          controller: _workDaysController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: l10n.workDaysPerMonthLabel,
                            errorText: _workDaysError(l10n),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _workHoursController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: l10n.workHoursPerDayLabel,
                            errorText: _workHoursError(l10n),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                8,
                20,
                MediaQuery.of(context).padding.bottom > 0 ? 16 : 24,
              ),
              child: Row(
                children: [
                  if (_pageIndex > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting ? null : _previousStep,
                        child: Text(l10n.backButton),
                      ),
                    ),
                  if (_pageIndex > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: () => _handlePrimaryAction(context),
                      child: _isSubmitting
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : Text(_primaryButtonLabel(l10n)),
                    ),
                  ),
                ],
              ),
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
          Text(
            l10n.onboardingWelcomeTitle,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.onboardingWelcomeSubtitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          _FeatureCard(
            icon: Icons.bolt_rounded,
            title: l10n.onboardingFeatureFastTitle,
            subtitle: l10n.onboardingFeatureFastSubtitle,
          ),
          const SizedBox(height: 12),
          _FeatureCard(
            icon: Icons.insights_rounded,
            title: l10n.onboardingFeatureForecastTitle,
            subtitle: l10n.onboardingFeatureForecastSubtitle,
          ),
          const SizedBox(height: 12),
          _FeatureCard(
            icon: Icons.hourglass_bottom_rounded,
            title: l10n.onboardingFeatureLifeTitle,
            subtitle: l10n.onboardingFeatureLifeSubtitle,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.language,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _LanguageButton(
                  label: l10n.english,
                  isSelected: currentCode == 'en',
                  onTap: () {
                    context
                        .read<LocaleController>()
                        .setLocale(const Locale('en'));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _LanguageButton(
                  label: l10n.russian,
                  isSelected: currentCode == 'ru',
                  onTap: () {
                    context
                        .read<LocaleController>()
                        .setLocale(const Locale('ru'));
                  },
                ),
              ),
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

  const _FormStep({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return _AdaptiveStepLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textTheme.headlineMedium),
          const SizedBox(height: 12),
          Text(subtitle, style: textTheme.bodyMedium),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}

class _AdaptiveStepLayout extends StatelessWidget {
  final Widget child;

  const _AdaptiveStepLayout({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Align(
              alignment: Alignment.topLeft,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class _StepProgress extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _StepProgress({
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: List.generate(totalSteps, (index) {
        final isActive = index <= currentStep;

        return Expanded(
          child: Container(
            height: 6,
            margin: EdgeInsets.only(right: index == totalSteps - 1 ? 0 : 8),
            decoration: BoxDecoration(
              color: isActive
                  ? colorScheme.primary
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(999),
            ),
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

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outlineVariant,
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Text(label),
    );
  }
}