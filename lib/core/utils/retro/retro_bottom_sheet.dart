// lib/widgets/ui/app_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:invenicum/core/utils/retro/retro_theme_extension.dart';

Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required Widget child,
}) {
  final retro = Theme.of(context).extension<RetroThemeExtension>()?.retro;

  if (retro != null) {
    // Retro: simula una ventana DOS flotante desde abajo
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: retro.messageBox,
          border: Border(
            top:   BorderSide(color: retro.border, width: 2),
            left:  BorderSide(color: retro.border, width: 2),
            right: BorderSide(color: retro.border, width: 2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Barra de título estilo DOS
            Container(
              width: double.infinity,
              color: retro.titleBar,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                '[ MENU ]',
                style: TextStyle(
                  color: retro.titleText,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 2,
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }

  // Material normal
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    builder: (_) => child,
  );
}