import '../../data/models/income_profile_model.dart';

class LifeValueService {

  /// Считает, сколько часов жизни потрачено
  double calculateHoursSpent({
    required double amount,
    required IncomeProfileModel profile,
    double? actualIncomeThisMonth,
  }) {
    final minuteValue = profile.valuePerMinute(actualIncomeThisMonth: actualIncomeThisMonth);
    if (minuteValue <= 0) return 0.0;

    return amount / (minuteValue * 60);
  }

  /// Возвращает удобный объект Duration (Часы и Минуты)
  Duration calculateDurationSpent({
    required double amount,
    required IncomeProfileModel profile,
    double? actualIncomeThisMonth,
  }) {
    final minuteValue = profile.valuePerMinute(actualIncomeThisMonth: actualIncomeThisMonth);
    if (minuteValue <= 0) return Duration.zero;

    final totalMinutes = (amount / minuteValue).round();
    return Duration(minutes: totalMinutes);
  }
}