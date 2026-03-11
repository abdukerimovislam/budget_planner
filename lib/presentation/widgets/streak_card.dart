import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../domain/services/streak_summary_model.dart';
import '../../l10n/app_localizations.dart';

class StreakCard extends StatelessWidget {
  final StreakSummaryModel streak;
  final VoidCallback? onTap; // Сделали необязательным

  const StreakCard({
    super.key,
    required this.streak,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // ИСПОЛЬЗУЕМ ПРАВИЛЬНЫЕ ПОЛЯ: currentStreakDays и hasActivityToday
    final isOnStreak = streak.currentStreakDays > 0;
    final color = isOnStreak ? CupertinoColors.systemOrange : CupertinoColors.systemGrey;

    final cardContent = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.surfaceVariant.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(isOnStreak ? CupertinoIcons.flame_fill : CupertinoIcons.flame, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.streakCurrentValue(streak.currentStreakDays),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface, letterSpacing: -0.5),
                ),
                const SizedBox(height: 4),
                Text(
                  streak.hasActivityToday ? l10n.streakTodayDone : l10n.streakTodayMissing,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: streak.hasActivityToday ? CupertinoColors.systemGreen : theme.colorScheme.onSurface.withOpacity(0.5)
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null) // Показываем стрелочку только если можно нажать
            Icon(CupertinoIcons.chevron_forward, color: theme.colorScheme.onSurface.withOpacity(0.3), size: 20),
        ],
      ),
    );

    if (onTap == null) return cardContent;

    return GestureDetector(
      onTap: onTap,
      child: cardContent,
    );
  }
}