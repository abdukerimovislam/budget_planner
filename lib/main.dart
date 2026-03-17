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
import 'data/datasources/local/isar_database_service.dart'; // <-- ИМПОРТ ISAR

// Сервисы
import 'domain/services/financial_forecast_service.dart';
import 'domain/services/financial_health_score_service.dart';
import 'domain/services/life_value_service.dart';
import 'domain/services/notification_service.dart';
import 'domain/services/premium_access_service.dart';

// НОВЫЕ ПРОВАЙДЕРЫ (Вместо HomeProvider)
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/transactions_provider.dart';
import 'presentation/providers/budget_provider.dart';
import 'presentation/providers/insights_provider.dart';

Future<void> main() async {
  // Обязательная инициализация биндингов перед запуском асинхронных методов
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // 1. Инициализация Firebase
  try {
    await Firebase.initializeApp();

    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity, // Защита для Android
      appleProvider: AppleProvider.deviceCheck,       // Защита для iOS
    );
  } catch (e) {
    debugPrint('Firebase init warning: $e');
  }

  // 2. Инициализация локальных баз данных
  await LocalStorageService.init();
  await IsarDatabaseService.instance.init(); // <-- ЗАПУСК ISAR

  // 3. Инициализация и запуск системы уведомлений
  await NotificationService.instance.init();
  await NotificationService.instance.requestPermissions(); // Запросит права при первом запуске
  await NotificationService.instance.scheduleDailyReminder(); // Заведет таймер на 20:00 каждый день

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

        // 2. TransactionsProvider (Чеки, расходы, доходы, долги) - Слушает настройки валюты
        ChangeNotifierProxyProvider<SettingsProvider, TransactionsProvider>(
          create: (ctx) => TransactionsProvider(
            settings: ctx.read<SettingsProvider>(),
          )..load(),
          // При смене настроек (например, валюты), пересчитываем кэш
          update: (_, settings, tx) => tx!..load(),
        ),

        // 3. BudgetProvider (Цели, бюджеты, подписки) - Слушает транзакции и настройки
        ChangeNotifierProxyProvider2<SettingsProvider, TransactionsProvider, BudgetProvider>(
          create: (ctx) => BudgetProvider(
            settings: ctx.read<SettingsProvider>(),
            transactions: ctx.read<TransactionsProvider>(),
          )..load(),
          update: (_, settings, tx, budget) => budget!..reloadBudgetForCurrentCurrency(),
        ),

        // 4. InsightsProvider (Аналитика, ИИ, здоровье) - Берет данные ото всех
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