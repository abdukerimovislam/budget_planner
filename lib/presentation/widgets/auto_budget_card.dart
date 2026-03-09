import 'package:flutter/material.dart';

import '../../core/utils/responsive.dart';
import '../../domain/services/auto_budget_service.dart';
import '../../l10n/app_localizations.dart';

class AutoBudgetCard extends StatelessWidget {
  final AutoBudgetRecommendation recommendation;
  final VoidCallback? onApplyTap;

  const AutoBudgetCard({
    super.key,
    required this.recommendation,
    this.onApplyTap,
  });

  String _formatNumber(num value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(Responsive.cardPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.autoBudgetTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _formatNumber(recommendation.recommendedTotalBudget),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: Responsive.largeTitleSize(context),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.autoBudgetSubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (onApplyTap != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onApplyTap,
                child: Text(l10n.applyAutoBudgetButton),
              ),
            ],
          ],
        ),
      ),
    );
  }
}