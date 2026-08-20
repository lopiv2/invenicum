import 'package:invenicum/widgets/ui/app_loading_indicator.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:invenicum/core/utils/retro/retro_dialog_helper.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import '../../data/services/toast_service.dart';

Future<T> runAsyncTask<T>(
  BuildContext context,
  Future<T> Function() task, {
  String loadingMessage = "Procesando...",
  String? errorMessage,
  Duration delayBeforeLoader = const Duration(milliseconds: 200),
}) async {
  bool dialogShown = false;

  final l10n = AppLocalizations.of(context)!;

  loadingMessage = l10n.processing;

  // Timer to avoid flicker if the operation is fast
  final timer = Timer(delayBeforeLoader, () {
    if (!context.mounted) return;

    dialogShown = true;

    showAppDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,

      title: loadingMessage,

      body: PopScope(
        canPop: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLoadingIndicator(),
            SizedBox(height: 20),
            Text(loadingMessage),
          ],
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
