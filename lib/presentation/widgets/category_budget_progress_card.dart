import 'package:flutter/material.dart';

import '../../core/utils/responsive.dart';

class CategoryBudgetProgressCard extends StatelessWidget {
  final String categoryLabel;
  final double spent;
  final double budget;
  final bool isOverBudget;

  const CategoryBudgetProgressCard({
    super.key,
    required this.categoryLabel,
    required this.spent,
    required this.budget,
    required this.isOverBudget,
  });

  String _formatNumber(num value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final progress = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    final progressColor = isOverBudget ? scheme.error : scheme.primary;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(Responsive.cardPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              categoryLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(999),
              color: progressColor,
              backgroundColor: scheme.surfaceContainerHighest,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _formatNumber(spent),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Text(
                  '/ ${_formatNumber(budget)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}