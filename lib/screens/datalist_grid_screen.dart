import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:invenicum/models/container_node.dart';
import 'package:invenicum/models/list_data.dart';
import 'package:invenicum/providers/container_provider.dart';
import 'package:invenicum/services/toast_service.dart';

class DataListGridScreen extends StatefulWidget {
  final String containerId;

  const DataListGridScreen({
    super.key,
    required this.containerId,
  });

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

  Future<void> _showDeleteConfirmation(BuildContext context, ListData dataList) async {
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
              child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
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
    final container = containerProvider.containers.cast<ContainerNode?>().firstWhere(
          (c) => c?.id == int.parse(widget.containerId),
          orElse: () => null,
        );

    if (container == null) {
      return const Center(child: Text('Contenedor no encontrado'));
    }

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          // --- CABECERA ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Listas Personalizadas - ${container.name}',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              FilledButton.icon(
                onPressed: () {
                  context.go('/container/${widget.containerId}/datalists/new');
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
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: container.dataLists.length,
                itemBuilder: (context, index) {
                  final dataList = container.dataLists[index];
                  return Card(
                    elevation: 2,
                    child: InkWell(
                      onTap: () {
                        context.push('/container/${widget.containerId}/datalists/${dataList.id}/edit', extra: dataList);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.list_alt,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    dataList.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.edit_outlined,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  onPressed: () {
                                    context.go('/container/${widget.containerId}/datalists/${dataList.id}/edit', extra: dataList);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _showDeleteConfirmation(context, dataList),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              dataList.description ?? 'Sin descripción',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  '${dataList.items.length} elementos',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}