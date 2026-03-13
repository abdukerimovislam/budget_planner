import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

import '../core/localization/locale_controller.dart';
import '../data/datasources/local/local_storage_service.dart';
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

class _BudgetPlannerAppState extends State<BudgetPlannerApp> with WidgetsBindingObserver {
  late Future<void> _startupFuture;

  bool _isAuthenticated = false;
  bool _isCheckingAuth = false;
  bool _showPrivacyScreen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startupFuture = _loadInitialData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final isProtectionEnabled = LocalStorageService.instance.isBiometricAuthEnabled();
    if (!isProtectionEnabled) return;

    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      setState(() {
        _showPrivacyScreen = true;
        _isAuthenticated = false;
      });
    } else if (state == AppLifecycleState.resumed) {
      _authenticate();
    }
  }

  Future<void> _loadInitialData() async {
    await Future.microtask(() {});

    if (!mounted) return;

    await context.read<AppState>().load();
    await context.read<LocaleController>().load();
    await context.read<HomeProvider>().load();

    final isProtectionEnabled = LocalStorageService.instance.isBiometricAuthEnabled();
    if (isProtectionEnabled && context.read<AppState>().isOnboardingCompleted) {
      setState(() => _showPrivacyScreen = true);
      await _authenticate();
    } else {
      setState(() {
        _isAuthenticated = true;
        _showPrivacyScreen = false;
      });
    }
  }

  Future<void> _authenticate() async {
    if (_isCheckingAuth || _isAuthenticated) return;

    setState(() {
      _isCheckingAuth = true;
      _showPrivacyScreen = true;
    });

    final auth = LocalAuthentication();
    bool authenticated = false;

    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Отсканируйте лицо для доступа к финансам',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException catch (e) {
      debugPrint('Biometric Auth Error: ${e.message}');
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticated = authenticated;
          _isCheckingAuth = false;
          _showPrivacyScreen = !authenticated;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeController = context.watch<LocaleController>();
    final appState = context.watch<AppState>();

    return FutureBuilder<void>(
      future: _startupFuture,
      builder: (context, snapshot) {
        Widget homeWidget;
        if (snapshot.connectionState != ConnectionState.done) {
          homeWidget = const _StartupScreen();
        } else if (!appState.isOnboardingCompleted) {
          homeWidget = const OnboardingScreen();
        } else {
          homeWidget = const MainNavigationScreen();
        }

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
          builder: (context, child) {
            return Stack(
              children: [
                child!,
                if (_showPrivacyScreen)
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.8),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.lock_outline_rounded,
                                size: 64,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Приложение заблокировано',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 32),
                              if (!_isCheckingAuth && !_isAuthenticated)
                                ElevatedButton.icon(
                                  onPressed: _authenticate,
                                  icon: const Icon(Icons.fingerprint),
                                  label: const Text('Разблокировать'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  ),
                                ),
                              if (_isCheckingAuth)
                                const CircularProgressIndicator(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
          home: homeWidget,
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