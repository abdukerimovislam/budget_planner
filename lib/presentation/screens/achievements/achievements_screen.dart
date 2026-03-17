import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/responsive.dart';
import '../../../l10n/app_localizations.dart';
// НОВЫЙ ПРОВАЙДЕР
import '../../providers/insights_provider.dart';

import '../../widgets/achievement_card.dart';
import '../../widgets/adaptive_page_padding.dart';
import '../../widgets/section_header.dart';
import '../../widgets/streak_card.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Используем InsightsProvider для данных о прогрессе
    final insights = context.watch<InsightsProvider>();
    final l10n = AppLocalizations.of(context);

    final streak = insights.streakSummary();
    final achievements = insights.achievements();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.achievementsTitle),
      ),
      body: AdaptivePagePadding(
        addBottomSafeArea: false,
        child: ListView(
          children: [
            StreakCard(streak: streak),
            SizedBox(height: Responsive.sectionGap(context)),
            SectionHeader(title: l10n.achievementsTitle),
            SizedBox(height: Responsive.itemGap(context)),
            if (achievements.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    'У вас пока нет достижений. Начните записывать расходы!',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ...achievements.map(
                    (achievement) => Padding(
                  padding: EdgeInsets.only(bottom: Responsive.itemGap(context)),
                  child: AchievementCard(achievement: achievement),
                ),
              ),
          ],
        ),
      ),
    );
  }
}