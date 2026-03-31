import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stac/stac.dart';
import 'package:invenicum/providers/plugin_provider.dart';
import 'package:invenicum/l10n/app_localizations.dart';

class StacSlot extends StatelessWidget {
  final String slotName;

  const StacSlot({super.key, required this.slotName});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<PluginProvider>(
      builder: (context, provider, child) {
        final slotPlugins = provider.installed
            .where((plugin) => plugin.slot == slotName)
            .toList();

        if (slotPlugins.isEmpty) return const SizedBox.shrink();

        return Column(
          children: slotPlugins.map((plugin) {
            final bool isActive = plugin.isActive;
            
            // 🚩 EXTRACCIÓN SEGURA DE LA UI
            // Buscamos la propiedad 'ui' dentro del mapa. 
            // Si 'plugin['ui']' es a su vez un mapa que contiene otra llave 'ui', la extraemos.
            final dynamic rawUi = plugin.ui;
            final Map<String, dynamic>? uiToRender = (rawUi is Map<String, dynamic> && rawUi.containsKey('ui'))
                ? rawUi['ui'] as Map<String, dynamic>
                : (rawUi is Map<String, dynamic> ? rawUi : null);

            return AnimatedOpacity(
              opacity: isActive ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              child: AnimatedSize(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                child: IgnorePointer(
                  ignoring: !isActive,
                  child: Container(
                    height: isActive ? null : 0,
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: uiToRender != null 
                        ? (Stac.fromJson(uiToRender, context) ?? Text(l10n.pluginRenderError))
                        : Text(l10n.invalidUiFormat),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}