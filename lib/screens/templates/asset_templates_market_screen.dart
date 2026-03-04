import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:invenicum/providers/template_provider.dart';
import 'package:invenicum/data/models/asset_template_model.dart';

class AssetTemplatesMarketScreen extends StatefulWidget {
  const AssetTemplatesMarketScreen({super.key});

  @override
  State<AssetTemplatesMarketScreen> createState() =>
      _AssetTemplatesMarketScreenState();
}

class _AssetTemplatesMarketScreenState
    extends State<AssetTemplatesMarketScreen> {
  final List<String> _selectedTags = [];
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 🚩 Disparamos la carga de datos del backend al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TemplateProvider>().fetchMarketTemplates();
    });
  }

  @override
  void dispose() {
    _searchController.dispose(); // Buena práctica para liberar memoria
    super.dispose();
  }

  // 🚩 Filtrar plantillas según las etiquetas seleccionadas
  List<AssetTemplate> _getFilteredTemplates(List<AssetTemplate> templates) {
    return templates.where((t) {
      // Filtro por nombre (ignora mayúsculas/minúsculas)
      final matchesName = t.name.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );

      // Filtro por etiquetas (debe tener todas las seleccionadas)
      final matchesTags =
          _selectedTags.isEmpty ||
          _selectedTags.every((tag) => t.tags.contains(tag));

      return matchesName && matchesTags;
    }).toList();
  }

  // 🚩 Obtener etiquetas disponibles
  List<String> _getAvailableTags(List<AssetTemplate> templates) {
    final allTags = templates.expand((t) => t.tags).toSet();
    return allTags.where((tag) => !_selectedTags.contains(tag)).toList()
      ..sort();
  }

  @override
  Widget build(BuildContext context) {
    // 🚩 Escuchamos los cambios en el provider
    final templateProvider = context.watch<TemplateProvider>();
    final templates = templateProvider.marketTemplates;
    final filteredTemplates = _getFilteredTemplates(templates);
    return Scaffold(
      body: Column(
        children: [
          _buildMarketHeader(context, templateProvider, templates),
          Expanded(child: _buildBody(templateProvider, filteredTemplates)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/templates/create'),
        icon: const Icon(Icons.add_to_photos),
        label: const Text('Publicar Plantilla'),
      ),
    );
  }

  Widget _buildBody(TemplateProvider provider, List<AssetTemplate> templates) {
    // 1. Estado de carga
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Estado de error
    if (provider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(provider.errorMessage!),
            TextButton(
              onPressed: () => provider.fetchMarketTemplates(),
              child: const Text("Reintentar"),
            ),
          ],
        ),
      );
    }

    // 3. Estado vacío
    if (templates.isEmpty) {
      return const Center(
        child: Text("No se encontraron plantillas en el mercado."),
      );
    }

    // 4. Lista de plantillas (Market real)
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // Ideal para web/escritorio
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        return _TemplateCard(
          key: ValueKey(templates[index].id),
          template: templates[index],
        );
      },
    );
  }

  Widget _buildMarketHeader(
    BuildContext context,
    TemplateProvider provider, // Añadimos el provider para el refresh
    List<AssetTemplate> templates,
  ) {
    final availableTags = _getAvailableTags(templates);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        24,
        40,
        24,
        32,
      ), // Más padding arriba si no hay AppBar
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
            Theme.of(context).colorScheme.surface,
          ],
        ),
      ),
      child: Column(
        children: [
          // --- CAPA DE TÍTULO Y RECARGA ---
          Container(
            width:
                double.infinity, // 🚩 Crucial para que el Positioned funcione
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 1. El Título (Siempre centrado)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.hub_rounded,
                      size: 40,
                      color: Colors.indigo,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Comunidad Invenicum',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: Colors.indigo.shade900,
                          ),
                    ),
                  ],
                ),
                // 2. El Botón de Recargar (A la derecha del todo)
                Positioned(
                  right: 0,
                  top: 0,
                  child: IconButton(
                    onPressed: () => provider.fetchMarketTemplates(),
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: Colors.indigo,
                    ),
                    tooltip: "Actualizar mercado",
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          const Text(
            'Explora y descarga configuraciones de la comunidad',
            style: TextStyle(color: Colors.blueGrey, fontSize: 14),
          ),

          const SizedBox(height: 24),

          // --- BUSCADOR HÍBRIDO (Nombre + Tags) ---
          _buildModernSearchBar(availableTags),

          const SizedBox(height: 16),

          // --- CHIPS CENTRADOS ---
          _buildActiveFiltersChips(),
        ],
      ),
    );
  }

  Widget _buildModernSearchBar(List<String> availableTags) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(27), // Forma de cápsula completa
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 18),
          const Icon(Icons.search_rounded, color: Colors.indigo, size: 22),
          const SizedBox(width: 12),

          // --- CAMPO DE TEXTO (Nombre) ---
          Expanded(
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              style: const TextStyle(fontSize: 15),
              decoration: const InputDecoration(
                hintText: "Buscar por nombre de plantilla...",
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.blueGrey, fontSize: 14),
                isDense: true,
              ),
            ),
          ),

          // Divisor vertical sutil
          Container(height: 24, width: 1, color: Colors.grey.withOpacity(0.2)),

          // --- SELECTOR DE ETIQUETAS (PopupMenu) ---
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.style_rounded,
              color: Colors.indigo,
              size: 22,
            ),
            tooltip: "Filtrar por etiqueta",
            offset: const Offset(0, 50), // Aparece justo debajo del botón
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            onSelected: (tag) {
              if (!_selectedTags.contains(tag)) {
                setState(() => _selectedTags.add(tag));
              }
            },
            itemBuilder: (context) {
              if (availableTags.isEmpty) {
                return [
                  const PopupMenuItem(
                    enabled: false,
                    child: Text(
                      "No hay más etiquetas",
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ];
              }
              return availableTags
                  .map(
                    (tag) => PopupMenuItem(
                      value: tag,
                      child: Row(
                        children: [
                          const Icon(Icons.tag, size: 16, color: Colors.indigo),
                          const SizedBox(width: 8),
                          Text(tag, style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  )
                  .toList();
            },
          ),

          // Botón de borrado rápido (solo si hay texto o tags)
          if (searchQuery.isNotEmpty || _selectedTags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: const Icon(
                  Icons.clear_rounded,
                  size: 18,
                  color: Colors.redAccent,
                ),
                onPressed: () {
                  setState(() {
                    searchQuery = "";
                    _selectedTags.clear();
                  });
                  // Nota: Para limpiar físicamente el TextField necesitarías un TextEditingController
                },
              ),
            )
          else
            const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _buildActiveFiltersChips() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      // Esto suaviza la aparición/desaparición de la fila de chips
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _selectedTags.isEmpty
          ? const SizedBox.shrink() // Si no hay filtros, no ocupa espacio
          : Padding(
              key: const ValueKey('active_chips_container'),
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Wrap(
                spacing: 8, // Espacio horizontal entre chips
                runSpacing: 8, // Espacio vertical si saltan de línea
                alignment: WrapAlignment.center,
                children: _selectedTags.map((tag) {
                  return RawChip(
                    label: Text(
                      tag,
                      style: TextStyle(
                        color: Colors.indigo.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    // Icono de eliminar personalizado
                    deleteIcon: const Icon(Icons.cancel_rounded, size: 18),
                    onDeleted: () {
                      setState(() {
                        _selectedTags.remove(tag);
                      });
                    },
                    // Estética moderna
                    elevation: 0,
                    pressElevation: 2,
                    backgroundColor: Colors.indigo.withOpacity(0.08),
                    selectedColor: Colors.indigo.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(
                      color: Colors.indigo.withOpacity(0.1),
                      width: 1,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                  );
                }).toList(),
              ),
            ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final AssetTemplate template;

  const _TemplateCard({super.key, required this.template});

  // Helper para no repetir código
  Widget _buildInitial() {
    return Text(
      template.author.isNotEmpty ? template.author[0].toUpperCase() : '?',
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.indigo,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: () {
          context.go('/templates/details/${template.id}', extra: template);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: template.isOfficial
                        ? Colors.indigo.withOpacity(0.1)
                        : Colors.teal.withOpacity(0.1),
                    child: Center(
                      child: Icon(
                        template.isOfficial
                            ? Icons.verified_user
                            : Icons.copy_all,
                        size: 40,
                        color: template.isOfficial
                            ? Colors.indigo
                            : Colors.teal,
                      ),
                    ),
                  ),
                  // 🚩 CONTADOR DE DESCARGAS FLOTANTE
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.file_download_outlined,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${template.downloadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          template.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (template.isOfficial)
                        const Icon(
                          Icons.verified,
                          size: 16,
                          color: Colors.blue,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.indigo.shade100,
                        child: ClipOval(
                          child:
                              template.authorAvatarUrl != null &&
                                  template.authorAvatarUrl!.isNotEmpty
                              ? Image.network(
                                  "${template.authorAvatarUrl!}?v=${template.id.hashCode}",
                                  fit: BoxFit.cover,
                                  width: 40,
                                  height: 40,
                                  // 🚩 Si la URL existe pero el servidor falla (ej. 404)
                                  errorBuilder: (context, error, stackTrace) {
                                    // Si falla, imprime el error exacto en consola para ver qué dice
                                    print(
                                      "Error loading avatar ${template.id}: $error",
                                    );
                                    return _buildInitial();
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return const Center(
                                          child: SizedBox(
                                            width: 15,
                                            height: 15,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        );
                                      },
                                )
                              : _buildInitial(), // 🚩 Si la URL es nula o vacía
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '@${template.author}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blueGrey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (template.tags.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: template.tags
                          .take(3)
                          .map((tag) => _badge(tag))
                          .toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, color: Colors.black87),
      ),
    );
  }
}
