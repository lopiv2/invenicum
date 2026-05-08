import 'package:flutter/material.dart';
import 'package:invenicum/core/utils/retro/retro_theme.dart';
import 'package:invenicum/core/utils/retro/retro_theme_extension.dart';
import 'package:invenicum/widgets/ui/CGA_dialog.dart';

/// ============================================================================
/// APP DIALOG
/// ============================================================================
///
/// Centralized dialog entry point.
///
/// - When the active theme is retro → always shows a CGADialog wrapper,
///   regardless of whether [builder], [title]+[body] or both are used.
/// - When the active theme is normal → behaves exactly like [showDialog].
///
/// The retro check reads [RetroThemeExtension] from the CALLING context
/// before opening the dialog, avoiding the white-flicker caused by reading
/// the theme inside the dialog's own context (which lives under the root
/// Navigator and may not inherit the extension).
///
/// Usage:
///
///   // Simple mode — retro-compatible
///   showAppDialog(
///     context: context,
///     title: 'Confirm',
///     body: Text('Are you sure?'),
///     actions: [...],
///   );
///
///   // Builder mode — full layout control, retro still applied automatically
///   showAppDialog(
///     context: context,
///     title: 'My Dialog',
///     builder: (context) => MyComplexWidget(),
///   );
///
/// ============================================================================

Future<T?> showAppDialog<T>({
  required BuildContext context,

  // ── Simple mode ────────────────────────────────────────────────────────────
  String? title,
  Widget? body,
  List<Widget>? actions,

  // ── Builder mode ───────────────────────────────────────────────────────────
  // When provided, the builder output is used as [body] inside CGADialog
  // (retro) or as the dialog itself (Material).
  WidgetBuilder? builder,

  // ── Shared options ─────────────────────────────────────────────────────────
  bool barrierDismissible = false,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
}) {
  // Read the retro extension from the CALLING context — before the dialog
  // opens — so we never lose the theme reference inside the route context.
  final RetroTheme? retro =
      Theme.of(context).extension<RetroThemeExtension>()?.retro;

  // ── RETRO MODE — always wraps in CGADialog ─────────────────────────────────
  if (retro != null) {
    assert(
      title != null,
      'showAppDialog: [title] is required in retro mode.',
    );

    return showCGADialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (innerContext) => CGADialog(
        title: title!,
        theme: retro,
        actions: actions,
        // Builder takes priority over body; falls back to body.
        body: builder != null ? builder(innerContext) : body!,
      ),
    );
  }

  // ── MATERIAL MODE ──────────────────────────────────────────────────────────

  // Builder mode: caller controls the full dialog widget.
  if (builder != null) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      useRootNavigator: true,
      routeSettings: routeSettings,
      builder: builder,
    );
  }

  // Simple mode: wrap in AlertDialog.
  assert(
    title != null && body != null,
    'showAppDialog: [title] and [body] are required when [builder] is not provided.',
  );

  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    useRootNavigator: false,
    routeSettings: routeSettings,
    builder: (_) => AlertDialog(
      title: Text(title!),
      content: body,
      actions: actions,
    ),
  );
}