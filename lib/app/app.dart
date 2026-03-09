import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../core/localization/locale_controller.dart';
import '../l10n/app_localizations.dart';
import '../presentation/providers/home_provider.dart';
import '../presentation/screens/onboarding/onboarding_screen.dart';
import '../presentation/widgets/main_navigation_screen.dart';
import 'app_state.dart';
import 'theme/app_theme.dart';

class BudgetPlannerApp extends StatefulWidget {
  const BudgetPlannerApp({super.key});

  @override
  State<BudgetPlannerApp> createState() => _BudgetPlannerAppState();
}

class _BudgetPlannerAppState extends State<BudgetPlannerApp> {
  late Future<void> _startupFuture;

  @override
  void initState() {
    super.initState();
    _startupFuture = _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await context.read<AppState>().load();
    await context.read<LocaleController>().load();
    await context.read<HomeProvider>().load();
  }

  @override
  Widget build(BuildContext context) {
    final localeController = context.watch<LocaleController>();
    final appState = context.watch<AppState>();

    return FutureBuilder<void>(
      future: _startupFuture,
      builder: (context, snapshot) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          locale: localeController.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.system,
          home: snapshot.connectionState != ConnectionState.done
              ? const _StartupScreen()
              : appState.isOnboardingCompleted
              ? const MainNavigationScreen()
              : const OnboardingScreen(),
        );
      },
    );
  }
}

class _StartupScreen extends StatelessWidget {
  const _StartupScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}