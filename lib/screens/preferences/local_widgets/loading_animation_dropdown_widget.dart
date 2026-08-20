import 'package:flutter/material.dart';
import 'package:invenicum/core/utils/loading_animation.dart';
import 'package:invenicum/data/services/toast_service.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/providers/preferences_provider.dart';
import 'package:provider/provider.dart';

class LoadingAnimationDropdownWidget extends StatelessWidget {
  const LoadingAnimationDropdownWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final current = context.watch<PreferencesProvider>().loadingAnimation;

    return DropdownButton<LoadingAnimation>(
      value: current,
      items: LoadingAnimation.values
          .map(
            (animation) => DropdownMenuItem(
              value: animation,
              child: Text(animation.value),
            ),
          )
          .toList(),
      onChanged: (animation) {
        if (animation == null) return;
        context.read<PreferencesProvider>().setLoadingAnimation(animation);
        ToastService.success(l10n.preferencesUpdated);
      },
    );
  }
}
