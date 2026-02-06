import 'package:flutter/material.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/providers/preferences_provider.dart';
import 'package:invenicum/services/toast_service.dart';
import 'package:provider/provider.dart';

class LanguageDropdownWidget extends StatelessWidget {
  final VoidCallback? onLanguageChanged;

  const LanguageDropdownWidget({
    super.key,
    this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final currentLocale = Localizations.localeOf(context);
    final currentLanguage = currentLocale.languageCode;

    return PopupMenuButton<String>(
      onSelected: (String languageCode) async {
        await _changeLanguage(context, languageCode);
        onLanguageChanged?.call();
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'en',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🇺🇸', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(width: 12),
              const Text('English'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'es',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🇪🇸', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(width: 12),
              const Text('Español'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'it',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🇮🇹', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(width: 12),
              const Text('Italiano'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'pt',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🇵🇹', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(width: 12),
              const Text('Português'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'fr',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🇫🇷', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(width: 12),
              const Text('Français'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'de',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🇩🇪', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(width: 12),
              const Text('Deutsch'),
            ],
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getFlagForLanguage(currentLanguage),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }

  String _getFlagForLanguage(String languageCode) {
    switch (languageCode) {
      case 'es':
        return '🇪🇸';
      case 'it':
        return '🇮🇹';
      case 'pt':
        return '🇵🇹';
      case 'fr':
        return '🇫🇷';
      case 'de':
        return '🇩🇪';
      case 'en':
      default:
        return '🇺🇸';
    }
  }

  Future<void> _changeLanguage(BuildContext context, String languageCode) async {
    try {
      await context.read<PreferencesProvider>().setLanguage(languageCode);

      final currentLocale = Localizations.localeOf(context);
      if (currentLocale.languageCode != languageCode) {
        ToastService.success(
          languageCode == 'es'
              ? AppLocalizations.of(context)!.languageChanged
              : 'Language changed to English!',
        );
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      ToastService.error('${l10n.errorChangingLanguage(e.toString())}');
    }
  }
}
