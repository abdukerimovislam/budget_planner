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
import 'domain/services/financial_forecast_service.dart';
import 'domain/services/financial_health_score_service.dart';
import 'domain/services/life_value_service.dart';
import 'presentation/providers/home_provider.dart';

Future<void> main() async {
  // Обязательная инициализация биндингов перед запуском асинхронных методов
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // 1. Инициализация Firebase (Подхватит настройки из firebase_options.dart, если он сгенерирован)
  try {
    await Firebase.initializeApp();

    // 2. Активация Firebase App Check (Защита API ключей)
    // Эта система проверяет, что запрос пришел с настоящего телефона (Play Integrity / DeviceCheck)
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity, // Защита для Android
      appleProvider: AppleProvider.deviceCheck,       // Защита для iOS
    );
  } catch (e) {
    debugPrint('Firebase init warning: $e');
    // Если Firebase еще не настроен (flutterfire configure), приложение все равно запустится,
    // но функции ИИ пока не будут работать. Это нормально для этапа разработки.
  }

  // 3. Инициализация локальной базы данных
  await LocalStorageService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => LocaleController()),
        ChangeNotifierProvider(
          create: (_) => HomeProvider(
            forecastService: FinancialForecastService(),
            scoreService: FinancialHealthScoreService(),
            lifeValueService: LifeValueService(),
          ),
        ),
      ],
      child: const BudgetPlannerApp(),
    ),
  );
}