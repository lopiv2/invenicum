import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stac/stac.dart';
import 'package:invenicum/providers/plugin_provider.dart';

class StacSlot extends StatelessWidget {
  final String slotName;

  const StacSlot({super.key, required this.slotName});

  @override
  Widget build(BuildContext context) {
    return Consumer<PluginProvider>(
      builder: (context, provider, child) {
        // 1. Obtenemos TODOS los plugins de este slot (activos e inactivos)
        // para que Flutter pueda animar la salida de los que se apagan.
        final slotPlugins = provider.installed
            .where((plugin) => plugin['slot'] == slotName)
            .toList();

        if (slotPlugins.isEmpty) return const SizedBox.shrink();

        return Column(
          children: slotPlugins.map((plugin) {
            final bool isActive = plugin['isActive'] ?? true;

            // 2. Usamos AnimatedOpacity para el efecto de desvanecimiento
            return AnimatedOpacity(
              opacity: isActive ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              // 3. Usamos AnimatedSize para que el hueco se cierre suavemente
              child: AnimatedSize(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                child: IgnorePointer(
                  ignoring: !isActive, // Si no está activo, no recibe clics
                  child: Container(
                    // Si está inactivo, forzamos la altura a 0 para que el slot se cierre
                    height: isActive ? null : 0,
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child:
                        Stac.fromJson(plugin['ui'], context) ??
                        const Text("Error de renderizado"),
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
