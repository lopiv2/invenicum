import 'package:flutter/material.dart';
import 'package:invenicum/providers/plugin_provider.dart';
import 'package:invenicum/services/toast_service.dart';
import 'package:invenicum/widgets/plugin_editor_dialog.dart';
import 'package:provider/provider.dart';
import 'package:stac/stac.dart';

class PluginAdminScreen extends StatefulWidget {
  const PluginAdminScreen({super.key});

  @override
  State<PluginAdminScreen> createState() => _PluginAdminScreenState();
}

class _PluginAdminScreenState extends State<PluginAdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime? _lastRefresh; // 🕒 Guardamos cuándo fue la última carga
  final Duration _refreshThreshold = const Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    // Creamos el controlador para 2 pestañas
    _tabController = TabController(length: 2, vsync: this);

    // Escuchamos cuando cambia la pestaña
    _tabController.addListener(_handleTabSelection);

    // Carga inicial
    _performInitialRefresh();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _performInitialRefresh() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        await context.read<PluginProvider>().refresh();
        _lastRefresh = DateTime.now(); // Marcamos el éxito inicial
      }
    });
  }

  void _handleTabSelection() {
    // Si entramos a Comunidad (index 1) y no estamos ya animando
    if (_tabController.index == 1 && !_tabController.indexIsChanging) {
      final now = DateTime.now();

      // Solo refresca si es la primera vez o si pasó más de 1 minuto
      if (_lastRefresh == null ||
          now.difference(_lastRefresh!) > _refreshThreshold) {
        context.read<PluginProvider>().refresh();
        _lastRefresh = now;
        debugPrint("Sincronizando comunidad con el servidor...");
      } else {
        debugPrint(
          "Usando datos en caché (frescos por ${60 - now.difference(_lastRefresh!).inSeconds}s más)",
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Plugin Manager"),
          actions: [
            // ➕ Botón de crear movido aquí
            IconButton(
              icon: const Icon(Icons.add_box_outlined),
              tooltip: "Crear Plugin",
              onPressed: () async {
                final result = await showDialog<Map<String, dynamic>>(
                  context: context,
                  builder: (context) => const PluginEditorDialog(),
                );
                if (result != null && mounted) {
                  context.read<PluginProvider>().savePlugin(result);
                }
              },
            ),
            const SizedBox(width: 8),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: "Instalados"),
              Tab(text: "Comunidad"),
            ],
          ),
        ),
        body: Consumer<PluginProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading)
              return const Center(child: CircularProgressIndicator());

            return TabBarView(
              controller: _tabController,
              children: [
                _PluginListView(plugins: provider.installed, isStore: false),
                _PluginListView(plugins: provider.community, isStore: true),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PluginListView extends StatelessWidget {
  final List<Map<String, dynamic>> plugins;
  final bool isStore;

  const _PluginListView({required this.plugins, required this.isStore});

  void _openEditor(BuildContext context, Map<String, dynamic> plugin) async {
    // 1. Guardamos la referencia al Navigator y al Provider antes de que el contexto cambie
    final provider = context.read<PluginProvider>();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => PluginEditorDialog(plugin: plugin),
    );

    // 2. Si hay resultado, primero nos aseguramos de que el diálogo se cerró
    if (result != null) {
      // 3. ESTA ES LA CLAVE: No dispares el savePlugin inmediatamente.
      // Deja que el frame actual termine de cerrar el diálogo.
      await Future.delayed(Duration.zero);

      // 4. Ejecutamos el guardado
      await provider.savePlugin(result);

      // 5. Feedback al usuario
      ToastService.success("¡Plugin actualizado!");
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PluginProvider>();
    final List<Map<String, dynamic>> currentPlugins = List.from(plugins);
    final installedIds = provider.installed
        .map((p) => p['id'].toString())
        .toSet();
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      key: PageStorageKey(isStore ? 'comunidad' : 'instalados'),
      itemCount: currentPlugins.length,
      itemBuilder: (context, index) {
        if (index >= currentPlugins.length) return const SizedBox.shrink();
        final plugin = plugins[index];
        final String pluginId = plugin['id'].toString();
        final bool isAlreadyInstalled = installedIds.contains(pluginId);
        final bool isActive = isStore ? true : (plugin['isActive'] ?? true);
        return AnimatedOpacity(
          opacity: isActive ? 1.0 : 0.5,
          curve: Curves.easeInOut,
          duration: const Duration(milliseconds: 300),
          child: Card(
            key: ValueKey("card_$pluginId"),
            elevation: isActive ? 2 : 0,
            clipBehavior: Clip.antiAlias,
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: InkWell(
              onTap: () => _showLargePreview(context, plugin), // Ver en grande
              child: IntrinsicHeight(
                // Para que el preview ocupe todo el alto
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Contenido principal (Info)
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              plugin['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Slot: ${plugin['slot']}",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      color: Colors.grey.shade100.withOpacity(0.5),
                      child: Center(
                        child: _buildActionRow(
                          context,
                          provider,
                          plugin,
                          isAlreadyInstalled,
                        ),
                      ),
                    ),

                    // 2. Separador vertical
                    VerticalDivider(width: 1, color: Colors.grey.shade300),

                    // 3. Mini Preview a la derecha
                    _buildAnimatedPreview(context, plugin, isActive),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedPreview(
    BuildContext context,
    Map plugin,
    bool isActive,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: MediaQuery.of(context).size.width * 0.3,
      color: isActive ? Colors.grey.shade50 : Colors.grey.shade200,
      alignment: Alignment.center,
      child: ColorFiltered(
        colorFilter: isActive
            ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
            : const ColorFilter.matrix(<double>[
                0.2126,
                0.7152,
                0.0722,
                0,
                0,
                0.2126,
                0.7152,
                0.0722,
                0,
                0,
                0.2126,
                0.7152,
                0.0722,
                0,
                0,
                0,
                0,
                0,
                1,
                0,
              ]), // Escala de grises si está desactivado
        child: Transform.scale(
          scale: 0.6,
          child: IgnorePointer(
            child:
                Stac.fromJson(plugin['ui'], context) ??
                const Icon(Icons.broken_image),
          ),
        ),
      ),
    );
  }

  Widget _buildActionRow(
    BuildContext context,
    PluginProvider provider,
    Map plugin,
    bool isInstalled,
  ) {
    if (isStore) {
      return isInstalled
          ? const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 24),
                Text(
                  "Activo",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          : IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.blue, size: 28),
              onPressed: () => provider.install(plugin['id'].toString()),
              tooltip: "Instalar",
            );
    } else {
      // --- NUEVA LÓGICA PARA INSTALADOS ---
      final bool isActive = plugin['isActive'] ?? true;
      final String pluginId = plugin['id'].toString();
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Interruptor rápido
          Transform.scale(
            scale: 0.8,
            child: Switch(
              key: ValueKey("switch_$pluginId"),
              value: isActive,
              activeColor: Colors.green,
              onChanged: (value) {
                context.read<PluginProvider>().togglePluginStatus(pluginId, value);
              },
            ),
          ),
          // Menú de opciones (editar, eliminar, etc)
          _buildPopupMenu(context, provider, plugin),
        ],
      );
    }
  }

  Widget _buildPopupMenu(
    BuildContext context,
    PluginProvider provider,
    Map plugin,
  ) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.grey),
      onSelected: (value) {
        if (value == 'edit') {
          _openEditor(context, Map<String, dynamic>.from(plugin));
        } else if (value == 'uninstall') {
          _confirmUninstall(context, provider, plugin);
        } else if (value == 'delete') {
          _confirmDelete(context, provider, plugin);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit, color: Colors.orange),
            title: Text("Editar"),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'uninstall',
          child: ListTile(
            leading: Icon(Icons.layers_clear, color: Colors.blueGrey),
            title: Text("Desinstalar"),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        //Solo mostramos "Eliminar" si el plugin no es de la comunidad (es decir, si el usuario lo creó)
        if (plugin['isMine'] == true)
          const PopupMenuItem(
            value: 'delete',
            child: ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text("Eliminar"),
              contentPadding: EdgeInsets.zero,
            ),
          ),
      ],
    );
  }

  void _showLargePreview(BuildContext context, Map<String, dynamic> plugin) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                plugin['name'],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(height: 30),
              Stac.fromJson(plugin['ui'], ctx) ??
                  const Text("Error al cargar UI"),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmUninstall(
    BuildContext context,
    PluginProvider provider,
    Map plugin,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("¿Eliminar plugin?"),
        content: Text(
          "Se quitará el widget '${plugin['name']}' de tu ${plugin['slot']}.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("CANCELAR"),
          ),
          TextButton(
            onPressed: () {
              provider.uninstall(plugin['id']);
              Navigator.pop(ctx);
            },
            child: const Text("ELIMINAR", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    PluginProvider provider,
    Map plugin,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("⚠️ ¡Atención!"),
        content: Text(
          "Estás a punto de borrar '${plugin['name']}' para TODOS los usuarios. Esta acción no se puede deshacer.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("CANCELAR"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              // Aquí llamarías a un nuevo método provider.deleteGlobalPlugin(id)
              provider.deletePlugin(plugin['id']);
              Navigator.pop(ctx);
            },
            child: const Text(
              "BORRAR DE LA DB",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
