import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/responsive.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/adaptive_page_padding.dart';
import '../../widgets/section_header.dart';
import '../../widgets/subscription_candidate_card.dart';

// НОВЫЙ ПРОВАЙДЕР
import '../../providers/insights_provider.dart';

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  String _formatNumber(num value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final insights = context.watch<InsightsProvider>();
    final l10n = AppLocalizations.of(context);

    // Берем данные о подписках из InsightsProvider
    final subscriptions = insights.detectedSubscriptions();
    final monthlyTotal = subscriptions.fold<double>(
      0,
          (sum, item) => sum + item.estimatedMonthlyCost,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.subscriptionsTitle),
      ),
      body: AdaptivePagePadding(
        addBottomSafeArea: false,
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(Responsive.cardPadding(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.subscriptionsSummaryTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatNumber(monthlyTotal),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: Responsive.largeTitleSize(context),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.subscriptionsSummarySubtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: Responsive.sectionGap(context)),
            SectionHeader(title: l10n.subscriptionsDetectedTitle),
            SizedBox(height: Responsive.itemGap(context)),
            if (subscriptions.isEmpty)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(Responsive.cardPadding(context)),
                  child: Text(
                    l10n.subscriptionsEmptyState,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              )
            else ...[
              ...subscriptions.map(
                    (item) => Padding(
                  padding: EdgeInsets.only(bottom: Responsive.itemGap(context)),
                  child: SubscriptionCandidateCard(candidate: item),
                ),
              ),
              SizedBox(height: Responsive.sectionGap(context)),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(Responsive.cardPadding(context)),
                  child: Text(
                    l10n.subscriptionsPotentialSavings(
                      _formatNumber(monthlyTotal * 0.5),
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}