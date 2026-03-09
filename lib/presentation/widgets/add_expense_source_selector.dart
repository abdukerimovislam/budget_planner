import 'package:flutter/material.dart';

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

    return SegmentedButton<AddExpenseSourceMode>(
      segments: [
        ButtonSegment(
          value: AddExpenseSourceMode.smartText,
          icon: const Icon(Icons.edit_note_rounded),
          label: Text(l10n.addSourceSmartText),
        ),
        ButtonSegment(
          value: AddExpenseSourceMode.voice,
          icon: const Icon(Icons.mic_rounded),
          label: Text(l10n.addSourceVoice),
        ),
        ButtonSegment(
          value: AddExpenseSourceMode.receipt,
          icon: const Icon(Icons.receipt_long_rounded),
          label: Text(l10n.addSourceReceipt),
        ),
      ],
      selected: {value},
      onSelectionChanged: (values) {
        onChanged(values.first);
      },
    );
  }
}