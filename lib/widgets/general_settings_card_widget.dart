import 'package:flutter/material.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/providers/integrations_provider.dart';
import 'package:invenicum/providers/preferences_provider.dart';
import 'package:invenicum/services/toast_service.dart';
import 'package:invenicum/widgets/language_dropdown_widget.dart';
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
    final bool isGeminiConnected = integrationProvider.isLinked('gemini');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.generalSettings,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: Text(AppLocalizations.of(context)!.applicationTheme),
              subtitle: Text(
                '${AppLocalizations.of(context)!.current}: $themeName',
              ),
              trailing: CircleAvatar(backgroundColor: themeColor, radius: 12),
              onTap: onThemePickerTap,
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
            SwitchListTile(
            title: const Text("Habilitar Inteligencia Artificial y Chatbot"),
            // Mostramos un subtítulo de advertencia solo si no está conectado
            subtitle: !isGeminiConnected 
              ? const Text(
                  "Requiere vinculación con Gemini en Integraciones",
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                )
              : const Text("Usa IA para organizar tu inventario de manera inteligente"),
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
                ToastService.info("Primero debes configurar la integración de Gemini");
                return;
              }

              // Si está vinculado, procedemos normal
              try {
                await prefsProvider.setAiEnabled(value);
                ToastService.success(value ? "IA Activada" : "IA Desactivada");
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
