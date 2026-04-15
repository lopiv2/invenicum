import 'package:flutter/material.dart';

class DraggableDragIcon extends StatefulWidget {
  final int index;

  const DraggableDragIcon({required this.index, super.key});

  @override
  State<DraggableDragIcon> createState() => _DraggableDragIconState();
}

class _DraggableDragIconState extends State<DraggableDragIcon> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: _isDragging
          ? SystemMouseCursors.grabbing
          : SystemMouseCursors.grab,
      child: Listener(
        onPointerDown: (_) => setState(() => _isDragging = true),
        onPointerUp: (_) => setState(() => _isDragging = false),
        onPointerCancel: (_) => setState(() => _isDragging = false),
        child: ReorderableDragStartListener(
          index: widget.index,
          child: const Icon(Icons.drag_handle),
        ),
      ),
    );
  }
}
