// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Budget Planner';

  @override
  String get homeTitle => 'Budget Planner';

  @override
  String get homeTab => 'Home';

  @override
  String get analyticsTab => 'Analytics';

  @override
  String get budgetTab => 'Budget';

  @override
  String get settingsTab => 'Settings';

  @override
  String get spentThisMonth => 'Spent this month';

  @override
  String lifeSpent(String value) {
    return 'Life spent: $value';
  }

  @override
  String get financialHealthScore => 'Financial Health Score';

  @override
  String get monthlyFinancialPulse => 'Your monthly financial pulse';

  @override
  String get forecast => 'Forecast';

  @override
  String get setBudgetToUnlockForecast => 'Set a budget to unlock forecast';

  @override
  String get riskOfOverspending => 'Risk of overspending this month';

  @override
  String get withinBudgetPace => 'You are within budget pace';

  @override
  String get addExpense => 'Add expense';

  @override
  String get language => 'Language';

  @override
  String get languageDescription => 'Choose the app language';

  @override
  String get russian => 'Russian';

  @override
  String get english => 'English';

  @override
  String get notAvailableShort => '—';

  @override
  String scoreValue(int value) {
    return '$value/100';
  }

  @override
  String durationMinutesOnly(int minutes) {
    return '$minutes min';
  }

  @override
  String durationHoursOnly(int hours) {
    return '$hours h';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String get onboardingTitle1 => 'Your money should feel clear';

  @override
  String get onboardingSubtitle1 =>
      'Set your monthly income and budget to unlock forecasts and life-based insights.';

  @override
  String get onboardingTitle2 => 'Translate money into life';

  @override
  String get onboardingSubtitle2 =>
      'Add your working schedule so the app can show how much time each expense costs.';

  @override
  String get monthlyIncomeLabel => 'Monthly income';

  @override
  String get monthlyBudgetLabel => 'Monthly budget';

  @override
  String get workDaysPerMonthLabel => 'Working days per month';

  @override
  String get workHoursPerDayLabel => 'Working hours per day';

  @override
  String get continueButton => 'Continue';

  @override
  String get finishButton => 'Finish';

  @override
  String get analyticsComingSoon => 'Analytics screen is coming soon';

  @override
  String get budgetComingSoon => 'Budget screen is coming soon';

  @override
  String get restartOnboarding => 'Restart onboarding';

  @override
  String get restartOnboardingDescription => 'Go through the intro setup again';

  @override
  String get smartInputHint => 'Enter an expense in plain text';

  @override
  String get smartInputExample => 'Coffee 150';

  @override
  String get previewAmount => 'Amount';

  @override
  String get previewCurrency => 'Currency';

  @override
  String get previewCategory => 'Category';

  @override
  String get previewMerchant => 'Merchant';

  @override
  String get saveExpenseButton => 'Save expense';

  @override
  String get categoryFood => 'Food';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categorySubscriptions => 'Subscriptions';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryBills => 'Bills';

  @override
  String get categoryEducation => 'Education';

  @override
  String get categoryGifts => 'Gifts';

  @override
  String get categoryTravel => 'Travel';

  @override
  String get categoryOther => 'Other';

  @override
  String get onboardingValidationError => 'Please fill in all fields correctly';

  @override
  String get backButton => 'Back';

  @override
  String onboardingStepCounter(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get onboardingWelcomeTitle => 'A budget that thinks with you';

  @override
  String get onboardingWelcomeSubtitle =>
      'Add expenses fast, get forecasts, and see how much life time your spending really costs.';

  @override
  String get onboardingFeatureFastTitle => 'Fast input';

  @override
  String get onboardingFeatureFastSubtitle =>
      'Add expenses in seconds using plain text.';

  @override
  String get onboardingFeatureForecastTitle => 'Smart forecasts';

  @override
  String get onboardingFeatureForecastSubtitle =>
      'See early whether you are staying within your monthly budget.';

  @override
  String get onboardingFeatureLifeTitle => 'Life map';

  @override
  String get onboardingFeatureLifeSubtitle =>
      'See how many hours of your life different purchases are costing you.';

  @override
  String get onboardingMoneyTitle => 'Set up your money baseline';

  @override
  String get onboardingMoneySubtitle =>
      'Enter your income and monthly budget so the app can calculate forecasts and financial health.';

  @override
  String get onboardingLifeTitle => 'Set up the value of your time';

  @override
  String get onboardingLifeSubtitle =>
      'Add your work schedule so the app can convert spending into hours and minutes of life.';

  @override
  String get validationEnterPositiveIncome =>
      'Enter a valid income greater than zero';

  @override
  String get validationEnterPositiveBudget =>
      'Enter a valid budget greater than zero';

  @override
  String get validationEnterPositiveWorkDays =>
      'Enter a valid number of working days';

  @override
  String get validationEnterPositiveWorkHours =>
      'Enter a valid number of working hours';

  @override
  String get recentExpensesTitle => 'Recent expenses';

  @override
  String get emptyExpensesTitle => 'No expenses yet';

  @override
  String get emptyExpensesSubtitle =>
      'Add your first expense to start seeing your financial picture.';

  @override
  String get todaySection => 'Today';

  @override
  String get yesterdaySection => 'Yesterday';

  @override
  String get earlierSection => 'Earlier';

  @override
  String get expenseDeletedMessage => 'Expense deleted';

  @override
  String get currentMonthlyBudgetTitle => 'Current monthly budget';

  @override
  String get currentMonthlyBudgetSubtitle =>
      'Your spending limit for the current month';

  @override
  String get budgetSpentSubtitle => 'Already spent this month';

  @override
  String get remainingBudgetTitle => 'Remaining budget';

  @override
  String get remainingBudgetPositiveSubtitle => 'You are still within budget';

  @override
  String get remainingBudgetNegativeSubtitle => 'You are over budget';

  @override
  String get editBudgetButton => 'Edit budget';

  @override
  String get editBudgetDialogTitle => 'Edit monthly budget';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get saveButton => 'Save';

  @override
  String get analyticsEmptyTitle => 'Not enough data yet';

  @override
  String get analyticsEmptySubtitle =>
      'Add a few expenses to see category analytics.';

  @override
  String get analyticsTotalSpentTitle => 'Total spent';

  @override
  String get analyticsTotalSpentSubtitle =>
      'Your spending for the current month';

  @override
  String get analyticsCategoriesTitle => 'Spending categories';

  @override
  String get analyticsBreakdownTitle => 'Category breakdown';

  @override
  String get analyticsTopCategoryTitle => 'Top category';

  @override
  String analyticsTopCategorySubtitle(String amount) {
    return 'Spent: $amount';
  }

  @override
  String get financialRadarTitle => 'Financial radar';

  @override
  String get emptyInsightsTitle => 'No insights yet';

  @override
  String get emptyInsightsSubtitle =>
      'Add more expenses so the app can start detecting patterns.';

  @override
  String get analyticsInsightsTitle => 'Insights';

  @override
  String get insightOverBudgetTitle => 'You are over budget';

  @override
  String insightOverBudgetDescription(String amount) {
    return 'You are currently exceeding your budget by $amount.';
  }

  @override
  String get insightHealthyPaceTitle => 'Healthy monthly pace';

  @override
  String get insightHealthyPaceDescription =>
      'So far your spending pace looks calm and under control.';

  @override
  String get insightTopCategoryTitle => 'One category is dominating';

  @override
  String insightTopCategoryDescription(String percent) {
    return 'One category already makes up $percent% of your monthly spending.';
  }

  @override
  String get insightSubscriptionsTitle =>
      'Subscriptions are becoming noticeable';

  @override
  String insightSubscriptionsDescription(String amount, String percent) {
    return 'Subscriptions already consumed $amount and account for $percent% of this month’s spending.';
  }

  @override
  String get insightStrongScoreTitle => 'Strong financial shape';

  @override
  String get insightStrongScoreDescription =>
      'Your current habits look stable and disciplined.';

  @override
  String get insightLowScoreTitle => 'There is room to improve';

  @override
  String get insightLowScoreDescription =>
      'Your budget currently looks stressed and needs attention.';

  @override
  String get scoreExcellentTitle => 'Excellent financial rhythm';

  @override
  String get scoreExcellentDescription =>
      'You have a strong balance between spending, budget discipline, and stability.';

  @override
  String get scoreGoodTitle => 'Good financial shape';

  @override
  String get scoreGoodDescription =>
      'You are in a decent position, but some categories already deserve closer attention.';

  @override
  String get scoreMediumTitle => 'Unstable balance';

  @override
  String get scoreMediumDescription =>
      'Some signals look fine, but your budget is starting to wobble.';

  @override
  String get scoreWeakTitle => 'Weak financial contour';

  @override
  String get scoreWeakDescription =>
      'Now it is important to cut extra spending and regain control over your budget.';

  @override
  String get autoBudgetTitle => 'Automatic budget';

  @override
  String get autoBudgetSubtitle =>
      'Recommendation based on the last 30 days of spending';

  @override
  String get applyAutoBudgetButton => 'Apply recommendation';

  @override
  String get autoBudgetAppliedMessage => 'Automatic budget applied';

  @override
  String get openSubscriptionsButton => 'Open subscriptions';

  @override
  String get subscriptionsTitle => 'Subscriptions';

  @override
  String get subscriptionsSummaryTitle => 'Subscriptions summary';

  @override
  String get subscriptionsSummarySubtitle =>
      'Estimated recurring monthly costs';

  @override
  String get subscriptionsDetectedTitle => 'Detected subscriptions';

  @override
  String get subscriptionsEmptyState =>
      'No stable recurring payments detected yet.';

  @override
  String subscriptionsPotentialSavings(String amount) {
    return 'If you cut even half of these subscriptions, you could save around $amount per month.';
  }

  @override
  String subscriptionEstimatedMonthlyCost(String amount) {
    return 'Estimated monthly cost: $amount';
  }

  @override
  String subscriptionOccurrences(int count, int days) {
    return 'Payments: $count, average interval: $days days';
  }

  @override
  String get quickAddTitle => 'Quick add';

  @override
  String get addSourceSmartText => 'Text';

  @override
  String get addSourceVoice => 'Voice';

  @override
  String get addSourceReceipt => 'Receipt';

  @override
  String get voiceInputTitle => 'Voice input';

  @override
  String get voiceInputSubtitle =>
      'Soon you will be able to dictate an expense like “coffee 150 som” in seconds.';

  @override
  String get startVoiceInputButton => 'Start recording';

  @override
  String get receiptScanTitle => 'Receipt scan';

  @override
  String get receiptScanSubtitle =>
      'Soon you will be able to photograph a receipt and extract the amount automatically.';

  @override
  String get scanReceiptButton => 'Scan receipt';

  @override
  String get voiceComingSoonMessage =>
      'Voice input will be connected in the next step';

  @override
  String get receiptComingSoonMessage =>
      'Receipt scanning will be connected in the next step';

  @override
  String smartInputExampleWithCategory(String category) {
    return '$category 150';
  }

  @override
  String get voiceUnavailableMessage =>
      'Voice input is unavailable on this device or permissions were not granted';

  @override
  String voiceErrorMessage(String message) {
    return 'Voice input error: $message';
  }

  @override
  String get voiceLanguageLabel => 'Recognition language';

  @override
  String get stopVoiceInputButton => 'Stop recording';

  @override
  String get voiceRecognizedTextTitle => 'Recognized text';

  @override
  String get pickReceiptFromGalleryButton => 'Pick from gallery';

  @override
  String get receiptRecognizedTextTitle => 'Recognized receipt text';

  @override
  String receiptScanErrorMessage(String message) {
    return 'Receipt scan error: $message';
  }

  @override
  String get receiptNoTextFoundMessage =>
      'No text could be recognized in the image';

  @override
  String get receiptParsedSummaryTitle => 'Parsed receipt data';

  @override
  String receiptConfidenceLabel(String value) {
    return 'Recognition confidence: $value%';
  }

  @override
  String get financialLevelTitle => 'Financial level';

  @override
  String get openMonthlyReportButton => 'Open monthly report';

  @override
  String get monthlyReportTitle => 'Monthly report';

  @override
  String get monthlyReportLevelTitle => 'Your level this month';

  @override
  String get monthlyReportShareHint =>
      'A shareable monthly summary card will appear here later.';

  @override
  String monthlyReportIncome(String value) {
    return 'Income: $value';
  }

  @override
  String monthlyReportSpent(String value) {
    return 'Spent: $value';
  }

  @override
  String monthlyReportSaved(String value) {
    return 'Saved: $value';
  }

  @override
  String monthlyReportTopCategory(String value) {
    return 'Top category: $value';
  }

  @override
  String monthlyReportLifeSpent(String value) {
    return 'Life spent: $value';
  }

  @override
  String monthlyReportScore(int value) {
    return 'Health score: $value/100';
  }

  @override
  String get levelSurvivor => 'Level 1 — Survivor';

  @override
  String get levelPlanner => 'Level 2 — Planner';

  @override
  String get levelStrategist => 'Level 3 — Strategist';

  @override
  String get levelInvestor => 'Level 4 — Investor';

  @override
  String get levelSurvivorDescription =>
      'Right now the main goal is to regain control and stabilize your budget.';

  @override
  String get levelPlannerDescription =>
      'You are already starting to manage spending more consciously.';

  @override
  String get levelStrategistDescription =>
      'Your spending looks more intentional and your decisions more deliberate.';

  @override
  String get levelInvestorDescription =>
      'You are moving like someone who manages money instead of chasing it.';

  @override
  String get openShareCardButton => 'Open share card';

  @override
  String get shareCardScreenTitle => 'Monthly card';

  @override
  String get shareCardTitle => 'My monthly finances';

  @override
  String get shareCardSubtitle => 'A short summary you will be able to share';

  @override
  String get shareCardIncome => 'Income';

  @override
  String get shareCardSpent => 'Spent';

  @override
  String get shareCardSaved => 'Saved';

  @override
  String get shareCardTopCategory => 'Top category';

  @override
  String get shareCardLifeSpent => 'Life spent';

  @override
  String get shareCardHealthScore => 'Health score';

  @override
  String get shareCardLevel => 'Financial level';

  @override
  String get shareCardFooter => 'Budget planner that thinks for you.';

  @override
  String get shareCardHintTitle => 'Share-ready summary';

  @override
  String get shareCardHintSubtitle =>
      'The next step will add image export and system sharing for this card.';

  @override
  String get shareCardPrepareButton => 'Prepare card';

  @override
  String get shareCardExportComingSoon =>
      'Card export will be added in the next step';

  @override
  String get shareCardHintSubtitleReady =>
      'The card is now ready for PNG export and system sharing.';

  @override
  String get shareCardPreparingButton => 'Preparing...';

  @override
  String get shareCardShareButton => 'Share card';

  @override
  String get shareCardShareText => 'My monthly finances';

  @override
  String get shareCardRenderError => 'Could not prepare the card';

  @override
  String shareCardExportError(String message) {
    return 'Card export error: $message';
  }

  @override
  String get receiptReviewTitle => 'Receipt review';

  @override
  String get receiptFieldConfidenceTitle => 'Field confidence';

  @override
  String receiptAmountConfidence(String value) {
    return 'Amount: $value';
  }

  @override
  String receiptMerchantConfidence(String value) {
    return 'Merchant: $value';
  }

  @override
  String receiptDateConfidence(String value) {
    return 'Date: $value';
  }

  @override
  String get receiptCandidateAmountsTitle => 'Candidate amounts';

  @override
  String get receiptPickDateButton => 'Pick receipt date';

  @override
  String receiptPickedDateButton(String value) {
    return 'Receipt date: $value';
  }

  @override
  String get receiptConfirmParsedButton => 'Confirm parsed data';

  @override
  String get categoryBudgetsTitle => 'Category budgets';

  @override
  String get categoryBudgetsEmpty =>
      'No category budgets yet. Apply automatic budget to see the breakdown.';

  @override
  String budgetDangerTitle(String category) {
    return 'Risk category: $category';
  }

  @override
  String get budgetDangerSubtitle =>
      'This category is moving toward overspending the fastest.';

  @override
  String get goalsTab => 'Goals';

  @override
  String get goalsTitle => 'Savings goals';

  @override
  String get goalsEmptyTitle => 'No goal yet';

  @override
  String get goalsEmptySubtitle =>
      'Create a goal and the app will start showing how to reach it faster.';

  @override
  String get goalsCreateHint => 'Add a savings goal';

  @override
  String get goalCreateTitle => 'New goal';

  @override
  String get goalCreateButton => 'Create goal';

  @override
  String get goalReplaceButton => 'Replace goal';

  @override
  String get goalTitleLabel => 'Goal title';

  @override
  String get goalTargetAmountLabel => 'Target amount';

  @override
  String get goalPickDateButton => 'Pick deadline';

  @override
  String goalPickedDateButton(String value) {
    return 'Deadline: $value';
  }

  @override
  String get goalTitleError => 'Enter a goal title';

  @override
  String get goalAmountError => 'Enter a valid amount';

  @override
  String goalProgressValue(String current, String target) {
    return 'Progress: $current / $target';
  }

  @override
  String goalRemainingValue(String value) {
    return 'Remaining: $value';
  }

  @override
  String goalRecommendedPerMonth(String value) {
    return 'Needed per month: $value';
  }

  @override
  String get goalProjectionTitle => 'Goal projection';

  @override
  String get goalProjectionNoDate =>
      'This goal has no deadline yet. Add a date to see a plan.';

  @override
  String goalProjectionWithDate(String amount, int months) {
    return 'To stay on track, you need to save about $amount per month for $months months.';
  }

  @override
  String get goalProjectionNoCurrentRate =>
      'Not enough data yet to estimate your current saving pace.';

  @override
  String goalProjectionCurrentRate(int months) {
    return 'At your current pace, the goal could be reached in about $months months.';
  }

  @override
  String get goalAddProgressTitle => 'Add progress';

  @override
  String get goalAddProgressLabel => 'Contribution amount';

  @override
  String get goalAddProgressButton => 'Add progress';

  @override
  String get actionPlanTitle => 'Action plan';

  @override
  String get actionPlanEmptyTitle => 'No actions yet';

  @override
  String get actionPlanEmptySubtitle =>
      'As more data appears, the app will start suggesting concrete financial moves.';

  @override
  String get actionPlanCutCategoryTitle => 'Slow down in the risk category';

  @override
  String actionPlanCutCategoryDescription(String percent) {
    return 'This category has already reached $percent% of its limit. If you slow down now, the month will be calmer.';
  }

  @override
  String get actionPlanSubscriptionsTitle => 'Review subscriptions';

  @override
  String actionPlanSubscriptionsDescription(String amount, String half) {
    return 'Subscriptions take about $amount per month. Even cutting them in half could return around $half.';
  }

  @override
  String get actionPlanGoalTitle => 'Accelerate your goal';

  @override
  String actionPlanGoalDescription(String amount, String months) {
    return 'To stay on deadline, you need to save about $amount per month for another $months months.';
  }

  @override
  String get actionPlanScoreTitle => 'Strengthen your financial shape';

  @override
  String get actionPlanScoreDescription =>
      'Right now it is especially important to hold category limits and avoid inflating small recurring spending.';

  @override
  String get cashflowTab => 'Cashflow';

  @override
  String get cashflowTitle => 'Cashflow';

  @override
  String get cashflowSummaryTitle => 'Flow summary';

  @override
  String get cashflowNoSalaryDay => 'Salary day is not set yet';

  @override
  String cashflowSalaryDayValue(int value) {
    return 'Salary day: $value';
  }

  @override
  String cashflowRecurringBillsValue(int value) {
    return 'Recurring bills: $value';
  }

  @override
  String get cashflowTimelineTitle => 'Upcoming events';

  @override
  String get cashflowEmpty =>
      'No events yet. Add a salary day and recurring bills.';

  @override
  String get salaryDayTitle => 'Salary day';

  @override
  String get salaryDayLabel => 'Day of month';

  @override
  String get salaryDayButton => 'Set salary day';

  @override
  String get salaryDayError => 'Enter a day from 1 to 31';

  @override
  String get recurringBillCreateTitle => 'New recurring bill';

  @override
  String get recurringBillCreateButton => 'Add recurring bill';

  @override
  String get recurringBillTitleLabel => 'Title';

  @override
  String get recurringBillAmountLabel => 'Amount';

  @override
  String get recurringBillDayLabel => 'Day of month';

  @override
  String get recurringBillTitleError => 'Enter a bill title';

  @override
  String get recurringBillAmountError => 'Enter a valid amount';

  @override
  String get recurringBillDayError => 'Enter a day from 1 to 31';

  @override
  String get premiumTitle => 'Premium';

  @override
  String get premiumHeroTitle => 'Unlock the full financial navigator';

  @override
  String get premiumHeroSubtitle =>
      'Get AI insights, receipt OCR, voice input, cashflow timeline, advanced subscriptions, and action planner.';

  @override
  String get premiumFeatureAiInsights =>
      'AI insights and explainable recommendations';

  @override
  String get premiumFeatureVoice => 'Voice expense input';

  @override
  String get premiumFeatureReceipt => 'Receipt OCR and review flow';

  @override
  String get premiumFeatureSubscriptions => 'Advanced subscription analysis';

  @override
  String get premiumFeatureCashflow => 'Cashflow timeline and future events';

  @override
  String get premiumFeatureGoals => 'A stronger goals system';

  @override
  String get premiumFeatureShare => 'Card export and sharing';

  @override
  String get premiumUnlockButton => 'Unlock Premium';

  @override
  String get premiumDisableDebugButton => 'Disable Premium';

  @override
  String get openPremiumButton => 'Open Premium';

  @override
  String get premiumLockedInsightsTitle =>
      'AI insights are available in Premium';

  @override
  String get premiumLockedInsightsSubtitle =>
      'The app will be able to show smart signals, comparisons, and a financial radar.';

  @override
  String get premiumLockedActionPlanTitle =>
      'Action plan is available in Premium';

  @override
  String get premiumLockedActionPlanSubtitle =>
      'Get concrete steps to improve your budget and goals faster.';

  @override
  String get premiumLockedSubscriptionsTitle =>
      'Subscription detection is available in Premium';

  @override
  String get premiumLockedSubscriptionsSubtitle =>
      'The app will find recurring payments and show where money can be recovered.';

  @override
  String get premiumLockedCashflowTitle =>
      'Cashflow timeline is available in Premium';

  @override
  String get premiumLockedCashflowSubtitle =>
      'Track upcoming income and recurring charges in advance.';

  @override
  String get premiumLockedShareTitle => 'Card export is available in Premium';

  @override
  String get premiumLockedShareSubtitle =>
      'Save and share your monthly card as an image.';

  @override
  String get expenseEditTitle => 'Edit expense';

  @override
  String get expenseNoteLabel => 'Note';

  @override
  String expenseEditDateValue(String value) {
    return 'Date: $value';
  }

  @override
  String get monthCloseTitle => 'Month close';

  @override
  String get monthCloseCardTitle => 'Monthly wrap-up';

  @override
  String get monthCloseHomeTitle => 'Close the month with clarity';

  @override
  String get monthCloseHomeSubtitle =>
      'See what worked, what slipped, and what to focus on next.';

  @override
  String get monthCloseOpenButton => 'Open monthly wrap-up';

  @override
  String monthCloseSpentChange(String value) {
    return 'Spending change: $value';
  }

  @override
  String monthCloseHealthDelta(int value) {
    return 'Health score change: $value';
  }

  @override
  String get monthCloseWinTitle => 'This month was stronger than the last one';

  @override
  String get monthCloseWinSubtitle =>
      'You either reduced spending or improved your financial shape. That is a strong signal.';

  @override
  String get monthCloseFocusTitle => 'Next month needs a sharper focus';

  @override
  String get monthCloseFocusSubtitle =>
      'Right now it is especially important to reduce leaks and keep category limits under control.';

  @override
  String get monthCloseStartNextMonthButton => 'Start the next month smarter';

  @override
  String get streakTitle => 'Streak';

  @override
  String streakCurrentValue(int value) {
    return 'Current: $value days';
  }

  @override
  String streakBestValue(int value) {
    return 'Best: $value days';
  }

  @override
  String get streakTodayDone => 'You already have activity today';

  @override
  String get streakTodayMissing => 'You can still continue your streak today';

  @override
  String get achievementsTitle => 'Achievements';

  @override
  String get achievementFirstExpenseTitle => 'First expense';

  @override
  String get achievementFirstExpenseSubtitle =>
      'You started tracking your money consciously.';

  @override
  String get achievementTracker7Title => '7 days in a row';

  @override
  String get achievementTracker7Subtitle =>
      'A full week of consistent tracking.';

  @override
  String get achievementTracker30Title => '30 days in a row';

  @override
  String get achievementTracker30Subtitle => 'A whole month of stable habit.';

  @override
  String get achievementGoalStartedTitle => 'First goal';

  @override
  String get achievementGoalStartedSubtitle => 'You set a financial direction.';

  @override
  String get achievementGoalProgressTitle => 'First goal progress';

  @override
  String get achievementGoalProgressSubtitle =>
      'You started not just tracking, but moving forward.';

  @override
  String get achievementMonthCloseTitle => 'First month close';

  @override
  String get achievementMonthCloseSubtitle =>
      'You completed your monthly financial wrap-up.';

  @override
  String get achievementNoOverspendTitle => 'No overspend month';

  @override
  String get achievementNoOverspendSubtitle =>
      'You kept your spending within budget.';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get greetingNight => 'Good night';

  @override
  String get leftToSpend => 'LEFT TO SPEND';

  @override
  String get safeToSpendToday => 'SAFE TO SPEND TODAY';

  @override
  String get healthLabel => 'Health';

  @override
  String get daysLeftLabel => 'Days left';

  @override
  String get keepPaceBudget => 'Keep this pace to stay on budget';

  @override
  String get monthCloseNearTitle => 'Month Close is near!';

  @override
  String monthCloseNearSubtitle(int days) {
    return 'Only $days days left to stay in budget.';
  }

  @override
  String get aiInsightsTitle => 'AI Insights';

  @override
  String get seeAllAction => 'See all';

  @override
  String get historyAction => 'History';

  @override
  String get warningLabel => 'Warning';

  @override
  String get tipLabel => 'Tip';

  @override
  String get customCategory => 'Custom';

  @override
  String get gotItButton => 'Got it';

  @override
  String get addCustomCategoryTitle => 'New Category';

  @override
  String get addCustomCategorySubtitle =>
      'Custom categories will be available in the next update!';

  @override
  String get expensesHistoryTitle => 'Transaction History';

  @override
  String get expensesHistoryEmpty =>
      'No expenses found. Try changing the filters.';

  @override
  String get expenseFilterAllCategories => 'All Categories';

  @override
  String get expenseSortNewest => 'Newest First';

  @override
  String get expenseSortOldest => 'Oldest First';

  @override
  String get expenseSortHighest => 'Highest Amount';

  @override
  String get expenseSortLowest => 'Lowest Amount';

  @override
  String get expenseSearchHint => 'Search by merchant or note...';

  @override
  String get expenseFilterCategoryLabel => 'Category';

  @override
  String get expenseFilterSortLabel => 'Sort By';

  @override
  String expenseFilterStartDate(String date) {
    return 'From: $date';
  }

  @override
  String expenseFilterEndDate(String date) {
    return 'To: $date';
  }

  @override
  String get expenseFilterClearDates => 'Clear Dates';

  @override
  String get profileTitle => 'Profile';

  @override
  String get gamificationSection => 'Your Progress';

  @override
  String get preferencesSection => 'Preferences';

  @override
  String get dangerZoneSection => 'Danger Zone';

  @override
  String get subscriptionSection => 'Subscription';

  @override
  String get premiumActiveTitle => 'Budget Planner Premium';

  @override
  String get premiumUpgradeTitle => 'Upgrade to Premium';

  @override
  String get premiumActiveSubtitle => 'Active';

  @override
  String get premiumUpgradeSubtitle => 'Unlock AI Insights & Unlimited Goals';

  @override
  String get clearAllDataTitle => 'Clear All Data';

  @override
  String get clearDataDialogTitle => 'Delete All Data?';

  @override
  String get clearDataDialogContent =>
      'This will permanently delete all your expenses, budgets, and settings. This action cannot be undone.';

  @override
  String get deleteButton => 'Delete';

  @override
  String get dataClearedMessage => 'All data cleared';

  @override
  String get validationEnterValidAmount => 'Please enter a valid amount';

  @override
  String get receiptReviewSubtitle => 'Review the scanned details';

  @override
  String get categoryCustom => 'Custom Category';

  @override
  String get newCategoryButton => 'New';

  @override
  String get analyticsVsLastMonth => 'vs last month';

  @override
  String get analyticsDailyAvg => 'Daily Avg';

  @override
  String get analyticsTransactions => 'Transactions';

  @override
  String get analyticsLargestTransaction => 'Largest Transaction';

  @override
  String analyticsTransactionsCount(int count) {
    return '$count transactions';
  }

  @override
  String get aiCopilotTitle => 'AI Copilot';

  @override
  String get aiGreeting =>
      'Hello! I am your financial AI assistant. Here is what I\'ve noticed about your budget recently:';

  @override
  String get aiChatHint => 'Ask about your finances...';

  @override
  String get askAiAction => 'Ask AI';
}
