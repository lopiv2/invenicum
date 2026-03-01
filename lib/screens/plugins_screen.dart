import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
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
        _lastRefresh = DateTime.now();
      }
    });
  }

  void _handleTabSelection() {
    if (_tabController.index == 1 && !_tabController.indexIsChanging) {
      final now = DateTime.now();
      // 🚩 ELIMINADO: refreshStore().
      // AHORA: Usamos loadCommunity() o simplemente refresh()
      if (_lastRefresh == null ||
          now.difference(_lastRefresh!) > _refreshThreshold) {
        context.read<PluginProvider>().loadCommunity(); // Método unificado
        _lastRefresh = now;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Plugin Manager"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
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
          tabs: const [
            Tab(text: "Instalados"),
            Tab(text: "Mis Plugins"),
            Tab(text: "Comunidad"),
          ],
        ),
      ),
      body: Consumer<PluginProvider>(
        builder: (context, provider, _) {
          // 🚩 Simplificamos el loading: solo usamos provider.isLoading
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            key: ValueKey(
              "tab_view_${provider.installed.length}_${provider.community.length}",
            ),
            children: [
              _PluginListView(
                plugins: provider.installed
                    .where((p) => p['isMine'] == false)
                    .toList(),
                isStore: false,
              ),
              _PluginListView(
                plugins: provider.installed
                    .where((p) => p['isMine'] == true)
                    .toList(),
                isStore: false,
              ),
              _PluginListView(plugins: provider.community, isStore: true),
            ],
          );
        },
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
    final List<Map<String, dynamic>> currentPlugins;
    if (isStore) {
      currentPlugins = provider.community;
    } else {
      currentPlugins = plugins;
    }
    final installedIds = provider.installed
        .map((p) => p['id'].toString())
        .toSet();
    if (provider.isLoading && currentPlugins.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      key: ValueKey("list_${isStore}_${currentPlugins.length}"),
      itemCount: currentPlugins.length,
      itemBuilder: (context, index) {
        if (index >= currentPlugins.length) return const SizedBox.shrink();
        final plugin = currentPlugins[index];
        final String pluginId = plugin['id'].toString();
        final bool isAlreadyInstalled = installedIds.contains(pluginId);
        final bool isActive = isStore ? true : (plugin['isActive'] ?? true);
        return AnimatedOpacity(
          opacity: isActive ? 1.0 : 0.5,
          curve: Curves.easeInOut,
          duration: const Duration(milliseconds: 300),
          child: Card(
            key: ValueKey(
              "card_${isStore ? 'st' : 'ins'}_${pluginId}_$isAlreadyInstalled",
            ),
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
                            const SizedBox(height: 10),
                            if (plugin['hasUpdate'] == true)
                              Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.system_update_alt_rounded,
                                        color: Colors.orange,
                                        size: 20,
                                      ),
                                      tooltip:
                                          "Actualización disponible: v${plugin['latestVersion'] ?? ''}",
                                      onPressed: () =>
                                          _confirmUpdate(context, plugin),
                                    ),
                                  )
                                  .animate(
                                    onPlay: (controller) => controller.repeat(),
                                  ) // 🔄 Lo hace infinito
                                  .moveY(
                                    begin: 0,
                                    end: -4,
                                    duration: 600.ms,
                                    curve: Curves.easeInOut,
                                  ) // Sube
                                  .then() // Espera a que termine lo anterior
                                  .moveY(
                                    begin: -4,
                                    end: 0,
                                    duration: 600.ms,
                                    curve: Curves.easeInOut,
                                  ) // Baja
                                  .shake(
                                    hz: 2,
                                    duration: 1200.ms,
                                  ), // Un pequeño temblor extra
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

  void _confirmUpdate(BuildContext context, Map<String, dynamic> plugin) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Actualización disponible"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("¿Deseas actualizar '${plugin['name']}'?"),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  "v${plugin['version']}",
                  style: const TextStyle(color: Colors.grey),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  "v${plugin['latestVersion']}",
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("CANCELAR"),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);

              // 🚩 LA SOLUCIÓN:
              // Creamos una copia para no modificar el objeto original de la lista
              final updatedData = Map<String, dynamic>.from(plugin);

              // Reemplazamos la versión vieja por la nueva antes de enviar al server
              updatedData['version'] = plugin['latestVersion'];

              // Ahora el backend recibirá la versión nueva en el campo 'version'
              context.read<PluginProvider>().install(updatedData);
            },
            child: const Text("ACTUALIZAR AHORA"),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedPreview(
    BuildContext context,
    Map<String, dynamic> plugin,
    bool isActive,
  ) {
    // 1. Extraemos la UI si ya existe, o la URL si es de la comunidad
    final dynamic localUi = plugin['ui'];
    final String? downloadUrl = plugin['download_url'];

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
              ]),
        child: Transform.scale(
          scale: 0.6,
          child: IgnorePointer(
            child: _buildStacContent(context, localUi, downloadUrl),
          ),
        ),
      ),
    );
  }

  /// Decide si renderizar la UI local o descargarla para la previa
  Widget _buildStacContent(BuildContext context, dynamic localUi, String? url) {
    // Caso A: Ya tenemos la UI (Plugins instalados)
    if (localUi != null) {
      // 🚩 Verificamos si es un mapa y si contiene la llave 'ui'
      final uiToRender = (localUi is Map && localUi.containsKey('ui'))
          ? localUi['ui']
          : localUi;

      return Stac.fromJson(uiToRender, context) ??
          const Icon(Icons.broken_image);
    }

    // Caso B: Es de la comunidad y hay que descargar la previa
    if (url != null && url.isNotEmpty) {
      return FutureBuilder<Map<String, dynamic>>(
        // Usamos el servicio que ya tienes para descargar el JSON
        future: context.read<PluginProvider>().downloadPluginStac(url),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(strokeWidth: 2);
          }
          if (snapshot.hasData) {
            final Map<String, dynamic> data =
                snapshot.data as Map<String, dynamic>;

            // Si el JSON viene con la nueva estructura, la UI está en la llave 'ui'
            // Si no, asumimos que el JSON entero es la UI (compatibilidad)
            final uiJson = data.containsKey('ui') ? data['ui'] : data;
            return Stac.fromJson(uiJson, context) ??
                const Icon(Icons.broken_image);
          }
          return const Icon(Icons.cloud_off, color: Colors.grey);
        },
      );
    }

    return const Icon(Icons.help_outline, color: Colors.grey);
  }

  Widget _buildActionRow(
    BuildContext context,
    PluginProvider provider,
    Map<String, dynamic> plugin,
    bool isInstalled,
  ) {
    if (isStore) {
      return isInstalled
          ? const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 24),
                Text(
                  "Instalado",
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
              // 🚩 CAMBIO CLAVE: Enviamos el objeto 'plugin' completo, no solo el ID
              onPressed: () => provider.install(plugin),
              tooltip: "Instalar",
            );
    } else {
      // --- NUEVA LÓGICA PARA INSTALADOS ---
      final bool isActive = plugin['isActive'] ?? true;

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Interruptor rápido
          Transform.scale(
            scale: 0.8,
            child: Switch(
              key: ValueKey("sw_${plugin['id']}_$isActive"),
              value: isActive,
              activeColor: Colors.green,
              onChanged: (value) async {
                // 1. Ejecutamos el cambio en el provider (que ya es optimista)
                // No pongas el Toast dentro del Provider, déjalo aquí en la UI
                await provider.togglePluginStatus(
                  plugin['id'].toString(),
                  value,
                );
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
    final pluginProvider = context.read<PluginProvider>();

    // Detectamos el estado actual del plugin
    final String? downloadUrl = plugin['download_url'];
    final dynamic localUi = plugin['ui'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Barra superior de arrastre
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Título y Versión
              Text(
                plugin['name'] ?? 'Plugin sin nombre',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (plugin['version'] != null)
                Text(
                  "Versión ${plugin['version']}",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),

              const Divider(height: 40, thickness: 1),

              // --- SECCIÓN DE PREVISUALIZACIÓN STAC ---
              const Text(
                "Previsualización",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 15),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: localUi != null
                    // Si ya es local, lo dibujamos directo
                    ? (Stac.fromJson(localUi, ctx) ??
                          const Text("Error de renderizado"))
                    // Si es de la comunidad, lo descargamos por el proxy
                    : FutureBuilder<Map<String, dynamic>>(
                        future: pluginProvider.downloadPluginStac(
                          downloadUrl ?? '',
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          if (snapshot.hasData) {
                            return Stac.fromJson(snapshot.data, ctx) ??
                                const Text("Formato no soportado");
                          }
                          return const Center(
                            child: Text("Previsualización no disponible"),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 30),

              // Descripción
              if (plugin['description'] != null) ...[
                const Text(
                  "Acerca de este plugin",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  plugin['description'],
                  style: const TextStyle(color: Colors.black87),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Version",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  plugin['version'] ?? 'N/A',
                  style: const TextStyle(color: Colors.black87),
                ),
              ],
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
    bool deleteFromGitHub = false;
    final bool isPublic = plugin['isPublic'] ?? false;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("¿Eliminar plugin?"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Estás a punto de borrar '${plugin['name']}'. Esta acción no se puede deshacer.",
              ),
              if (isPublic) ...[
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.withOpacity(0.2)),
                  ),
                  child: CheckboxListTile(
                    title: const Text(
                      "Borrar de GitHub",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: const Text(
                      "Eliminará el archivo .json y la entrada en el repositorio público.",
                      style: TextStyle(fontSize: 12),
                    ),
                    value: deleteFromGitHub,
                    activeColor: Colors.red,
                    onChanged: (val) => setState(() => deleteFromGitHub = val!),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("CANCELAR"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                // Pasamos el booleano al provider
                provider.deletePlugin(
                  plugin['id'],
                  deleteFromGitHub: deleteFromGitHub,
                );
                Navigator.pop(ctx);
              },
              child: const Text(
                "BORRAR DEFINITIVAMENTE",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
