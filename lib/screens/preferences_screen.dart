import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/models/custom_theme_model.dart';
import 'package:invenicum/providers/theme_provider.dart';
import 'package:invenicum/widgets/color_dot_widget.dart';
import 'package:provider/provider.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  @override
  Widget build(BuildContext context) {
    // Usamos watch para que la UI reaccione a los cambios de tema inmediatamente
    final themeName = context.select<ThemeProvider, String>(
      (p) => p.currentTheme.name,
    );
    final themeColor = context.select<ThemeProvider, Color>(
      (p) => p.currentTheme.primaryColor,
    );

    // Para las funciones usamos read (esto no provoca re-renders)
    final provider = context.read<ThemeProvider>();

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preferencias',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configuración General',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.palette_outlined),
                      title: const Text('Tema de la aplicación'),
                      subtitle: Text('Actual: $themeName'),
                      trailing: CircleAvatar(
                        backgroundColor:
                            themeColor, // Usa la variable themeColor
                        radius: 12,
                      ),
                      onTap: () => _showThemePicker(context, provider),
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Idioma'),
                      subtitle: const Text(
                        'Selecciona el idioma de la aplicación',
                      ),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Funcionalidad de idioma por implementar',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gestión de Préstamos',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Editor de Vales de Entrega'),
                      subtitle: const Text(
                        'Personaliza la plantilla PDF para préstamos',
                      ),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () {
                        context.push('/delivery-voucher-editor');
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Sobre Invenicum'),
                      subtitle: const Text('Versión 1.0.0'),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Invenicum v1.0.0')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- FUNCIONES DE APOYO CORREGIDAS ---

void _showThemePicker(BuildContext context, ThemeProvider provider) {
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
              const Text(
                'Temas del Sistema',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 15,
                children: [
                  ThemeColorDot(theme: ThemeProvider.brandTheme),
                  ...ThemeProvider.predefinedThemes.map(
                    (t) => Tooltip(
                      message: t.name,
                      child: ThemeColorDot(theme: t),
                    ),
                  ),
                  IconButton.filledTonal(
                    // Pasamos el sheetContext para que el Dialog sepa que se abre desde el Modal
                    onPressed: () =>
                        _showCustomColorPicker(sheetContext, themeProvider),
                    icon: const Icon(Icons.colorize),
                  ),
                ],
              ),
              const Divider(height: 30),
              const Text(
                'Mis Temas Guardados',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (themeProvider.userThemes.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'No tienes temas guardados aún',
                    style: TextStyle(color: Colors.grey),
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
                              ? 'Modo Oscuro'
                              : 'Modo Claro',
                        ),
                        trailing:
                            themeProvider.currentTheme.primaryColor.value ==
                                theme.primaryColor.value
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
                          // Usamos Navigator manual para cerrar SOLO el BottomSheet
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
    text: 'Mi Tema',
  );

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          title: const Text('Guardar Tema Personalizado'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del tema',
                  ),
                ),
                const SizedBox(height: 20),
                BlockPicker(
                  pickerColor: tempColor,
                  onColorChanged: (color) {
                    setDialogState(() => tempColor = color);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newTheme = CustomTheme(
                  id: '',
                  name: nameController.text.trim().isEmpty
                      ? 'Personalizado'
                      : nameController.text,
                  primaryColor: tempColor,
                  brightness: provider.currentTheme.brightness,
                );

                if (context.mounted) {
                  await provider.saveThemeToLibrary(newTheme);
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Guardar y Aplicar'),
            ),
          ],
        );
      },
    ),
  );
}
