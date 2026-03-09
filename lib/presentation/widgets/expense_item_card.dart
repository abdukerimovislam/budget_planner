import 'package:flutter/material.dart';

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

    final minutesPerMonth =
        profile.workingDaysPerMonth * profile.workingHoursPerDay * 60;

    if (minutesPerMonth <= 0) return '';

    final valuePerMinute = profile.monthlyIncome / minutesPerMonth;
    if (valuePerMinute <= 0) return '';

    final minutes = (expense.amount / valuePerMinute).round();
    if (minutes <= 0) return '';

    return '$minutes min';
  }

  @override
  Widget build(BuildContext context) {
    final subtitleParts = <String>[
      if (expense.merchant.isNotEmpty) expense.merchant,
      if ((expense.note ?? '').trim().isNotEmpty) expense.note!.trim(),
      if (_lifeCost().isNotEmpty) _lifeCost(),
    ];

    final content = ListTile(
      leading: CircleAvatar(
        child: Text(
          expense.category.name.characters.first.toUpperCase(),
        ),
      ),
      title: Text(_formatNumber(expense.amount)),
      subtitle: subtitleParts.isEmpty ? null : Text(subtitleParts.join(' • ')),
      trailing: const Icon(Icons.chevron_right_rounded),
    );

    return Card(
      child: onTap == null
          ? content
          : InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: content,
      ),
    );
  }
}