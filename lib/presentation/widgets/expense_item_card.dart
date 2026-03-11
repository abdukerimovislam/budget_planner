import 'package:flutter/material.dart';

import '../../core/utils/category_extension.dart'; // <-- ИМПОРТИРУЕМ РАСШИРЕНИЕ
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
    if (profile == null || profile.monthlyIncome <= 0) return '';

    final minutesPerMonth = profile.workingDaysPerMonth * profile.workingHoursPerDay * 60;
    if (minutesPerMonth <= 0) return '';

    final valuePerMinute = profile.monthlyIncome / minutesPerMonth;
    if (valuePerMinute <= 0) return '';

    final minutes = (expense.amount / valuePerMinute).round();
    if (minutes <= 0) return '';

    return '$minutes min';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // ДОСТАЕМ РЕАЛЬНЫЕ ДАННЫЕ (Учитывая customCategoryId!)
    final iconData = expense.category.dynamicIcon(context, customCategoryId: expense.customCategoryId);
    final catColor = expense.category.dynamicColor(context, customCategoryId: expense.customCategoryId);
    final catName = expense.category.localizedName(context, customCategoryId: expense.customCategoryId);

    final subtitleParts = <String>[
      if (expense.merchant.isNotEmpty) expense.merchant,
      if ((expense.note ?? '').trim().isNotEmpty) expense.note!.trim(),
      if (_lifeCost().isNotEmpty) _lifeCost(),
    ];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // 1. ИКОНКА (Apple Style)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: catColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, color: catColor, size: 24),
              ),
              const SizedBox(width: 16),

              // 2. ИНФОРМАЦИЯ
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      catName, // ВЫВОДИТ "Курс", А НЕ "Custom"!
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (subtitleParts.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitleParts.join(' • '),
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ]
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // 3. СУММА
              Text(
                '-${_formatNumber(expense.amount)}',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}