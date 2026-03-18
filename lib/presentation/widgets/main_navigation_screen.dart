import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart'; // <-- ИМПОРТ БИБЛИОТЕКИ АНИМАЦИЙ

import '../../l10n/app_localizations.dart';

// ПРОВАЙДЕРЫ
import '../providers/settings_provider.dart';
import '../providers/transactions_provider.dart';

// ЭКРАНЫ
import '../screens/home/home_screen.dart';
import '../screens/analytics/analytics_screen.dart';
import '../screens/budget/budget_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/add_expense/add_expense_screen.dart';
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
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = context.watch<SettingsProvider>();
    final tx = context.watch<TransactionsProvider>();

    if (settings.isInitialized && tx.needsMonthClose) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        tx.markMonthCloseAsSeen();
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => const MonthCloseScreen(),
            fullscreenDialog: true,
          ),
        );
      });
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      backgroundColor: theme.scaffoldBackgroundColor, // Базовый цвет фона
      body: Stack(
        children: [
          // --- ГЛОБАЛЬНЫЙ ГРАДИЕНТ ДЛЯ ВСЕХ ЭКРАНОВ ---
          Positioned(
            top: -100,
            left: -50,
            right: -50,
            height: 400,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(isDark ? 0.3 : 0.15),
                    theme.colorScheme.secondary.withOpacity(isDark ? 0.2 : 0.1),
                    Colors.transparent,
                  ],
                  radius: 0.8,
                ),
              ),
            ),
          ),

          // --- ПРЕМИАЛЬНАЯ АНИМАЦИЯ ПЕРЕКЛЮЧЕНИЯ ВКЛАДОК ---
          PageTransitionSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (
                Widget child,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
                ) {
              return FadeThroughTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                // Важно: прозрачный фон, чтобы не перекрывать наш глобальный градиент
                fillColor: Colors.transparent,
                child: child,
              );
            },
            child: _screens[_currentIndex], // Flutter сам поймет, когда нужно запустить анимацию
          ),
        ],
      ),

      floatingActionButton: SizedBox(
        height: 64,
        width: 64,
        child: FloatingActionButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (_) => const AddExpenseScreen(),
                fullscreenDialog: true,
              ),
            );
          },
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: 4,
          highlightElevation: 12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: const Icon(Icons.add_rounded, size: 36),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: _buildBottomAppBar(theme, l10n),
    );
  }

  Widget _buildBottomAppBar(ThemeData theme, AppLocalizations l10n) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), // Сильное размытие фона под меню
        child: BottomAppBar(
          // Делаем цвет меню полупрозрачным! (0.8 = 80% видимости)
          color: theme.colorScheme.surface.withOpacity(0.8),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          notchMargin: 10,
          shape: const CircularNotchedRectangle(),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavBarItem(icon: CupertinoIcons.home, activeIcon: CupertinoIcons.house_fill, label: l10n.homeTab, isSelected: _currentIndex == 0, onTap: () => _onTabTapped(0)),
              _NavBarItem(icon: CupertinoIcons.chart_pie, activeIcon: CupertinoIcons.chart_pie_fill, label: 'Анализ', isSelected: _currentIndex == 1, onTap: () => _onTabTapped(1)),
              const SizedBox(width: 48), // Место для центральной кнопки (FAB)
              _NavBarItem(icon: CupertinoIcons.flag, activeIcon: CupertinoIcons.flag_fill, label: 'Цели', isSelected: _currentIndex == 2, onTap: () => _onTabTapped(2)),
              _NavBarItem(icon: CupertinoIcons.person, activeIcon: CupertinoIcons.person_fill, label: 'Профиль', isSelected: _currentIndex == 3, onTap: () => _onTabTapped(3)),
            ],
          ),
        ),
      ),
    );
  }

  void _onTabTapped(int index) {
    if (_currentIndex == index) return; // Не анимируем, если нажали на текущую вкладку
    HapticFeedback.selectionClick();
    setState(() {
      _currentIndex = index;
    });
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon; final IconData activeIcon; final String label; final bool isSelected; final VoidCallback onTap;
  const _NavBarItem({required this.icon, required this.activeIcon, required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.4);

    return InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(16), splashColor: Colors.transparent, highlightColor: Colors.transparent,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                child: Icon(isSelected ? activeIcon : icon, key: ValueKey(isSelected), color: color, size: 26)
            ),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}