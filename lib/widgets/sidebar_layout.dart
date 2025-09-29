import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/providers/container_provider.dart';
import 'package:invenicum/widgets/container_tree_view.dart';
import 'package:invenicum/widgets/sidebar.dart';
import 'package:provider/provider.dart';

class SidebarLayout extends StatefulWidget {
  @override
  State<SidebarLayout> createState() => _SidebarLayoutState();
}

class _SidebarLayoutState extends State<SidebarLayout> {
  // 1. Eliminamos el estado local `containers` y la instancia de `ContainerService`.

  @override
  void initState() {
    super.initState();
    // 2. Disparamos la carga de contenedores una vez, después de que el widget se haya montado.
    // Usamos context.read porque no queremos que initState reaccione a los cambios futuros,
    // solo queremos iniciar la acción.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContainerProvider>().loadContainers();
    });
  }

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

          // 4. Se muestra el estado de carga o la lista
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : containers.isEmpty
                ? const Center(child: Text('Crea tu primer contenedor.'))
                : ContainerTreeView(
                    onDeleteContainer: _handleDeleteContainer,
                    onRenameContainer: _handleRenameContainer,
                    containers: containers, // La lista viene del Provider
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

    final result = await showDialog<Map<String, String?>>(
      context: context,
      builder: (context) => AlertDialog(
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
                });
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        // Llama al Provider, que ejecuta la lógica de la API y llama a notifyListeners().
        await containerProvider.createNewContainer(
          result['name']!,
          result['description'],
        );

        // ¡El setState() ya no es necesario! La llamada al Provider lo maneja.

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Contenedor "${result['name']}" creado exitosamente',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al crear el contenedor: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
