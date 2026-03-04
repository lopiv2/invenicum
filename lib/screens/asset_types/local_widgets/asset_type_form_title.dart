import 'package:flutter/material.dart';

/// Widget para el título del formulario de tipo de activo
class AssetTypeFormTitle extends StatelessWidget {
  final String title;

  const AssetTypeFormTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .headlineMedium
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}
