import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/responsive.dart';
import '../../../data/models/recurring_bill_model.dart';
import '../../../domain/services/premium_feature.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/home_provider.dart';
import '../../widgets/adaptive_page_padding.dart';
import '../../widgets/cashflow_event_card.dart';
import '../../widgets/premium_lock_card.dart';
import '../../widgets/premium_background.dart'; // <-- ИМПОРТ ФОНА
import '../premium/premium_screen.dart';

class CashflowScreen extends StatelessWidget {
  const CashflowScreen({super.key});

  Future<void> _showSalaryDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();

    await showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: Text(l10n.salaryDayTitle),
          content: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: CupertinoTextField(
              controller: controller,
              keyboardType: TextInputType.number,
              placeholder: '1-31',
              autofocus: true,
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(),
              isDestructiveAction: true,
              child: Text(l10n.cancelButton),
            ),
            CupertinoDialogAction(
              onPressed: () async {
                final value = int.tryParse(controller.text.trim());
                if (value == null || value < 1 || value > 31) return;

                await context.read<HomeProvider>().setSalaryDay(value);
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              },
              isDefaultAction: true,
              child: Text(l10n.saveButton),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showRecurringBillDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final dayController = TextEditingController();

    await showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: Text(l10n.recurringBillCreateTitle),
          content: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CupertinoTextField(
                  controller: titleController,
                  placeholder: l10n.recurringBillTitleLabel,
                ),
                const SizedBox(height: 8),
                CupertinoTextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  placeholder: l10n.recurringBillAmountLabel,
                ),
                const SizedBox(height: 8),
                CupertinoTextField(
                  controller: dayController,
                  keyboardType: TextInputType.number,
                  placeholder: 'Day (1-31)',
                ),
              ],
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(),
              isDestructiveAction: true,
              child: Text(l10n.cancelButton),
            ),
            CupertinoDialogAction(
              onPressed: () async {
                final title = titleController.text.trim();
                final amount = double.tryParse(amountController.text.trim().replaceAll(',', '.'));
                final day = int.tryParse(dayController.text.trim());

                if (title.isEmpty || amount == null || amount <= 0 || day == null || day < 1 || day > 31) return;

                await context.read<HomeProvider>().addRecurringBill(
                  RecurringBillModel(
                    id: const Uuid().v4(),
                    title: title,
                    amount: amount,
                    currency: 'KGS',
                    dayOfMonth: day,
                    isActive: true,
                    createdAt: DateTime.now(),
                  ),
                );

                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              },
              isDefaultAction: true,
              child: Text(l10n.saveButton),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final now = DateTime.now();

    final timeline = provider.cashflowTimeline(now);
    final salaryDay = provider.salaryDay;
    final recurringBills = provider.recurringBills;

    if (!provider.canUseFeature(PremiumFeature.cashflowTimeline)) {
      return PremiumBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            title: Text(l10n.cashflowTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          body: AdaptivePagePadding(
            addBottomSafeArea: false,
            child: ListView(
              children: [
                PremiumLockCard(
                  title: l10n.premiumLockedCashflowTitle,
                  subtitle: l10n.premiumLockedCashflowSubtitle,
                  onTap: () => Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const PremiumScreen())),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return PremiumBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverAppBar.large(
              stretch: true,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              title: Text(
                l10n.cashflowTitle,
                style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5),
              ),
            ),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.cardPadding(context)),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),

                  // 1. БЛОК НАСТРОЕК (APPLE STYLE)
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: theme.colorScheme.surfaceVariant.withOpacity(0.5)),
                    ),
                    child: Column(
                      children: [
                        _SettingsRow(
                          icon: CupertinoIcons.money_dollar_circle_fill,
                          iconColor: CupertinoColors.systemGreen,
                          title: 'Salary Day',
                          value: salaryDay != null ? 'Day $salaryDay' : 'Not set',
                          onTap: () => _showSalaryDialog(context),
                        ),
                        _SettingsRow(
                          icon: CupertinoIcons.arrow_2_squarepath,
                          iconColor: CupertinoColors.activeBlue,
                          title: 'Recurring Bills',
                          value: '${recurringBills.length} active',
                          onTap: () => _showRecurringBillDialog(context),
                          isLast: true,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: Responsive.sectionGap(context)),

                  // 2. TIMELINE ЗАГОЛОВОК
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 16),
                    child: Text(
                      l10n.cashflowTimelineTitle,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: theme.colorScheme.onSurface),
                    ),
                  ),

                  // 3. САМА ВРЕМЕННАЯ ШКАЛА (TIMELINE)
                  if (timeline.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: theme.colorScheme.surfaceVariant.withOpacity(0.5)),
                      ),
                      child: Column(
                        children: [
                          Icon(CupertinoIcons.calendar_badge_minus, size: 48, color: theme.colorScheme.primary.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text(l10n.cashflowEmpty, style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                        ],
                      ),
                    )
                  else
                    ...timeline.asMap().entries.map((entry) {
                      final index = entry.key;
                      final event = entry.value;
                      final isLast = index == timeline.length - 1;

                      return IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Линия таймлайна слева
                            SizedBox(
                              width: 40,
                              child: Column(
                                children: [
                                  Container(
                                    width: 12, height: 12,
                                    margin: const EdgeInsets.only(top: 24),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: theme.colorScheme.surface, width: 3),
                                    ),
                                  ),
                                  if (!isLast)
                                    Expanded(
                                      child: Container(
                                        width: 2,
                                        color: theme.colorScheme.primary.withOpacity(0.2),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // Сама карточка события
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: theme.colorScheme.surfaceVariant.withOpacity(0.5)),
                                  ),
                                  child: CashflowEventCard(event: event),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                  SizedBox(height: 100 + MediaQuery.of(context).padding.bottom),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Вспомогательный виджет настроек (Apple Style)
class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final VoidCallback onTap;
  final bool isLast;

  const _SettingsRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: isLast ? Radius.zero : const Radius.circular(24),
          bottom: isLast ? const Radius.circular(24) : Radius.zero,
        ),
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
                  Text(value, style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                  const SizedBox(width: 8),
                  Icon(CupertinoIcons.chevron_forward, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3), size: 18),
                ],
              ),
            ),
            if (!isLast) Padding(padding: const EdgeInsets.only(left: 56), child: Divider(height: 1, color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5))),
          ],
        ),
      ),
    );
  }
}