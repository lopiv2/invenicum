import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:invenicum/data/models/store_plugin_model.dart';
import 'package:invenicum/providers/plugin_provider.dart';
import 'package:invenicum/screens/plugins/local_widgets/plugin_editor_dialog.dart';
import 'package:invenicum/screens/plugins/local_widgets/plugin_modern_card.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/widgets/ui/under_construction_overlay.dart';
import 'package:provider/provider.dart';

class PluginAdminScreen extends StatefulWidget {
  const PluginAdminScreen({super.key});

  @override
  State<PluginAdminScreen> createState() => _PluginAdminScreenState();
}

class _PluginAdminScreenState extends State<PluginAdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final bool _showUnderConstruction = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _refresh();
  }

  void _refresh() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PluginProvider>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                expandedHeight: 140.0,
                floating: true,
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsetsDirectional.only(
                    start: 20,
                    bottom: 95,
                  ),
                  title: Text(
                    l10n.plugins,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w900,
                      fontSize: 26,
                    ),
                  ),
                  background: Container(color: Colors.white),
                ),
                actions: [
                  IconButton(
                    onPressed: _refresh,
                    icon: const Icon(Icons.sync_rounded),
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(70),
                  child: _buildModernTabBar(colorScheme),
                ),
              ),
            ],
            body: Consumer<PluginProvider>(
              builder: (context, provider, _) {
                // 🚩 Cambiamos provider.installed.isEmpty por la lógica de tipos
                if (provider.isLoading && provider.installed.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _PluginGrid(
                      plugins: provider.installedFromStore,
                      type: 'library',
                    ),
                    _PluginGrid(
                      plugins: provider.myCreatedPlugins,
                      type: 'mine',
                    ),
                    _PluginGrid(plugins: provider.community, type: 'market'),
                  ],
                );
              },
            ),
          ),
          if (_showUnderConstruction)
            Positioned.fill(
              child: AbsorbPointer(child: const UnderConstructionOverlay()),
            ),
        ],
      ),
      floatingActionButton: _showUnderConstruction
        ? const SizedBox.shrink()
        : FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => const PluginEditorDialog(),
        ),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.newPluginLabel),
      ).animate().scale(delay: 300.ms, curve: Curves.bounceInOut),
    );
  }

  Widget _buildModernTabBar(ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: [
          Tab(text: l10n.pluginTabLibrary),
          Tab(text: l10n.pluginTabMine),
          Tab(text: l10n.pluginTabMarket),
        ],
      ),
    );
  }
}

class _PluginGrid extends StatelessWidget {
  // 🚩 CORRECCIÓN: Cambiamos de List<Map> a List<StorePlugin>
  final List<StorePlugin> plugins;
  final String type;

  const _PluginGrid({required this.plugins, required this.type});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (plugins.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.extension_off_rounded,
              size: 60,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noPluginsAvailable,
              style: TextStyle(color: Colors.grey.shade400),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:
            4, // 🚩 Lo he vuelto a poner en 2 para que se vean bien las tarjetas
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.55,
        mainAxisExtent:
            240, // 🚩 Aumentado un poco para evitar overflow de texto
      ),
      itemCount: plugins.length,
      itemBuilder: (context, index) {
        return ModernPluginCard(
              plugin: plugins[index], // 🚩 Ahora pasa un objeto StorePlugin
              isMarket: type == 'market',
            )
            .animate()
            .fadeIn(delay: (index * 30).ms)
            .scale(begin: const Offset(0.9, 0.9));
      },
    );
  }
}
