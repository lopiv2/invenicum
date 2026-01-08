// lib/utils/toast_service.dart
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Definimos los tipos de Toast disponibles
enum ToastType {
  success,
  info,
  error,
}

class ToastService {
  // Función principal para mostrar el toast
  static void show(
    String message,
    ToastType type,
    [int durationSeconds = 3, // Opcional
    ToastGravity gravity = ToastGravity.BOTTOM] // Opcional
  ) {
    Color backgroundColor;
    final textColor = Colors.white;

    // 1. Asignar colores e iconos según el tipo de Toast
    switch (type) {
      case ToastType.success:
        backgroundColor = Colors.green.shade600;
        break;
      case ToastType.info:
        backgroundColor = Colors.blue.shade600;
        break;
      case ToastType.error:
        backgroundColor = Colors.red.shade600;
        break;
    }

    // 2. Mostrar el Toast usando la función nativa de fluttertoast
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG, // Usamos LONG para que se vea más tiempo
      gravity: gravity,
      timeInSecForIosWeb: durationSeconds,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: 16.0,
      
      // 💡 Opcional: Construir un Widget personalizado
      webShowClose: true, // Útil para web
      // webBgColor: "#${backgroundColor.value.toRadixString(16).substring(2)}", // Configuración opcional para web
      
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