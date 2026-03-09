// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Планировщик бюджета';

  @override
  String get homeTitle => 'Планировщик бюджета';

  @override
  String get homeTab => 'Главная';

  @override
  String get analyticsTab => 'Аналитика';

  @override
  String get budgetTab => 'Бюджет';

  @override
  String get settingsTab => 'Настройки';

  @override
  String get spentThisMonth => 'Потрачено за месяц';

  @override
  String lifeSpent(String value) {
    return 'Потрачено жизни: $value';
  }

  @override
  String get financialHealthScore => 'Индекс финансового здоровья';

  @override
  String get monthlyFinancialPulse => 'Ваш финансовый пульс за месяц';

  @override
  String get forecast => 'Прогноз';

  @override
  String get setBudgetToUnlockForecast =>
      'Установите бюджет, чтобы открыть прогноз';

  @override
  String get riskOfOverspending => 'Есть риск выйти за бюджет в этом месяце';

  @override
  String get withinBudgetPace => 'Вы укладываетесь в темп бюджета';

  @override
  String get addExpense => 'Добавить расход';

  @override
  String get language => 'Язык';

  @override
  String get languageDescription => 'Выберите язык приложения';

  @override
  String get russian => 'Русский';

  @override
  String get english => 'Английский';

  @override
  String get notAvailableShort => '—';

  @override
  String scoreValue(int value) {
    return '$value/100';
  }

  @override
  String durationMinutesOnly(int minutes) {
    return '$minutes мин';
  }

  @override
  String durationHoursOnly(int hours) {
    return '$hours ч';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours ч $minutes мин';
  }

  @override
  String get onboardingTitle1 => 'Деньги должны быть понятными';

  @override
  String get onboardingSubtitle1 =>
      'Укажите доход и месячный бюджет, чтобы открыть прогнозы и инсайты на основе жизни.';

  @override
  String get onboardingTitle2 => 'Переводите деньги во время жизни';

  @override
  String get onboardingSubtitle2 =>
      'Добавьте свой рабочий график, чтобы приложение показывало, сколько времени стоит каждая трата.';

  @override
  String get monthlyIncomeLabel => 'Доход в месяц';

  @override
  String get monthlyBudgetLabel => 'Бюджет на месяц';

  @override
  String get workDaysPerMonthLabel => 'Рабочих дней в месяц';

  @override
  String get workHoursPerDayLabel => 'Рабочих часов в день';

  @override
  String get continueButton => 'Далее';

  @override
  String get finishButton => 'Готово';

  @override
  String get analyticsComingSoon => 'Экран аналитики скоро появится';

  @override
  String get budgetComingSoon => 'Экран бюджета скоро появится';

  @override
  String get restartOnboarding => 'Пройти онбординг заново';

  @override
  String get restartOnboardingDescription =>
      'Снова открыть начальную настройку';

  @override
  String get smartInputHint => 'Введите расход обычным текстом';

  @override
  String get smartInputExample => 'Кофе 150';

  @override
  String get previewAmount => 'Сумма';

  @override
  String get previewCurrency => 'Валюта';

  @override
  String get previewCategory => 'Категория';

  @override
  String get previewMerchant => 'Место';

  @override
  String get saveExpenseButton => 'Сохранить расход';

  @override
  String get categoryFood => 'Еда';

  @override
  String get categoryTransport => 'Транспорт';

  @override
  String get categorySubscriptions => 'Подписки';

  @override
  String get categoryEntertainment => 'Развлечения';

  @override
  String get categoryShopping => 'Покупки';

  @override
  String get categoryHealth => 'Здоровье';

  @override
  String get categoryBills => 'Счета';

  @override
  String get categoryEducation => 'Образование';

  @override
  String get categoryGifts => 'Подарки';

  @override
  String get categoryTravel => 'Путешествия';

  @override
  String get categoryOther => 'Другое';

  @override
  String get onboardingValidationError =>
      'Пожалуйста, заполните все поля корректно';

  @override
  String get backButton => 'Назад';

  @override
  String onboardingStepCounter(int current, int total) {
    return 'Шаг $current из $total';
  }

  @override
  String get onboardingWelcomeTitle => 'Бюджет, который думает вместе с вами';

  @override
  String get onboardingWelcomeSubtitle =>
      'Быстро добавляйте расходы, получайте прогнозы и смотрите, сколько времени жизни стоят ваши траты.';

  @override
  String get onboardingFeatureFastTitle => 'Быстрый ввод';

  @override
  String get onboardingFeatureFastSubtitle =>
      'Добавляйте расходы за пару секунд обычным текстом.';

  @override
  String get onboardingFeatureForecastTitle => 'Умные прогнозы';

  @override
  String get onboardingFeatureForecastSubtitle =>
      'Понимайте заранее, укладываетесь ли вы в бюджет месяца.';

  @override
  String get onboardingFeatureLifeTitle => 'Карта жизни';

  @override
  String get onboardingFeatureLifeSubtitle =>
      'Смотрите, сколько часов вашей жизни уходит на разные покупки.';

  @override
  String get onboardingMoneyTitle => 'Настройте финансовую основу';

  @override
  String get onboardingMoneySubtitle =>
      'Укажите доход и месячный бюджет, чтобы приложение могло считать прогноз и индекс здоровья бюджета.';

  @override
  String get onboardingLifeTitle => 'Настройте стоимость вашего времени';

  @override
  String get onboardingLifeSubtitle =>
      'Добавьте рабочий график, чтобы приложение переводило траты в часы и минуты жизни.';

  @override
  String get validationEnterPositiveIncome =>
      'Введите корректный доход больше нуля';

  @override
  String get validationEnterPositiveBudget =>
      'Введите корректный бюджет больше нуля';

  @override
  String get validationEnterPositiveWorkDays =>
      'Введите корректное число рабочих дней';

  @override
  String get validationEnterPositiveWorkHours =>
      'Введите корректное число рабочих часов';

  @override
  String get recentExpensesTitle => 'Последние расходы';

  @override
  String get emptyExpensesTitle => 'Пока нет расходов';

  @override
  String get emptyExpensesSubtitle =>
      'Добавьте первый расход, чтобы начать видеть свою финансовую картину.';

  @override
  String get todaySection => 'Сегодня';

  @override
  String get yesterdaySection => 'Вчера';

  @override
  String get earlierSection => 'Ранее';

  @override
  String get expenseDeletedMessage => 'Расход удалён';

  @override
  String get currentMonthlyBudgetTitle => 'Текущий месячный бюджет';

  @override
  String get currentMonthlyBudgetSubtitle =>
      'Ваш лимит расходов на текущий месяц';

  @override
  String get budgetSpentSubtitle => 'Уже потрачено в этом месяце';

  @override
  String get remainingBudgetTitle => 'Остаток бюджета';

  @override
  String get remainingBudgetPositiveSubtitle => 'Вы всё ещё в пределах бюджета';

  @override
  String get remainingBudgetNegativeSubtitle => 'Вы вышли за пределы бюджета';

  @override
  String get editBudgetButton => 'Изменить бюджет';

  @override
  String get editBudgetDialogTitle => 'Изменить месячный бюджет';

  @override
  String get cancelButton => 'Отмена';

  @override
  String get saveButton => 'Сохранить';

  @override
  String get analyticsEmptyTitle => 'Пока недостаточно данных';

  @override
  String get analyticsEmptySubtitle =>
      'Добавьте несколько расходов, чтобы увидеть аналитику по категориям.';

  @override
  String get analyticsTotalSpentTitle => 'Всего потрачено';

  @override
  String get analyticsTotalSpentSubtitle => 'Сумма расходов за текущий месяц';

  @override
  String get analyticsCategoriesTitle => 'Категории расходов';

  @override
  String get analyticsBreakdownTitle => 'Разбивка по категориям';

  @override
  String get analyticsTopCategoryTitle => 'Главная категория';

  @override
  String analyticsTopCategorySubtitle(String amount) {
    return 'Потрачено: $amount';
  }

  @override
  String get financialRadarTitle => 'Финансовый радар';

  @override
  String get emptyInsightsTitle => 'Пока нет инсайтов';

  @override
  String get emptyInsightsSubtitle =>
      'Добавьте больше расходов, чтобы приложение начало видеть закономерности.';

  @override
  String get analyticsInsightsTitle => 'Инсайты';

  @override
  String get insightOverBudgetTitle => 'Вы вышли за бюджет';

  @override
  String insightOverBudgetDescription(String amount) {
    return 'Сейчас вы превышаете бюджет на $amount.';
  }

  @override
  String get insightHealthyPaceTitle => 'Хороший темп месяца';

  @override
  String get insightHealthyPaceDescription =>
      'Пока вы тратите спокойно и остаетесь в здоровом темпе.';

  @override
  String get insightTopCategoryTitle => 'Одна категория доминирует';

  @override
  String insightTopCategoryDescription(String percent) {
    return 'Одна категория уже занимает $percent% ваших трат за месяц.';
  }

  @override
  String get insightSubscriptionsTitle => 'Подписки стали заметными';

  @override
  String insightSubscriptionsDescription(String amount, String percent) {
    return 'Подписки уже съели $amount и занимают $percent% расходов месяца.';
  }

  @override
  String get insightStrongScoreTitle => 'Сильная финансовая форма';

  @override
  String get insightStrongScoreDescription =>
      'Ваши текущие привычки выглядят устойчиво и аккуратно.';

  @override
  String get insightLowScoreTitle => 'Есть пространство для улучшения';

  @override
  String get insightLowScoreDescription =>
      'Ваш бюджет пока выглядит напряженным и требует внимания.';

  @override
  String get scoreExcellentTitle => 'Отличный финансовый ритм';

  @override
  String get scoreExcellentDescription =>
      'У вас сильный баланс между расходами, бюджетом и устойчивостью.';

  @override
  String get scoreGoodTitle => 'Хорошая финансовая форма';

  @override
  String get scoreGoodDescription =>
      'Вы в неплохой позиции, но некоторые категории уже стоит держать под контролем.';

  @override
  String get scoreMediumTitle => 'Нестабильный баланс';

  @override
  String get scoreMediumDescription =>
      'Часть сигналов выглядит нормально, но бюджет уже начинает шататься.';

  @override
  String get scoreWeakTitle => 'Слабый финансовый контур';

  @override
  String get scoreWeakDescription =>
      'Сейчас важно сократить лишние траты и вернуть контроль над бюджетом.';

  @override
  String get autoBudgetTitle => 'Автоматический бюджет';

  @override
  String get autoBudgetSubtitle =>
      'Рекомендация на основе последних 30 дней расходов';

  @override
  String get applyAutoBudgetButton => 'Применить рекомендацию';

  @override
  String get autoBudgetAppliedMessage => 'Автоматический бюджет применён';

  @override
  String get openSubscriptionsButton => 'Открыть подписки';

  @override
  String get subscriptionsTitle => 'Подписки';

  @override
  String get subscriptionsSummaryTitle => 'Сводка по подпискам';

  @override
  String get subscriptionsSummarySubtitle =>
      'Оценка повторяющихся расходов в месяц';

  @override
  String get subscriptionsDetectedTitle => 'Обнаруженные подписки';

  @override
  String get subscriptionsEmptyState =>
      'Пока не найдено устойчивых повторяющихся платежей.';

  @override
  String subscriptionsPotentialSavings(String amount) {
    return 'Если сократить хотя бы половину этих подписок, можно вернуть около $amount в месяц.';
  }

  @override
  String subscriptionEstimatedMonthlyCost(String amount) {
    return 'Оценка в месяц: $amount';
  }

  @override
  String subscriptionOccurrences(int count, int days) {
    return 'Платежей: $count, средний интервал: $days дней';
  }

  @override
  String get quickAddTitle => 'Быстрое добавление';

  @override
  String get addSourceSmartText => 'Текст';

  @override
  String get addSourceVoice => 'Голос';

  @override
  String get addSourceReceipt => 'Чек';

  @override
  String get voiceInputTitle => 'Голосовой ввод';

  @override
  String get voiceInputSubtitle =>
      'Скоро здесь можно будет быстро надиктовать расход вроде «кофе 150 сом».';

  @override
  String get startVoiceInputButton => 'Начать запись';

  @override
  String get receiptScanTitle => 'Сканирование чека';

  @override
  String get receiptScanSubtitle =>
      'Скоро здесь можно будет сфотографировать чек и извлечь сумму автоматически.';

  @override
  String get scanReceiptButton => 'Сканировать чек';

  @override
  String get voiceComingSoonMessage =>
      'Голосовой ввод будет подключён следующим шагом';

  @override
  String get receiptComingSoonMessage =>
      'Сканирование чека будет подключено следующим шагом';

  @override
  String smartInputExampleWithCategory(String category) {
    return '$category 150';
  }

  @override
  String get voiceUnavailableMessage =>
      'Голосовой ввод недоступен на этом устройстве или не выданы разрешения';

  @override
  String voiceErrorMessage(String message) {
    return 'Ошибка голосового ввода: $message';
  }

  @override
  String get voiceLanguageLabel => 'Язык распознавания';

  @override
  String get stopVoiceInputButton => 'Остановить запись';

  @override
  String get voiceRecognizedTextTitle => 'Распознанный текст';

  @override
  String get pickReceiptFromGalleryButton => 'Выбрать из галереи';

  @override
  String get receiptRecognizedTextTitle => 'Распознанный текст чека';

  @override
  String receiptScanErrorMessage(String message) {
    return 'Ошибка сканирования чека: $message';
  }

  @override
  String get receiptNoTextFoundMessage =>
      'На изображении не удалось распознать текст';

  @override
  String get receiptParsedSummaryTitle => 'Разобранные данные чека';

  @override
  String receiptConfidenceLabel(String value) {
    return 'Уверенность распознавания: $value%';
  }

  @override
  String get financialLevelTitle => 'Финансовый уровень';

  @override
  String get openMonthlyReportButton => 'Открыть месячный отчет';

  @override
  String get monthlyReportTitle => 'Месячный отчет';

  @override
  String get monthlyReportLevelTitle => 'Ваш уровень месяца';

  @override
  String get monthlyReportShareHint =>
      'Позже здесь появится карточка для шаринга итогов месяца.';

  @override
  String monthlyReportIncome(String value) {
    return 'Доход: $value';
  }

  @override
  String monthlyReportSpent(String value) {
    return 'Потрачено: $value';
  }

  @override
  String monthlyReportSaved(String value) {
    return 'Сохранено: $value';
  }

  @override
  String monthlyReportTopCategory(String value) {
    return 'Главная категория: $value';
  }

  @override
  String monthlyReportLifeSpent(String value) {
    return 'Потрачено жизни: $value';
  }

  @override
  String monthlyReportScore(int value) {
    return 'Индекс здоровья: $value/100';
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
      'Сейчас главная задача — вернуть контроль и стабилизировать бюджет.';

  @override
  String get levelPlannerDescription =>
      'Вы уже начинаете осознанно управлять расходами.';

  @override
  String get levelStrategistDescription =>
      'Ваши траты выглядят продуманнее, а решения — сильнее.';

  @override
  String get levelInvestorDescription =>
      'Вы двигаетесь как человек, который управляет деньгами, а не догоняет их.';

  @override
  String get openShareCardButton => 'Открыть share card';

  @override
  String get shareCardScreenTitle => 'Карточка месяца';

  @override
  String get shareCardTitle => 'Мои финансы за месяц';

  @override
  String get shareCardSubtitle =>
      'Краткий итог, которым можно будет поделиться';

  @override
  String get shareCardIncome => 'Доход';

  @override
  String get shareCardSpent => 'Потрачено';

  @override
  String get shareCardSaved => 'Сохранено';

  @override
  String get shareCardTopCategory => 'Главная категория';

  @override
  String get shareCardLifeSpent => 'Потрачено жизни';

  @override
  String get shareCardHealthScore => 'Индекс здоровья';

  @override
  String get shareCardLevel => 'Финансовый уровень';

  @override
  String get shareCardFooter => 'Budget planner that thinks for you.';

  @override
  String get shareCardHintTitle => 'Share-ready summary';

  @override
  String get shareCardHintSubtitle =>
      'Следующим шагом здесь появится экспорт карточки в изображение и системный шаринг.';

  @override
  String get shareCardPrepareButton => 'Подготовить карточку';

  @override
  String get shareCardExportComingSoon =>
      'Экспорт карточки будет добавлен следующим шагом';

  @override
  String get shareCardHintSubtitleReady =>
      'Карточка уже готова к экспорту в PNG и системному шарингу.';

  @override
  String get shareCardPreparingButton => 'Подготовка...';

  @override
  String get shareCardShareButton => 'Поделиться карточкой';

  @override
  String get shareCardShareText => 'Мои финансы за месяц';

  @override
  String get shareCardRenderError => 'Не удалось подготовить карточку';

  @override
  String shareCardExportError(String message) {
    return 'Ошибка экспорта карточки: $message';
  }

  @override
  String get receiptReviewTitle => 'Проверка чека';

  @override
  String get receiptFieldConfidenceTitle => 'Уверенность по полям';

  @override
  String receiptAmountConfidence(String value) {
    return 'Сумма: $value';
  }

  @override
  String receiptMerchantConfidence(String value) {
    return 'Место: $value';
  }

  @override
  String receiptDateConfidence(String value) {
    return 'Дата: $value';
  }

  @override
  String get receiptCandidateAmountsTitle => 'Подходящие суммы';

  @override
  String get receiptPickDateButton => 'Выбрать дату чека';

  @override
  String receiptPickedDateButton(String value) {
    return 'Дата чека: $value';
  }

  @override
  String get receiptConfirmParsedButton => 'Подтвердить данные';

  @override
  String get categoryBudgetsTitle => 'Бюджеты по категориям';

  @override
  String get categoryBudgetsEmpty =>
      'Пока нет бюджетов по категориям. Примените автоматический бюджет, чтобы увидеть разбивку.';

  @override
  String budgetDangerTitle(String category) {
    return 'Категория риска: $category';
  }

  @override
  String get budgetDangerSubtitle =>
      'Эта категория быстрее всех приближается к перерасходу.';

  @override
  String get goalsTab => 'Цели';

  @override
  String get goalsTitle => 'Цели накопления';

  @override
  String get goalsEmptyTitle => 'Пока нет цели';

  @override
  String get goalsEmptySubtitle =>
      'Создайте цель, и приложение начнет показывать, как быстрее к ней прийти.';

  @override
  String get goalsCreateHint => 'Добавьте цель накопления';

  @override
  String get goalCreateTitle => 'Новая цель';

  @override
  String get goalCreateButton => 'Создать цель';

  @override
  String get goalReplaceButton => 'Изменить цель';

  @override
  String get goalTitleLabel => 'Название цели';

  @override
  String get goalTargetAmountLabel => 'Сумма цели';

  @override
  String get goalPickDateButton => 'Выбрать срок';

  @override
  String goalPickedDateButton(String value) {
    return 'Срок: $value';
  }

  @override
  String get goalTitleError => 'Введите название цели';

  @override
  String get goalAmountError => 'Введите корректную сумму';

  @override
  String goalProgressValue(String current, String target) {
    return 'Прогресс: $current / $target';
  }

  @override
  String goalRemainingValue(String value) {
    return 'Осталось: $value';
  }

  @override
  String goalRecommendedPerMonth(String value) {
    return 'Нужно в месяц: $value';
  }

  @override
  String get goalProjectionTitle => 'Прогноз цели';

  @override
  String get goalProjectionNoDate =>
      'У цели пока нет срока. Добавьте дату, чтобы увидеть план.';

  @override
  String goalProjectionWithDate(String amount, int months) {
    return 'Чтобы успеть, нужно откладывать около $amount в месяц в течение $months мес.';
  }

  @override
  String get goalProjectionNoCurrentRate =>
      'Пока недостаточно данных, чтобы оценить текущий темп накопления.';

  @override
  String goalProjectionCurrentRate(int months) {
    return 'С текущим темпом цель будет достигнута примерно за $months мес.';
  }

  @override
  String get goalAddProgressTitle => 'Добавить прогресс';

  @override
  String get goalAddProgressLabel => 'Сумма пополнения';

  @override
  String get goalAddProgressButton => 'Добавить прогресс';

  @override
  String get actionPlanTitle => 'План действий';

  @override
  String get actionPlanEmptyTitle => 'Пока нет действий';

  @override
  String get actionPlanEmptySubtitle =>
      'Когда появится больше данных, приложение начнет предлагать конкретные финансовые шаги.';

  @override
  String get actionPlanCutCategoryTitle => 'Снизьте темп в риск-категории';

  @override
  String actionPlanCutCategoryDescription(String percent) {
    return 'Эта категория уже достигла $percent% своего лимита. Если притормозить сейчас, месяц будет спокойнее.';
  }

  @override
  String get actionPlanSubscriptionsTitle => 'Проверьте подписки';

  @override
  String actionPlanSubscriptionsDescription(String amount, String half) {
    return 'Подписки забирают около $amount в месяц. Даже сокращение наполовину вернет примерно $half.';
  }

  @override
  String get actionPlanGoalTitle => 'Ускорьте цель';

  @override
  String actionPlanGoalDescription(String amount, String months) {
    return 'Чтобы успеть к сроку, нужно откладывать около $amount в месяц еще $months мес.';
  }

  @override
  String get actionPlanScoreTitle => 'Укрепите финансовую форму';

  @override
  String get actionPlanScoreDescription =>
      'Сейчас особенно важно держать лимиты категорий и не раздувать мелкие регулярные траты.';

  @override
  String get cashflowTab => 'Cashflow';

  @override
  String get cashflowTitle => 'Денежный поток';

  @override
  String get cashflowSummaryTitle => 'Сводка потока';

  @override
  String get cashflowNoSalaryDay => 'День зарплаты пока не задан';

  @override
  String cashflowSalaryDayValue(int value) {
    return 'День зарплаты: $value';
  }

  @override
  String cashflowRecurringBillsValue(int value) {
    return 'Регулярных счетов: $value';
  }

  @override
  String get cashflowTimelineTitle => 'Ближайшие события';

  @override
  String get cashflowEmpty =>
      'Пока нет событий. Добавьте день зарплаты и регулярные счета.';

  @override
  String get salaryDayTitle => 'День зарплаты';

  @override
  String get salaryDayLabel => 'Число месяца';

  @override
  String get salaryDayButton => 'Указать день зарплаты';

  @override
  String get salaryDayError => 'Введите день от 1 до 31';

  @override
  String get recurringBillCreateTitle => 'Новый регулярный счет';

  @override
  String get recurringBillCreateButton => 'Добавить регулярный счет';

  @override
  String get recurringBillTitleLabel => 'Название';

  @override
  String get recurringBillAmountLabel => 'Сумма';

  @override
  String get recurringBillDayLabel => 'День месяца';

  @override
  String get recurringBillTitleError => 'Введите название счета';

  @override
  String get recurringBillAmountError => 'Введите корректную сумму';

  @override
  String get recurringBillDayError => 'Введите день от 1 до 31';

  @override
  String get premiumTitle => 'Premium';

  @override
  String get premiumHeroTitle =>
      'Разблокируйте финансового навигатора полностью';

  @override
  String get premiumHeroSubtitle =>
      'Получите AI-инсайты, OCR чеков, voice input, cashflow timeline, продвинутые подписки и action planner.';

  @override
  String get premiumFeatureAiInsights => 'AI-инсайты и объяснимые рекомендации';

  @override
  String get premiumFeatureVoice => 'Голосовой ввод расходов';

  @override
  String get premiumFeatureReceipt => 'OCR чеков и review flow';

  @override
  String get premiumFeatureSubscriptions => 'Продвинутый анализ подписок';

  @override
  String get premiumFeatureCashflow => 'Cashflow timeline и будущие события';

  @override
  String get premiumFeatureGoals => 'Более сильная система целей';

  @override
  String get premiumFeatureShare => 'Экспорт и шаринг карточек';

  @override
  String get premiumUnlockButton => 'Разблокировать Premium';

  @override
  String get premiumDisableDebugButton => 'Отключить Premium';

  @override
  String get openPremiumButton => 'Открыть Premium';

  @override
  String get premiumLockedInsightsTitle => 'AI-инсайты доступны в Premium';

  @override
  String get premiumLockedInsightsSubtitle =>
      'Приложение сможет показывать умные сигналы, сравнения и финансовый радар.';

  @override
  String get premiumLockedActionPlanTitle => 'План действий доступен в Premium';

  @override
  String get premiumLockedActionPlanSubtitle =>
      'Получайте конкретные шаги, как быстрее улучшить бюджет и цели.';

  @override
  String get premiumLockedSubscriptionsTitle =>
      'Подписки-паразиты доступны в Premium';

  @override
  String get premiumLockedSubscriptionsSubtitle =>
      'Приложение найдет повторяющиеся платежи и покажет, где можно вернуть деньги.';

  @override
  String get premiumLockedCashflowTitle =>
      'Cashflow timeline доступен в Premium';

  @override
  String get premiumLockedCashflowSubtitle =>
      'Отслеживайте ближайшие доходы и регулярные списания заранее.';

  @override
  String get premiumLockedShareTitle => 'Экспорт карточки доступен в Premium';

  @override
  String get premiumLockedShareSubtitle =>
      'Сохраняйте и делитесь своей месячной карточкой как изображением.';

  @override
  String get expenseEditTitle => 'Редактировать расход';

  @override
  String get expenseNoteLabel => 'Заметка';

  @override
  String expenseEditDateValue(String value) {
    return 'Дата: $value';
  }

  @override
  String get monthCloseTitle => 'Закрытие месяца';

  @override
  String get monthCloseCardTitle => 'Итог месяца';

  @override
  String get monthCloseHomeTitle => 'Завершите месяц осознанно';

  @override
  String get monthCloseHomeSubtitle =>
      'Посмотрите, что получилось, что просело и с каким фокусом идти дальше.';

  @override
  String get monthCloseOpenButton => 'Открыть итог месяца';

  @override
  String monthCloseSpentChange(String value) {
    return 'Изменение трат: $value';
  }

  @override
  String monthCloseHealthDelta(int value) {
    return 'Изменение health score: $value';
  }

  @override
  String get monthCloseWinTitle => 'Месяц получился сильнее прошлого';

  @override
  String get monthCloseWinSubtitle =>
      'Вы либо снизили траты, либо улучшили финансовую форму. Это хороший сигнал.';

  @override
  String get monthCloseFocusTitle =>
      'Следующий месяц требует более точного фокуса';

  @override
  String get monthCloseFocusSubtitle =>
      'Сейчас особенно важно сократить утечки и держать категорийные лимиты под контролем.';

  @override
  String get monthCloseStartNextMonthButton => 'Начать новый месяц умнее';

  @override
  String get streakTitle => 'Серия';

  @override
  String streakCurrentValue(int value) {
    return 'Сейчас: $value дн.';
  }

  @override
  String streakBestValue(int value) {
    return 'Лучшее: $value дн.';
  }

  @override
  String get streakTodayDone => 'Сегодня активность уже есть';

  @override
  String get streakTodayMissing => 'Сегодня еще можно продолжить серию';

  @override
  String get achievementsTitle => 'Достижения';

  @override
  String get achievementFirstExpenseTitle => 'Первый расход';

  @override
  String get achievementFirstExpenseSubtitle =>
      'Вы начали вести свои деньги осознанно.';

  @override
  String get achievementTracker7Title => '7 дней подряд';

  @override
  String get achievementTracker7Subtitle =>
      'Неделя непрерывного трекинга расходов.';

  @override
  String get achievementTracker30Title => '30 дней подряд';

  @override
  String get achievementTracker30Subtitle => 'Целый месяц устойчивой привычки.';

  @override
  String get achievementGoalStartedTitle => 'Первая цель';

  @override
  String get achievementGoalStartedSubtitle =>
      'Вы задали финансовое направление.';

  @override
  String get achievementGoalProgressTitle => 'Первый прогресс по цели';

  @override
  String get achievementGoalProgressSubtitle =>
      'Вы начали не только считать, но и двигаться вперед.';

  @override
  String get achievementMonthCloseTitle => 'Первое закрытие месяца';

  @override
  String get achievementMonthCloseSubtitle =>
      'Вы подвели месячный финансовый итог.';

  @override
  String get achievementNoOverspendTitle => 'Месяц без перерасхода';

  @override
  String get achievementNoOverspendSubtitle =>
      'Вы удержали расходы в рамках бюджета.';
}
