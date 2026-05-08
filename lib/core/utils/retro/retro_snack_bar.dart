// lib/widgets/ui/app_snack_bar.dart

import 'package:flutter/material.dart';
import 'package:invenicum/core/utils/retro/retro_theme_extension.dart';

void showAppSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  final retro = Theme.of(context).extension<RetroThemeExtension>()?.retro;

  if (retro != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(
              isError ? '[ERR] ' : '[OK]  ',
              style: TextStyle(
                color: isError ? retro.buttonCancel : retro.buttonOk,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: retro.messageText,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: retro.messageBox,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: retro.border),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  // Material normal
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : null,
    ),
  );
}