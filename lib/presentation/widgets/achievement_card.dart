import 'package:flutter/material.dart';

import '../../core/utils/responsive.dart';
import '../../data/models/achievement_model.dart';
import '../../l10n/app_localizations.dart';

class AchievementCard extends StatelessWidget {
  final AchievementModel achievement;

  const AchievementCard({
    super.key,
    required this.achievement,
  });

  String _resolve(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context);

    switch (key) {
      case 'achievementFirstExpenseTitle':
        return l10n.achievementFirstExpenseTitle;
      case 'achievementFirstExpenseSubtitle':
        return l10n.achievementFirstExpenseSubtitle;
      case 'achievementTracker7Title':
        return l10n.achievementTracker7Title;
      case 'achievementTracker7Subtitle':
        return l10n.achievementTracker7Subtitle;
      case 'achievementTracker30Title':
        return l10n.achievementTracker30Title;
      case 'achievementTracker30Subtitle':
        return l10n.achievementTracker30Subtitle;
      case 'achievementGoalStartedTitle':
        return l10n.achievementGoalStartedTitle;
      case 'achievementGoalStartedSubtitle':
        return l10n.achievementGoalStartedSubtitle;
      case 'achievementGoalProgressTitle':
        return l10n.achievementGoalProgressTitle;
      case 'achievementGoalProgressSubtitle':
        return l10n.achievementGoalProgressSubtitle;
      case 'achievementMonthCloseTitle':
        return l10n.achievementMonthCloseTitle;
      case 'achievementMonthCloseSubtitle':
        return l10n.achievementMonthCloseSubtitle;
      case 'achievementNoOverspendTitle':
        return l10n.achievementNoOverspendTitle;
      case 'achievementNoOverspendSubtitle':
        return l10n.achievementNoOverspendSubtitle;
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(Responsive.cardPadding(context)),
        child: Row(
          children: [
            Icon(
              achievement.isUnlocked
                  ? Icons.workspace_premium_rounded
                  : Icons.lock_outline_rounded,
              color: achievement.isUnlocked
                  ? scheme.primary
                  : scheme.outline,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _resolve(context, achievement.titleKey),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _resolve(context, achievement.subtitleKey),
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