import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/l10n/app_localizations.dart';

/// Widget para los botones de acción (Guardar/Cancelar)
class AssetTypeActionButtons extends StatelessWidget {
  final VoidCallback onSave;
  final String? saveLabel;
  final bool isLoading;

  const AssetTypeActionButtons({
    super.key,
    required this.onSave,
    this.saveLabel,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayLabel = saveLabel ?? AppLocalizations.of(context)!.createAssetTypeButtonDefault;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: isLoading ? null : onSave,
          icon: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save),
          label: Text(
            displayLabel,
            style: const TextStyle(fontSize: 16),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 15,
            ),
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: isLoading ? null : () => context.pop(),
          icon: const Icon(Icons.cancel),
          label: Text(AppLocalizations.of(context)!.cancel, style: const TextStyle(fontSize: 16)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 15,
            ),
          ),
        ),
      ],
    );
  }
}
