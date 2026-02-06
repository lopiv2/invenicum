import 'package:flutter/material.dart';
import 'package:invenicum/models/asset_type_model.dart';
import 'package:invenicum/models/custom_field_definition.dart';
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

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.confirmDeletion),
              content: Text(AppLocalizations.of(context)!.confirmDeleteAssetType(assetType.name)),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
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

    // Obtener solo los campos booleanos del tipo de activo
    final booleanFields = assetType.fieldDefinitions
        .where((field) =>
            field.type == CustomFieldType.boolean)
        .toList();

    if (!context.mounted) return;

    final result = await showDialog<Map<String, String?>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.configureCollectionFields),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.selectBooleanFields,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                Text(AppLocalizations.of(context)!.possessionFieldDef + ':'),
                const SizedBox(height: 8),
                if (booleanFields.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      AppLocalizations.of(context)!.noBooleanFields,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  DropdownButtonFormField<String?>(
                    value: possessionFieldId,
                    hint: Text(AppLocalizations.of(context)!.selectField),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(AppLocalizations.of(context)!.none),
                      ),
                      ...booleanFields.map((field) {
                        return DropdownMenuItem(
                          value: field.id.toString(),
                          child: Text(field.name),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        possessionFieldId = value;
                      });
                    },
                  ),
                const SizedBox(height: 20),
                Text(AppLocalizations.of(context)!.desiredField + ':'),
                const SizedBox(height: 8),
                if (booleanFields.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      AppLocalizations.of(context)!.noBooleanFields,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  DropdownButtonFormField<String?>(
                    value: desiredFieldId,
                    hint: Text(AppLocalizations.of(context)!.selectField),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(AppLocalizations.of(context)!.none),
                      ),
                      ...booleanFields.map((field) {
                        return DropdownMenuItem(
                          value: field.id.toString(),
                          child: Text(field.name),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        desiredFieldId = value;
                      });
                    },
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
          ToastService.success('Campos de colección configurados.');
        }
      } catch (e) {
        if (context.mounted) {
          ToastService.error('Error: $e');
        }
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
          ToastService.success(
            'Tipo de Activo "${assetType.name}" eliminado con éxito.',
          );
        }
      } catch (e) {
        if (context.mounted) {
          ToastService.error('Error al eliminar ${assetType.name}: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = assetType.images.isNotEmpty
        ? assetType.images.first.url
        : null;
    final fullImageUrl = imageUrl != null
        ? '${Environment.apiUrl}$imageUrl'
        : '';
    final hasImage = fullImageUrl.isNotEmpty;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Row(
          children: [
            // Contenedor de imagen
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.07,
                height: MediaQuery.of(context).size.height * 0.15,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  color: Colors.grey.shade100,
                ),
                child: hasImage
                    ? Image.network(
                        fullImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 30,
                                color: Colors.grey,
                              ),
                            ),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        },
                      )
                    : const Center(
                        child: Icon(
                          Icons.inventory_2_outlined,
                          size: 30,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),
            // Contenido
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Columna izquierda: Título y contador
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            assetType.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$assetCount Activos',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Columna derecha: Iconos y botones
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 🔑 BOTÓN DE CONFIGURAR COLECCIÓN
                        IconButton(
                          icon: const Icon(
                            Icons.tune_outlined,
                            color: Colors.orange,
                          ),
                          onPressed: () =>
                              _showConfigureCollectionDialog(context),
                          tooltip: 'Configurar campos de colección',
                        ),
                        // 🔑 BOTÓN DE EDITAR
                        IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: Colors.blueGrey,
                          ),
                          onPressed: onEdit, // Usar el nuevo callback
                          tooltip: 'Editar tipo de activo',
                        ),

                        // BOTÓN DE ELIMINAR
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () => _handleDelete(context),
                          tooltip: 'Eliminar tipo de activo',
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
    );
  }
}
