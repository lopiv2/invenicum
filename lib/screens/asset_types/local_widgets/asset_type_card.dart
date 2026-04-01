import 'package:flutter/material.dart';
import 'package:invenicum/data/models/asset_type_model.dart';
import 'package:invenicum/data/models/custom_field_definition.dart';
import 'package:invenicum/data/models/custom_field_definition_model.dart';
import 'package:invenicum/data/services/toast_service.dart';
import 'package:provider/provider.dart';
import 'package:invenicum/providers/container_provider.dart';
import 'package:invenicum/config/environment.dart';
import 'package:invenicum/l10n/app_localizations.dart';

class AssetTypeCard extends StatelessWidget {
  final String containerId;
  final AssetType assetType;
  final int assetCount;
  final bool isCollection;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  const AssetTypeCard({
    super.key,
    required this.containerId,
    required this.assetType,
    required this.assetCount,
    required this.isCollection,
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
    if (!isCollection) {
      ToastService.error(
        'Los campos de posesión y deseados solo se configuran dentro de contenedores de colección.',
      );
      return;
    }

    if (assetType.isSerialized) {
      ToastService.error(
        'Los campos de colección solo pueden asignarse a tipos no seriados. Cambia este tipo a no seriado antes de configurarlos.',
      );
      return;
    }

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
          ToastService.success(AppLocalizations.of(context)!.assetTypeDeletedSuccess(assetType.name));
        }
      } catch (e) {
        if (context.mounted) ToastService.error(AppLocalizations.of(context)!.unknownError);
      }
    }
  }

  // --- DISEÑO ACTUALIZADO CON NOMBRE ARRIBA ---

  /// Construye la URL pública completa de una imagen de forma segura.
  ///
  /// Maneja los tres casos posibles que pueden venir de la DB:
  ///   1. URL ya absoluta: "http://server/images/asset-types/file.jpg" → la devuelve tal cual
  ///   2. URL relativa con barra: "/images/asset-types/file.jpg"       → añade el host
  ///   3. URL relativa sin barra: "asset-types/file.jpg" (registros viejos) → añade host + /images/
  static String _buildImageUrl(String rawUrl) {
    if (rawUrl.isEmpty) return '';

    // Caso 1: ya es absoluta
    if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) {
      return rawUrl;
    }

    // Host sin trailing slash
    final host = Environment.apiUrl.endsWith('/')
        ? Environment.apiUrl.substring(0, Environment.apiUrl.length - 1)
        : Environment.apiUrl;

    // Caso 2: relativa correcta ("/images/...")
    if (rawUrl.startsWith('/')) {
      return '$host$rawUrl';
    }

    // Caso 3: relativa sin barra inicial (registros guardados antes del fix)
    // Añadimos el prefijo /images/ que debería tener
    final staticPrefix = '/images';
    return '$host$staticPrefix/$rawUrl';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 900;
    
    final indicatorColor = isCollection
        ? Colors.lightGreen
        : theme.primaryColor;
    final fullImageUrl = assetType.images.isNotEmpty
        ? _buildImageUrl(assetType.images.first.url)
        : '';
    
    // Dimensiones responsivas
    final imageWidth = isMobile ? 80.0 : (isTablet ? 100.0 : 110.0);
    final cardHeight = isMobile ? 110.0 : 125.0;
    final fontSize = isMobile ? 14.0 : 18.0;
    final padding = isMobile ? 12.0 : 16.0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border(
          bottom: BorderSide(
            color: indicatorColor,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
              height: cardHeight,
              child: Row(
                children: [
                  // Imagen lateral - responsive
                  _buildHeroImage(fullImageUrl, theme, imageWidth),

                  // Contenido Principal
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(padding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. NOMBRE ARRIBA
                          Flexible(
                            child: Text(
                              assetType.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: fontSize,
                                letterSpacing: -0.5,
                              ),
                              maxLines: isMobile ? 1 : 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Spacer(),
                          // 2. FILA INFERIOR: Badge + Botones
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                flex: 2,
                                child: _buildAssetBadge(context, theme, isMobile),
                              ),
                              const SizedBox(width: 4),
                              // Botones responsive
                              Flexible(
                                flex: 3,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: _buildActionRow(
                                    context,
                                    theme,
                                    isMobile,
                                  ),
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

  Widget _buildHeroImage(
    String url,
    ThemeData theme,
    double width,
  ) {
    return Container(
      width: width,
      height: double.infinity,
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.05),
      ),
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
      color: theme.primaryColor.withValues(alpha: 0.2),
      size: 35,
    );
  }

  Widget _buildAssetBadge(
    BuildContext context,
    ThemeData theme,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 6.0 : 10.0,
        vertical: isMobile ? 3.0 : 4.0,
      ),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$assetCount ${AppLocalizations.of(context)!.active}',
        style: TextStyle(
          fontSize: isMobile ? 11.0 : 12.0,
          fontWeight: FontWeight.bold,
          color: theme.primaryColor,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildActionRow(
    BuildContext context,
    ThemeData theme,
    bool isMobile,
  ) {
    final buttonSize = isMobile ? 36.0 : 40.0;
    final iconSize = isMobile ? 18.0 : 20.0;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isCollection)
          _CircleIconButton(
            icon: Icons.tune_rounded,
            color: Colors.orange,
            size: buttonSize,
            iconSize: iconSize,
            onPressed: () => _showConfigureCollectionDialog(context),
            tooltip: 'Campos de colección',
          ),
        const SizedBox(width: 4),
        _CircleIconButton(
          icon: Icons.edit_rounded,
          color: theme.primaryColor,
          size: buttonSize,
          iconSize: iconSize,
          onPressed: onEdit,
          tooltip: 'Editar',
        ),
        const SizedBox(width: 4),
        _CircleIconButton(
          icon: Icons.delete_outline_rounded,
          color: Colors.redAccent,
          size: buttonSize,
          iconSize: iconSize,
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
  final double size;
  final double iconSize;

  const _CircleIconButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.tooltip,
    this.size = 40.0,
    this.iconSize = 20.0,
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
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(icon, size: iconSize, color: color),
            ),
          ),
        ),
      ),
    );
  }
}
