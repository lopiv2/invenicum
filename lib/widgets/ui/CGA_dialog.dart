import 'package:flutter/material.dart';
import 'package:invenicum/core/utils/cga_constants.dart';
import 'package:invenicum/widgets/ui/CGA_double_border_painter.dart';

/// A reusable CGA/EGA-style dialog shell inspired by LucasArts SCUMM engine.
///
/// Provides the double-line border, blue title bar, and consistent layout.
/// Compose the [body] with CGA primitive widgets from `cga_widgets.dart`.
///
/// Example:
/// ```dart
/// CGADialog(
///   title: 'WARNING',
///   maxWidth: 340,
///   body: Column(
///     children: [
///       CGATextBox(text: 'Are you sure?'),
///       CGADivider(),
///       Row(
///         children: [
///           CGAButton(label: 'YES', onPressed: () => Navigator.pop(context, true), fgColor: CGA.brightGreen),
///           CGAButton(label: 'NO',  onPressed: () => Navigator.pop(context, false), fgColor: CGA.brightRed),
///         ],
///       ),
///     ],
///   ),
/// )
/// ```
class CGADialog extends StatelessWidget {
  /// Text shown in the blue title bar, auto-uppercased.
  final String title;

  /// Content placed below the title bar. Use CGA* widgets for consistency.
  final Widget body;

  /// Maximum dialog width. Defaults to 340. Use a larger value for wider content.
  final double maxWidth;

  /// Color of the double-line border and title bar divider.
  final Color borderColor;

  /// Background color of the title bar.
  final Color titleBarColor;

  /// Text color of the title.
  final Color titleColor;

  const CGADialog({
    super.key,
    required this.title,
    required this.body,
    this.maxWidth = 540,
    this.borderColor = CGA.brightCyan,
    this.titleBarColor = CGA.blue,
    this.titleColor = CGA.yellow,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: CustomPaint(
        painter: CGADoubleBorderPainter(color: borderColor),
        child: Container(
          color: CGA.black,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Title bar ──────────────────────────────────────────────
              Container(
                color: titleBarColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    const Text(
                      '▓▒░ ',
                      style: TextStyle(
                        color: CGA.brightCyan,
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        title.toUpperCase(),
                        style: TextStyle(
                          color: titleColor,
                          fontFamily: 'monospace',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Text(
                      ' ░▒▓',
                      style: TextStyle(
                        color: CGA.brightCyan,
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Title divider ──────────────────────────────────────────
              Container(height: 1, color: borderColor),

              // ── Body ──────────────────────────────────────────────────
              body,
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows a [CGADialog] as a modal dialog.
///
/// Use [builder] to return the [CGADialog] widget.
/// Returns whatever [Navigator.pop] is called with.
Future<T?> showCGADialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = false,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: Colors.black87,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
      child: builder(ctx),
    ),
  );
}