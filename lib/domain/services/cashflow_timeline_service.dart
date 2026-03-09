import '../../data/models/cashflow_event_model.dart';
import '../../data/models/recurring_bill_model.dart';

class CashflowTimelineService {
  List<CashflowEventModel> buildTimeline({
    required DateTime now,
    required int? salaryDay,
    required double monthlyIncome,
    required List<RecurringBillModel> recurringBills,
    int daysAhead = 30,
  }) {
    final events = <CashflowEventModel>[];
    final endDate = now.add(Duration(days: daysAhead));

    if (salaryDay != null && salaryDay >= 1 && salaryDay <= 31 && monthlyIncome > 0) {
      final salaryDates = _generateMonthlyDates(
        start: now,
        end: endDate,
        dayOfMonth: salaryDay,
      );

      for (final date in salaryDates) {
        events.add(
          CashflowEventModel(
            id: 'salary_${date.toIso8601String()}',
            title: 'Salary',
            amount: monthlyIncome,
            currency: 'KGS',
            date: date,
            type: CashflowEventType.income,
          ),
        );
      }
    }

    for (final bill in recurringBills.where((b) => b.isActive)) {
      final billDates = _generateMonthlyDates(
        start: now,
        end: endDate,
        dayOfMonth: bill.dayOfMonth,
      );

      for (final date in billDates) {
        events.add(
          CashflowEventModel(
            id: '${bill.id}_${date.toIso8601String()}',
            title: bill.title,
            amount: bill.amount,
            currency: bill.currency,
            date: date,
            type: CashflowEventType.bill,
          ),
        );
      }
    }

    events.sort((a, b) => a.date.compareTo(b.date));
    return events;
  }

  List<DateTime> _generateMonthlyDates({
    required DateTime start,
    required DateTime end,
    required int dayOfMonth,
  }) {
    final result = <DateTime>[];

    var cursor = DateTime(start.year, start.month, 1);

    while (!cursor.isAfter(end)) {
      final lastDay = DateTime(cursor.year, cursor.month + 1, 0).day;
      final safeDay = dayOfMonth > lastDay ? lastDay : dayOfMonth;
      final candidate = DateTime(cursor.year, cursor.month, safeDay);

      if (!candidate.isBefore(DateTime(start.year, start.month, start.day)) &&
          !candidate.isAfter(end)) {
        result.add(candidate);
      }

      cursor = DateTime(cursor.year, cursor.month + 1, 1);
    }

    return result;
  }
}