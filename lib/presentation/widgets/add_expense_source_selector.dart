import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';

enum AddExpenseSourceMode {
  smartText,
  voice,
  receipt,
}

class AddExpenseSourceSelector extends StatelessWidget {
  final AddExpenseSourceMode value;
  final ValueChanged<AddExpenseSourceMode> onChanged;

  const AddExpenseSourceSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Внешний фон (слегка серая/полупрозрачная капсула)
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildSegment(
            context,
            mode: AddExpenseSourceMode.smartText,
            icon: CupertinoIcons.keyboard,
            label: l10n.addSourceSmartText,
          ),
          _buildSegment(
            context,
            mode: AddExpenseSourceMode.voice,
            icon: CupertinoIcons.mic,
            label: l10n.addSourceVoice,
          ),
          _buildSegment(
            context,
            mode: AddExpenseSourceMode.receipt,
            icon: CupertinoIcons.doc_text_viewfinder,
            label: l10n.addSourceReceipt,
          ),
        ],
      ),
    );
  }

  Widget _buildSegment(
      BuildContext context, {
        required AddExpenseSourceMode mode,
        required IconData icon,
        required String label,
      }) {
    final isSelected = value == mode;
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (!isSelected) {
            HapticFeedback.selectionClick(); // Премиальный клик при смене вкладки
            onChanged(mode);
          }
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            // Если выбрана - белая плашка с тенью, если нет - прозрачно
            color: isSelected ? theme.colorScheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}