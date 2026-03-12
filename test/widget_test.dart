import 'package:budget_planner/app/app.dart';
import 'package:budget_planner/app/app_state.dart';
import 'package:budget_planner/core/localization/locale_controller.dart';
import 'package:budget_planner/data/datasources/local/local_storage_service.dart';
import 'package:budget_planner/domain/services/financial_forecast_service.dart';
import 'package:budget_planner/domain/services/financial_health_score_service.dart';
import 'package:budget_planner/domain/services/life_value_service.dart';
import 'package:budget_planner/presentation/providers/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await LocalStorageService.init();
  });

  testWidgets('BudgetPlannerApp builds with required providers', (
      WidgetTester tester,
      ) async {
    await tester.pumpWidget(
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

    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}