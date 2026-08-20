import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class Model3DInputSection extends StatelessWidget {
  const Model3DInputSection({
    super.key,
    required this.files,
    required this.pathController,
    required this.onFilesChanged,
  });

  final List<PlatformFile> files;
  final TextEditingController pathController;
  final ValueChanged<List<PlatformFile>> onFilesChanged;

  Future<void> _pickFiles() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['glb'],
      allowMultiple: true,
      withData: true,
    );
    if (result != null) onFilesChanged([...files, ...result.files]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilledButton.icon(
          onPressed: _pickFiles,
          icon: const Icon(Icons.view_in_ar),
          label: const Text('Añadir modelos GLB'),
        ),
        if (files.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...files.asMap().entries.map(
            (entry) => ListTile(
              dense: true,
              leading: const Icon(Icons.threed_rotation),
              title: Text(entry.value.name),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  final updated = [...files]..removeAt(entry.key);
                  onFilesChanged(updated);
                },
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        TextField(
          controller: pathController,
          decoration: const InputDecoration(
            labelText: 'Ruta controlada del servidor',
            hintText: 'models3d/catalogo/modelo.glb',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Usa una ruta relativa dentro del directorio de modelos 3D.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
