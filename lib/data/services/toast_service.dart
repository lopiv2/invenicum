// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:invenicum/core/routing/app_router.dart';

enum ToastType { success, info, error, achievement }

class ToastService {
  static final List<String> _achievementQueue = [];
  static final List<({OverlayEntry entry, ValueNotifier<double> topNotifier})>
  _activeEntries = [];
  static const double _toastHeight = 80.0;
  static const double _topBase = 60.0;
  static const double _gap = 8.0;

  static void show(String message, ToastType type, [int durationSeconds = 3]) {
    if (type == ToastType.achievement) {
      achievement(message);
    } else {
      _showFToast(message, type, durationSeconds);
    }
  }

  static void _showFToast(String message, ToastType type, int durationSeconds) {
    Future.delayed(const Duration(milliseconds: 300), () {
      final context = rootNavigatorKey.currentContext;
      if (context == null) return;
      FToast()
          .init(context)
          .showToast(
            child: _buildCustomToast(message, type),
            gravity: ToastGravity.BOTTOM,
            toastDuration: Duration(seconds: durationSeconds),
          );
    });
  }

  static Widget _buildCustomToast(String message, ToastType type) {
    final Color color = _getColor(type);
    final IconData icon = _getIcon(type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(right: 20, bottom: 20),
      decoration: BoxDecoration(
        color: color.withAlpha(100),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(left: BorderSide(color: color, width: 6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Color _getColor(ToastType type) {
    switch (type) {
      case ToastType.success:
        return Colors.green;
      case ToastType.error:
        return Colors.red;
      case ToastType.info:
        return Colors.blue;
      case ToastType.achievement:
        return const Color(0xFF66C0F4);
    }
  }

  static IconData _getIcon(ToastType type) {
    switch (type) {
      case ToastType.success:
        return Icons.check_circle_outlined;
      case ToastType.error:
        return Icons.error_rounded;
      case ToastType.info:
        return Icons.info_rounded;
      case ToastType.achievement:
        return Icons.emoji_events;
    }
  }

  static void _showNextInQueue() {
    if (_achievementQueue.isEmpty) return;

    final overlay = rootNavigatorKey.currentState?.overlay;
    if (overlay == null) return;

    final message = _achievementQueue.removeAt(0);
    final index = _activeEntries.length;
    final topNotifier = ValueNotifier<double>(
      _topBase + index * (_toastHeight + _gap),
    );

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => ValueListenableBuilder<double>(
        valueListenable: topNotifier,
        builder: (_, top, _) => _AchievementToastOverlay(
          message: message,
          duration: const Duration(seconds: 8),
          topOffset: top,
          onDone: () {
            entry.remove();
            _activeEntries.removeWhere((e) => e.entry == entry);
            topNotifier.dispose();
            _rebuildAll();
          },
        ),
      ),
    );

    _activeEntries.add((entry: entry, topNotifier: topNotifier));
    overlay.insert(entry);

    if (_achievementQueue.isNotEmpty) {
      Future.microtask(_showNextInQueue);
    }
  }

  static void _rebuildAll() {
    for (int i = 0; i < _activeEntries.length; i++) {
      _activeEntries[i].topNotifier.value =
          _topBase + i * (_toastHeight + _gap);
    }
  }

  static void achievement(String message) {
    _achievementQueue.add(message);
    _showNextInQueue();
  }

  static void success(String message) => show(message, ToastType.success);
  static void error(String message) => show(message, ToastType.error);
  static void info(String message) => show(message, ToastType.info);
}

class _AchievementToastOverlay extends StatefulWidget {
  final String message;
  final Duration duration;
  final VoidCallback onDone;
  final double topOffset;

  const _AchievementToastOverlay({
    required this.message,
    required this.duration,
    required this.onDone,
    required this.topOffset,
  });

  @override
  State<_AchievementToastOverlay> createState() =>
      _AchievementToastOverlayState();
}

class _AchievementToastOverlayState extends State<_AchievementToastOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(1.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    _ctrl.forward();

    Future.delayed(widget.duration - const Duration(milliseconds: 400), () {
      if (mounted) _ctrl.reverse().then((_) => widget.onDone());
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.topOffset,
      right: 20,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2838),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF66C0F4), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF66C0F4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.emoji_events, color: Colors.black),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Achievement Unlocked',
                          style: TextStyle(
                            color: Color(0xFF66C0F4),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
