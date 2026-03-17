import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/debt_model.dart';
import '../../widgets/premium_background.dart';

// НОВЫЕ ПРОВАЙДЕРЫ
import '../../providers/settings_provider.dart';
import '../../providers/transactions_provider.dart';

class DebtsScreen extends StatefulWidget {
  const DebtsScreen({super.key});

  @override
  State<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends State<DebtsScreen> {
  int _currentTab = 0; // 0 - Мне должны, 1 - Я должен

  void _showAddDebtSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddDebtSheet(),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _formatNumber(double value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final tx = context.watch<TransactionsProvider>();
    final theme = Theme.of(context);

    // Фильтруем долги по выбранной вкладке
    final displayedDebts = tx.debts.where((d) {
      if (_currentTab == 0) return d.isOwedToMe;
      return !d.isOwedToMe;
    }).toList();

    // Сортируем: сначала активные, потом возвращенные
    displayedDebts.sort((a, b) {
      if (a.isPaid == b.isPaid) return b.createdAt.compareTo(a.createdAt);
      return a.isPaid ? 1 : -1;
    });

    return PremiumBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverAppBar.large(
              stretch: true,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              title: const Text('Долги', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5)),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _showAddDebtSheet(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))
                          ]
                      ),
                      child: const Icon(CupertinoIcons.add, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: CupertinoSlidingSegmentedControl<int>(
                    groupValue: _currentTab,
                    thumbColor: theme.colorScheme.surface,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    children: {
                      0: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text('Мне должны', style: TextStyle(fontWeight: _currentTab == 0 ? FontWeight.w700 : FontWeight.w500, color: _currentTab == 0 ? CupertinoColors.systemGreen : theme.colorScheme.onSurface)),
                      ),
                      1: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text('Я должен', style: TextStyle(fontWeight: _currentTab == 1 ? FontWeight.w700 : FontWeight.w500, color: _currentTab == 1 ? CupertinoColors.destructiveRed : theme.colorScheme.onSurface)),
                      ),
                    },
                    onValueChanged: (val) {
                      if (val != null) {
                        HapticFeedback.selectionClick();
                        setState(() => _currentTab = val);
                      }
                    },
                  ),
                ),
              ),
            ),

            if (displayedDebts.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.person_2_alt, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
                      const SizedBox(height: 16),
                      Text(
                        _currentTab == 0 ? 'Никто вам не должен' : 'Вы никому не должны',
                        style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 16),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final debt = displayedDebts[index];
                      final isPaid = debt.isPaid;
                      final amountColor = isPaid
                          ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                          : (debt.isOwedToMe ? CupertinoColors.systemGreen : CupertinoColors.destructiveRed);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Slidable(
                          key: ValueKey(debt.id),
                          startActionPane: isPaid ? null : ActionPane(
                            motion: const StretchMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (_) async {
                                  HapticFeedback.heavyImpact();
                                  await tx.markDebtAsPaid(debt.id);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(debt.isOwedToMe ? 'Долг возвращен! Доход добавлен.' : 'Долг закрыт! Расход добавлен.'),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: theme.colorScheme.surface,
                                    ),
                                  );
                                },
                                backgroundColor: CupertinoColors.activeBlue,
                                foregroundColor: Colors.white,
                                icon: CupertinoIcons.checkmark_alt,
                                label: 'Вернули',
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ],
                          ),
                          endActionPane: ActionPane(
                            motion: const StretchMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (_) {
                                  HapticFeedback.mediumImpact();
                                  tx.deleteDebt(debt.id);
                                },
                                backgroundColor: CupertinoColors.destructiveRed,
                                foregroundColor: Colors.white,
                                icon: CupertinoIcons.trash,
                                label: 'Удалить',
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ],
                          ),
                          child: Opacity(
                            opacity: isPaid ? 0.6 : 1.0,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: amountColor.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                        isPaid ? CupertinoIcons.checkmark_shield_fill : CupertinoIcons.person_fill,
                                        color: amountColor,
                                        size: 20
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          debt.personName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                            color: theme.colorScheme.onSurface,
                                            decoration: isPaid ? TextDecoration.lineThrough : null,
                                          ),
                                        ),
                                        if (debt.dueDate != null) ...[
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(CupertinoIcons.calendar, size: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                                              const SizedBox(width: 4),
                                              Text(
                                                'До ${_formatDate(debt.dueDate!)}',
                                                style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 13),
                                              ),
                                            ],
                                          )
                                        ]
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${_formatNumber(debt.amount)} ${debt.currency}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                          color: amountColor,
                                        ),
                                      ),
                                      if (isPaid)
                                        const Text('ЗАКРЫТ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: CupertinoColors.systemGrey))
                                      else
                                        Text(debt.isOwedToMe ? 'Ждем' : 'Отдать', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: displayedDebts.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

class _AddDebtSheet extends StatefulWidget {
  const _AddDebtSheet();

  @override
  State<_AddDebtSheet> createState() => _AddDebtSheetState();
}

class _AddDebtSheetState extends State<_AddDebtSheet> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _amountCtrl = TextEditingController();
  bool _isOwedToMe = true;
  DateTime? _dueDate;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '.'));

    if (name.isEmpty || amount == null || amount <= 0) {
      HapticFeedback.heavyImpact();
      return;
    }

    final tx = context.read<TransactionsProvider>();
    final settings = context.read<SettingsProvider>();

    final newDebt = DebtModel(
      id: const Uuid().v4(),
      amount: amount,
      currency: settings.activeCurrency,
      personName: name,
      isOwedToMe: _isOwedToMe,
      dueDate: _dueDate,
      createdAt: DateTime.now(),
    );

    tx.addDebt(newDebt);
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: theme.colorScheme.surface.withValues(alpha: 0.9),
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24, bottom: bottomInset > 0 ? bottomInset + 16 : 32,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Новый долг', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: CupertinoSlidingSegmentedControl<bool>(
                    groupValue: _isOwedToMe,
                    children: const {
                      true: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Я дал в долг')),
                      false: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Я взял в долг')),
                    },
                    onValueChanged: (val) {
                      if (val != null) setState(() => _isOwedToMe = val);
                    },
                  ),
                ),
                const SizedBox(height: 24),

                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Имя человека',
                    hintText: 'Например: Иван',
                    prefixIcon: Icon(CupertinoIcons.person),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _amountCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Сумма',
                    hintText: '0.00',
                    prefixIcon: Icon(CupertinoIcons.money_dollar),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),

                GestureDetector(
                  onTap: () async {
                    FocusScope.of(context).unfocus();
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (date != null) setState(() => _dueDate = date);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.calendar, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                        const SizedBox(width: 12),
                        Text(
                          _dueDate == null ? 'Дата возврата (необязательно)' : 'Вернуть до: ${_dueDate!.day}.${_dueDate!.month}.${_dueDate!.year}',
                          style: TextStyle(
                            color: _dueDate == null ? theme.colorScheme.onSurface.withValues(alpha: 0.5) : theme.colorScheme.onSurface,
                            fontWeight: _dueDate == null ? FontWeight.w400 : FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                FilledButton(
                  onPressed: _save,
                  child: const Text('Сохранить'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}