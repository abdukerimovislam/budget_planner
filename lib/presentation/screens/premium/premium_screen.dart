import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/responsive.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/home_provider.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<HomeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.premiumTitle),
      ),
      body: Padding(
        padding: EdgeInsets.all(Responsive.pageHorizontalPadding(context)),
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(Responsive.cardPadding(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.premiumHeroTitle,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.premiumHeroSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: Responsive.sectionGap(context)),
            _FeatureTile(text: l10n.premiumFeatureAiInsights),
            _FeatureTile(text: l10n.premiumFeatureVoice),
            _FeatureTile(text: l10n.premiumFeatureReceipt),
            _FeatureTile(text: l10n.premiumFeatureSubscriptions),
            _FeatureTile(text: l10n.premiumFeatureCashflow),
            _FeatureTile(text: l10n.premiumFeatureGoals),
            _FeatureTile(text: l10n.premiumFeatureShare),
            SizedBox(height: Responsive.sectionGap(context)),
            FilledButton(
              onPressed: () async {
                await provider.setPremium(true);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: Text(l10n.premiumUnlockButton),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: provider.isPremium
                  ? () async {
                await provider.setPremium(false);
              }
                  : null,
              child: Text(l10n.premiumDisableDebugButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final String text;

  const _FeatureTile({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}