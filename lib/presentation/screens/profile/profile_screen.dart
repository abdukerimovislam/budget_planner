import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../app/app_state.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/utils/responsive.dart';
import '../../../l10n/app_localizations.dart';
import '../../monthly_report/monthly_report_screen.dart';
import '../../providers/home_provider.dart';
import '../../widgets/financial_level_card.dart';
import '../../widgets/premium_background.dart'; // <-- ИМПОРТ ФОНА
import '../../widgets/streak_card.dart';
import '../achievements/achievements_screen.dart';
import '../premium/premium_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<HomeProvider>();

    final streak = provider.streakSummary();
    final report = provider.monthlyReport(DateTime.now());
    final isPremium = provider.isPremium;

    // ОБОРАЧИВАЕМ ЭКРАН В НАШ ФОН
    return PremiumBackground(
      child: Scaffold(
        // ПРОЗРАЧНЫЙ ФОН СКЭФФОЛДА
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverAppBar.large(
              stretch: true,
              // ПРОЗРАЧНЫЙ АППБАР
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              title: Text(
                l10n.profileTitle,
                style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.5),
              ),
            ),

            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.cardPadding(context),
                vertical: 16,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  // 1. БЛОК ГЕЙМИФИКАЦИИ
                  _SectionTitle(title: l10n.gamificationSection.toUpperCase()),
                  const SizedBox(height: 8),
                  StreakCard(
                    streak: streak,
                    onTap: () => Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const AchievementsScreen())),
                  ),
                  const SizedBox(height: 12),
                  FinancialLevelCard(
                    level: report.level,
                    onTapReport: () => Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const MonthlyReportScreen())),
                  ),

                  const SizedBox(height: 32),

                  // 2. БЛОК ПРЕМИУМ
                  _SectionTitle(title: l10n.subscriptionSection.toUpperCase()),
                  const SizedBox(height: 8),
                  _SettingsGroup(
                    children: [
                      _SettingsRow(
                        icon: CupertinoIcons.star_circle_fill,
                        iconColor: CupertinoColors.systemYellow,
                        title: isPremium ? l10n.premiumActiveTitle : l10n.premiumUpgradeTitle,
                        subtitle: isPremium ? l10n.premiumActiveSubtitle : l10n.premiumUpgradeSubtitle,
                        onTap: () => Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const PremiumScreen())),
                        isLast: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // 3. БЛОК НАСТРОЕК
                  _SectionTitle(title: l10n.preferencesSection.toUpperCase()),
                  const SizedBox(height: 8),
                  _SettingsGroup(
                    children: [
                      _SettingsRow(
                        icon: CupertinoIcons.globe,
                        iconColor: CupertinoColors.activeBlue,
                        title: l10n.language,
                        trailing: _buildLanguageSelector(context),
                        isLast: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // 4. DANGER ZONE
                  _SectionTitle(title: l10n.dangerZoneSection.toUpperCase()),
                  const SizedBox(height: 8),
                  _SettingsGroup(
                    children: [
                      _SettingsRow(
                        icon: CupertinoIcons.refresh_circled,
                        iconColor: CupertinoColors.systemOrange,
                        title: l10n.restartOnboarding,
                        onTap: () => context.read<AppState>().resetOnboarding(),
                      ),
                      _SettingsRow(
                        icon: CupertinoIcons.trash_fill,
                        iconColor: CupertinoColors.destructiveRed,
                        title: l10n.clearAllDataTitle,
                        textColor: CupertinoColors.destructiveRed,
                        onTap: () => _showClearDataConfirm(context),
                        isLast: true,
                      ),
                    ],
                  ),

                  SizedBox(height: 48 + MediaQuery.of(context).padding.bottom),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeController = context.watch<LocaleController>();

    final isRu = localeController.locale?.languageCode == 'ru';
    final currentLang = isRu ? l10n.russian : l10n.english;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          currentLang,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontSize: 16),
        ),
        const SizedBox(width: 4),
        PopupMenuButton<String>(
          icon: Icon(CupertinoIcons.chevron_up_chevron_down, size: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
          onSelected: (value) => localeController.setLocale(Locale(value)),
          color: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          itemBuilder: (context) => [
            PopupMenuItem(value: 'en', child: Text(l10n.english, style: const TextStyle(fontWeight: FontWeight.w500))),
            PopupMenuItem(value: 'ru', child: Text(l10n.russian, style: const TextStyle(fontWeight: FontWeight.w500))),
          ],
        ),
      ],
    );
  }

  void _showClearDataConfirm(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(l10n.clearDataDialogTitle),
        content: Text(l10n.clearDataDialogContent),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text(l10n.cancelButton),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text(l10n.deleteButton),
            onPressed: () {
              context.read<HomeProvider>().clearAllData();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.dataClearedMessage),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  )
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 6),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          fontWeight: FontWeight.w600,
          fontSize: 13,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // ДЕЛАЕМ ФОН КАРТОЧКИ ПОЛУПРОЗРАЧНЫМ, ЧТОБЫ ПРОСВЕЧИВАЛ ГРАДИЕНТ
        color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5)),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Color? textColor;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isLast;

  const _SettingsRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.textColor,
    this.trailing,
    this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: !isLast && childrenCountIsOne() ? const Radius.circular(20) : Radius.zero,
          bottom: isLast ? const Radius.circular(20) : Radius.zero,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: iconColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            title,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.4,
                              color: textColor ?? Theme.of(context).colorScheme.onSurface,
                            )
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                              subtitle!,
                              style: TextStyle(
                                fontSize: 13,
                                letterSpacing: -0.1,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                              )
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) trailing!
                  else if (onTap != null) Icon(CupertinoIcons.chevron_forward, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3), size: 20),
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

  bool childrenCountIsOne() => true;
}