import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/services/toast_service.dart';

Future<T> runAsyncTask<T>(
  BuildContext context,
  Future<T> Function() task, {
  String loadingMessage = "Procesando...",
  String? errorMessage,
  Duration delayBeforeLoader = const Duration(milliseconds: 200),
}) async {
  bool dialogShown = false;

  // Timer para evitar flicker si la operación es rápida
  final timer = Timer(delayBeforeLoader, () {
    if (!context.mounted) return;

    dialogShown = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(loadingMessage),
            ],
          ),
        ),
      ),
    );
  });

  try {
    final result = await task();

    timer.cancel();

    if (dialogShown && context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    return result;
  } catch (e) {
    timer.cancel();

    if (dialogShown && context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    if (context.mounted) {
      ToastService.error(errorMessage ?? "Error: $e");
    }

    rethrow;
  }
}