import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../data/models/expense_source_type.dart';
import '../../l10n/app_localizations.dart';

class MorphingFab extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final Function(ExpenseSourceType) onSelectSource;

  const MorphingFab({
    super.key,
    required this.isExpanded,
    required this.onToggle,
    required this.onSelectSource,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(bottom: 24 + MediaQuery.of(context).padding.bottom),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            // AnimatedSize сама плавно меняет ширину в зависимости от контента внутри
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              child: Container(
                height: 64,
                // Если открыто - ширина во весь экран с отступами. Если закрыто - null (адаптивная под контент)
                width: isExpanded ? MediaQuery.of(context).size.width - 48 : null,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: isExpanded
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _FabOption(icon: CupertinoIcons.mic_solid, onTap: () => onSelectSource(ExpenseSourceType.voice)),
                      Container(width: 1, height: 24, color: Colors.white.withOpacity(0.3)),
                      _FabOption(icon: CupertinoIcons.camera_fill, onTap: () => onSelectSource(ExpenseSourceType.receipt)),
                      Container(width: 1, height: 24, color: Colors.white.withOpacity(0.3)),
                      _FabOption(icon: CupertinoIcons.pen, onTap: () => onSelectSource(ExpenseSourceType.smartText)),
                    ],
                  )
                      : InkWell(
                    onTap: onToggle,
                    borderRadius: BorderRadius.circular(32),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0), // Адаптивные отступы по бокам
                      child: Row(
                        mainAxisSize: MainAxisSize.min, // Берем ровно столько места, сколько нужно иконке и тексту
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(CupertinoIcons.add, color: Colors.white, size: 24),
                          const SizedBox(width: 8),
                          Flexible( // Защита от переполнения (overflow) при огромных системных шрифтах
                            child: Text(
                              l10n.addExpense,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}