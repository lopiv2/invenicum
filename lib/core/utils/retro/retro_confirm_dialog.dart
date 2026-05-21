// lib/widgets/ui/app_confirm_dialog.dart

import 'package:flutter/material.dart';
import 'package:invenicum/core/utils/retro/retro_dialog_helper.dart';
import 'package:invenicum/core/utils/retro/retro_theme_extension.dart';
import 'package:invenicum/l10n/app_localizations.dart';

Future<bool> showAppConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String? confirmLabel,
  String? cancelLabel,
  bool destructive = false,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final retro = Theme.of(context).extension<RetroThemeExtension>()?.retro;

  final result = await showAppDialog<bool>(
    context: context,
    title: title,
    body: Text(message),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: Text(cancelLabel ?? l10n.cancel),
      ),
      // En retro el botón destructivo usa buttonCancel, el normal buttonOk
      ElevatedButton(
        style: retro != null && destructive
            ? ElevatedButton.styleFrom(foregroundColor: retro.buttonCancel)
            : null,
        onPressed: () => Navigator.pop(context, true),
        child: Text(confirmLabel ?? l10n.confirm),
      ),
    ],
  );

  return result ?? false;
}