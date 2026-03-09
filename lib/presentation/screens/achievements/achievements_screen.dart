import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/responsive.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/home_provider.dart';
import '../../widgets/achievement_card.dart';
import '../../widgets/adaptive_page_padding.dart';
import '../../widgets/section_header.dart';
import '../../widgets/streak_card.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final l10n = AppLocalizations.of(context);

    final streak = provider.streakSummary();
    final achievements = provider.achievements();

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