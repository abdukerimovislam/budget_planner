import '../../data/models/income_profile_model.dart';

class LifeValueService {
  double calculateHoursSpent({
    required double amount,
    required IncomeProfileModel profile,
  }) {
    if (profile.hourlyIncome <= 0) return 0;
    return amount / profile.hourlyIncome;
  }

  Duration calculateDurationSpent({
    required double amount,
    required IncomeProfileModel profile,
  }) {
    final hours = calculateHoursSpent(amount: amount, profile: profile);
    final totalMinutes = (hours * 60).round();
    return Duration(minutes: totalMinutes);
  }
}