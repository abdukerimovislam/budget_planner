import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../providers/home_provider.dart';
import '../screens/analytics/analytics_screen.dart'; // Объединенная Аналитика + Бюджет
import '../screens/expenses/expenses_screen.dart'; // Наша новая вкладка История
import '../screens/cashflow/cashflow_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/month_close/month_close_screen.dart';
import '../screens/debts/debts_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // ИСПРАВЛЕНИЕ: Новый, более логичный стек экранов
  late final List<Widget> _screens = const [
    HomeScreen(),         // Главная
    AnalyticsScreen(),    // Планирование (Аналитика + Бюджет)
    ExpensesScreen(),     // История транзакций (ВМЕСТО ОТДЕЛЬНОГО БЮДЖЕТА)
    DebtsScreen(),        // Долги
    CashflowScreen(),     // Денежный поток / Цели
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<HomeProvider>();

    if (provider.isInitialized && provider.needsMonthClose) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        provider.markMonthCloseAsSeen();
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => const MonthCloseScreen(),
            fullscreenDialog: true,
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
            label: 'Аналитика',
          ),
          // НОВАЯ ВСТАВКА: История транзакций (Посередине, чтобы было удобно)
          const NavigationDestination(
            icon: Icon(Icons.list_alt_rounded),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'История',
          ),
          const NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon: Icon(Icons.people_rounded),
            label: 'Долги',
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