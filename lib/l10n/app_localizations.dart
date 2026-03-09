import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Budget Planner'**
  String get appTitle;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Budget Planner'**
  String get homeTitle;

  /// No description provided for @homeTab.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTab;

  /// No description provided for @analyticsTab.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analyticsTab;

  /// No description provided for @budgetTab.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budgetTab;

  /// No description provided for @settingsTab.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTab;

  /// No description provided for @spentThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Spent this month'**
  String get spentThisMonth;

  /// No description provided for @lifeSpent.
  ///
  /// In en, this message translates to:
  /// **'Life spent: {value}'**
  String lifeSpent(String value);

  /// No description provided for @financialHealthScore.
  ///
  /// In en, this message translates to:
  /// **'Financial Health Score'**
  String get financialHealthScore;

  /// No description provided for @monthlyFinancialPulse.
  ///
  /// In en, this message translates to:
  /// **'Your monthly financial pulse'**
  String get monthlyFinancialPulse;

  /// No description provided for @forecast.
  ///
  /// In en, this message translates to:
  /// **'Forecast'**
  String get forecast;

  /// No description provided for @setBudgetToUnlockForecast.
  ///
  /// In en, this message translates to:
  /// **'Set a budget to unlock forecast'**
  String get setBudgetToUnlockForecast;

  /// No description provided for @riskOfOverspending.
  ///
  /// In en, this message translates to:
  /// **'Risk of overspending this month'**
  String get riskOfOverspending;

  /// No description provided for @withinBudgetPace.
  ///
  /// In en, this message translates to:
  /// **'You are within budget pace'**
  String get withinBudgetPace;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get addExpense;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose the app language'**
  String get languageDescription;

  /// No description provided for @russian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get russian;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @notAvailableShort.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get notAvailableShort;

  /// No description provided for @scoreValue.
  ///
  /// In en, this message translates to:
  /// **'{value}/100'**
  String scoreValue(int value);

  /// No description provided for @durationMinutesOnly.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String durationMinutesOnly(int minutes);

  /// No description provided for @durationHoursOnly.
  ///
  /// In en, this message translates to:
  /// **'{hours} h'**
  String durationHoursOnly(int hours);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours} h {minutes} min'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Your money should feel clear'**
  String get onboardingTitle1;

  /// No description provided for @onboardingSubtitle1.
  ///
  /// In en, this message translates to:
  /// **'Set your monthly income and budget to unlock forecasts and life-based insights.'**
  String get onboardingSubtitle1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Translate money into life'**
  String get onboardingTitle2;

  /// No description provided for @onboardingSubtitle2.
  ///
  /// In en, this message translates to:
  /// **'Add your working schedule so the app can show how much time each expense costs.'**
  String get onboardingSubtitle2;

  /// No description provided for @monthlyIncomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly income'**
  String get monthlyIncomeLabel;

  /// No description provided for @monthlyBudgetLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly budget'**
  String get monthlyBudgetLabel;

  /// No description provided for @workDaysPerMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'Working days per month'**
  String get workDaysPerMonthLabel;

  /// No description provided for @workHoursPerDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Working hours per day'**
  String get workHoursPerDayLabel;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @finishButton.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finishButton;

  /// No description provided for @analyticsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Analytics screen is coming soon'**
  String get analyticsComingSoon;

  /// No description provided for @budgetComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Budget screen is coming soon'**
  String get budgetComingSoon;

  /// No description provided for @restartOnboarding.
  ///
  /// In en, this message translates to:
  /// **'Restart onboarding'**
  String get restartOnboarding;

  /// No description provided for @restartOnboardingDescription.
  ///
  /// In en, this message translates to:
  /// **'Go through the intro setup again'**
  String get restartOnboardingDescription;

  /// No description provided for @smartInputHint.
  ///
  /// In en, this message translates to:
  /// **'Enter an expense in plain text'**
  String get smartInputHint;

  /// No description provided for @smartInputExample.
  ///
  /// In en, this message translates to:
  /// **'Coffee 150'**
  String get smartInputExample;

  /// No description provided for @previewAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get previewAmount;

  /// No description provided for @previewCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get previewCurrency;

  /// No description provided for @previewCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get previewCategory;

  /// No description provided for @previewMerchant.
  ///
  /// In en, this message translates to:
  /// **'Merchant'**
  String get previewMerchant;

  /// No description provided for @saveExpenseButton.
  ///
  /// In en, this message translates to:
  /// **'Save expense'**
  String get saveExpenseButton;

  /// No description provided for @categoryFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get categoryFood;

  /// No description provided for @categoryTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get categoryTransport;

  /// No description provided for @categorySubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get categorySubscriptions;

  /// No description provided for @categoryEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get categoryEntertainment;

  /// No description provided for @categoryShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get categoryShopping;

  /// No description provided for @categoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get categoryHealth;

  /// No description provided for @categoryBills.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get categoryBills;

  /// No description provided for @categoryEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get categoryEducation;

  /// No description provided for @categoryGifts.
  ///
  /// In en, this message translates to:
  /// **'Gifts'**
  String get categoryGifts;

  /// No description provided for @categoryTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get categoryTravel;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @onboardingValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields correctly'**
  String get onboardingValidationError;

  /// No description provided for @backButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backButton;

  /// No description provided for @onboardingStepCounter.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String onboardingStepCounter(int current, int total);

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'A budget that thinks with you'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add expenses fast, get forecasts, and see how much life time your spending really costs.'**
  String get onboardingWelcomeSubtitle;

  /// No description provided for @onboardingFeatureFastTitle.
  ///
  /// In en, this message translates to:
  /// **'Fast input'**
  String get onboardingFeatureFastTitle;

  /// No description provided for @onboardingFeatureFastSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add expenses in seconds using plain text.'**
  String get onboardingFeatureFastSubtitle;

  /// No description provided for @onboardingFeatureForecastTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart forecasts'**
  String get onboardingFeatureForecastTitle;

  /// No description provided for @onboardingFeatureForecastSubtitle.
  ///
  /// In en, this message translates to:
  /// **'See early whether you are staying within your monthly budget.'**
  String get onboardingFeatureForecastSubtitle;

  /// No description provided for @onboardingFeatureLifeTitle.
  ///
  /// In en, this message translates to:
  /// **'Life map'**
  String get onboardingFeatureLifeTitle;

  /// No description provided for @onboardingFeatureLifeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'See how many hours of your life different purchases are costing you.'**
  String get onboardingFeatureLifeSubtitle;

  /// No description provided for @onboardingMoneyTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your money baseline'**
  String get onboardingMoneyTitle;

  /// No description provided for @onboardingMoneySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your income and monthly budget so the app can calculate forecasts and financial health.'**
  String get onboardingMoneySubtitle;

  /// No description provided for @onboardingLifeTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up the value of your time'**
  String get onboardingLifeTitle;

  /// No description provided for @onboardingLifeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your work schedule so the app can convert spending into hours and minutes of life.'**
  String get onboardingLifeSubtitle;

  /// No description provided for @validationEnterPositiveIncome.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid income greater than zero'**
  String get validationEnterPositiveIncome;

  /// No description provided for @validationEnterPositiveBudget.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid budget greater than zero'**
  String get validationEnterPositiveBudget;

  /// No description provided for @validationEnterPositiveWorkDays.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number of working days'**
  String get validationEnterPositiveWorkDays;

  /// No description provided for @validationEnterPositiveWorkHours.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number of working hours'**
  String get validationEnterPositiveWorkHours;

  /// No description provided for @recentExpensesTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent expenses'**
  String get recentExpensesTitle;

  /// No description provided for @emptyExpensesTitle.
  ///
  /// In en, this message translates to:
  /// **'No expenses yet'**
  String get emptyExpensesTitle;

  /// No description provided for @emptyExpensesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your first expense to start seeing your financial picture.'**
  String get emptyExpensesSubtitle;

  /// No description provided for @todaySection.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todaySection;

  /// No description provided for @yesterdaySection.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterdaySection;

  /// No description provided for @earlierSection.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get earlierSection;

  /// No description provided for @expenseDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Expense deleted'**
  String get expenseDeletedMessage;

  /// No description provided for @currentMonthlyBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Current monthly budget'**
  String get currentMonthlyBudgetTitle;

  /// No description provided for @currentMonthlyBudgetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your spending limit for the current month'**
  String get currentMonthlyBudgetSubtitle;

  /// No description provided for @budgetSpentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Already spent this month'**
  String get budgetSpentSubtitle;

  /// No description provided for @remainingBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Remaining budget'**
  String get remainingBudgetTitle;

  /// No description provided for @remainingBudgetPositiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You are still within budget'**
  String get remainingBudgetPositiveSubtitle;

  /// No description provided for @remainingBudgetNegativeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You are over budget'**
  String get remainingBudgetNegativeSubtitle;

  /// No description provided for @editBudgetButton.
  ///
  /// In en, this message translates to:
  /// **'Edit budget'**
  String get editBudgetButton;

  /// No description provided for @editBudgetDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit monthly budget'**
  String get editBudgetDialogTitle;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @analyticsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Not enough data yet'**
  String get analyticsEmptyTitle;

  /// No description provided for @analyticsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add a few expenses to see category analytics.'**
  String get analyticsEmptySubtitle;

  /// No description provided for @analyticsTotalSpentTitle.
  ///
  /// In en, this message translates to:
  /// **'Total spent'**
  String get analyticsTotalSpentTitle;

  /// No description provided for @analyticsTotalSpentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your spending for the current month'**
  String get analyticsTotalSpentSubtitle;

  /// No description provided for @analyticsCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Spending categories'**
  String get analyticsCategoriesTitle;

  /// No description provided for @analyticsBreakdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Category breakdown'**
  String get analyticsBreakdownTitle;

  /// No description provided for @analyticsTopCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Top category'**
  String get analyticsTopCategoryTitle;

  /// No description provided for @analyticsTopCategorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Spent: {amount}'**
  String analyticsTopCategorySubtitle(String amount);

  /// No description provided for @financialRadarTitle.
  ///
  /// In en, this message translates to:
  /// **'Financial radar'**
  String get financialRadarTitle;

  /// No description provided for @emptyInsightsTitle.
  ///
  /// In en, this message translates to:
  /// **'No insights yet'**
  String get emptyInsightsTitle;

  /// No description provided for @emptyInsightsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add more expenses so the app can start detecting patterns.'**
  String get emptyInsightsSubtitle;

  /// No description provided for @analyticsInsightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get analyticsInsightsTitle;

  /// No description provided for @insightOverBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'You are over budget'**
  String get insightOverBudgetTitle;

  /// No description provided for @insightOverBudgetDescription.
  ///
  /// In en, this message translates to:
  /// **'You are currently exceeding your budget by {amount}.'**
  String insightOverBudgetDescription(String amount);

  /// No description provided for @insightHealthyPaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Healthy monthly pace'**
  String get insightHealthyPaceTitle;

  /// No description provided for @insightHealthyPaceDescription.
  ///
  /// In en, this message translates to:
  /// **'So far your spending pace looks calm and under control.'**
  String get insightHealthyPaceDescription;

  /// No description provided for @insightTopCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'One category is dominating'**
  String get insightTopCategoryTitle;

  /// No description provided for @insightTopCategoryDescription.
  ///
  /// In en, this message translates to:
  /// **'One category already makes up {percent}% of your monthly spending.'**
  String insightTopCategoryDescription(String percent);

  /// No description provided for @insightSubscriptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions are becoming noticeable'**
  String get insightSubscriptionsTitle;

  /// No description provided for @insightSubscriptionsDescription.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions already consumed {amount} and account for {percent}% of this month’s spending.'**
  String insightSubscriptionsDescription(String amount, String percent);

  /// No description provided for @insightStrongScoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Strong financial shape'**
  String get insightStrongScoreTitle;

  /// No description provided for @insightStrongScoreDescription.
  ///
  /// In en, this message translates to:
  /// **'Your current habits look stable and disciplined.'**
  String get insightStrongScoreDescription;

  /// No description provided for @insightLowScoreTitle.
  ///
  /// In en, this message translates to:
  /// **'There is room to improve'**
  String get insightLowScoreTitle;

  /// No description provided for @insightLowScoreDescription.
  ///
  /// In en, this message translates to:
  /// **'Your budget currently looks stressed and needs attention.'**
  String get insightLowScoreDescription;

  /// No description provided for @scoreExcellentTitle.
  ///
  /// In en, this message translates to:
  /// **'Excellent financial rhythm'**
  String get scoreExcellentTitle;

  /// No description provided for @scoreExcellentDescription.
  ///
  /// In en, this message translates to:
  /// **'You have a strong balance between spending, budget discipline, and stability.'**
  String get scoreExcellentDescription;

  /// No description provided for @scoreGoodTitle.
  ///
  /// In en, this message translates to:
  /// **'Good financial shape'**
  String get scoreGoodTitle;

  /// No description provided for @scoreGoodDescription.
  ///
  /// In en, this message translates to:
  /// **'You are in a decent position, but some categories already deserve closer attention.'**
  String get scoreGoodDescription;

  /// No description provided for @scoreMediumTitle.
  ///
  /// In en, this message translates to:
  /// **'Unstable balance'**
  String get scoreMediumTitle;

  /// No description provided for @scoreMediumDescription.
  ///
  /// In en, this message translates to:
  /// **'Some signals look fine, but your budget is starting to wobble.'**
  String get scoreMediumDescription;

  /// No description provided for @scoreWeakTitle.
  ///
  /// In en, this message translates to:
  /// **'Weak financial contour'**
  String get scoreWeakTitle;

  /// No description provided for @scoreWeakDescription.
  ///
  /// In en, this message translates to:
  /// **'Now it is important to cut extra spending and regain control over your budget.'**
  String get scoreWeakDescription;

  /// No description provided for @autoBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Automatic budget'**
  String get autoBudgetTitle;

  /// No description provided for @autoBudgetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Recommendation based on the last 30 days of spending'**
  String get autoBudgetSubtitle;

  /// No description provided for @applyAutoBudgetButton.
  ///
  /// In en, this message translates to:
  /// **'Apply recommendation'**
  String get applyAutoBudgetButton;

  /// No description provided for @autoBudgetAppliedMessage.
  ///
  /// In en, this message translates to:
  /// **'Automatic budget applied'**
  String get autoBudgetAppliedMessage;

  /// No description provided for @openSubscriptionsButton.
  ///
  /// In en, this message translates to:
  /// **'Open subscriptions'**
  String get openSubscriptionsButton;

  /// No description provided for @subscriptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get subscriptionsTitle;

  /// No description provided for @subscriptionsSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions summary'**
  String get subscriptionsSummaryTitle;

  /// No description provided for @subscriptionsSummarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Estimated recurring monthly costs'**
  String get subscriptionsSummarySubtitle;

  /// No description provided for @subscriptionsDetectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Detected subscriptions'**
  String get subscriptionsDetectedTitle;

  /// No description provided for @subscriptionsEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No stable recurring payments detected yet.'**
  String get subscriptionsEmptyState;

  /// No description provided for @subscriptionsPotentialSavings.
  ///
  /// In en, this message translates to:
  /// **'If you cut even half of these subscriptions, you could save around {amount} per month.'**
  String subscriptionsPotentialSavings(String amount);

  /// No description provided for @subscriptionEstimatedMonthlyCost.
  ///
  /// In en, this message translates to:
  /// **'Estimated monthly cost: {amount}'**
  String subscriptionEstimatedMonthlyCost(String amount);

  /// No description provided for @subscriptionOccurrences.
  ///
  /// In en, this message translates to:
  /// **'Payments: {count}, average interval: {days} days'**
  String subscriptionOccurrences(int count, int days);

  /// No description provided for @quickAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick add'**
  String get quickAddTitle;

  /// No description provided for @addSourceSmartText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get addSourceSmartText;

  /// No description provided for @addSourceVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get addSourceVoice;

  /// No description provided for @addSourceReceipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get addSourceReceipt;

  /// No description provided for @voiceInputTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice input'**
  String get voiceInputTitle;

  /// No description provided for @voiceInputSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Soon you will be able to dictate an expense like “coffee 150 som” in seconds.'**
  String get voiceInputSubtitle;

  /// No description provided for @startVoiceInputButton.
  ///
  /// In en, this message translates to:
  /// **'Start recording'**
  String get startVoiceInputButton;

  /// No description provided for @receiptScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Receipt scan'**
  String get receiptScanTitle;

  /// No description provided for @receiptScanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Soon you will be able to photograph a receipt and extract the amount automatically.'**
  String get receiptScanSubtitle;

  /// No description provided for @scanReceiptButton.
  ///
  /// In en, this message translates to:
  /// **'Scan receipt'**
  String get scanReceiptButton;

  /// No description provided for @voiceComingSoonMessage.
  ///
  /// In en, this message translates to:
  /// **'Voice input will be connected in the next step'**
  String get voiceComingSoonMessage;

  /// No description provided for @receiptComingSoonMessage.
  ///
  /// In en, this message translates to:
  /// **'Receipt scanning will be connected in the next step'**
  String get receiptComingSoonMessage;

  /// No description provided for @smartInputExampleWithCategory.
  ///
  /// In en, this message translates to:
  /// **'{category} 150'**
  String smartInputExampleWithCategory(String category);

  /// No description provided for @voiceUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'Voice input is unavailable on this device or permissions were not granted'**
  String get voiceUnavailableMessage;

  /// No description provided for @voiceErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Voice input error: {message}'**
  String voiceErrorMessage(String message);

  /// No description provided for @voiceLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Recognition language'**
  String get voiceLanguageLabel;

  /// No description provided for @stopVoiceInputButton.
  ///
  /// In en, this message translates to:
  /// **'Stop recording'**
  String get stopVoiceInputButton;

  /// No description provided for @voiceRecognizedTextTitle.
  ///
  /// In en, this message translates to:
  /// **'Recognized text'**
  String get voiceRecognizedTextTitle;

  /// No description provided for @pickReceiptFromGalleryButton.
  ///
  /// In en, this message translates to:
  /// **'Pick from gallery'**
  String get pickReceiptFromGalleryButton;

  /// No description provided for @receiptRecognizedTextTitle.
  ///
  /// In en, this message translates to:
  /// **'Recognized receipt text'**
  String get receiptRecognizedTextTitle;

  /// No description provided for @receiptScanErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Receipt scan error: {message}'**
  String receiptScanErrorMessage(String message);

  /// No description provided for @receiptNoTextFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'No text could be recognized in the image'**
  String get receiptNoTextFoundMessage;

  /// No description provided for @receiptParsedSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Parsed receipt data'**
  String get receiptParsedSummaryTitle;

  /// No description provided for @receiptConfidenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Recognition confidence: {value}%'**
  String receiptConfidenceLabel(String value);

  /// No description provided for @financialLevelTitle.
  ///
  /// In en, this message translates to:
  /// **'Financial level'**
  String get financialLevelTitle;

  /// No description provided for @openMonthlyReportButton.
  ///
  /// In en, this message translates to:
  /// **'Open monthly report'**
  String get openMonthlyReportButton;

  /// No description provided for @monthlyReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly report'**
  String get monthlyReportTitle;

  /// No description provided for @monthlyReportLevelTitle.
  ///
  /// In en, this message translates to:
  /// **'Your level this month'**
  String get monthlyReportLevelTitle;

  /// No description provided for @monthlyReportShareHint.
  ///
  /// In en, this message translates to:
  /// **'A shareable monthly summary card will appear here later.'**
  String get monthlyReportShareHint;

  /// No description provided for @monthlyReportIncome.
  ///
  /// In en, this message translates to:
  /// **'Income: {value}'**
  String monthlyReportIncome(String value);

  /// No description provided for @monthlyReportSpent.
  ///
  /// In en, this message translates to:
  /// **'Spent: {value}'**
  String monthlyReportSpent(String value);

  /// No description provided for @monthlyReportSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved: {value}'**
  String monthlyReportSaved(String value);

  /// No description provided for @monthlyReportTopCategory.
  ///
  /// In en, this message translates to:
  /// **'Top category: {value}'**
  String monthlyReportTopCategory(String value);

  /// No description provided for @monthlyReportLifeSpent.
  ///
  /// In en, this message translates to:
  /// **'Life spent: {value}'**
  String monthlyReportLifeSpent(String value);

  /// No description provided for @monthlyReportScore.
  ///
  /// In en, this message translates to:
  /// **'Health score: {value}/100'**
  String monthlyReportScore(int value);

  /// No description provided for @levelSurvivor.
  ///
  /// In en, this message translates to:
  /// **'Level 1 — Survivor'**
  String get levelSurvivor;

  /// No description provided for @levelPlanner.
  ///
  /// In en, this message translates to:
  /// **'Level 2 — Planner'**
  String get levelPlanner;

  /// No description provided for @levelStrategist.
  ///
  /// In en, this message translates to:
  /// **'Level 3 — Strategist'**
  String get levelStrategist;

  /// No description provided for @levelInvestor.
  ///
  /// In en, this message translates to:
  /// **'Level 4 — Investor'**
  String get levelInvestor;

  /// No description provided for @levelSurvivorDescription.
  ///
  /// In en, this message translates to:
  /// **'Right now the main goal is to regain control and stabilize your budget.'**
  String get levelSurvivorDescription;

  /// No description provided for @levelPlannerDescription.
  ///
  /// In en, this message translates to:
  /// **'You are already starting to manage spending more consciously.'**
  String get levelPlannerDescription;

  /// No description provided for @levelStrategistDescription.
  ///
  /// In en, this message translates to:
  /// **'Your spending looks more intentional and your decisions more deliberate.'**
  String get levelStrategistDescription;

  /// No description provided for @levelInvestorDescription.
  ///
  /// In en, this message translates to:
  /// **'You are moving like someone who manages money instead of chasing it.'**
  String get levelInvestorDescription;

  /// No description provided for @openShareCardButton.
  ///
  /// In en, this message translates to:
  /// **'Open share card'**
  String get openShareCardButton;

  /// No description provided for @shareCardScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly card'**
  String get shareCardScreenTitle;

  /// No description provided for @shareCardTitle.
  ///
  /// In en, this message translates to:
  /// **'My monthly finances'**
  String get shareCardTitle;

  /// No description provided for @shareCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A short summary you will be able to share'**
  String get shareCardSubtitle;

  /// No description provided for @shareCardIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get shareCardIncome;

  /// No description provided for @shareCardSpent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get shareCardSpent;

  /// No description provided for @shareCardSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get shareCardSaved;

  /// No description provided for @shareCardTopCategory.
  ///
  /// In en, this message translates to:
  /// **'Top category'**
  String get shareCardTopCategory;

  /// No description provided for @shareCardLifeSpent.
  ///
  /// In en, this message translates to:
  /// **'Life spent'**
  String get shareCardLifeSpent;

  /// No description provided for @shareCardHealthScore.
  ///
  /// In en, this message translates to:
  /// **'Health score'**
  String get shareCardHealthScore;

  /// No description provided for @shareCardLevel.
  ///
  /// In en, this message translates to:
  /// **'Financial level'**
  String get shareCardLevel;

  /// No description provided for @shareCardFooter.
  ///
  /// In en, this message translates to:
  /// **'Budget planner that thinks for you.'**
  String get shareCardFooter;

  /// No description provided for @shareCardHintTitle.
  ///
  /// In en, this message translates to:
  /// **'Share-ready summary'**
  String get shareCardHintTitle;

  /// No description provided for @shareCardHintSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The next step will add image export and system sharing for this card.'**
  String get shareCardHintSubtitle;

  /// No description provided for @shareCardPrepareButton.
  ///
  /// In en, this message translates to:
  /// **'Prepare card'**
  String get shareCardPrepareButton;

  /// No description provided for @shareCardExportComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Card export will be added in the next step'**
  String get shareCardExportComingSoon;

  /// No description provided for @shareCardHintSubtitleReady.
  ///
  /// In en, this message translates to:
  /// **'The card is now ready for PNG export and system sharing.'**
  String get shareCardHintSubtitleReady;

  /// No description provided for @shareCardPreparingButton.
  ///
  /// In en, this message translates to:
  /// **'Preparing...'**
  String get shareCardPreparingButton;

  /// No description provided for @shareCardShareButton.
  ///
  /// In en, this message translates to:
  /// **'Share card'**
  String get shareCardShareButton;

  /// No description provided for @shareCardShareText.
  ///
  /// In en, this message translates to:
  /// **'My monthly finances'**
  String get shareCardShareText;

  /// No description provided for @shareCardRenderError.
  ///
  /// In en, this message translates to:
  /// **'Could not prepare the card'**
  String get shareCardRenderError;

  /// No description provided for @shareCardExportError.
  ///
  /// In en, this message translates to:
  /// **'Card export error: {message}'**
  String shareCardExportError(String message);

  /// No description provided for @receiptReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Receipt review'**
  String get receiptReviewTitle;

  /// No description provided for @receiptFieldConfidenceTitle.
  ///
  /// In en, this message translates to:
  /// **'Field confidence'**
  String get receiptFieldConfidenceTitle;

  /// No description provided for @receiptAmountConfidence.
  ///
  /// In en, this message translates to:
  /// **'Amount: {value}'**
  String receiptAmountConfidence(String value);

  /// No description provided for @receiptMerchantConfidence.
  ///
  /// In en, this message translates to:
  /// **'Merchant: {value}'**
  String receiptMerchantConfidence(String value);

  /// No description provided for @receiptDateConfidence.
  ///
  /// In en, this message translates to:
  /// **'Date: {value}'**
  String receiptDateConfidence(String value);

  /// No description provided for @receiptCandidateAmountsTitle.
  ///
  /// In en, this message translates to:
  /// **'Candidate amounts'**
  String get receiptCandidateAmountsTitle;

  /// No description provided for @receiptPickDateButton.
  ///
  /// In en, this message translates to:
  /// **'Pick receipt date'**
  String get receiptPickDateButton;

  /// No description provided for @receiptPickedDateButton.
  ///
  /// In en, this message translates to:
  /// **'Receipt date: {value}'**
  String receiptPickedDateButton(String value);

  /// No description provided for @receiptConfirmParsedButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm parsed data'**
  String get receiptConfirmParsedButton;

  /// No description provided for @categoryBudgetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Category budgets'**
  String get categoryBudgetsTitle;

  /// No description provided for @categoryBudgetsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No category budgets yet. Apply automatic budget to see the breakdown.'**
  String get categoryBudgetsEmpty;

  /// No description provided for @budgetDangerTitle.
  ///
  /// In en, this message translates to:
  /// **'Risk category: {category}'**
  String budgetDangerTitle(String category);

  /// No description provided for @budgetDangerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This category is moving toward overspending the fastest.'**
  String get budgetDangerSubtitle;

  /// No description provided for @goalsTab.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goalsTab;

  /// No description provided for @goalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Savings goals'**
  String get goalsTitle;

  /// No description provided for @goalsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No goal yet'**
  String get goalsEmptyTitle;

  /// No description provided for @goalsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a goal and the app will start showing how to reach it faster.'**
  String get goalsEmptySubtitle;

  /// No description provided for @goalsCreateHint.
  ///
  /// In en, this message translates to:
  /// **'Add a savings goal'**
  String get goalsCreateHint;

  /// No description provided for @goalCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'New goal'**
  String get goalCreateTitle;

  /// No description provided for @goalCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create goal'**
  String get goalCreateButton;

  /// No description provided for @goalReplaceButton.
  ///
  /// In en, this message translates to:
  /// **'Replace goal'**
  String get goalReplaceButton;

  /// No description provided for @goalTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Goal title'**
  String get goalTitleLabel;

  /// No description provided for @goalTargetAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Target amount'**
  String get goalTargetAmountLabel;

  /// No description provided for @goalPickDateButton.
  ///
  /// In en, this message translates to:
  /// **'Pick deadline'**
  String get goalPickDateButton;

  /// No description provided for @goalPickedDateButton.
  ///
  /// In en, this message translates to:
  /// **'Deadline: {value}'**
  String goalPickedDateButton(String value);

  /// No description provided for @goalTitleError.
  ///
  /// In en, this message translates to:
  /// **'Enter a goal title'**
  String get goalTitleError;

  /// No description provided for @goalAmountError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get goalAmountError;

  /// No description provided for @goalProgressValue.
  ///
  /// In en, this message translates to:
  /// **'Progress: {current} / {target}'**
  String goalProgressValue(String current, String target);

  /// No description provided for @goalRemainingValue.
  ///
  /// In en, this message translates to:
  /// **'Remaining: {value}'**
  String goalRemainingValue(String value);

  /// No description provided for @goalRecommendedPerMonth.
  ///
  /// In en, this message translates to:
  /// **'Needed per month: {value}'**
  String goalRecommendedPerMonth(String value);

  /// No description provided for @goalProjectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Goal projection'**
  String get goalProjectionTitle;

  /// No description provided for @goalProjectionNoDate.
  ///
  /// In en, this message translates to:
  /// **'This goal has no deadline yet. Add a date to see a plan.'**
  String get goalProjectionNoDate;

  /// No description provided for @goalProjectionWithDate.
  ///
  /// In en, this message translates to:
  /// **'To stay on track, you need to save about {amount} per month for {months} months.'**
  String goalProjectionWithDate(String amount, int months);

  /// No description provided for @goalProjectionNoCurrentRate.
  ///
  /// In en, this message translates to:
  /// **'Not enough data yet to estimate your current saving pace.'**
  String get goalProjectionNoCurrentRate;

  /// No description provided for @goalProjectionCurrentRate.
  ///
  /// In en, this message translates to:
  /// **'At your current pace, the goal could be reached in about {months} months.'**
  String goalProjectionCurrentRate(int months);

  /// No description provided for @goalAddProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Add progress'**
  String get goalAddProgressTitle;

  /// No description provided for @goalAddProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'Contribution amount'**
  String get goalAddProgressLabel;

  /// No description provided for @goalAddProgressButton.
  ///
  /// In en, this message translates to:
  /// **'Add progress'**
  String get goalAddProgressButton;

  /// No description provided for @actionPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Action plan'**
  String get actionPlanTitle;

  /// No description provided for @actionPlanEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No actions yet'**
  String get actionPlanEmptyTitle;

  /// No description provided for @actionPlanEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'As more data appears, the app will start suggesting concrete financial moves.'**
  String get actionPlanEmptySubtitle;

  /// No description provided for @actionPlanCutCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Slow down in the risk category'**
  String get actionPlanCutCategoryTitle;

  /// No description provided for @actionPlanCutCategoryDescription.
  ///
  /// In en, this message translates to:
  /// **'This category has already reached {percent}% of its limit. If you slow down now, the month will be calmer.'**
  String actionPlanCutCategoryDescription(String percent);

  /// No description provided for @actionPlanSubscriptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Review subscriptions'**
  String get actionPlanSubscriptionsTitle;

  /// No description provided for @actionPlanSubscriptionsDescription.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions take about {amount} per month. Even cutting them in half could return around {half}.'**
  String actionPlanSubscriptionsDescription(String amount, String half);

  /// No description provided for @actionPlanGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Accelerate your goal'**
  String get actionPlanGoalTitle;

  /// No description provided for @actionPlanGoalDescription.
  ///
  /// In en, this message translates to:
  /// **'To stay on deadline, you need to save about {amount} per month for another {months} months.'**
  String actionPlanGoalDescription(String amount, String months);

  /// No description provided for @actionPlanScoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Strengthen your financial shape'**
  String get actionPlanScoreTitle;

  /// No description provided for @actionPlanScoreDescription.
  ///
  /// In en, this message translates to:
  /// **'Right now it is especially important to hold category limits and avoid inflating small recurring spending.'**
  String get actionPlanScoreDescription;

  /// No description provided for @cashflowTab.
  ///
  /// In en, this message translates to:
  /// **'Cashflow'**
  String get cashflowTab;

  /// No description provided for @cashflowTitle.
  ///
  /// In en, this message translates to:
  /// **'Cashflow'**
  String get cashflowTitle;

  /// No description provided for @cashflowSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Flow summary'**
  String get cashflowSummaryTitle;

  /// No description provided for @cashflowNoSalaryDay.
  ///
  /// In en, this message translates to:
  /// **'Salary day is not set yet'**
  String get cashflowNoSalaryDay;

  /// No description provided for @cashflowSalaryDayValue.
  ///
  /// In en, this message translates to:
  /// **'Salary day: {value}'**
  String cashflowSalaryDayValue(int value);

  /// No description provided for @cashflowRecurringBillsValue.
  ///
  /// In en, this message translates to:
  /// **'Recurring bills: {value}'**
  String cashflowRecurringBillsValue(int value);

  /// No description provided for @cashflowTimelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Upcoming events'**
  String get cashflowTimelineTitle;

  /// No description provided for @cashflowEmpty.
  ///
  /// In en, this message translates to:
  /// **'No events yet. Add a salary day and recurring bills.'**
  String get cashflowEmpty;

  /// No description provided for @salaryDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Salary day'**
  String get salaryDayTitle;

  /// No description provided for @salaryDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Day of month'**
  String get salaryDayLabel;

  /// No description provided for @salaryDayButton.
  ///
  /// In en, this message translates to:
  /// **'Set salary day'**
  String get salaryDayButton;

  /// No description provided for @salaryDayError.
  ///
  /// In en, this message translates to:
  /// **'Enter a day from 1 to 31'**
  String get salaryDayError;

  /// No description provided for @recurringBillCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'New recurring bill'**
  String get recurringBillCreateTitle;

  /// No description provided for @recurringBillCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Add recurring bill'**
  String get recurringBillCreateButton;

  /// No description provided for @recurringBillTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get recurringBillTitleLabel;

  /// No description provided for @recurringBillAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get recurringBillAmountLabel;

  /// No description provided for @recurringBillDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Day of month'**
  String get recurringBillDayLabel;

  /// No description provided for @recurringBillTitleError.
  ///
  /// In en, this message translates to:
  /// **'Enter a bill title'**
  String get recurringBillTitleError;

  /// No description provided for @recurringBillAmountError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get recurringBillAmountError;

  /// No description provided for @recurringBillDayError.
  ///
  /// In en, this message translates to:
  /// **'Enter a day from 1 to 31'**
  String get recurringBillDayError;

  /// No description provided for @premiumTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premiumTitle;

  /// No description provided for @premiumHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock the full financial navigator'**
  String get premiumHeroTitle;

  /// No description provided for @premiumHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get AI insights, receipt OCR, voice input, cashflow timeline, advanced subscriptions, and action planner.'**
  String get premiumHeroSubtitle;

  /// No description provided for @premiumFeatureAiInsights.
  ///
  /// In en, this message translates to:
  /// **'AI insights and explainable recommendations'**
  String get premiumFeatureAiInsights;

  /// No description provided for @premiumFeatureVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice expense input'**
  String get premiumFeatureVoice;

  /// No description provided for @premiumFeatureReceipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt OCR and review flow'**
  String get premiumFeatureReceipt;

  /// No description provided for @premiumFeatureSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Advanced subscription analysis'**
  String get premiumFeatureSubscriptions;

  /// No description provided for @premiumFeatureCashflow.
  ///
  /// In en, this message translates to:
  /// **'Cashflow timeline and future events'**
  String get premiumFeatureCashflow;

  /// No description provided for @premiumFeatureGoals.
  ///
  /// In en, this message translates to:
  /// **'A stronger goals system'**
  String get premiumFeatureGoals;

  /// No description provided for @premiumFeatureShare.
  ///
  /// In en, this message translates to:
  /// **'Card export and sharing'**
  String get premiumFeatureShare;

  /// No description provided for @premiumUnlockButton.
  ///
  /// In en, this message translates to:
  /// **'Unlock Premium'**
  String get premiumUnlockButton;

  /// No description provided for @premiumDisableDebugButton.
  ///
  /// In en, this message translates to:
  /// **'Disable Premium'**
  String get premiumDisableDebugButton;

  /// No description provided for @openPremiumButton.
  ///
  /// In en, this message translates to:
  /// **'Open Premium'**
  String get openPremiumButton;

  /// No description provided for @premiumLockedInsightsTitle.
  ///
  /// In en, this message translates to:
  /// **'AI insights are available in Premium'**
  String get premiumLockedInsightsTitle;

  /// No description provided for @premiumLockedInsightsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The app will be able to show smart signals, comparisons, and a financial radar.'**
  String get premiumLockedInsightsSubtitle;

  /// No description provided for @premiumLockedActionPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Action plan is available in Premium'**
  String get premiumLockedActionPlanTitle;

  /// No description provided for @premiumLockedActionPlanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get concrete steps to improve your budget and goals faster.'**
  String get premiumLockedActionPlanSubtitle;

  /// No description provided for @premiumLockedSubscriptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscription detection is available in Premium'**
  String get premiumLockedSubscriptionsTitle;

  /// No description provided for @premiumLockedSubscriptionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The app will find recurring payments and show where money can be recovered.'**
  String get premiumLockedSubscriptionsSubtitle;

  /// No description provided for @premiumLockedCashflowTitle.
  ///
  /// In en, this message translates to:
  /// **'Cashflow timeline is available in Premium'**
  String get premiumLockedCashflowTitle;

  /// No description provided for @premiumLockedCashflowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track upcoming income and recurring charges in advance.'**
  String get premiumLockedCashflowSubtitle;

  /// No description provided for @premiumLockedShareTitle.
  ///
  /// In en, this message translates to:
  /// **'Card export is available in Premium'**
  String get premiumLockedShareTitle;

  /// No description provided for @premiumLockedShareSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save and share your monthly card as an image.'**
  String get premiumLockedShareSubtitle;

  /// No description provided for @expenseEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit expense'**
  String get expenseEditTitle;

  /// No description provided for @expenseNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get expenseNoteLabel;

  /// No description provided for @expenseEditDateValue.
  ///
  /// In en, this message translates to:
  /// **'Date: {value}'**
  String expenseEditDateValue(String value);

  /// No description provided for @monthCloseTitle.
  ///
  /// In en, this message translates to:
  /// **'Month close'**
  String get monthCloseTitle;

  /// No description provided for @monthCloseCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly wrap-up'**
  String get monthCloseCardTitle;

  /// No description provided for @monthCloseHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Close the month with clarity'**
  String get monthCloseHomeTitle;

  /// No description provided for @monthCloseHomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'See what worked, what slipped, and what to focus on next.'**
  String get monthCloseHomeSubtitle;

  /// No description provided for @monthCloseOpenButton.
  ///
  /// In en, this message translates to:
  /// **'Open monthly wrap-up'**
  String get monthCloseOpenButton;

  /// No description provided for @monthCloseSpentChange.
  ///
  /// In en, this message translates to:
  /// **'Spending change: {value}'**
  String monthCloseSpentChange(String value);

  /// No description provided for @monthCloseHealthDelta.
  ///
  /// In en, this message translates to:
  /// **'Health score change: {value}'**
  String monthCloseHealthDelta(int value);

  /// No description provided for @monthCloseWinTitle.
  ///
  /// In en, this message translates to:
  /// **'This month was stronger than the last one'**
  String get monthCloseWinTitle;

  /// No description provided for @monthCloseWinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You either reduced spending or improved your financial shape. That is a strong signal.'**
  String get monthCloseWinSubtitle;

  /// No description provided for @monthCloseFocusTitle.
  ///
  /// In en, this message translates to:
  /// **'Next month needs a sharper focus'**
  String get monthCloseFocusTitle;

  /// No description provided for @monthCloseFocusSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Right now it is especially important to reduce leaks and keep category limits under control.'**
  String get monthCloseFocusSubtitle;

  /// No description provided for @monthCloseStartNextMonthButton.
  ///
  /// In en, this message translates to:
  /// **'Start the next month smarter'**
  String get monthCloseStartNextMonthButton;

  /// No description provided for @streakTitle.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streakTitle;

  /// No description provided for @streakCurrentValue.
  ///
  /// In en, this message translates to:
  /// **'Current: {value} days'**
  String streakCurrentValue(int value);

  /// No description provided for @streakBestValue.
  ///
  /// In en, this message translates to:
  /// **'Best: {value} days'**
  String streakBestValue(int value);

  /// No description provided for @streakTodayDone.
  ///
  /// In en, this message translates to:
  /// **'You already have activity today'**
  String get streakTodayDone;

  /// No description provided for @streakTodayMissing.
  ///
  /// In en, this message translates to:
  /// **'You can still continue your streak today'**
  String get streakTodayMissing;

  /// No description provided for @achievementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievementsTitle;

  /// No description provided for @achievementFirstExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'First expense'**
  String get achievementFirstExpenseTitle;

  /// No description provided for @achievementFirstExpenseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You started tracking your money consciously.'**
  String get achievementFirstExpenseSubtitle;

  /// No description provided for @achievementTracker7Title.
  ///
  /// In en, this message translates to:
  /// **'7 days in a row'**
  String get achievementTracker7Title;

  /// No description provided for @achievementTracker7Subtitle.
  ///
  /// In en, this message translates to:
  /// **'A full week of consistent tracking.'**
  String get achievementTracker7Subtitle;

  /// No description provided for @achievementTracker30Title.
  ///
  /// In en, this message translates to:
  /// **'30 days in a row'**
  String get achievementTracker30Title;

  /// No description provided for @achievementTracker30Subtitle.
  ///
  /// In en, this message translates to:
  /// **'A whole month of stable habit.'**
  String get achievementTracker30Subtitle;

  /// No description provided for @achievementGoalStartedTitle.
  ///
  /// In en, this message translates to:
  /// **'First goal'**
  String get achievementGoalStartedTitle;

  /// No description provided for @achievementGoalStartedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You set a financial direction.'**
  String get achievementGoalStartedSubtitle;

  /// No description provided for @achievementGoalProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'First goal progress'**
  String get achievementGoalProgressTitle;

  /// No description provided for @achievementGoalProgressSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You started not just tracking, but moving forward.'**
  String get achievementGoalProgressSubtitle;

  /// No description provided for @achievementMonthCloseTitle.
  ///
  /// In en, this message translates to:
  /// **'First month close'**
  String get achievementMonthCloseTitle;

  /// No description provided for @achievementMonthCloseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You completed your monthly financial wrap-up.'**
  String get achievementMonthCloseSubtitle;

  /// No description provided for @achievementNoOverspendTitle.
  ///
  /// In en, this message translates to:
  /// **'No overspend month'**
  String get achievementNoOverspendTitle;

  /// No description provided for @achievementNoOverspendSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You kept your spending within budget.'**
  String get achievementNoOverspendSubtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
