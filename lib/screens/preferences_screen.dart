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
    final themeProvider = context.watch<ThemeProvider>();
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
                      subtitle: Text(
                        'Actual: ${themeProvider.currentTheme.name}',
                      ),
                      trailing: CircleAvatar(
                        backgroundColor:
                            themeProvider.currentTheme.primaryColor,
                        radius: 12,
                      ),
                      onTap: () => _showThemePicker(context, themeProvider),
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

// Función para mostrar el selector
void _showThemePicker(BuildContext context, ThemeProvider provider) {
  // Cargamos los temas de la DB cada vez que abrimos el selector
  provider.loadUserThemes();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Para que no se corte si hay muchos temas
    builder: (context) => Consumer<ThemeProvider>( // Escuchamos cambios aquí dentro
      builder: (context, themeProvider, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Temas del Sistema', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 15,
                children: [
                  ThemeColorDot(theme: ThemeProvider.brandTheme),
                  ...ThemeProvider.predefinedThemes.map((t) => ThemeColorDot(theme: t)),
                  // Botón para crear nuevo
                  IconButton.filledTonal(
                    onPressed: () => _showCustomColorPicker(context, themeProvider),
                    icon: const Icon(Icons.colorize),
                  ),
                ],
              ),
              const Divider(height: 30),
              const Text('Mis Temas Guardados', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              if (themeProvider.userThemes.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('No tienes temas guardados aún', style: TextStyle(color: Colors.grey)),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: themeProvider.userThemes.length,
                    itemBuilder: (context, index) {
                      final theme = themeProvider.userThemes[index];
                      return ListTile(
                        leading: CircleAvatar(backgroundColor: theme.primaryColor),
                        title: Text(theme.name),
                        subtitle: Text(theme.brightness == Brightness.dark ? 'Modo Oscuro' : 'Modo Claro'),
                        trailing: themeProvider.currentTheme.primaryColor.value == theme.primaryColor.value 
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : IconButton(
                                icon: const Icon(Icons.delete_outline, size: 20),
                                onPressed: () => themeProvider.deleteThemeFromLibrary(theme.id),
                              ),
                        onTap: () {
                          themeProvider.setTheme(theme);
                          Navigator.pop(context); // Cierra el selector
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
  // 1. Color inicial basado en el actual
  Color tempColor = provider.currentTheme.primaryColor;
  final TextEditingController nameController = TextEditingController(text: 'Mi Tema');

  showDialog(
    context: context,
    barrierDismissible: false, // Evita cerrar tocando fuera para controlar el flujo
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          title: const Text('Guardar Tema Personalizado'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre del tema'),
              ),
              const SizedBox(height: 20),
              // Usamos BlockPicker o MaterialPicker
              BlockPicker(
                pickerColor: tempColor,
                onColorChanged: (color) {
                  // Actualiza el estado del diálogo para que el usuario vea el cambio
                  setDialogState(() => tempColor = color);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newTheme = CustomTheme(
                  id: '', 
                  name: nameController.text.trim().isEmpty ? 'Personalizado' : nameController.text,
                  primaryColor: tempColor, 
                  brightness: provider.currentTheme.brightness,
                );
                
                // Ejecutamos la lógica del provider
                await provider.saveThemeToLibrary(newTheme);

                // 2. CIERRE SEGURO:
                // Primero cerramos el diálogo usando su propio context
                if (Navigator.of(dialogContext).canPop()) {
                  Navigator.of(dialogContext).pop();
                }
                
                // Luego cerramos el BottomSheet usando el context de la pantalla
                // Pero solo si sigue ahí (canPop)
                if (context.mounted && Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
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
