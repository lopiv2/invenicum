import 'package:flutter/material.dart';
import 'package:invenicum/models/asset_type_model.dart';
import 'package:invenicum/models/custom_field_definition.dart';
import 'package:invenicum/models/custom_field_definition_model.dart';
import 'package:invenicum/services/toast_service.dart';
import 'package:provider/provider.dart';
import 'package:invenicum/providers/container_provider.dart';
import 'package:invenicum/config/environment.dart';
import 'package:invenicum/l10n/app_localizations.dart';

class AssetTypeCard extends StatelessWidget {
  final String containerId;
  final AssetType assetType;
  final int assetCount;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  const AssetTypeCard({
    super.key,
    required this.containerId,
    required this.assetType,
    required this.assetCount,
    this.onTap,
    this.onEdit,
  });

  // --- MÉTODOS DE LÓGICA (Mantenidos igual para funcionalidad total) ---

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Text(AppLocalizations.of(context)!.confirmDeletion),
              content: Text(
                AppLocalizations.of(
                  context,
                )!.confirmDeleteAssetType(assetType.name),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(AppLocalizations.of(context)!.delete),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _showConfigureCollectionDialog(BuildContext context) async {
    String? possessionFieldId = assetType.possessionFieldId;
    String? desiredFieldId = assetType.desiredFieldId;

    final booleanFields = assetType.fieldDefinitions
        .where((field) => field.type == CustomFieldType.boolean)
        .toList();

    if (!context.mounted) return;

    final result = await showDialog<Map<String, String?>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(AppLocalizations.of(context)!.configureCollectionFields),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.selectBooleanFields,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDropdownLabel(
                  AppLocalizations.of(context)!.possessionFieldDef,
                ),
                _buildDropdown(
                  context,
                  value: possessionFieldId,
                  fields: booleanFields,
                  onChanged: (val) => setState(() => possessionFieldId = val),
                ),
                const SizedBox(height: 20),
                _buildDropdownLabel(AppLocalizations.of(context)!.desiredField),
                _buildDropdown(
                  context,
                  value: desiredFieldId,
                  fields: booleanFields,
                  onChanged: (val) => setState(() => desiredFieldId = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(context, {
                'possession': possessionFieldId,
                'desired': desiredFieldId,
              }),
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        ),
      ),
    );

    if (result != null && context.mounted) {
      try {
        final containerIdInt = int.tryParse(containerId);
        if (containerIdInt == null) return;

        await context.read<ContainerProvider>().updateAssetTypeCollectionFields(
          containerId: containerIdInt,
          assetTypeId: assetType.id,
          possessionFieldId: result['possession'],
          desiredFieldId: result['desired'],
        );

        if (context.mounted) {
          ToastService.success('Configuración guardada correctamente.');
        }
      } catch (e) {
        if (context.mounted) ToastService.error('Error: $e');
      }
    }
  }

  void _handleDelete(BuildContext context) async {
    final confirmed = await _showDeleteConfirmationDialog(context);
    if (confirmed) {
      try {
        await context.read<ContainerProvider>().deleteAssetType(
          int.parse(containerId),
          assetType.id,
        );
        if (context.mounted) {
          ToastService.success('"${assetType.name}" eliminado.');
        }
      } catch (e) {
        if (context.mounted) ToastService.error('Error: $e');
      }
    }
  }

  // --- DISEÑO ACTUALIZADO CON NOMBRE ARRIBA ---

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String? imageUrl = assetType.images.isNotEmpty
        ? assetType.images.first.url
        : null;
    final fullImageUrl = imageUrl != null
        ? '${Environment.apiUrl}$imageUrl'
        : '';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: theme.cardColor,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              height:
                  125, // Un poco más de altura para acomodar el nombre arriba
              child: Row(
                children: [
                  // Imagen lateral
                  _buildHeroImage(fullImageUrl, theme),

                  // Contenido Principal
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. NOMBRE ARRIBA (con más espacio)
                          Text(
                            assetType.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              letterSpacing: -0.5,
                            ),
                            maxLines: 2, // Permite 2 líneas si es muy largo
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(), // Empuja el resto hacia abajo
                          // 2. FILA INFERIOR: Badge + Botones
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                flex: 2,
                                child: _buildAssetBadge(context, theme),
                              ),
                              const SizedBox(width: 4),
                              // Botones envueltos en Flexible para que no desborden
                              Flexible(
                                flex: 3,
                                child: FittedBox(
                                  // Asegura que los botones se escalen si no caben
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerRight,
                                  child: _buildActionRow(context, theme),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroImage(String url, ThemeData theme) {
    return Container(
      width: 110,
      height: double.infinity,
      decoration: BoxDecoration(color: theme.primaryColor.withOpacity(0.05)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          url.isNotEmpty
              ? Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildPlaceholder(theme),
                )
              : _buildPlaceholder(theme),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Colors.black12, Colors.transparent],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Icon(
      Icons.category_outlined,
      color: theme.primaryColor.withOpacity(0.2),
      size: 35,
    );
  }

  Widget _buildAssetBadge(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$assetCount Activos',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: theme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildActionRow(BuildContext context, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CircleIconButton(
          icon: Icons.tune_rounded,
          color: Colors.orange,
          onPressed: () => _showConfigureCollectionDialog(context),
          tooltip: 'Configurar',
        ),
        _CircleIconButton(
          icon: Icons.edit_rounded,
          color: theme.primaryColor,
          onPressed: onEdit,
          tooltip: 'Editar',
        ),
        _CircleIconButton(
          icon: Icons.delete_outline_rounded,
          color: Colors.redAccent,
          onPressed: () => _handleDelete(context),
          tooltip: 'Eliminar',
        ),
      ],
    );
  }

  // --- HELPERS PARA DIÁLOGOS ---

  Widget _buildDropdownLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label + ':',
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildDropdown(
    BuildContext context, {
    required String? value,
    required List<CustomFieldDefinition> fields,
    required Function(String?) onChanged,
  }) {
    if (fields.isEmpty) {
      return Text(
        AppLocalizations.of(context)!.noBooleanFields,
        style: const TextStyle(color: Colors.grey, fontSize: 13),
      );
    }
    return DropdownButtonFormField<String?>(
      value: value,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      hint: Text(AppLocalizations.of(context)!.selectField),
      items: [
        DropdownMenuItem(
          value: null,
          child: Text(AppLocalizations.of(context)!.none),
        ),
        ...fields.map(
          (field) => DropdownMenuItem(
            value: field.id.toString(),
            child: Text(field.name),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;
  final String tooltip;

  const _CircleIconButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(
              8,
            ), // Un poco más pequeño para dar aire al nombre
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      ),
    );
  }
}
