// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:invenicum/core/utils/retro/cga_palette.dart';

// ─── Text box ────────────────────────────────────────────────────────────────

/// A framed text area with a blue background, like SCUMM dialog message boxes.
class CGATextBox extends StatelessWidget {
  final String text;
  final int maxLines;
  final Color bgColor;
  final Color borderColor;
  final Color textColor;
  final TextAlign textAlign;

  const CGATextBox({
    super.key,
    required this.text,
    this.maxLines = 2,
    this.bgColor = CGA.blue,
    this.borderColor = CGA.brightCyan,
    this.textColor = CGA.white,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontFamily: 'monospace',
          fontSize: 13,
          height: 1.45,
          letterSpacing: 0.2,
        ),
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        softWrap: true,
      ),
    );
  }
}

// ─── Button ──────────────────────────────────────────────────────────────────

/// A CGA-style button that inverts colors on press.
class CGAButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final Color fgColor;
  final Color bgColor;

  const CGAButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.fgColor = CGA.brightCyan,
    this.bgColor = CGA.black,
  });

  @override
  State<CGAButton> createState() => _CGAButtonState();
}

class _CGAButtonState extends State<CGAButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: _pressed ? widget.fgColor : widget.bgColor,
          border: Border.all(color: widget.fgColor, width: 2),
        ),
        child: Text(
          '[ ${widget.label} ]',
          style: TextStyle(
            color: _pressed ? widget.bgColor : widget.fgColor,
            fontFamily: 'monospace',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}

// ─── Radio ───────────────────────────────────────────────────────────────────

/// A CGA-style radio option rendered as `(•) Label` in monospace.
class CGARadio<T> extends StatelessWidget {
  final String label;
  final T value;
  final T groupValue;
  final ValueChanged<T> onChanged;
  final Color selectedColor;
  final Color unselectedColor;

  const CGARadio({
    super.key,
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.selectedColor = CGA.brightGreen,
    this.unselectedColor = CGA.lightGray,
  });

  @override
  Widget build(BuildContext context) {
    final bool sel = value == groupValue;
    final Color col = sel ? selectedColor : unselectedColor;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            sel ? '(•)' : '( )',
            style: TextStyle(
              color: col,
              fontFamily: 'monospace',
              fontSize: 13,
              fontWeight: sel ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: col,
              fontFamily: 'monospace',
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Dividers ────────────────────────────────────────────────────────────────

/// A solid 1px horizontal rule in CGA style.
class CGADivider extends StatelessWidget {
  final Color color;
  final EdgeInsetsGeometry padding;

  const CGADivider({
    super.key,
    this.color = CGA.brightCyan,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Container(height: 1, color: color),
    );
  }
}

/// A labeled section separator: `── LABEL ──`
class CGASectionLabel extends StatelessWidget {
  final String label;
  final Color color;

  const CGASectionLabel({
    super.key,
    required this.label,
    this.color = CGA.yellow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '── $label ──',
      style: TextStyle(
        color: color,
        fontFamily: 'monospace',
        fontSize: 11,
        letterSpacing: 1,
      ),
    );
  }
}