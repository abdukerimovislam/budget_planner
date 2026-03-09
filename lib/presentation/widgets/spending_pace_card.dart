import 'package:flutter/material.dart';

import '../../core/utils/responsive.dart';

class SpendingPaceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isWarning;

  const SpendingPaceCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isWarning,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final iconColor = isWarning ? scheme.error : scheme.primary;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(Responsive.cardPadding(context)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isWarning ? Icons.warning_amber_rounded : Icons.check_circle_outline,
              color: iconColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}