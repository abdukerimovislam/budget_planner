import '../../data/models/expense_model.dart';
import 'streak_summary_model.dart';

class StreakService {
  StreakSummaryModel calculate(List<ExpenseModel> expenses) {
    if (expenses.isEmpty) {
      return const StreakSummaryModel(
        currentStreakDays: 0,
        bestStreakDays: 0,
        hasActivityToday: false,
      );
    }

    final uniqueDays = expenses
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    final hasActivityToday = uniqueDays.contains(todayOnly);

    int currentStreak = 0;
    DateTime cursor = hasActivityToday
        ? todayOnly
        : todayOnly.subtract(const Duration(days: 1));

    while (uniqueDays.contains(cursor)) {
      currentStreak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    int bestStreak = 1;
    int run = 1;

    for (int i = 1; i < uniqueDays.length; i++) {
      final prev = uniqueDays[i - 1];
      final current = uniqueDays[i];

      final diff = prev.difference(current).inDays;
      if (diff == 1) {
        run += 1;
        if (run > bestStreak) bestStreak = run;
      } else {
        run = 1;
      }
    }

    return StreakSummaryModel(
      currentStreakDays: currentStreak,
      bestStreakDays: bestStreak,
      hasActivityToday: hasActivityToday,
    );
  }
}