import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../providers/home_provider.dart';
import '../screens/analytics/analytics_screen.dart';
import '../screens/budget/budget_screen.dart';
import '../screens/cashflow/cashflow_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/month_close/month_close_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens = const [
    HomeScreen(),
    AnalyticsScreen(),
    BudgetScreen(),
    CashflowScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<HomeProvider>();

    // Системная проверка: Если сменился месяц, форсированно показываем экран итогов
    if (provider.isInitialized && provider.needsMonthClose) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        // Помечаем как просмотренное, чтобы не зациклить
        provider.markMonthCloseAsSeen();

        // Открываем экран закрытия месяца
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => const MonthCloseScreen(),
            fullscreenDialog: true, // Открываем поверх всего
          ),
        );
      });
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.homeTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.pie_chart_outline_rounded),
            selectedIcon: const Icon(Icons.pie_chart_rounded),
            label: l10n.analyticsTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: const Icon(Icons.account_balance_wallet),
            label: l10n.budgetTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.timeline_outlined),
            selectedIcon: const Icon(Icons.timeline),
            label: l10n.cashflowTab,
          ),
        ],
      ),
    );
  }
}