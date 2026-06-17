// lib/widgets/ui/app_snack_bar.dart

import 'package:flutter/material.dart';
import 'package:invenicum/data/services/toast_service.dart';

void showAppSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  if (isError) {
    ToastService.error(message);
  } else {
    ToastService.success(message);
  }
}