import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../data/models/expense_source_type.dart';
import '../../l10n/app_localizations.dart';

class MorphingFab extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final Function(ExpenseSourceType source, bool isIncome) onSelectSource;

  const MorphingFab({
    super.key,
    required this.isExpanded,
    required this.onToggle,
    required this.onSelectSource,
  });

  @override
  State<MorphingFab> createState() => _MorphingFabState();
}

class _MorphingFabState extends State<MorphingFab> {
  bool _isIncome = false;

  @override
  void didUpdateWidget(covariant MorphingFab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isExpanded && oldWidget.isExpanded) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _isIncome = false);
      });
    }
  }

  String _t(String en, String ru) {
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    return isRu ? ru : en;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fabColor = _isIncome ? CupertinoColors.systemGreen : theme.colorScheme.primary;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(bottom: 24 + MediaQuery.of(context).padding.bottom),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                color: fabColor.withOpacity(0.95),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(color: fabColor.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              // Анимация размера будет происходить АВТОМАТИЧЕСКИ благодаря AnimatedSize
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                alignment: Alignment.center,
                child: Material(
                  color: Colors.transparent,
                  child: widget.isExpanded
                      ? Container(
                    // Жесткая ширина, чтобы иконки распределились ровно
                    width: MediaQuery.of(context).size.width - 48,
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // УМНЫЙ СВИТЧЕР ВНУТРИ FAB
                        Container(
                          height: 38,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setState(() => _isIncome = false);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      color: !_isIncome ? Colors.white : Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _t('Expense', 'Расход'),
                                        style: TextStyle(
                                          color: !_isIncome ? theme.colorScheme.primary : Colors.white.withOpacity(0.7),
                                          fontWeight: !_isIncome ? FontWeight.w700 : FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setState(() => _isIncome = true);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      color: _isIncome ? Colors.white : Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _t('Income', 'Доход'),
                                        style: TextStyle(
                                          color: _isIncome ? CupertinoColors.systemGreen : Colors.white.withOpacity(0.7),
                                          fontWeight: _isIncome ? FontWeight.w700 : FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ПАНЕЛЬ ИНСТРУМЕНТОВ
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _FabOption(icon: CupertinoIcons.mic_solid, onTap: () => widget.onSelectSource(ExpenseSourceType.voice, _isIncome)),
                            Container(width: 1, height: 20, color: Colors.white.withOpacity(0.3)),
                            _FabOption(icon: CupertinoIcons.camera_fill, onTap: () => widget.onSelectSource(ExpenseSourceType.receipt, _isIncome)),
                            Container(width: 1, height: 20, color: Colors.white.withOpacity(0.3)),
                            _FabOption(icon: CupertinoIcons.pen, onTap: () => widget.onSelectSource(ExpenseSourceType.smartText, _isIncome)),
                          ],
                        ),
                      ],
                    ),
                  )
                      : InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onToggle();
                    },
                    borderRadius: BorderRadius.circular(32),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(CupertinoIcons.add, color: Colors.white, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            _t('Add', 'Добавить'),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FabOption extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _FabOption({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}