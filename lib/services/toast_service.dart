// lib/utils/toast_service.dart
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Definimos los tipos de Toast disponibles
enum ToastType { success, info, error }

class ToastService {
  // Función principal para mostrar el toast
  static void show(
    String message,
    ToastType type, [
    int durationSeconds = 3, // Opcional
    ToastGravity gravity = ToastGravity.BOTTOM, // Opcional
  ]) {
    String webColor;
    Color bgColor;
    final textColor = Colors.white;

    // 1. Asignar colores e iconos según el tipo de Toast
    switch (type) {
      case ToastType.success:
        webColor = "#2e7d32"; // Green shade 800
        bgColor = Colors.green;
        break;
      case ToastType.info:
        webColor = "#1976d2"; // Blue shade 700
        bgColor = Colors.blue;
        break;
      case ToastType.error:
        webColor = "#d32f2f"; // Red shade 700 (¡Este es el que quieres!)
        bgColor = Colors.red;
        break;
    }

    // 2. Mostrar el Toast usando la función nativa de fluttertoast
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG, // Usamos LONG para que se vea más tiempo
      gravity: gravity,
      timeInSecForIosWeb: durationSeconds,
      backgroundColor: bgColor,
      textColor: textColor,
      fontSize: 16.0,

      // 💡 Opcional: Construir un Widget personalizado
      webShowClose: true, // Útil para web
      webBgColor: webColor, // Configuración opcional para web
      // Para un estilo más avanzado (como añadir el icono),
      // tendrías que usar el enfoque de FToast.showToast() y crear un Widget.
      // Sin embargo, la implementación básica de Fluttertoast (mostrada arriba)
      // es la más simple y portable.
    );
  }

  // --- Opcional: Métodos de Acceso Directo ---
  static void success(String message, [int durationSeconds = 3]) {
    show(message, ToastType.success, durationSeconds);
  }

  static void info(String message, [int durationSeconds = 3]) {
    show(message, ToastType.info, durationSeconds);
  }

  static void error(String message, [int durationSeconds = 3]) {
    show(message, ToastType.error, durationSeconds);
  }
}
