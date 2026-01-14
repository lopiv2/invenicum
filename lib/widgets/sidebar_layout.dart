import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/providers/container_provider.dart';
import 'package:invenicum/services/toast_service.dart';
import 'package:invenicum/widgets/container_tree_view.dart';
import 'package:invenicum/widgets/sidebar.dart';
import 'package:provider/provider.dart';

class SidebarLayout extends StatefulWidget {
  @override
  State<SidebarLayout> createState() => _SidebarLayoutState();
}

class _SidebarLayoutState extends State<SidebarLayout> {
  // initState ya no es necesario, el provider se encarga de la carga inicial.

  @override
  Widget build(BuildContext context) {
    // 3. Observamos (watch) el ContainerProvider para reconstruir automáticamente
    //    el widget cuando la lista de contenedores o el estado de carga cambien.
    final containerProvider = context.watch<ContainerProvider>();
    final containers = containerProvider.containers;
    final isLoading = containerProvider.isLoading;

    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        children: [
          Sidebar(
            icon: Icons.dashboard,
            title: 'Dashboard',
            onTap: () => context.go('/dashboard'),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Text(
                  'Contenedores',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const Spacer(),
                // Botón Añadir: Muestra un indicador de carga si está activo.
                IconButton(
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add),
                  onPressed: isLoading
                      ? null
                      : () => _showNewContainerDialog(context),
                  tooltip: 'Añadir contenedor',
                ),
                // Botón de Recarga (opcional)
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: isLoading
                      ? null
                      : containerProvider.loadContainers,
                  tooltip: 'Recargar contenedores',
                ),
              ],
            ),
          ),

          // 4. Se muestra el estado de carga o la lista (área scrollable)
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : containers.isEmpty
                ? const Center(child: Text('Crea tu primer contenedor.'))
                : ContainerTreeView(
                    onDeleteContainer: _handleDeleteContainer,
                    onRenameContainer: _handleRenameContainer,
                    onContainerTap: (container, String? subSection) {
                      if (subSection != null) {
                        print(
                          'Navegando a la sección $subSection del contenedor ${container.name}',
                        );
                      } else {
                        print('Navegando al contenedor ${container.name}');
                      }
                    },
                  ),
          ),
          const Divider(),
          Sidebar(
            icon: Icons.notifications_active,
            title: 'Alertas y Notificaciones',
            onTap: () => context.go('/alerts'),
          ),
          // 5. Sección de Preferencias (siempre visible, no scrollable)
          const Divider(),
          Sidebar(
            icon: Icons.settings,
            title: 'Preferencias',
            onTap: () => context.go('/preferences'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDeleteContainer(int containerId) async {
    final containerNotifier = Provider.of<ContainerProvider>(
      context,
      listen: false,
    );

    await containerNotifier.deleteContainer(containerId);
  }

  Future<void> _handleRenameContainer(int containerId, String newName) async {
    final containerNotifier = Provider.of<ContainerProvider>(
      context,
      listen: false,
    );

    await containerNotifier.renameContainer(containerId, newName);
  }

  Future<void> _showNewContainerDialog(BuildContext context) async {
    // Usamos context.read para la acción, ya que no queremos reconstruir aquí.
    final containerProvider = context.read<ContainerProvider>();

    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    bool isCollection = false; // Estado local para el checkbox

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nuevo contenedor'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del contenedor',
                  hintText: 'Ingrese el nombre del contenedor',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  hintText: 'Ingrese una descripción',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('¿Es una colección?'),
                      value: isCollection,
                      onChanged: (value) {
                        setState(() {
                          isCollection = value ?? false;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Tooltip(
                    message:
                        'Los contenedores de colección tienen barras de seguimiento de colecciones, valor invertido, valor de mercado y vista de Exposición',
                    child: Icon(
                      Icons.help_outline,
                      size: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  Navigator.pop(context, {
                    'name': nameController.text,
                    'description': descriptionController.text.isEmpty
                        ? null
                        : descriptionController.text,
                    'isCollection': isCollection,
                  });
                }
              },
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      try {
        // Llama al Provider, que ejecuta la lógica de la API y llama a notifyListeners().
        await containerProvider.createNewContainer(
          result['name']!,
          result['description'],
          isCollection: result['isCollection'] ?? false,
        );

        // ¡El setState() ya no es necesario! La llamada al Provider lo maneja.

        if (mounted) {
          ToastService.success('Contenedor "${result['name']}" creado correctamente.');
        }
      } catch (e) {
        if (mounted) {
          ToastService.error('Error al crear el contenedor: ${e.toString()}', 5);
        }
      }
    }
  }
}
