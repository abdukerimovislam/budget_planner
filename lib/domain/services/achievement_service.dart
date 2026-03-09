import '../../data/models/achievement_model.dart';
import '../../data/models/expense_model.dart';
import 'streak_summary_model.dart';

class AchievementService {
  List<AchievementModel> build({
    required List<ExpenseModel> expenses,
    required StreakSummaryModel streak,
    required bool hasGoal,
    required bool hasGoalProgress,
    required bool hasMonthCloseSignal,
    required bool hasNoOverspendMonth,
  }) {
    final now = DateTime.now();

    return [
      AchievementModel(
        id: 'first_expense',
        titleKey: 'achievementFirstExpenseTitle',
        subtitleKey: 'achievementFirstExpenseSubtitle',
        isUnlocked: expenses.isNotEmpty,
        unlockedAt: expenses.isNotEmpty ? now : null,
      ),
      AchievementModel(
        id: 'tracker_7',
        titleKey: 'achievementTracker7Title',
        subtitleKey: 'achievementTracker7Subtitle',
        isUnlocked: streak.bestStreakDays >= 7,
        unlockedAt: streak.bestStreakDays >= 7 ? now : null,
      ),
      AchievementModel(
        id: 'tracker_30',
        titleKey: 'achievementTracker30Title',
        subtitleKey: 'achievementTracker30Subtitle',
        isUnlocked: streak.bestStreakDays >= 30,
        unlockedAt: streak.bestStreakDays >= 30 ? now : null,
      ),
      AchievementModel(
        id: 'goal_started',
        titleKey: 'achievementGoalStartedTitle',
        subtitleKey: 'achievementGoalStartedSubtitle',
        isUnlocked: hasGoal,
        unlockedAt: hasGoal ? now : null,
      ),
      AchievementModel(
        id: 'goal_progress',
        titleKey: 'achievementGoalProgressTitle',
        subtitleKey: 'achievementGoalProgressSubtitle',
        isUnlocked: hasGoalProgress,
        unlockedAt: hasGoalProgress ? now : null,
      ),
      AchievementModel(
        id: 'month_close',
        titleKey: 'achievementMonthCloseTitle',
        subtitleKey: 'achievementMonthCloseSubtitle',
        isUnlocked: hasMonthCloseSignal,
        unlockedAt: hasMonthCloseSignal ? now : null,
      ),
      AchievementModel(
        id: 'no_overspend',
        titleKey: 'achievementNoOverspendTitle',
        subtitleKey: 'achievementNoOverspendSubtitle',
        isUnlocked: hasNoOverspendMonth,
        unlockedAt: hasNoOverspendMonth ? now : null,
      ),
    ];
  }
}