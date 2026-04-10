import 'package:flutter/material.dart';
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
      builder: (context, themeProvider, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(sheetContext)!.systemThemesModal,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 15,
                children: [
                  Tooltip(
                    message: localizeThemeName(
                      sheetContext,
                      ThemeProvider.brandTheme,
                    ),
                    child: ThemeColorDot(theme: ThemeProvider.brandTheme),
                  ),
                  ...ThemeProvider.predefinedThemes.map(
                    (t) => Tooltip(
                      message: localizeThemeName(sheetContext, t),
                      child: ThemeColorDot(theme: t),
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: () =>
                        _showCustomColorPicker(sheetContext, themeProvider),
                    icon: const Icon(Icons.colorize),
                  ),
                ],
              ),
              const Divider(height: 30),
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
                        trailing:
                            themeProvider.currentTheme.primaryColor.toARGB32() ==
                                theme.primaryColor.toARGB32()
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

void _showCustomColorPicker(BuildContext context, ThemeProvider provider) {
  Color tempColor = provider.currentTheme.primaryColor;
  final TextEditingController nameController = TextEditingController(
    text: AppLocalizations.of(context)!.myCustomTheme,
  );

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.saveCustomTheme),
          content: SingleChildScrollView(
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
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final newTheme = CustomTheme(
                  id: '',
                  name: nameController.text.trim().isEmpty
                      ? AppLocalizations.of(context)!.myCustomTheme
                      : nameController.text,
                  primaryColor: tempColor,
                  brightness: provider.currentTheme.brightness,
                );

                if (context.mounted) {
                  await provider.saveThemeToLibrary(newTheme);
                  Navigator.pop(dialogContext);
                }
              },
              child: Text(AppLocalizations.of(context)!.saveAndApply),
            ),
          ],
        );
      },
    ),
  );
}
