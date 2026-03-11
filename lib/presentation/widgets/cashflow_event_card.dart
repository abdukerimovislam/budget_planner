import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

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
        return CupertinoIcons.arrow_down_circle_fill;
      case CashflowEventType.bill:
        return CupertinoIcons.doc_text_fill;
      case CashflowEventType.plannedExpense:
        return CupertinoIcons.calendar_circle_fill;
    }
  }

  Color _color(BuildContext context) {
    switch (event.type) {
      case CashflowEventType.income:
        return CupertinoColors.systemGreen;
      case CashflowEventType.bill:
        return CupertinoColors.systemRed;
      case CashflowEventType.plannedExpense:
        return CupertinoColors.systemOrange;
    }
  }

  String _formatNumber(num value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _color(context);
    final isIncome = event.type == CashflowEventType.income;

    // Мы убрали Card, потому что родительский виджет в таймлайне
    // уже рисует красивый контейнер с рамкой и нужным фоном.
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // 1. Иконка в мягком цветном кружке (Apple Style)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(_icon(), color: color, size: 24),
          ),
          const SizedBox(width: 16),

          // 2. Название и Дата
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${event.date.day.toString().padLeft(2, '0')}.'
                      '${event.date.month.toString().padLeft(2, '0')}.'
                      '${event.date.year}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // 3. Сумма (Зеленая для дохода, Красная для расхода)
          Text(
            '${isIncome ? '+' : '-'}${_formatNumber(event.amount)}',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}