import 'package:flutter/material.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/providers/preferences_provider.dart';
import 'package:invenicum/services/toast_service.dart';
import 'package:provider/provider.dart';

class LanguageDropdownWidget extends StatelessWidget {
  final VoidCallback? onLanguageChanged;

  // Definimos el tamaño aquí para cambiarlo fácilmente en un solo sitio
  static const double _flagSize = 24.0;

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
        _buildMenuItem(context, 'en', '🇺🇸', 'English'),
        _buildMenuItem(context, 'es', '🇪🇸', 'Español'),
        _buildMenuItem(context, 'it', '🇮🇹', 'Italiano'),
        _buildMenuItem(context, 'pt', '🇵🇹', 'Português'),
        _buildMenuItem(context, 'fr', '🇫🇷', 'Français'),
        _buildMenuItem(context, 'de', '🇩🇪', 'Deutsch'),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getFlagForLanguage(currentLanguage),
              style: const TextStyle(fontSize: _flagSize), // Bandera principal grande
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }

  // Método helper para no repetir código y aplicar el tamaño a todas
  PopupMenuItem<String> _buildMenuItem(
      BuildContext context, String value, String flag, String label) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(flag, style: const TextStyle(fontSize: _flagSize)), // Bandera del menú grande
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }

  String _getFlagForLanguage(String languageCode) {
    switch (languageCode) {
      case 'es': return '🇪🇸';
      case 'it': return '🇮🇹';
      case 'pt': return '🇵🇹';
      case 'fr': return '🇫🇷';
      case 'de': return '🇩🇪';
      case 'en':
      default: return '🇺🇸';
    }
  }

  Future<void> _changeLanguage(BuildContext context, String languageCode) async {
    try {
      await context.read<PreferencesProvider>().setLanguage(languageCode);
      ToastService.success(AppLocalizations.of(context)!.languageChanged);
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      ToastService.error(l10n.errorChangingLanguage(e.toString()));
    }
  }
}