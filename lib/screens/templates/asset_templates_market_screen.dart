import 'package:invenicum/widgets/ui/app_loading_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/core/routing/route_names.dart';
import 'package:provider/provider.dart';
import 'package:invenicum/providers/template_provider.dart';
import 'package:invenicum/data/models/asset_template_model.dart';
import 'package:invenicum/l10n/app_localizations.dart';

class _TagPalette {
  final Color background;
  final Color border;
  final Color text;
  final Color selectedBackground;
  final Color selectedBorder;
  final Color selectedText;

  const _TagPalette({
    required this.background,
    required this.border,
    required this.text,
    required this.selectedBackground,
    required this.selectedBorder,
    required this.selectedText,
  });
}

String _normalizeTagValue(String tag) => tag.trim().toLowerCase();

_TagPalette _buildTagPalette(String tag, {bool isDark = false}) {
  final normalized = _normalizeTagValue(tag);
  final hash = normalized.hashCode.abs();
  final hue = (hash % 360).toDouble();

  final baseColor = HSVColor.fromAHSV(1, hue, 0.62, 0.78).toColor();
  final baseHsl = HSLColor.fromColor(baseColor);

  return _TagPalette(
    background: baseColor.withValues(alpha: 0.12),
    border: baseColor.withValues(alpha: 0.34),
    text: isDark
        ? baseHsl.withLightness(0.7).toColor()
        : baseHsl.withLightness(0.28).toColor(),
    selectedBackground: baseColor.withValues(alpha: 0.24),
    selectedBorder: baseColor.withValues(alpha: 0.60),
    selectedText: isDark
        ? baseHsl.withLightness(0.85).toColor()
        : baseHsl.withLightness(0.22).toColor(),
  );
}

class AssetTemplatesMarketScreen extends StatefulWidget {
  const AssetTemplatesMarketScreen({super.key});

  @override
  State<AssetTemplatesMarketScreen> createState() =>
      _AssetTemplatesMarketScreenState();
}

class _AssetTemplatesMarketScreenState
    extends State<AssetTemplatesMarketScreen> {
  final List<String> _selectedTags = [];
  bool _matchAllSelectedTags = true;
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  String _normalizeTag(String tag) => _normalizeTagValue(tag);

  bool _isTagSelected(String tag) {
    final normalized = _normalizeTag(tag);
    return _selectedTags.any(
      (selected) => _normalizeTag(selected) == normalized,
    );
  }

  void _addTagFilter(String tag) {
    if (!_isTagSelected(tag)) {
      setState(() => _selectedTags.add(tag));
    }
  }

  Future<void> _openTagSearchSheet(List<String> availableTags) async {
    final l10n = AppLocalizations.of(context)!;
    String localQuery = '';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setModalState) {
            final filteredTags = availableTags.where((tag) {
              if (_isTagSelected(tag)) return false;
              if (localQuery.trim().isEmpty) return true;
              return _normalizeTag(tag).contains(_normalizeTag(localQuery));
            }).toList();

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 8,
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 520),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.filterByTagTooltip,
                        style: Theme.of(sheetContext).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        autofocus: true,
                        onChanged: (value) {
                          setModalState(() {
                            localQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Buscar tag...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: filteredTags.isEmpty
                            ? Center(
                                child: Text(
                                  l10n.noMoreTags,
                                  style: TextStyle(
                                    color: Theme.of(
                                      sheetContext,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              )
                            : ListView.separated(
                                itemCount: filteredTags.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 6),
                                itemBuilder: (context, index) {
                                  final tag = filteredTags[index];
                                  final palette = _buildTagPalette(tag, isDark: Theme.of(sheetContext).brightness == Brightness.dark);

                                  return Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(10),
                                      onTap: () {
                                        _addTagFilter(tag);
                                        setModalState(() {});
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: palette.background,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: palette.border,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.tag_rounded,
                                              size: 16,
                                              color: palette.text,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                tag,
                                                style: TextStyle(
                                                  color: palette.text,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
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
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTagSelectorButton(List<String> availableTags) {
    final l10n = AppLocalizations.of(context)!;

    return IconButton(
      icon: Icon(
        Icons.style_rounded,
        size: 22,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
      ),
      tooltip: l10n.filterByTagTooltip,
      onPressed: () => _openTagSearchSheet(availableTags),
    );
  }

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
    final normalizedQuery = searchQuery.trim().toLowerCase();
    final normalizedSelectedTags = _selectedTags
        .map(_normalizeTag)
        .where((tag) => tag.isNotEmpty)
        .toList();

    return templates.where((t) {
      // Filtro por nombre (ignora mayúsculas/minúsculas)
      final matchesName = t.name.toLowerCase().contains(normalizedQuery);

      final templateTags = t.tags.map(_normalizeTag).toSet();

      // Filtro por etiquetas (debe tener todas las seleccionadas)
      final matchesTags =
          normalizedSelectedTags.isEmpty ||
          (_matchAllSelectedTags
              ? normalizedSelectedTags.every(
                  (tag) => templateTags.contains(tag),
                )
              : normalizedSelectedTags.any(
                  (tag) => templateTags.contains(tag),
                ));

      return matchesName && matchesTags;
    }).toList();
  }

  // 🚩 Obtener etiquetas disponibles
  List<String> _getAvailableTags(List<AssetTemplate> templates) {
    final tagsByNormalized = <String, String>{};
    for (final tag in templates.expand((t) => t.tags)) {
      final normalized = _normalizeTag(tag);
      if (normalized.isEmpty) continue;
      tagsByNormalized.putIfAbsent(normalized, () => tag.trim());
    }

    final selectedNormalized = _selectedTags.map(_normalizeTag).toSet();
    final available = tagsByNormalized.entries
        .where((entry) => !selectedNormalized.contains(entry.key))
        .map((entry) => entry.value)
        .toList();
    available.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return available;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color lightenForDark(Color c) {
      if (!isDark) return c;
      final hsl = HSLColor.fromColor(c);
      return hsl.lightness < 0.5 ? hsl.withLightness(0.55).toColor() : c;
    }

    final marketAccent = lightenForDark(Colors.indigo);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 700;
    final isTablet = screenWidth >= 700 && screenWidth < 1100;
    // 🚩 Escuchamos los cambios en el provider
    final templateProvider = context.watch<TemplateProvider>();
    final templates = templateProvider.marketTemplates;
    final filteredTemplates = _getFilteredTemplates(templates);
    return Scaffold(
      body: Column(
        children: [
          _buildMarketHeader(
            context,
            templateProvider,
            templates,
            isMobile: isMobile,
            isTablet: isTablet,
            marketAccent: marketAccent,
            isDark: isDark,
          ),
          Expanded(
            child: _buildBody(
              templateProvider,
              filteredTemplates,
              availableWidth: screenWidth,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.goNamed(RouteNames.templateCreate),
        icon: Icon(Icons.add_to_photos, color: marketAccent),
        label: Text(l10n.publishTemplateLabel),
      ),
    );
  }

  Widget _buildBody(
    TemplateProvider provider,
    List<AssetTemplate> templates, {
    required double availableWidth,
  }) {
    final l10n = AppLocalizations.of(context)!;
    // 1. Estado de carga
    if (provider.isLoading) {
      return const Center(child: AppLoadingIndicator());
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
              child: Text(l10n.retryLabel),
            ),
          ],
        ),
      );
    }

    // 3. Estado vacío
    if (templates.isEmpty) {
      return Center(child: Text(l10n.noTemplatesFoundInMarket));
    }

    final gridPadding = availableWidth < 700 ? 12.0 : 16.0;
    final crossAxisCount = availableWidth < 700
        ? 1
        : (availableWidth < 1050 ? 2 : (availableWidth < 1500 ? 3 : 4));
    final childAspectRatio = crossAxisCount == 1
        ? 2.0
        : (crossAxisCount == 2 ? 1.05 : 0.82);

    // 4. Lista de plantillas (Market real)
    return GridView.builder(
      padding: EdgeInsets.all(gridPadding),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        return _TemplateCard(
          key: ValueKey(templates[index].id),
          template: templates[index],
          selectedTags: _selectedTags,
          onTagTap: _addTagFilter,
        );
      },
    );
  }

  Widget _buildMarketHeader(
    BuildContext context,
    TemplateProvider provider,
    List<AssetTemplate> templates, {
    required bool isMobile,
    required bool isTablet,
    required Color marketAccent,
    required bool isDark,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final availableTags = _getAvailableTags(templates);
    final horizontalPadding = isMobile ? 14.0 : (isTablet ? 18.0 : 24.0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        isMobile ? 24 : 40,
        horizontalPadding,
        isMobile ? 20 : 32,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.4),
            Theme.of(context).colorScheme.surface,
          ],
        ),
      ),
      child: Column(
        children: [
          // --- CAPA DE TÍTULO Y RECARGA ---
          if (isMobile)
            Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => provider.fetchMarketTemplates(),
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: marketAccent,
                    ),
                    tooltip: l10n.refreshMarketTooltip,
                  ),
                ),
                Icon(Icons.hub_rounded, size: 34, color: marketAccent),
                const SizedBox(height: 8),
                Text(
                  l10n.invenicumCommunity,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                    color: marketAccent,
                  ),
                ),
              ],
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.hub_rounded,
                        size: 40,
                        color: marketAccent,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.invenicumCommunity,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                              color: marketAccent,
                            ),
                      ),
                    ],
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: IconButton(
                      onPressed: () => provider.fetchMarketTemplates(),
                      icon: Icon(
                        Icons.refresh_rounded,
                        color: marketAccent,
                      ),
                      tooltip: l10n.refreshMarketTooltip,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 12),
          Text(
            l10n.exploreCommunityConfigurations,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 24),

          // --- BUSCADOR HÍBRIDO (Nombre + Tags) ---
          _buildModernSearchBar(
            availableTags,
            isMobile: isMobile,
            marketAccent: marketAccent,
            isDark: isDark,
          ),

          const SizedBox(height: 16),

          // --- CHIPS CENTRADOS ---
          _buildActiveFiltersChips(isDark: isDark),
        ],
      ),
    );
  }

  Widget _buildModernSearchBar(
    List<String> availableTags, {
    required bool isMobile,
    required Color marketAccent,
    required bool isDark,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      constraints: BoxConstraints(minHeight: isMobile ? 90 : 54),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 8),
                    Icon(
                      Icons.search_rounded,
                      color: marketAccent,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) =>
                            setState(() => searchQuery = value),
                        style: TextStyle(fontSize: 15, color: theme.colorScheme.onSurface),
                        decoration: InputDecoration(
                          hintText: l10n.searchByTemplateName,
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildTagSelectorButton(availableTags),
                      if (searchQuery.isNotEmpty || _selectedTags.isNotEmpty)
                        IconButton(
                          icon: const Icon(
                            Icons.clear_rounded,
                            size: 18,
                            color: Colors.redAccent,
                          ),
                          onPressed: () {
                            setState(() {
                              searchQuery = "";
                              _selectedTags.clear();
                              _searchController.clear();
                            });
                          },
                        )
                      else
                        const SizedBox(width: 4),
                    ],
                  ),
                ),
              ],
            )
          : Row(
              children: [
                const SizedBox(width: 18),
                Icon(
                  Icons.search_rounded,
                  color: marketAccent,
                  size: 22,
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => searchQuery = value),
                    style: TextStyle(fontSize: 15, color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: l10n.searchByTemplateName,
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                      isDense: true,
                    ),
                  ),
                ),

                Container(
                  height: 24,
                  width: 1,
                  color: theme.colorScheme.outlineVariant,
                ),

                _buildTagSelectorButton(availableTags),

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
                          _searchController.clear();
                        });
                      },
                    ),
                  )
                else
                  const SizedBox(width: 12),
              ],
            ),
    );
  }

  Widget _buildActiveFiltersChips({bool isDark = false}) {
    final showLogicToggle = _selectedTags.length > 1;

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
              child: Column(
                children: [
                  if (showLogicToggle)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment<bool>(
                            value: true,
                            label: Text('AND'),
                            icon: Icon(Icons.join_full_rounded, size: 16),
                          ),
                          ButtonSegment<bool>(
                            value: false,
                            label: Text('OR'),
                            icon: Icon(Icons.call_split_rounded, size: 16),
                          ),
                        ],
                        selected: {_matchAllSelectedTags},
                        showSelectedIcon: false,
                        onSelectionChanged: (newSelection) {
                          setState(() {
                            _matchAllSelectedTags = newSelection.first;
                          });
                        },
                      ),
                    ),
                  Wrap(
                    spacing: 8, // Espacio horizontal entre chips
                    runSpacing: 8, // Espacio vertical si saltan de línea
                    alignment: WrapAlignment.center,
                    children: _selectedTags.map((tag) {
                      final palette = _buildTagPalette(tag, isDark: isDark);
                      return RawChip(
                        label: Text(
                          tag,
                          style: TextStyle(
                            color: palette.text,
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
                        backgroundColor: palette.background,
                        selectedColor: palette.selectedBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: palette.border, width: 1),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final AssetTemplate template;
  final List<String> selectedTags;
  final ValueChanged<String> onTagTap;

  const _TemplateCard({
    super.key,
    required this.template,
    required this.selectedTags,
    required this.onTagTap,
  });

  String _normalizeTag(String tag) => _normalizeTagValue(tag);

  bool _isSelected(String tag) {
    final normalized = _normalizeTag(tag);
    return selectedTags.any(
      (selected) => _normalizeTag(selected) == normalized,
    );
  }

  // Helper para no repetir código
  Widget _buildInitial(ThemeData theme) {
    return Text(
      template.author.isNotEmpty ? template.author[0].toUpperCase() : '?',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color lightenForDark(Color c) {
      if (!isDark) return c;
      final hsl = HSLColor.fromColor(c);
      return hsl.lightness < 0.5 ? hsl.withLightness(0.55).toColor() : c;
    }

    final indigo = lightenForDark(Colors.indigo);
    final teal = lightenForDark(Colors.teal);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: () {
          context.goNamed(
            RouteNames.templateDetail,
            pathParameters: {'templateId': template.id},
            extra: template,
          );
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
                        ? indigo.withValues(alpha: 0.1)
                        : teal.withValues(alpha: 0.1),
                    child: Center(
                      child: Icon(
                        template.isOfficial
                            ? Icons.verified_user
                            : Icons.copy_all,
                        size: 40,
                        color: template.isOfficial
                            ? indigo
                            : teal,
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
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.file_download_outlined,
                            color: theme.colorScheme.surface,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${template.downloadCount}',
                            style: TextStyle(
                              color: theme.colorScheme.surface,
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
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (template.isOfficial)
                        Icon(
                          Icons.verified,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: theme.colorScheme.primaryContainer,
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
                                    if (kDebugMode) {
                                      debugPrint(
                                      "Avatar load error ${template.id}: $error",
                                    );
                                    }
                                    return _buildInitial(theme);
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return const Center(
                                          child: SizedBox(
                                            width: 15,
                                            height: 15,
                                            child: AppLoadingIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        );
                                      },
                                )
                              : _buildInitial(theme), // 🚩 Si la URL es nula o vacía
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '@${template.author}',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
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
                          .map(
                            (tag) => _badge(
                              tag,
                              isSelected: _isSelected(tag),
                              onTap: () => onTagTap(tag),
                              isDark: isDark,
                            ),
                          )
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

  Widget _badge(
    String text, {
    required bool isSelected,
    required VoidCallback onTap,
    bool isDark = false,
  }) {
    final palette = _buildTagPalette(text, isDark: isDark);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: isSelected ? palette.selectedBackground : palette.background,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isSelected ? palette.selectedBorder : palette.border,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? palette.selectedText : palette.text,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
