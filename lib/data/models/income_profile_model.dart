import 'dart:math'; // <-- ДОБАВЛЕНО: для умного расчета дохода

enum IncomeType {
  salary,      // 1. Стабильная з/п (считаем по дням и часам)
  freelance,   // 2. Фриланс (четкая ставка в час)
  business,    // 3. Плавающий доход (Бизнес/Инвестиции - считаем по часам в неделю)
}

class IncomeProfileModel {
  // Ожидаемый базовый доход (нужен для прогнозов и построения планов)
  final double expectedMonthlyIncome;
  final IncomeType incomeType;

  // Настройки для Salary (Офис)
  final int? workingDaysPerMonth;
  final int? workingHoursPerDay;

  // Настройки для Freelance (Прямая оценка часа)
  final double? hourlyRate;

  // Настройки для Business (Сколько реально часов в неделю уходит на дела)
  final int? workingHoursPerWeek;

  final String currency;

  const IncomeProfileModel({
    required this.expectedMonthlyIncome,
    required this.incomeType,
    this.workingDaysPerMonth,
    this.workingHoursPerDay,
    this.hourlyRate,
    this.workingHoursPerWeek,
    this.currency = 'USD', // <-- ИСПРАВЛЕНО: Глобальный дефолт без хардкода локальной валюты
  });

  /// УМНЫЙ АЛГОРИТМ РАСЧЕТА СТОИМОСТИ 1 МИНУТЫ ЖИЗНИ
  double valuePerMinute({double? actualIncomeThisMonth}) {
    // 1. Если человек жестко задал стоимость своего часа
    if (hourlyRate != null && hourlyRate! > 0) {
      return hourlyRate! / 60;
    }

    // 2. ИСПРАВЛЕНИЕ ЛОВУШКИ: Берем максимум между ожидаемым и фактическим доходом.
    // Это спасет расчеты в начале месяца (когда бизнесмен заработал пока только $10).
    final incomeToUse = max(expectedMonthlyIncome, actualIncomeThisMonth ?? 0.0);

    if (incomeToUse <= 0) return 0.0;

    // 3. Расчет для классического найма
    if (incomeType == IncomeType.salary) {
      final days = workingDaysPerMonth ?? 20;
      final hours = workingHoursPerDay ?? 8;
      if (days > 0 && hours > 0) {
        return incomeToUse / (days * hours * 60);
      }
    }

    // 4. Расчет для бизнеса (считаем через среднее количество часов в неделю)
    if (incomeType == IncomeType.business) {
      final hoursPerWeek = workingHoursPerWeek ?? 40;
      if (hoursPerWeek > 0) {
        // В месяце в среднем 4.33 недели
        return incomeToUse / (hoursPerWeek * 4.33 * 60);
      }
    }

    return 0.0;
  }

  // Заглушка для обратной совместимости
  double get monthlyIncome => expectedMonthlyIncome;

  IncomeProfileModel copyWith({
    double? expectedMonthlyIncome,
    IncomeType? incomeType,
    int? workingDaysPerMonth,
    int? workingHoursPerDay,
    double? hourlyRate,
    int? workingHoursPerWeek,
    String? currency,
  }) {
    return IncomeProfileModel(
      expectedMonthlyIncome: expectedMonthlyIncome ?? this.expectedMonthlyIncome,
      incomeType: incomeType ?? this.incomeType,
      workingDaysPerMonth: workingDaysPerMonth ?? this.workingDaysPerMonth,
      workingHoursPerDay: workingHoursPerDay ?? this.workingHoursPerDay,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      workingHoursPerWeek: workingHoursPerWeek ?? this.workingHoursPerWeek,
      currency: currency ?? this.currency,
    );
  }
}