import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../core/utils/category_extension.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/income_profile_model.dart';

class ExpenseItemCard extends StatelessWidget {
  final ExpenseModel expense;
  final IncomeProfileModel? incomeProfile;
  final VoidCallback? onTap;

  const ExpenseItemCard({
    super.key,
    required this.expense,
    required this.incomeProfile,
    this.onTap,
  });

  String _formatNumber(num value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }

  String _lifeCost() {
    final profile = incomeProfile;
    if (profile == null) return '';

    final minuteValue = profile.valuePerMinute();
    if (minuteValue <= 0) return '';

    final totalMinutes = (expense.amount / minuteValue).round();
    if (totalMinutes <= 0) return '';

    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;

    if (hours > 0) return '${hours}h ${mins}m';
    return '${mins}m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final iconData = expense.category.dynamicIcon(context, customCategoryId: expense.customCategoryId);
    final catColor = expense.category.dynamicColor(context, customCategoryId: expense.customCategoryId);
    final catName = expense.category.localizedName(context, customCategoryId: expense.customCategoryId);

    final subtitleParts = <String>[
      if (expense.merchant.isNotEmpty) expense.merchant,
      if ((expense.note ?? '').trim().isNotEmpty) expense.note!.trim(),
    ];

    final lifeCostStr = _lifeCost();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: catColor.withOpacity(0.15), shape: BoxShape.circle),
                child: Icon(iconData, color: catColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      catName,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                    ),
                    if (subtitleParts.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitleParts.join(' • '),
                        style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ]
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // ИСПРАВЛЕНИЕ: Вывод суммы вместе с Валютой!
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${expense.isIncome ? '+' : '-'}${_formatNumber(expense.amount)}',
                        style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w800,
                          color: expense.isIncome ? CupertinoColors.systemGreen : theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        expense.currency,
                        style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700,
                          color: expense.isIncome ? CupertinoColors.systemGreen.withOpacity(0.7) : theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                  if (!expense.isIncome && lifeCostStr.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: CupertinoColors.systemRed.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(CupertinoIcons.clock_fill, size: 10, color: CupertinoColors.systemRed),
                          const SizedBox(width: 4),
                          Text(lifeCostStr, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: CupertinoColors.systemRed)),
                        ],
                      ),
                    ),
                  ]
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}