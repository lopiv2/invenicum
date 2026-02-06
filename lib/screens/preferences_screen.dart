import 'package:flutter/material.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/providers/theme_provider.dart';
import 'package:invenicum/widgets/general_settings_card_widget.dart';
import 'package:invenicum/widgets/loan_management_card_widget.dart';
import 'package:invenicum/widgets/about_card_widget.dart';
import 'package:invenicum/widgets/theme_picker_modal_widget.dart';
import 'package:provider/provider.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  @override
  Widget build(BuildContext context) {
    // Usamos watch para que la UI reaccione a los cambios de tema inmediatamente
    final themeName = context.select<ThemeProvider, String>(
      (p) => p.currentTheme.name,
    );
    final themeColor = context.select<ThemeProvider, Color>(
      (p) => p.currentTheme.primaryColor,
    );

    // Para las funciones usamos read (esto no provoca re-renders)
    final provider = context.read<ThemeProvider>();

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.preferences,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 32),
            GeneralSettingsCardWidget(
              themeName: themeName,
              themeColor: themeColor,
              onThemePickerTap: () => showThemePickerModal(context, provider),
            ),
            const SizedBox(height: 16),
            const LoanManagementCardWidget(),
            const SizedBox(height: 16),
            const AboutCardWidget(),
          ],
        ),
      ),
    );
  }
}
