import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

enum ToastType { success, info, error }

class ToastService {
  // Función principal adaptada a Toastification
  static void show(
    String message,
    ToastType type, [
    int durationSeconds = 4, // Toastification luce mejor con un poco más de tiempo
    Alignment alignment = Alignment.bottomCenter,
  ]) {
    
    // 1. Mapeamos tus tipos a los estilos de Toastification
    ToastificationType toastType;
    IconData icon;
    Color primaryColor;

    switch (type) {
      case ToastType.success:
        toastType = ToastificationType.success;
        icon = Icons.check_circle_outline;
        primaryColor = Colors.green.shade800;
        break;
      case ToastType.info:
        toastType = ToastificationType.info;
        icon = Icons.info_outline;
        primaryColor = Colors.blue.shade700;
        break;
      case ToastType.error:
        toastType = ToastificationType.error;
        icon = Icons.error_outline;
        primaryColor = Colors.red.shade800;
        break;
    }

    // 2. Ejecutamos la notificación
    toastification.show(
      type: toastType,
      style: ToastificationStyle.flatColored, // Estilo limpio y moderno
      autoCloseDuration: Duration(seconds: durationSeconds),
      title: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
      alignment: alignment,
      direction: TextDirection.ltr,
      animationDuration: const Duration(milliseconds: 300),
      icon: Icon(icon, color: primaryColor),
      primaryColor: primaryColor,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: BorderRadius.circular(12),
      showProgressBar: true, // Barra de tiempo visual muy útil
      closeButtonShowType: CloseButtonShowType.onHover,
      pauseOnHover: true,
      dragToClose: true,
    );
  }

  // --- Métodos de Acceso Directo (Exactamente iguales a los que tenías) ---
  static void success(String message, [int durationSeconds = 4]) {
    show(message, ToastType.success, durationSeconds);
  }

  static void info(String message, [int durationSeconds = 4]) {
    show(message, ToastType.info, durationSeconds);
  }

  static void error(String message, [int durationSeconds = 4]) {
    show(message, ToastType.error, durationSeconds);
  }
}