class StreakSummaryModel {
  final int currentStreakDays;
  final int bestStreakDays;
  final bool hasActivityToday;

  const StreakSummaryModel({
    required this.currentStreakDays,
    required this.bestStreakDays,
    required this.hasActivityToday,
  });
}