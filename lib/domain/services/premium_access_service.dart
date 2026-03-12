import 'premium_feature.dart';

class PremiumAccessService {
  bool canUse({
    required bool isPremium,
    required PremiumFeature feature,
    int activeGoalsCount = 0,
  }) {
    if (isPremium) return true;

    switch (feature) {
      case PremiumFeature.aiInsights:
        return false;
      case PremiumFeature.voiceInput:
        return false;
      case PremiumFeature.receiptOcr:
        return false;
      case PremiumFeature.advancedSubscriptions:
        return false;
      case PremiumFeature.cashflowTimeline:
        return false;
      case PremiumFeature.multipleGoals:
        return activeGoalsCount < 1;
      case PremiumFeature.shareExport:
        return false;
      case PremiumFeature.actionPlanner:
        return false;
      case PremiumFeature.multiCurrency: // <-- ИСПРАВЛЕНИЕ: Добавили проверку новой фичи
        return false;
    }
  }
}