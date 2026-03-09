import '../../data/models/saving_goal_model.dart';
import 'savings_goal_projection.dart';

class SavingsGoalService {
  SavingsGoalProjection project({
    required SavingsGoalModel goal,
    required double currentMonthlySavings,
    required DateTime now,
  }) {
    final remaining = (goal.targetAmount - goal.currentAmount).clamp(0, double.infinity).toDouble();
    final progress = goal.targetAmount > 0
        ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;

    int? monthsToTargetDate;
    double recommendedMonthlyContribution = 0;

    if (goal.targetDate != null) {
      final months = _monthsBetween(now, goal.targetDate!);
      monthsToTargetDate = months > 0 ? months : 1;
      recommendedMonthlyContribution = remaining / monthsToTargetDate;
    }

    int? monthsAtCurrentRate;
    if (currentMonthlySavings > 0 && remaining > 0) {
      monthsAtCurrentRate = (remaining / currentMonthlySavings).ceil();
    }

    final isOnTrack = monthsToTargetDate == null ||
        monthsAtCurrentRate == null ||
        monthsAtCurrentRate <= monthsToTargetDate;

    return SavingsGoalProjection(
      remainingAmount: remaining,
      progress: progress,
      recommendedMonthlyContribution: recommendedMonthlyContribution,
      monthsToTargetDate: monthsToTargetDate,
      monthsAtCurrentSavingsRate: monthsAtCurrentRate,
      isOnTrack: isOnTrack,
    );
  }

  int _monthsBetween(DateTime from, DateTime to) {
    return ((to.year - from.year) * 12) + (to.month - from.month);
  }
}