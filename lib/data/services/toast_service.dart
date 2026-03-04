import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:invenicum/core/routing/app_router.dart';

enum ToastType { success, info, error }

class ToastService {
  static void show(String message, ToastType type, [int durationSeconds = 3]) {
    // 🚩 IMPORTANTE: El delay de 300ms para que el ListView/Switch se estabilice
    Future.delayed(const Duration(milliseconds: 300), () {
      final context = rootNavigatorKey.currentContext;
      if (context == null) return;

      FToast fToast = FToast();
      fToast.init(context);

      fToast.showToast(
        child: _buildCustomToast(message, type),
        gravity: ToastGravity.BOTTOM,
        toastDuration: Duration(seconds: durationSeconds),
      );
    });
  }

  static Widget _buildCustomToast(String message, ToastType type) {
    // Configuración según el tipo (Estilo Toastification)
    final Color color = _getColor(type);
    final IconData icon = _getIcon(type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(right: 20, bottom: 20),
      decoration: BoxDecoration(
        color: color.withAlpha(100), // Fondo suave del color
        borderRadius: BorderRadius.circular(12),
        // Sombra suave estilo moderno
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        // Pequeño borde lateral para indicar el tipo
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
    }
  }

  // Métodos de acceso
  static void success(String message) => show(message, ToastType.success);
  static void error(String message) => show(message, ToastType.error);
  static void info(String message) => show(message, ToastType.info);
}
