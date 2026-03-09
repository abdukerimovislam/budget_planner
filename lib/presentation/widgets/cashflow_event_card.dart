import 'package:flutter/material.dart';

import '../../core/utils/responsive.dart';
import '../../data/models/cashflow_event_model.dart';

class CashflowEventCard extends StatelessWidget {
  final CashflowEventModel event;

  const CashflowEventCard({
    super.key,
    required this.event,
  });

  IconData _icon() {
    switch (event.type) {
      case CashflowEventType.income:
        return Icons.arrow_downward_rounded;
      case CashflowEventType.bill:
        return Icons.receipt_long_rounded;
      case CashflowEventType.plannedExpense:
        return Icons.event_note_rounded;
    }
  }

  String _formatNumber(num value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final iconColor = event.type == CashflowEventType.income
        ? scheme.primary
        : scheme.error;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(Responsive.cardPadding(context)),
        child: Row(
          children: [
            Icon(_icon(), color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${event.date.day.toString().padLeft(2, '0')}.'
                        '${event.date.month.toString().padLeft(2, '0')}.'
                        '${event.date.year}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${_formatNumber(event.amount)} ${event.currency}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}