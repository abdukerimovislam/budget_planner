import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../data/models/financial_level_model.dart';
import '../../l10n/app_localizations.dart';

class FinancialLevelCard extends StatelessWidget {
  final FinancialLevel level;
  final VoidCallback onTapReport;

  const FinancialLevelCard({
    super.key,
    required this.level,
    required this.onTapReport,
  });

  String _levelLabel(AppLocalizations l10n) {
    switch (level) {
      case FinancialLevel.survivor: return l10n.levelSurvivor;
      case FinancialLevel.planner: return l10n.levelPlanner;
      case FinancialLevel.strategist: return l10n.levelStrategist;
      case FinancialLevel.investor: return l10n.levelInvestor;
    }
  }

  Color _levelColor() {
    switch (level) {
      case FinancialLevel.survivor: return CupertinoColors.systemRed;
      case FinancialLevel.planner: return CupertinoColors.systemOrange;
      case FinancialLevel.strategist: return CupertinoColors.systemBlue;
      case FinancialLevel.investor: return CupertinoColors.systemPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final color = _levelColor();

    return GestureDetector(
      onTap: onTapReport,
      child: Container(
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
              child: Icon(CupertinoIcons.star_circle_fill, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _levelLabel(l10n),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.openMonthlyReportButton,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: theme.colorScheme.primary),
                  ),
                ],
              ),
            ),
            Icon(CupertinoIcons.chevron_forward, color: theme.colorScheme.onSurface.withOpacity(0.3), size: 20),
          ],
        ),
      ),
    );
  }
}