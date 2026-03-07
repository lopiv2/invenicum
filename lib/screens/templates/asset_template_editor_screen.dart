import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/data/models/asset_template_model.dart'; // Tu modelo
import 'package:invenicum/data/models/custom_field_definition.dart';
import 'package:invenicum/data/models/custom_field_definition_model.dart';
import 'package:invenicum/providers/auth_provider.dart';
import 'package:invenicum/providers/template_provider.dart';
import 'package:invenicum/data/services/toast_service.dart';
import 'package:invenicum/screens/asset_types/local_widgets/custom_field_editor.dart';
import 'package:provider/provider.dart';

class AssetTemplateEditorScreen extends StatefulWidget {
  final AssetTemplate? initialDraft;
  const AssetTemplateEditorScreen({super.key, this.initialDraft});

  @override
  State<AssetTemplateEditorScreen> createState() =>
      _AssetTemplateEditorScreenState();
}

class _AssetTemplateEditorScreenState extends State<AssetTemplateEditorScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _categoryController = TextEditingController();
  final _githubController = TextEditingController();

  List<CustomFieldDefinition> _fieldDefinitions = [];

  @override
  void initState() {
    super.initState();
    // 🚩 RELLENO DINÁMICO DESDE LA IA O VACÍO
    if (widget.initialDraft != null) {
      _nameController.text = widget.initialDraft!.name;
      _descController.text = widget.initialDraft!.description;
      _categoryController.text = widget.initialDraft!.category;
      // Cargamos los campos que generó Veni
      _fieldDefinitions = List.from(widget.initialDraft!.fields);
    }
    // 🚩 AUTO-RELLENO DE GITHUB AL INICIAR
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isGitHubLinked) {
      _githubController.text = authProvider.user?.githubHandle ?? '';
    }
  }

  void _addNewField() {
    setState(() {
      _fieldDefinitions.add(
        CustomFieldDefinition(
          // Generamos un ID temporal para que ValueKey funcione correctamente
          id: DateTime.now().millisecondsSinceEpoch,
          name: '',
          type: CustomFieldType.text,
          options: [], // Inicializamos la lista vacía
        ),
      );
    });
  }

  Future<void> _handlePublish() async {
    final authProvider = context.read<AuthProvider>();
    final templateProvider = context.read<TemplateProvider>();

    if (!authProvider.isGitHubLinked) {
      ToastService.error("Debes vincular GitHub en tu perfil para publicar.");
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    if (_fieldDefinitions.isEmpty) {
      ToastService.error("La plantilla debe tener al menos un campo definido.");
      return;
    }

    // 🚩 CAMBIO AQUÍ: Crear el objeto respetando el nuevo contrato
    final template = AssetTemplate(
      id: '', // El backend generará el tpl_uuid
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      category: _categoryController.text.trim(),
      author: authProvider.user!.githubHandle!,
      authorAvatarUrl: authProvider.user!.avatarUrl,
      fields: _fieldDefinitions,
      tags: [], // 👈 Añadimos lista vacía para el DTO
      isPublic: true,
      isOfficial:
          false, // Siempre false al publicar; el admin de GitHub lo cambiará
      createdAt: DateTime.now(), // 👈 Opcional, el backend lo sobreescribirá
      updatedAt: DateTime.now(),
    );

    try {
      // Mostrar un diálogo de carga (opcional pero recomendado)
      final success = await templateProvider.publishTemplateToMarket(template);

      if (success && mounted) {
        ToastService.success(
          "¡Propuesta enviada! Se ha creado un Pull Request en GitHub.",
        );
        context.pop();
      }
    } catch (e) {
      ToastService.error("Error al publicar: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final bool isLinked = authProvider.isGitHubLinked;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Plantilla Global'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: ActionChip(
                avatar: Icon(
                  isLinked ? Icons.check_circle : Icons.warning,
                  color: isLinked ? Colors.green : Colors.orange,
                  size: 16,
                ),
                label: Text(
                  isLinked ? "GitHub Verificado" : "GitHub No Vinculado",
                ),
                onPressed: () => context.push('/myprofile'),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // 🚀 BANNER DE IA: Solo aparece si venimos del Chatbot
            if (widget.initialDraft != null)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.blue),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        "Veni ha diseñado esta estructura basándose en tu solicitud. Revísala y ajústala antes de publicar.",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            _buildMainInfoSection(isLinked),
            const Divider(height: 48),
            _buildFieldsSection(),
            const SizedBox(height: 40),
            _buildSaveButtons(isLinked),
          ],
        ),
      ),
    );
  }

  Widget _buildMainInfoSection(bool isLinked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nombre de la Plantilla',
            hintText: 'Ej: Mi Colección de Cómics',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.title),
          ),
          validator: (v) => v!.isEmpty ? "Campo obligatorio" : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _githubController,
          readOnly: true, // 🚩 NO EDITABLE SIEMPRE (Se rellena por Auth)
          decoration: InputDecoration(
            labelText: 'Usuario de GitHub',
            prefixText: '@ ',
            filled: true,
            fillColor: Colors.grey[100],
            border: const OutlineInputBorder(),
            prefixIcon: const FaIcon(FontAwesomeIcons.github, size: 20),
            suffixIcon: isLinked ? const Icon(Icons.lock, size: 16) : null,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _categoryController,
          decoration: const InputDecoration(
            labelText: 'Categoría',
            hintText: 'Ej: Libros, Electrónica...',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Descripción del propósito',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldsSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Campos Definidos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            FilledButton.icon(
              onPressed: _addNewField,
              icon: const Icon(Icons.add),
              label: const Text('Añadir Campo'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_fieldDefinitions.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Text("Haz clic en 'Añadir Campo' para empezar a diseñar."),
          ),
        ..._fieldDefinitions.asMap().entries.map((entry) {
          final index = entry.key;
          final field = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Column(
              children: [
                CustomFieldEditor(
                  key: ValueKey(field.id ?? index),
                  field: field,
                  availableDataLists: const [],
                  onDelete: () =>
                      setState(() => _fieldDefinitions.removeAt(entry.key)),
                  onUpdate: (updated) {
                    // 1. Actualizamos el dato en la lista (esto mantiene la lógica)
                    _fieldDefinitions[index] = updated;

                    if (field.type != updated.type) {
                      setState(() {});
                    }
                  },
                ),
                if (field.type == CustomFieldType.dropdown)
                  _buildOptionsEditor(index, field),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildOptionsEditor(int fieldIndex, CustomFieldDefinition field) {
    final TextEditingController _optionController = TextEditingController();

    return Container(
      margin: const EdgeInsets.only(top: 4, left: 8, right: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withOpacity(0.05),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
        border: Border.all(color: Colors.blueGrey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.list, size: 16, color: Colors.blueGrey),
              SizedBox(width: 8),
              Text(
                "CONFIGURAR OPCIONES",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: Colors.blueGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (field.options != null && field.options!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: field.options!.asMap().entries.map((optEntry) {
                  return InputChip(
                    label: Text(
                      optEntry.value,
                      style: const TextStyle(fontSize: 12),
                    ),
                    onDeleted: () {
                      final newOptions = List<String>.from(field.options!);
                      newOptions.removeAt(optEntry.key);
                      setState(() {
                        _fieldDefinitions[fieldIndex] = field.copyWith(
                          options: newOptions,
                        );
                      });
                    },
                    backgroundColor: Colors.white,
                    deleteIconColor: Colors.redAccent,
                  );
                }).toList(),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    controller: _optionController,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: "Escribe una opción y pulsa Intro",
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onSubmitted: (val) =>
                        _addOption(fieldIndex, field, val, _optionController),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: () => _addOption(
                  fieldIndex,
                  field,
                  _optionController.text,
                  _optionController,
                ),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addOption(
    int index,
    CustomFieldDefinition field,
    String value,
    TextEditingController controller,
  ) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;

    final newOptions = List<String>.from(field.options ?? []);
    if (!newOptions.contains(trimmed)) {
      newOptions.add(trimmed);
      setState(() {
        _fieldDefinitions[index] = field.copyWith(options: newOptions);
      });
    }
    controller.clear();
  }

  Widget _buildSaveButtons(bool isLinked) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => context.pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text("CANCELAR"),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FilledButton.icon(
            onPressed: _handlePublish,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: isLinked ? Colors.black : Colors.grey,
            ),
            icon: const FaIcon(FontAwesomeIcons.github, size: 18),
            label: const Text("PUBLICAR EN GITHUB"),
          ),
        ),
      ],
    );
  }
}
