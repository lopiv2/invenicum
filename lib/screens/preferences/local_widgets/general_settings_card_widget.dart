import 'package:flutter/material.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/providers/integrations_provider.dart';
import 'package:invenicum/providers/preferences_provider.dart';
import 'package:invenicum/data/services/toast_service.dart';
import 'package:invenicum/screens/preferences/local_widgets/currency_dropdown_widget.dart';
import 'package:invenicum/screens/preferences/local_widgets/language_dropdown_widget.dart';
import 'package:provider/provider.dart';

class GeneralSettingsCardWidget extends StatelessWidget {
  final String themeName;
  final Color themeColor;
  final VoidCallback onThemePickerTap;

  const GeneralSettingsCardWidget({
    super.key,
    required this.themeName,
    required this.themeColor,
    required this.onThemePickerTap,
  });

  @override
  Widget build(BuildContext context) {
    final prefsProvider = context.watch<PreferencesProvider>();
    final integrationProvider = context.watch<IntegrationProvider>();
    final l10n = AppLocalizations.of(context)!;
    final bool isGeminiConnected = integrationProvider.isLinked('gemini');
    final bool isAutoDark = prefsProvider.useSystemTheme;
    final bool isManualDark = prefsProvider.isDarkMode;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.generalSettings,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            // --- SELECTOR DE COLOR DE TEMA ---
            ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: Text(AppLocalizations.of(context)!.applicationTheme),
              subtitle: Text(
                '${AppLocalizations.of(context)!.current}: $themeName',
              ),
              trailing: CircleAvatar(backgroundColor: themeColor, radius: 12),
              onTap: onThemePickerTap,
            ),
            // --- MODO OSCURO AUTOMÁTICO ---
            SwitchListTile(
              secondary: const Icon(Icons.brightness_auto),
              title: Text(l10n.automaticDarkModeLabel),
              subtitle: Text(l10n.syncWithSystemLabel),
              value: isAutoDark,
              onChanged: (bool value) {
                prefsProvider.setUseSystemTheme(value);
              },
            ),

            // --- MODO OSCURO MANUAL (Se deshabilita si el automático está activo) ---
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode_outlined),
              title: Text(l10n.manualDarkModeLabel),
              subtitle: isAutoDark
                  ? Text(l10n.disableAutomaticToChange)
                  : Text(l10n.changeLightDark),
              value: isManualDark,
              // 🚀 CRÍTICO: Si isAutoDark es true, el switch se ve gris y no responde
              onChanged: prefsProvider.useSystemTheme
                  ? null
                  : (bool value) => prefsProvider.setDarkMode(value),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(AppLocalizations.of(context)!.language),
              subtitle: Text(
                AppLocalizations.of(context)!.selectApplicationLanguage,
              ),
              trailing: const LanguageDropdownWidget(),
              onTap: null,
            ),
            ListTile(
              leading: const Icon(Icons.money),
              title: Text(AppLocalizations.of(context)!.currency),
              subtitle: Text(
                AppLocalizations.of(context)!.selectApplicationCurrency,
              ),
              trailing: const CurrencyDropdownWidget(),
              onTap: null,
            ),
            if (prefsProvider.selectedCurrency != 'USD' &&
                prefsProvider.exchangeRates != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onPrimaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "1 USD = ${prefsProvider.exchangeRates![prefsProvider.selectedCurrency]?.toStringAsFixed(4)} ${prefsProvider.selectedCurrency}",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        l10n.marketRealRate,
                        style: TextStyle(
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            SwitchListTile(
              title: Text(l10n.enableAiAndChatbot),
              // Mostramos un subtítulo de advertencia solo si no está conectado
              subtitle: !isGeminiConnected
                  ? Text(
                      l10n.requiresGeminiLinking,
                      style: const TextStyle(color: Colors.orange, fontSize: 12),
                    )
                  : Text(l10n.aiOrganizeInventory),
              secondary: Icon(
                Icons.auto_awesome,
                // Cambiamos el color del icono según la disponibilidad
                color: isGeminiConnected ? Colors.blue : Colors.grey,
              ),
              // El valor del switch depende de las preferencias,
              // pero si Gemini no está conectado, forzamos que se vea apagado
              value: isGeminiConnected && prefsProvider.aiEnabled,

              // LÓGICA DE VALIDACIÓN
              onChanged: (bool value) async {
                if (!isGeminiConnected) {
                  // Si intenta activarlo sin estar vinculado, avisamos
                  ToastService.info(
                    l10n.requiresGeminiLinking,
                  );
                  return;
                }

                // Si está vinculado, procedemos normal
                try {
                  await prefsProvider.setAiEnabled(value);
                  ToastService.success(
                    value ? l10n.aiProviderUpdated : l10n.aiProviderUpdated,
                  );
                } catch (e) {
                  ToastService.error("Error al actualizar la preferencia");
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
