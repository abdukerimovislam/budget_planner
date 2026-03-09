import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'app/app_state.dart';
import 'core/localization/locale_controller.dart';
import 'data/datasources/local/local_storage_service.dart';
import 'domain/services/financial_forecast_service.dart';
import 'domain/services/financial_health_score_service.dart';
import 'domain/services/life_value_service.dart';
import 'presentation/providers/home_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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