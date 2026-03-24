import 'package:flutter/material.dart';
import 'package:invenicum/data/models/store_plugin_model.dart';
import 'package:invenicum/providers/plugin_provider.dart';
import 'package:invenicum/screens/plugins/local_widgets/plugin_editor_dialog.dart';
import 'package:provider/provider.dart';
import 'package:stac/stac.dart';

class ModernPluginCard extends StatelessWidget {
  final StorePlugin plugin;
  final bool isMarket;

  const ModernPluginCard({
    super.key,
    required this.plugin,
    required this.isMarket,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<PluginProvider>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. ÁREA SUPERIOR: Previsualización (Stack con Preview y Badges)
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.05),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Center(
                    child: Transform.scale(
                      scale: 0.7,
                      child: IgnorePointer(child: _buildStacPreview(context)),
                    ),
                  ),
                ),
                if (!isMarket)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: _buildContextMenu(context, provider),
                  ),
                Positioned(top: 10, left: 10, child: _buildSlotBadge()),
              ],
            ),
          ),

          // 2. ÁREA INFERIOR: Información
          Expanded(
            flex: 8,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                // <--- Esta es la columna que desborda
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CABECERA (Título y badges)
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          plugin.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ), // Bajamos un punto el font
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      _buildDownloadCount(),
                      const SizedBox(width: 4),
                      _buildVersionBadge(),
                    ],
                  ),

                  // INDICADOR DE UPDATE (Lo movemos debajo del título si no cabe al lado)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      children: [
                        if (plugin.hasUpdate) _buildUpdateIndicator(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 6),

                  // DESCRIPCIÓN (Flexible)
                  Expanded(
                    child: Text(
                      plugin.description.isEmpty
                          ? "Sin descripción disponible."
                          : plugin.description,
                      style: TextStyle(
                        fontSize: 11, // Bajamos un poco para ganar espacio
                        color: Colors.grey.shade600,
                        height: 1.2, // Reducimos interlineado
                      ),
                      maxLines:
                          2, // Reducimos de 3 a 2 líneas para asegurar espacio al botón
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const Divider(height: 12, thickness: 0.5),
                  _buildAuthorInfo(),
                  const SizedBox(height: 6),

                  // ACCIONES (Switch / Botones)
                  // Usamos un bloque que ocupe solo lo necesario
                  if (!isMarket)
                    _buildLibraryActions(provider)
                  else
                    _buildMarketActions(theme, provider),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS DE ACCIÓN ---

  Widget _buildLibraryActions(PluginProvider provider) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Estado",
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 20,
              child: Transform.scale(
                scale: 0.7,
                child: Switch.adaptive(
                  value: plugin.isActive,
                  onChanged: (v) => provider.togglePluginStatus(plugin.id, v),
                ),
              ),
            ),
          ],
        ),
        if (plugin.hasUpdate)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SizedBox(
              width: double.infinity,
              height: 32,
              child: ElevatedButton.icon(
                onPressed: () => provider.updateFromStore(plugin),
                icon: const Icon(Icons.system_update_alt, size: 14),
                label: Text("Actualizar a v${plugin.latestVersion}"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMarketActions(ThemeData theme, PluginProvider provider) {
    return SizedBox(
      width: double.infinity,
      height: 32,
      child: ElevatedButton(
        onPressed: () => provider.install(plugin),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          "Instalar Plugin",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // --- WIDGETS DE INFORMACIÓN Y ESTILO ---

  Widget _buildUpdateIndicator() {
    if (!plugin.hasUpdate) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.orange.shade400, width: 0.5),
      ),
      child: Text(
        "UPDATE",
        style: TextStyle(
          fontSize: 8,
          color: Colors.orange.shade900,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildVersionBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        "v${plugin.version}",
        style: const TextStyle(
          fontSize: 9,
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDownloadCount() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.file_download_outlined,
          size: 14,
          color: Colors.grey.shade500,
        ),
        const SizedBox(width: 2),
        Text(
          "${plugin.downloadCount}",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildSlotBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4),
        ],
      ),
      child: Text(
        plugin.slot.split('_').last.toUpperCase(),
        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAuthorInfo() {
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundImage: plugin.authorAvatar != null
              ? NetworkImage(plugin.authorAvatar!)
              : null,
          child: plugin.authorAvatar == null
              ? const Icon(Icons.person, size: 10)
              : null,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            "@${plugin.author}",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStacPreview(BuildContext context) {
    try {
      if (plugin.ui != null)
        return Stac.fromJson(plugin.ui!, context) ?? const SizedBox();
    } catch (_) {}
    return const Icon(Icons.extension_rounded, color: Colors.grey, size: 40);
  }

  Widget _buildContextMenu(BuildContext context, PluginProvider provider) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, size: 18),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onSelected: (value) => _handleAction(context, provider, value),
        itemBuilder: (context) => [
          if (plugin.isMine)
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit_outlined, size: 20),
                title: Text("Editar"),
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
          const PopupMenuItem(
            value: 'uninstall',
            child: ListTile(
              leading: Icon(Icons.download_for_offline_outlined, size: 20),
              title: Text("Desinstalar"),
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ),
          const PopupMenuDivider(),
          const PopupMenuItem(
            value: 'delete',
            child: ListTile(
              leading: Icon(Icons.delete_outline, color: Colors.red, size: 20),
              title: Text("Eliminar", style: TextStyle(color: Colors.red)),
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }

  void _handleAction(
    BuildContext context,
    PluginProvider provider,
    String action,
  ) async {
    // 🚩 Agregamos async para esperar al diálogo
    switch (action) {
      case 'edit':
        // 1. Esperamos a que el diálogo se cierre y capturemos los datos
        final Map<String, dynamic>? result =
            await showDialog<Map<String, dynamic>>(
              context: context,
              builder: (context) => PluginEditorDialog(plugin: plugin.toJson()),
            );

        // 2. Si el usuario no canceló (result != null), procesamos la edición
        if (result != null) {
          // Creamos un StorePlugin con los datos actualizados para el provider
          final updatedPlugin = StorePlugin.fromJson({
            ...plugin.toJson(), // Mantenemos ID, autor, etc.
            ...result, // Sobrescribimos con los cambios del diálogo
          });

          // 3. Llamamos al método del provider que gestionará el PUT o el PR
          await provider.editMyPluginMetadata(updatedPlugin);
        }
        break;

      case 'uninstall':
        provider.uninstall(plugin.id);
        break;

      case 'delete':
        _showDeleteDialog(context, provider);
        break;
    }
  }

  void _showDeleteDialog(BuildContext context, PluginProvider provider) {
    bool deleteFromGitHub = false;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("¿Eliminar plugin?"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Se eliminará de tu base de datos local."),
              if (plugin.isPublic && plugin.isMine) ...[
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.1)),
                  ),
                  child: CheckboxListTile(
                    title: const Text(
                      "Borrar de GitHub",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: const Text(
                      "Elimina el archivo del market público",
                      style: TextStyle(fontSize: 11),
                    ),
                    value: deleteFromGitHub,
                    onChanged: (val) => setState(() => deleteFromGitHub = val!),
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: Colors.red,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                "CANCELAR",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                provider.deletePlugin(
                  plugin.id,
                  deleteFromGitHub: deleteFromGitHub,
                );
                Navigator.pop(ctx);
              },
              child: const Text(
                "BORRAR",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
