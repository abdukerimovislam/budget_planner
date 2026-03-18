import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

// ПРОВАЙДЕРЫ
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/transactions_provider.dart';
import 'presentation/providers/budget_provider.dart';
import 'presentation/providers/insights_provider.dart';

void main() {
  // 1. Глобальный перехватчик фатальных ошибок платформы и асинхронных сбоев
  runZonedGuarded(() async {
    // Гарантируем инициализацию биндингов Flutter ДО работы с нативным кодом
    final binding = WidgetsFlutterBinding.ensureInitialized();

    // Удерживаем Splash Screen, пока идет тяжелая инициализация (Firebase, Isar, и т.д.)
    binding.deferFirstFrame();

    try {
      // Блокируем ориентацию экрана (только портретный режим)
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      // Делаем системные панели (статус-бар и навигацию) прозрачными
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );

      // Загрузка переменных окружения (ключи API)
      await dotenv.load(fileName: ".env");

      // 2. Инициализация Firebase
      try {
        await Firebase.initializeApp();
        await FirebaseAppCheck.instance.activate(
          androidProvider: AndroidProvider.playIntegrity,
          appleProvider: AppleProvider.deviceCheck,
        );
      } catch (e) {
        debugPrint('Firebase init warning: $e');
      }

      // 3. Инициализация локальных баз данных
      await LocalStorageService.init();
      await IsarDatabaseService.instance.init();

      // 4. Инициализация и запуск системы уведомлений
      await NotificationService.instance.init();
      await NotificationService.instance.requestPermissions();
      await NotificationService.instance.scheduleDailyReminder();

    } catch (e, stackTrace) {
      debugPrint('CRITICAL ERROR DURING INITIALIZATION: $e');
      debugPrint(stackTrace.toString());
      // В будущем тут можно отправить лог в Crashlytics
    } finally {
      // Снимаем блокировку сплеш-скрина в любом случае (даже если была ошибка)
      binding.allowFirstFrame();
    }

    // 5. Перехват ошибок внутри самого Flutter (UI, Layout)
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('FLUTTER UI ERROR: ${details.exception}');
    };

    // 6. Запуск приложения с провайдерами
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppState()),
          ChangeNotifierProvider(create: (_) => LocaleController()),

          // --- АРХИТЕКТУРА ПРОВАЙДЕРОВ ---

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
            // Фильтрация валюты происходит "на лету" в геттерах.
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

  }, (error, stackTrace) {
    // Перехват глобальных асинхронных ошибок Dart (защита от падений)
    debugPrint('UNCAUGHT ASYNC ERROR: $error');
    debugPrint(stackTrace.toString());
  });
}