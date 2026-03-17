import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Импорты Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app/app.dart';
import 'app/app_state.dart';
import 'core/localization/locale_controller.dart';
import 'data/datasources/local/local_storage_service.dart';
import 'data/datasources/local/isar_database_service.dart';

// Сервисы
import 'domain/services/financial_forecast_service.dart';
import 'domain/services/financial_health_score_service.dart';
import 'domain/services/life_value_service.dart';
import 'domain/services/notification_service.dart';
import 'domain/services/premium_access_service.dart';

// НОВЫЕ ПРОВАЙДЕРЫ
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/transactions_provider.dart';
import 'presentation/providers/budget_provider.dart';
import 'presentation/providers/insights_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // 1. Инициализация Firebase
  try {
    await Firebase.initializeApp();

    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.deviceCheck,
    );
  } catch (e) {
    debugPrint('Firebase init warning: $e');
  }

  // 2. Инициализация локальных баз данных
  await LocalStorageService.init();
  await IsarDatabaseService.instance.init();

  // 3. Инициализация и запуск системы уведомлений
  await NotificationService.instance.init();
  await NotificationService.instance.requestPermissions();
  await NotificationService.instance.scheduleDailyReminder();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => LocaleController()),

        // --- НОВАЯ АРХИТЕКТУРА ПРОВАЙДЕРОВ ---

        // 1. SettingsProvider (Глобальные настройки, профиль, премиум)
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(
            premiumAccessService: PremiumAccessService(),
          )..load(),
        ),

        // 2. TransactionsProvider (Чеки, расходы, доходы, долги)
        ChangeNotifierProxyProvider<SettingsProvider, TransactionsProvider>(
          create: (ctx) => TransactionsProvider(
            settings: ctx.read<SettingsProvider>(),
          )..load(),
          // ИСПРАВЛЕНИЕ: Убрали ..load(). Фильтрация валюты происходит "на лету" в геттерах.
          update: (_, settings, tx) => tx!,
        ),

        // 3. BudgetProvider (Цели, бюджеты, подписки)
        ChangeNotifierProxyProvider2<SettingsProvider, TransactionsProvider, BudgetProvider>(
          create: (ctx) => BudgetProvider(
            settings: ctx.read<SettingsProvider>(),
            transactions: ctx.read<TransactionsProvider>(),
          )..load(),
          update: (_, settings, tx, budget) => budget!..reloadBudgetForCurrentCurrency(),
        ),

        // 4. InsightsProvider (Аналитика, ИИ, здоровье)
        ChangeNotifierProxyProvider3<SettingsProvider, TransactionsProvider, BudgetProvider, InsightsProvider>(
          create: (ctx) => InsightsProvider(
            settings: ctx.read<SettingsProvider>(),
            transactions: ctx.read<TransactionsProvider>(),
            budgetProvider: ctx.read<BudgetProvider>(),
            forecastService: FinancialForecastService(),
            scoreService: FinancialHealthScoreService(),
            lifeValueService: LifeValueService(),
          ),
          update: (_, settings, tx, budget, insights) => insights!,
        ),
      ],
      child: const BudgetPlannerApp(),
    ),
  );
}