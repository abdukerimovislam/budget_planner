import 'package:flutter/material.dart';

import '../../core/utils/responsive.dart';
import '../../l10n/app_localizations.dart';
import 'premium_badge.dart';

class PremiumLockCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const PremiumLockCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(Responsive.cardPadding(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PremiumBadge(),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onTap,
                child: Text(l10n.openPremiumButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}