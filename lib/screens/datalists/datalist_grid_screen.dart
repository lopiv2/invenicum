import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/core/routing/route_names.dart';
import 'package:provider/provider.dart';
import 'package:invenicum/data/models/container_node.dart';
import 'package:invenicum/data/models/list_data.dart';
import 'package:invenicum/providers/container_provider.dart';
import 'package:invenicum/data/services/toast_service.dart';

class DataListGridScreen extends StatefulWidget {
  final String containerId;

  const DataListGridScreen({super.key, required this.containerId});

  @override
  State<DataListGridScreen> createState() => _DataListGridScreenState();
}

class _DataListGridScreenState extends State<DataListGridScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Cargar solo las listas del contenedor actual
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await context.read<ContainerProvider>().loadDataLists(
          int.parse(widget.containerId),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    });
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    ListData dataList,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text(
            '¿Estás seguro de que quieres eliminar la lista "${dataList.name}"? Esta acción es irreversible.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      try {
        final provider = context.read<ContainerProvider>();
        await provider.deleteDataList(dataList.id);
        if (context.mounted) {
          ToastService.success('Lista "${dataList.name}" eliminada con éxito.');
        }
      } catch (e) {
        if (context.mounted) {
          ToastService.error('Error al eliminar la lista: ${e.toString()}');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final containerProvider = context.watch<ContainerProvider>();
    final container = containerProvider.containers
        .cast<ContainerNode?>()
        .firstWhere(
          (c) => c?.id == int.parse(widget.containerId),
          orElse: () => null,
        );

    if (container == null) {
      return const Center(child: Text('Contenedor no encontrado'));
    }

    return Padding(
      padding: EdgeInsets.all(
        MediaQuery.of(context).size.width < 600 ? 16.0 : 32.0,
      ),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- CABECERA ---
                // --- CABECERA ADAPTATIVA (WRAP) ---
                Wrap(
                  spacing: 16, // Espacio horizontal entre elementos
                  runSpacing: 16, // Espacio vertical cuando salta de línea
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Listas Personalizadas - ${container.name}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        // Tamaño de fuente dinámico para que no rompa en pantallas muy pequeñas
                        fontSize: MediaQuery.of(context).size.width < 400
                            ? 20
                            : null,
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () {
                        context.goNamed(
                          RouteNames.dataListCreate,
                          pathParameters: {'containerId': widget.containerId},
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Nueva Lista'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // --- GRID DE LISTAS ---
                if (container.dataLists.isEmpty)
                  const Center(
                    child: Text(
                      'No hay listas personalizadas. ¡Crea una nueva!',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                else
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent:
                            400, // Un poco más ancho para que en móvil ocupe casi todo
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        // Ajustamos la altura de la tarjeta según el dispositivo
                        childAspectRatio:
                            MediaQuery.of(context).size.width < 600 ? 2 : 2.5,
                      ),
                      itemCount: container.dataLists.length,
                      itemBuilder: (context, index) {
                        final dataList = container.dataLists[index];
                        return _buildDataListCard(context, dataList);
                      },
                    ),
                  ),
              ],
            ),
    );
  }

  // Extraemos la tarjeta a un método para limpiar el build
  Widget _buildDataListCard(BuildContext context, ListData dataList) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          context.pushNamed(
            RouteNames.dataListEdit,
            pathParameters: {
              'containerId': widget.containerId,
              'dataListId': dataList.id
                  .toString(), // GoRouter siempre espera Strings en los parámetros de ruta
            },
            extra: dataList,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.list_alt, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      dataList.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Agrupamos botones para que no se amontonen en tarjetas pequeñas
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        constraints:
                            const BoxConstraints(), // Quita padding extra
                        padding: const EdgeInsets.all(4),
                        icon: Icon(
                          Icons.edit_outlined,
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                        onPressed: () => context.goNamed(
                          RouteNames.dataListEdit,
                          pathParameters: {
                            'containerId': widget.containerId,
                            'dataListId': dataList.id.toString(),
                          },
                          extra: dataList,
                        ),
                      ),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: () =>
                            _showDeleteConfirmation(context, dataList),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  dataList.description ?? 'Sin descripción',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${dataList.items.length} elementos',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
