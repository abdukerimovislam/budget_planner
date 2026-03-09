class IncomeProfileModel {
  final double monthlyIncome;
  final int workingDaysPerMonth;
  final double workingHoursPerDay;

  const IncomeProfileModel({
    required this.monthlyIncome,
    required this.workingDaysPerMonth,
    required this.workingHoursPerDay,
  });

  double get hourlyIncome {
    final totalHours = workingDaysPerMonth * workingHoursPerDay;
    if (totalHours <= 0) return 0;
    return monthlyIncome / totalHours;
  }
}