import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/app_state.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTab),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text(l10n.language),
                  subtitle: Text(l10n.languageDescription),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      final localeController = context.read<LocaleController>();
                      if (value == 'en') {
                        localeController.setLocale(const Locale('en'));
                      } else if (value == 'ru') {
                        localeController.setLocale(const Locale('ru'));
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'en',
                        child: Text(l10n.english),
                      ),
                      PopupMenuItem(
                        value: 'ru',
                        child: Text(l10n.russian),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: Text(l10n.restartOnboarding),
                  subtitle: Text(l10n.restartOnboardingDescription),
                  onTap: () {
                    context.read<AppState>().resetOnboarding();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}