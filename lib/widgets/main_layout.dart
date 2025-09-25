import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/widgets/sidebar.dart';
import 'package:provider/provider.dart'; // NECESARIO
import '../services/api_service.dart';
import '../providers/container_provider.dart'; // NECESARIO
import '../widgets/container_tree_view.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _Header(),
          Expanded(
            child: Row(
              children: [
                _Sidebar(),
                Expanded(
                  child: Container(color: Colors.grey[100], child: child),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  // ... (Sin cambios)
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      color: Theme.of(context).primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Text(
            'Invenicum',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              // NOTA: Si ApiService() se crea aquí, debe ser singleton o inyectado.
              // Asumiendo que funciona por ahora, pero idealmente se inyectaría.
              await ApiService().logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------------
// CLASE _SIDEBAR (REFRACTORIZADA PARA USAR PROVIDER)
// -------------------------------------------------------------------

class _Sidebar extends StatefulWidget {
  @override
  State<_Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<_Sidebar> {
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
                    containers: containers, // La lista viene del Provider
                    onContainerTap: (container, subSection) {
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

  // 5. El diálogo ahora llama al método del Provider.
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
