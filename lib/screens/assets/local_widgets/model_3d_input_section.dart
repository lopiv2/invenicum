import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:invenicum/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilledButton.icon(
          onPressed: _pickFiles,
          icon: const Icon(Icons.view_in_ar),
          label: Text(l10n.addGlbModelsButton),
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
          decoration: InputDecoration(
            labelText: l10n.serverControlledPathLabel,
            hintText: l10n.modelPathExampleHint,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.modelRelativePathHelp,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
