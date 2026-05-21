import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invenicum/core/utils/retro/retro_theme.dart';
import 'package:invenicum/widgets/ui/CGA_double_border_painter.dart';

class CGADialog extends StatelessWidget {
  final String title;
  final Widget body;
  final RetroTheme theme;
  final double maxWidth;
  final List<Widget>? actions;
  final bool glow;
  final EdgeInsetsGeometry padding;

  const CGADialog({
    super.key,
    required this.title,
    required this.body,
    required this.theme,
    this.maxWidth = 540,
    this.actions,
    this.glow = true,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final effectiveWidth = min(screenWidth * 0.92, maxWidth);

    return Shortcuts(
      shortcuts: {LogicalKeySet(LogicalKeyboardKey.escape): DismissIntent()},
      child: Actions(
        actions: {
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (_) {
              Navigator.of(context).maybePop();
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: effectiveWidth,
              maxHeight: MediaQuery.of(context).size.height * 0.88,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                boxShadow: glow
                    ? [
                        BoxShadow(
                          color: theme.border.withValues(alpha:0.25),
                          blurRadius: 14,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: CustomPaint(
                painter: CGADoubleBorderPainter(color: theme.border),
                child: Material(
                  color: theme.messageBox,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ───────────────── TITLE BAR ─────────────────
                      Container(
                        color: theme.titleBar,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Row(
                          children: [
                            Text(
                              '▓▒░ ',
                              style: TextStyle(
                                color: theme.border,
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                title.toUpperCase(),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: theme.titleText,
                                  fontFamily: 'monospace',
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            Text(
                              ' ░▒▓',
                              style: TextStyle(
                                color: theme.border,
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ───────────────── DIVIDER ─────────────────
                      Container(height: 1, color: theme.border),

                      // ───────────────── BODY ─────────────────
                      Flexible(
                        child: SingleChildScrollView(
                          padding: padding,
                          child: DefaultTextStyle(
                            style: TextStyle(
                              color: theme.messageText,
                              fontFamily: 'monospace',
                              fontSize: 12,
                              height: 1.4,
                            ),
                            child: body,
                          ),
                        ),
                      ),

                      // ───────────────── ACTIONS ─────────────────
                      if (actions != null && actions!.isNotEmpty) ...[
                        Container(height: 1, color: theme.divider),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 12,
                            runSpacing: 8,
                            children: actions!,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// SHOW RETRO DIALOG
// =============================================================================

Future<T?> showCGADialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = false,
  Color barrierColor = Colors.black87,
  Duration transitionDuration = const Duration(milliseconds: 120),
}) {
  return showGeneralDialog<T>(
    context: context,
    // ── CRÍTICO: evita subir al Navigator raíz que no hereda el tema ─────────
    // Sin esto, el contexto del diálogo no tiene RetroThemeExtension y
    // aparece un flash blanco antes de que se pinte el fondo retro.
    useRootNavigator: false,
    barrierDismissible: barrierDismissible,
    barrierLabel: '',
    barrierColor: barrierColor,
    transitionDuration: transitionDuration,
    pageBuilder: (ctx, anim1, anim2) {
      return SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: builder(ctx),
          ),
        ),
      );
    },
    transitionBuilder: (ctx, animation, secondary, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}

// =============================================================================
// ESCAPE INTENT
// =============================================================================

class DismissIntent extends Intent {
  const DismissIntent();
}