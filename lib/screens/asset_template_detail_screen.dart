import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/models/custom_field_definition.dart';
import 'package:invenicum/models/custom_field_definition_model.dart';
import 'package:invenicum/models/list_data.dart';
import 'package:provider/provider.dart';

import 'package:invenicum/models/asset_template_model.dart';
import 'package:invenicum/models/container_node.dart';
import 'package:invenicum/providers/container_provider.dart';
import 'package:invenicum/providers/template_provider.dart';
import 'package:invenicum/services/toast_service.dart';

class AssetTemplateDetailScreen extends StatefulWidget {
  final String templateId;
  final AssetTemplate? initialTemplate;

  const AssetTemplateDetailScreen({
    super.key,
    required this.templateId,
    this.initialTemplate,
  });

  @override
  State<AssetTemplateDetailScreen> createState() =>
      _AssetTemplateDetailScreenState();
}

class _AssetTemplateDetailScreenState extends State<AssetTemplateDetailScreen> {
  AssetTemplate? _template;
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    if (widget.initialTemplate != null) {
      _template = widget.initialTemplate;

      // 🚩 LA CORRECCIÓN CLAVE:
      // Si el objeto existe pero los campos están vacíos,
      // significa que viene del resumen del Market y hay que pedir el detalle.
      if (_template!.fields.isEmpty) {
        print("Estructura incompleta, hidratando desde el servidor...");
        await _fetchTemplateData();
      }
    } else {
      await _fetchTemplateData();
    }
  }

  Future<void> _fetchTemplateData() async {
    if (!mounted) return;
    setState(() => _isFetching = true);

    try {
      final provider = context.read<TemplateProvider>();
      // IMPORTANTE: Asegúrate de que el provider devuelva el objeto hidratado
      final result = await provider.getTemplateById(widget.templateId);

      if (mounted) {
        setState(() {
          _template = result;
          _isFetching = false; // Bajamos el flag aquí
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isFetching = false);
      ToastService.error("No se pudo obtener el detalle de la plantilla");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isFetching) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_template == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text("La plantilla no existe o no está disponible"),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text("Volver"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Plantilla'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_add_outlined),
            tooltip: 'Guardar en biblioteca',
            onPressed: () => _handleSaveOnly(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomAction(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            Text(
              _template!.description,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 16),
            _buildTags(),
            const Divider(height: 40),
            _buildFieldsSection(),
            const SizedBox(height: 100), // Espacio para el botón inferior
          ],
        ),
      ),
    );
  }

  // --- COMPONENTES DE UI ---

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.indigo.shade100,
          // 🚩 backgroundImage maneja la imagen si existe
          backgroundImage:
              _template!.authorAvatarUrl != null &&
                  _template!.authorAvatarUrl!.isNotEmpty
              ? NetworkImage(_template!.authorAvatarUrl!)
              : null,
          // 🚩 child solo se muestra si la imagen falla o no existe
          child:
              (_template!.authorAvatarUrl == null ||
                  _template!.authorAvatarUrl!.isEmpty)
              ? Text(
                  _template!.author[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _template!.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'por @${_template!.author}',
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (_template!.isOfficial)
          const Tooltip(
            message: 'Plantilla Oficial Verificada',
            child: Icon(Icons.verified, color: Colors.blue, size: 28),
          ),
      ],
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 8,
      children: _template!.tags
          .map(
            (tag) => Chip(
              label: Text('#$tag', style: const TextStyle(fontSize: 12)),
              backgroundColor: Colors.grey.shade100,
              side: BorderSide.none,
            ),
          )
          .toList(),
    );
  }

  Widget _buildFieldsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.account_tree_outlined, color: Colors.blueGrey),
            const SizedBox(width: 8),
            Text(
              'ESTRUCTURA DE DATOS (${_template!.fields.length} CAMPOS)',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
                color: Colors.blueGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _template!.fields.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final field = _template!.fields[index];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.drag_indicator,
                    color: Colors.grey,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          field.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          field.type.name.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (field.isRequired)
                    const Text(
                      "*",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomAction() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: () => _showInstallDialog(),
          icon: const Icon(Icons.download_for_offline_rounded),
          label: const Text(
            "INSTALAR EN MI INVENTARIO",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  // --- LÓGICA ---

  Future<void> _handleSaveOnly() async {
    final success = await context
        .read<TemplateProvider>()
        .saveTemplateToLibrary(_template!);
    if (success) ToastService.success("Añadida a tu biblioteca personal");
  }

  void _showInstallDialog() {
    final containers = context.read<ContainerProvider>().containers;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "¿Dónde quieres instalarlo?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (containers.isEmpty)
              const Text("No tienes contenedores. Crea uno primero.")
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: containers.length,
                  itemBuilder: (c, i) => ListTile(
                    leading: const Icon(
                      Icons.inventory_2,
                      color: Colors.indigo,
                    ),
                    title: Text(containers[i].name),
                    onTap: () {
                      Navigator.pop(ctx);
                      _executeInstallation(containers[i]);
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _executeInstallation(ContainerNode container) async {
    final router = GoRouter.of(context);
    final navigator = Navigator.of(context);
    final tProvider = context.read<TemplateProvider>();
    final cProvider = context.read<ContainerProvider>();

    try {
      // 1. Opcional: Guardar en biblioteca personal
      await tProvider.saveTemplateToLibrary(_template!);

      // 2. Obtener el contenedor actualizado para verificar listas existentes
      final currentContainer = cProvider.containers.firstWhere(
        (c) => c.id == container.id,
        orElse: () => container,
      );

      List<CustomFieldDefinition> finalFields = [];

      // 3. Procesar cada campo de la plantilla
      for (var field in _template!.fields) {
        // Si el campo es dropdown y tiene opciones definidas
        if (field.type == CustomFieldType.dropdown &&
            field.options != null &&
            field.options!.isNotEmpty) {
          final String listName = '${field.name} (${_template!.name})';

          // --- Lógica de No Duplicar ---
          final existingList = currentContainer.dataLists.firstWhere(
            (l) => l.name == listName,
            orElse: () => ListData(id: -1, name: '', items: []),
          );

          int targetListId;

          if (existingList.id != -1) {
            // Si la lista ya existe (por una instalación previa), usamos su ID
            targetListId = existingList.id;
          } else {
            // Si no existe, la creamos en el servidor
            final newList = await cProvider.createDataList(
              containerId: container.id,
              name: listName,
              description: 'Lista generada automáticamente desde plantilla',
              items: field.options!,
            );
            targetListId = newList.id;
          }

          // 🚩 ASIGNACIÓN AUTOMÁTICA:
          // Inyectamos el dataListId en el campo como si el usuario lo hubiera seleccionado
          finalFields.add(field.copyWith(dataListId: targetListId));
        } else {
          // Campos normales (text, number, etc.) se añaden sin cambios
          finalFields.add(field);
        }
      }

      // 4. Crear el AssetType real con los campos ya vinculados a las listas
      await cProvider.addNewAssetTypeToContainer(
        containerId: container.id,
        name: _template!.name,
        fieldDefinitions: finalFields, // <-- Aquí ya van los IDs
        isSerialized: true,
      );

      if (navigator.canPop()) navigator.pop();
      ToastService.success(
        "¡Instalación exitosa! Listas configuradas automáticamente.",
      );
      router.go('/container/${container.id}/asset-types');
    } catch (e) {
      if (navigator.canPop()) navigator.pop();
      ToastService.error("Error al instalar: $e");
    }
  }
}
