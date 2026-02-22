import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/models/asset_type_model.dart';
import 'package:invenicum/models/container_node.dart';
import 'package:invenicum/models/custom_field_definition_model.dart';
import 'package:invenicum/providers/container_provider.dart';
import 'package:invenicum/providers/integrations_provider.dart';
import 'package:invenicum/providers/preferences_provider.dart';
import 'package:invenicum/services/toast_service.dart';
import 'package:invenicum/widgets/asset_image_gallery_widget.dart';
import 'package:invenicum/widgets/price_display_widget.dart';
import 'package:invenicum/widgets/price_history_chart_widget.dart';
import 'package:provider/provider.dart';
import 'package:invenicum/l10n/app_localizations.dart'; // Asegúrate de que esta ruta es correcta
import 'package:invenicum/models/inventory_item.dart';
import 'package:invenicum/models/custom_field_definition.dart'; // Necesario para CustomFieldType
import 'package:invenicum/providers/inventory_item_provider.dart';
import 'package:invenicum/config/environment.dart'; // Para la URL base de imágenes
import 'package:url_launcher/url_launcher.dart'; // Para abrir URLs

class AssetDetailScreen extends StatefulWidget {
  final String containerId;
  final String assetTypeId;
  final String itemId;

  const AssetDetailScreen({
    Key? key,
    required this.containerId,
    required this.assetTypeId,
    required this.itemId,
  }) : super(key: key);

  @override
  State<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends State<AssetDetailScreen> {
  String? _selectedImageUrl; // Para la galería de imágenes

  @override
  void initState() {
    super.initState();
    // Cargar el ítem específico si no está ya en caché o para asegurar datos frescos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InventoryItemProvider>(
        context,
        listen: false,
      ).loadInventoryItems(
        containerId: int.parse(widget.containerId),
        assetTypeId: int.parse(widget.assetTypeId),
        forceReload: false, // No forzar recarga si ya está en caché
      );
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryItemProvider>().loadPriceHistory(
        int.parse(widget.itemId),
      );
    });
  }

  @override
  void didUpdateWidget(covariant AssetDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 🚩 Si alguno de los IDs cambia, forzamos la recarga de datos
    if (oldWidget.itemId != widget.itemId ||
        oldWidget.containerId != widget.containerId ||
        oldWidget.assetTypeId != widget.assetTypeId) {
      _selectedImageUrl = null; // Resetear imagen

      // Forzar al provider a cargar los nuevos datos del nuevo container/assetType
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final itemProvider = Provider.of<InventoryItemProvider>(
          context,
          listen: false,
        );

        // Sincronizamos los IDs internos del provider inmediatamente
        itemProvider.updateContextIds(
          int.parse(widget.containerId),
          int.parse(widget.assetTypeId),
        );

        // Cargamos los items del nuevo contexto
        itemProvider.loadInventoryItems(
          containerId: int.parse(widget.containerId),
          assetTypeId: int.parse(widget.assetTypeId),
          forceReload:
              false, // Forzamos para evitar ver datos del container anterior
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final itemProvider = context.watch<InventoryItemProvider>();
    final preferencesProvider = context.watch<PreferencesProvider>();
    final int itemId = int.tryParse(widget.itemId) ?? 0;

    if (itemId == 0) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.assetDetail)),
        body: Center(child: Text(l10n.invalidAssetId)),
      );
    }

    final InventoryItem? item = itemProvider.inventoryItems
        .cast<InventoryItem?>()
        .firstWhere((i) => i?.id == itemId, orElse: () => null);

    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.assetDetail)),
        body: itemProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(child: Text(l10n.assetNotFound)),
      );
    }

    // Inicializar _selectedImageUrl si no hay ninguna seleccionada y hay imágenes
    if (_selectedImageUrl == null && item.images.isNotEmpty) {
      _selectedImageUrl = '${Environment.apiUrl}${item.images.first.url}';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(), // Vuelve a la pantalla anterior
        ),
        actions: [
          // Flecha Anterior
          IconButton(
            icon: const Icon(Icons.arrow_left, size: 32),
            tooltip: l10n
                .previous, // Asegúrate de tener esta clave en arb o usa "Anterior"
            onPressed: () => _navigateToSibling(-1),
          ),
          // Flecha Siguiente
          IconButton(
            icon: const Icon(Icons.arrow_right, size: 32),
            tooltip: l10n
                .next, // Asegúrate de tener esta clave en arb o usa "Siguiente"
            onPressed: () => _navigateToSibling(1),
          ),
          const VerticalDivider(
            width: 20,
            indent: 10,
            endIndent: 10,
          ), // Separador visual
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: l10n.edit,
            onPressed: () {
              // Navegar a la pantalla de edición
              context.go(
                '/container/${widget.containerId}/asset-types/${widget.assetTypeId}/assets/${item.id}/edit',
                extra:
                    item, // Pasamos el objeto para evitar que el edit tenga que volver a cargar de la API
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección de Galería de Imágenes y Detalles Clave
            _buildHeaderSection(context, item, l10n, preferencesProvider),
            const SizedBox(height: 32),

            // Descripción (si existe)
            if (item.description != null && item.description!.isNotEmpty) ...[
              Text(
                l10n.description,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                item.description!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
            ],

            // Sección de Campos Personalizados
            _buildCustomFieldsSection(context, item, itemProvider, l10n),
            const SizedBox(height: 32),
            Consumer<InventoryItemProvider>(
              builder: (context, provider, child) {
                if (provider.loadingHistory) {
                  return const Center(child: CircularProgressIndicator());
                }

                return PriceHistoryChart(history: provider.itemHistory);
              },
            ),
            // Información Adicional (Creación, Actualización)
            _buildMetadataSection(context, item, l10n),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black, // Fondo negro para resaltar la imagen
        child: Stack(
          children: [
            // Widget para permitir zoom y paneo
            Center(
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.broken_image,
                    color: Colors.white,
                    size: 100,
                  ),
                ),
              ),
            ),
            // Botón de cerrar en la esquina superior
            Positioned(
              top: 20,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToSibling(int offset) {
    final itemProvider = Provider.of<InventoryItemProvider>(
      context,
      listen: false,
    );
    final items = itemProvider.inventoryItems;

    if (items.isEmpty) return;

    final int currentId = int.tryParse(widget.itemId) ?? 0;
    final int currentIndex = items.indexWhere((i) => i.id == currentId);

    if (currentIndex != -1) {
      // Cálculo del nuevo índice con lógica circular
      int nextIndex = currentIndex + offset;

      if (nextIndex < 0) {
        // Si es menor a 0, saltamos al último
        nextIndex = items.length - 1;
      } else if (nextIndex >= items.length) {
        // Si sobrepasa el final, volvemos al primero
        nextIndex = 0;
      }

      final nextItem = items[nextIndex];

      // Resetear imagen seleccionada para el nuevo ítem
      setState(() {
        _selectedImageUrl = null;
      });

      // Navegar
      context.go(
        '/container/${widget.containerId}/asset-types/${widget.assetTypeId}/assets/${nextItem.id}',
      );
    }
  }

  // --- Widgets Auxiliares ---

  Widget _buildHeaderSection(
    BuildContext context,
    InventoryItem item,
    AppLocalizations l10n,
    PreferencesProvider preferencesProvider,
  ) {
    final integrationProv = context.watch<IntegrationProvider>();
    final itemProvider = context.watch<InventoryItemProvider>();
    final history = item.priceHistory ?? [];
    IconData? trendIcon;
    Color? trendColor;
    String? percentageText;
    if (history.length >= 2) {
      final lastPrice = history.last.price;
      final previousPrice = history[history.length - 2].price;

      if (previousPrice > 0) {
        // Cálculo del porcentaje: ((Actual - Anterior) / Anterior) * 100
        final double change =
            ((lastPrice - previousPrice) / previousPrice) * 100;

        // Formateamos con un decimal y el signo + si es positivo
        percentageText =
            "${change > 0 ? '+' : ''}${change.toStringAsFixed(1)}%";

        if (change > 0) {
          trendIcon = Icons.trending_up;
          trendColor = Colors.green.shade700;
        } else if (change < 0) {
          trendIcon = Icons.trending_down;
          trendColor = Colors.red.shade700;
        } else {
          if (change == 0) {
            trendIcon = Icons.trending_flat;
            trendColor = Colors.yellow.shade700;
          }
        }
        // Si change == 0, trendIcon se queda nulo y no se muestra nada
      }
    }
    // 2. Verificamos si la integración está activa
    final bool isUpcEnabled = integrationProv.isLinked('upcitemdb');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Galería de Imágenes (a la izquierda)
        Expanded(
          flex: 2,
          child: AssetImageGallery(
            item: item,
            onImageTap: (url) => _showFullScreenImage(context, url),
          ),
        ),
        const SizedBox(width: 32),
        // Detalles Clave (a la derecha)
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(l10n.quantity, item.quantity.toString()),
              _buildInfoRow(l10n.minStock, item.minStock.toString()),
              if (item.location != null)
                _buildInfoRow(l10n.location, item.location!.name),
              if (item.barcode != null)
                _buildInfoRow(l10n.barCode, item.barcode!),
              // --- SECCIÓN DE VALOR DE MERCADO ---
              if (item.marketValue > 0) ...[
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      // 🔑 CAMBIO AQUÍ: Usamos el preferencesProvider para obtener el precio y símbolo correctos
                      "${preferencesProvider.convertPrice(item.marketValue).toStringAsFixed(2)} ${preferencesProvider.selectedCurrency}",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                    if (trendIcon != null) ...[
                      const SizedBox(width: 8),
                      Icon(trendIcon, color: trendColor, size: 24),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: trendColor!.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          percentageText!,
                          style: TextStyle(
                            color: trendColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  "(${l10n.averageMarketValue})",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 4),
              ],
              if (isUpcEnabled) ...[
                const SizedBox(height: 20),
                itemProvider.isSyncing
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            await itemProvider.syncWithUPC(item.id);
                            ToastService.success(
                              "Datos actualizados correctamente",
                            );
                          } catch (e) {
                            if (mounted) {
                              ToastService.error("Error al sincronizar: $e");
                            }
                          }
                        },
                        icon: const Icon(Icons.cloud_sync_outlined),
                        label: const Text("Obtener valor de mercado"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade50,
                          foregroundColor: Colors.blue.shade800,
                          elevation: 0,
                        ),
                      ),
              ],
              // Puedes añadir más campos clave aquí
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Flexible(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildCustomFieldsSection(
    BuildContext context,
    InventoryItem item,
    InventoryItemProvider itemProvider,
    AppLocalizations l10n,
  ) {
    final containerProvider = context.watch<ContainerProvider>();
    final cIdInt = int.tryParse(widget.containerId);
    final atIdInt = int.tryParse(widget.assetTypeId);

    final container = containerProvider.containers
        .cast<ContainerNode?>()
        .firstWhere((c) => c?.id == cIdInt, orElse: () => null);
    // Obtener las definiciones de campos personalizados del assetType
    final assetType = container?.assetTypes.cast<AssetType?>().firstWhere(
      (at) => at?.id == atIdInt,
      orElse: () => null,
    );
    if (assetType == null || assetType.fieldDefinitions.isEmpty) {
      return const SizedBox.shrink(); // No hay campos personalizados que mostrar
    }

    final List<CustomFieldDefinition> customFields = assetType.fieldDefinitions;

    // Filtramos los campos personalizados que tienen un valor o no son nulos
    final displayedCustomFields = customFields.where((fieldDef) {
      final fieldValue =
          item.customFieldValues?[fieldDef.id.toString()] ??
          item.customFieldValues?[fieldDef.id] ??
          item.customFieldValues?[fieldDef.name];
      return fieldValue != null && fieldValue.toString().isNotEmpty;
    }).toList();

    if (displayedCustomFields.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.customFields,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(), // Desactiva el scroll propio
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, // 2 columnas por fila
            crossAxisSpacing: 24,
            mainAxisSpacing: 16,
            childAspectRatio:
                3, // Ajusta esto según el espacio que necesites para cada campo
          ),
          itemCount: displayedCustomFields.length,
          itemBuilder: (context, index) {
            final fieldDef = displayedCustomFields[index];
            final fieldValue =
                item.customFieldValues?[fieldDef.id.toString()] ??
                item.customFieldValues?[fieldDef.id] ??
                item.customFieldValues?[fieldDef.name];

            return _buildCustomFieldDisplay(context, fieldDef, fieldValue);
          },
        ),
      ],
    );
  }

  Widget _buildCustomFieldDisplay(
    BuildContext context,
    CustomFieldDefinition fieldDef,
    dynamic fieldValue,
  ) {
    final String displayValue = fieldValue?.toString() ?? '—';

    Widget valueWidget;
    if (fieldDef.type == CustomFieldType.boolean) {
      final isChecked = fieldValue == true;
      valueWidget = Tooltip(
        message: isChecked ? 'Verdadero' : 'Falso',
        child: Icon(
          isChecked ? Icons.check_circle : Icons.cancel,
          color: isChecked ? Colors.green.shade600 : Colors.red.shade600,
          size: 20,
        ),
      );
    } else if (fieldDef.type == CustomFieldType.url &&
        displayValue != '—' &&
        displayValue.isNotEmpty) {
      valueWidget = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => _launchUrl(displayValue),
          child: Tooltip(
            message: 'Abrir enlace: $displayValue',
            child: Text(
              displayValue,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );
    } else if (fieldDef.type == CustomFieldType.price && fieldValue != null) {
      valueWidget = PriceDisplayWidget(value: fieldValue);
    } else {
      valueWidget = Tooltip(
        message: displayValue,
        child: Text(
          displayValue,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            fieldDef.name,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          valueWidget,
        ],
      ),
    );
  }

  Widget _buildMetadataSection(
    BuildContext context,
    InventoryItem item,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            l10n.additionalInformation, // Asegúrate de tener esta clave en l10n
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetadataItem(
                l10n.createdAt,
                item.createdAt != null
                    ? "${item.createdAt!.day}/${item.createdAt!.month}/${item.createdAt!.year}"
                    : "—",
              ),
              _buildMetadataItem(
                l10n.updatedAt,
                item.updatedAt != null
                    ? "${item.updatedAt!.day}/${item.updatedAt!.month}/${item.updatedAt!.year}"
                    : "—",
              ),
              _buildMetadataItem("ID", "#${item.id}"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // --- Lógica para Abrir URL ---
  Future<void> _launchUrl(String url) async {
    String fullUrl = url.startsWith('http') ? url : 'https://$url';
    final Uri uri = Uri.parse(fullUrl);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch $uri');
      }
    } catch (e) {
      debugPrint('Error launching URL $uri: $e');
    }
  }
}
