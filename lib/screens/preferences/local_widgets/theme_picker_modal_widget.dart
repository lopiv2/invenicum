import 'package:flutter/material.dart';
import 'package:invenicum/core/themes/app_themes_registry.dart';
import 'package:invenicum/core/utils/retro/retro_dialog_helper.dart';
import 'package:invenicum/core/utils/theme_name_localizer.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/data/models/custom_theme_model.dart';
import 'package:invenicum/providers/theme_provider.dart';
import 'package:invenicum/screens/preferences/local_widgets/color_dot_widget.dart';
import 'package:provider/provider.dart';

void showThemePickerModal(BuildContext context, ThemeProvider provider) {
  provider.loadUserThemes();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Container(
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Standard themes ───────────────────────────────────────────
              Text(
                AppLocalizations.of(sheetContext)!.systemThemesModal,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 15,
                children: [
                  Tooltip(
                    message: localizeThemeName(sheetContext, AppThemesRegistry.brand, includeNotes: true),
                    child: ThemeColorDot(theme: AppThemesRegistry.brand),
                  ),
                  ...AppThemesRegistry.standard.map(
                    (t) => Tooltip(
                      message: localizeThemeName(sheetContext, t, includeNotes: true),
                      child: ThemeColorDot(theme: t),
                    ),
                  ),
                  // Custom color picker button
                  IconButton.filledTonal(
                    onPressed: () =>
                        _showCustomColorPicker(sheetContext, themeProvider),
                    icon: const Icon(Icons.colorize),
                  ),
                ],
              ),

              const Divider(height: 30),

              // ── Retro themes — same model, separate visual section ────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.computer, size: 16),
                  const SizedBox(width: 6),
                  const Text(
                    'Retro',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 15,
                // Retro themes are plain CustomThemes — just display them
                // using their paletteId for the dot appearance.
                children: AppThemesRegistry.retro.map((t) {
                  final bool isActive = themeProvider.currentTheme.id == t.id;
                  return Tooltip(
                    message: localizeThemeName(sheetContext, t, includeNotes: true),
                    child: GestureDetector(
                      onTap: () {
                        themeProvider.setTheme(t);
                        Navigator.pop(sheetContext);
                      },
                      child: _RetroThemeDot(theme: t, isActive: isActive),
                    ),
                  );
                }).toList(),
              ),

              const Divider(height: 30),

              // ── User saved themes ─────────────────────────────────────────
              Text(
                AppLocalizations.of(sheetContext)!.myThemesStored,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (themeProvider.userThemes.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    AppLocalizations.of(sheetContext)!.noThemesSaved,
                    style: const TextStyle(color: Colors.grey),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: themeProvider.userThemes.length,
                    itemBuilder: (context, index) {
                      final theme = themeProvider.userThemes[index];
                      final bool isActive =
                          themeProvider.currentTheme.primaryColor.toARGB32() ==
                          theme.primaryColor.toARGB32();
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.primaryColor,
                        ),
                        title: Text(theme.name),
                        subtitle: Text(
                          theme.brightness == Brightness.dark
                              ? AppLocalizations.of(context)!.darkMode
                              : AppLocalizations.of(context)!.lightMode,
                        ),
                        trailing: isActive
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                            : IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                ),
                                onPressed: () => themeProvider
                                    .deleteThemeFromLibrary(theme.id),
                              ),
                        onTap: () {
                          themeProvider.setTheme(theme);
                          Navigator.pop(sheetContext);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    ),
  );
}

// ─── Retro theme dot ──────────────────────────────────────────────────────────
//
// Visual appearance driven by [paletteId], not by a RetroMode enum.

class _RetroThemeDot extends StatelessWidget {
  final CustomTheme theme;
  final bool isActive;

  const _RetroThemeDot({required this.theme, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final retro = AppThemesRegistry.retroThemeForPaletteId(theme.paletteId);
    final accentColor = retro?.border ?? Colors.white;
    final label = (theme.paletteId ?? 'RETRO').toUpperCase();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(
          color: isActive ? accentColor : Colors.grey,
          width: isActive ? 3 : 1.5,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: accentColor,
            fontFamily: 'monospace',
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ─── Custom color picker (unchanged) ─────────────────────────────────────────

void _showCustomColorPicker(BuildContext context, ThemeProvider provider) {
  Color tempColor = provider.currentTheme.primaryColor;
  final TextEditingController nameController = TextEditingController(
    text: AppLocalizations.of(context)!.myCustomTheme,
  );

  showAppDialog(
    context: context,
    barrierDismissible: false,
    title: AppLocalizations.of(context)!.saveCustomTheme,

    body: Builder(
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.themeNameLabel,
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    ),

    actions: [
      Builder(
        builder: (dialogContext) {
          return TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),

            child: Text(AppLocalizations.of(context)!.cancel),
          );
        },
      ),

      Builder(
        builder: (dialogContext) {
          return ElevatedButton(
            onPressed: () async {
              final newTheme = CustomTheme(
                id: '',

                name: nameController.text.trim().isEmpty
                    ? AppLocalizations.of(context)!.myCustomTheme
                    : nameController.text,

                primaryColor: tempColor,

                brightness: provider.currentTheme.brightness,
              );

              await provider.saveThemeToLibrary(newTheme);

              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
            },

            child: Text(AppLocalizations.of(context)!.saveAndApply),
          );
        },
      ),
    ],
  );
}
