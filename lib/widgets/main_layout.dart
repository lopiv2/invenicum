// lib/widgets/main_layout.dart

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/providers/alert_provider.dart';
import 'package:invenicum/providers/auth_provider.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/providers/container_provider.dart';
import 'package:invenicum/providers/inventory_item_provider.dart';
import 'package:invenicum/providers/loan_provider.dart';
import 'package:invenicum/providers/preferences_provider.dart';
import 'package:invenicum/widgets/chatbot_veni_widget.dart';
import 'package:invenicum/widgets/pulsing_avatar_widget.dart';
import 'package:invenicum/widgets/ringing_bell_widget.dart';
import 'package:invenicum/widgets/search_bar_widget.dart';
import 'package:invenicum/widgets/sidebar_layout.dart';
import 'package:invenicum/widgets/stac_slot.dart';
import 'package:provider/provider.dart';
import 'package:random_avatar/random_avatar.dart';

class MainLayout extends StatefulWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

// lib/widgets/main_layout.dart

class _MainLayoutState extends State<MainLayout> {
  bool _isChatOpen = false;
  bool _isSidebarVisible = true;
  late Offset _veniPosition;
  bool _isInitialized = false;
  bool _isAnimating = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final size = MediaQuery.of(context).size;
      // Posición inicial segura: un poco alejada de los bordes (bottom-right)
      _veniPosition = Offset(size.width - 60, size.height - 20);
      _isInitialized = true;
    }
  }

  @override
  void initState() {
    super.initState();
    // Ejecutamos la carga inicial después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hydrateStateFromUrl();
      context.read<AlertProvider>().loadAlerts();
    });
  }

  Future<void> _hydrateStateFromUrl() async {
    if (!mounted) return;

    final String location = GoRouterState.of(context).uri.toString();
    final match = RegExp(r'/container/(\d+)').firstMatch(location);

    if (match != null) {
      final int containerId = int.parse(match.group(1)!);
      final containerProvider = context.read<ContainerProvider>();
      final loanProvider = context.read<LoanProvider>();
      final itemProvider = context.read<InventoryItemProvider>();

      // 3. 🛡️ Si la lista está vacía, ESPERAMOS a que cargue
      if (containerProvider.containers.isEmpty) {
        await containerProvider.loadContainers();
      }

      if (!mounted) return;

      // 4. Buscamos de forma segura (sin que explote si no existe)
      final container = containerProvider.containers.firstWhereOrNull(
        (c) => c.id == containerId,
      );

      if (container != null) {
        // Carga de datos para Sidebar (listas personalizadas + préstamos)
        await Future.wait([
          containerProvider.loadDataLists(containerId),
          loanProvider.fetchLoans(containerId),
        ]);

        // Carga de datos para la cuadrícula de tipos de activos (Grid)
        if (location.contains('/asset-types')) {
          for (var assetType in container.assetTypes) {
            itemProvider.loadInventoryItems(
              containerId: containerId,
              assetTypeId: assetType.id,
            );
          }
        }
      } else {
        print(
          "⚠️ Hidratación: El contenedor $containerId no se encontró tras la carga.",
        );
      }
    }
  }

  void _handleToggleSidebar() {
    setState(() {
      _isSidebarVisible = !_isSidebarVisible;
      _isAnimating = true; // Empieza la animación
    });

    // Duración coincidente con la del AnimatedContainer (300ms)
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _isAnimating = false); // Termina la animación
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final aiEnabled = context.watch<PreferencesProvider>().aiEnabled;
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    final showFAB = aiEnabled && !_isChatOpen;
    final showChat = aiEnabled && _isChatOpen;

    return Scaffold(
      body: Stack(
        children: [
          _buildBaseApp(context),

          // Usamos un solo Positioned para el "Contenedor de Veni"
          // Importante: No le damos ancho/alto fijo aquí para que no bloquee la pantalla
          Positioned(
            right: size.width - _veniPosition.dx,
            bottom: size.height - _veniPosition.dy,
            child: Stack(
              clipBehavior: Clip.none,
              // Alineamos al centro para que la expansión del chat sea simétrica
              // o mantén bottomRight si prefieres que crezca hacia arriba/izquierda
              alignment: Alignment.bottomRight,
              children: [
                // 1. EL CHAT (Se dibuja primero para que el botón pueda estar encima si coinciden)
                IgnorePointer(
                  ignoring: !showChat,
                  child: AnimatedScale(
                    scale: showChat ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutBack,
                    // Alineamos el crecimiento desde donde estaría el botón
                    alignment: Alignment.bottomRight,
                    child: AnimatedOpacity(
                      opacity: showChat ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Material(
                        elevation: 12,
                        borderRadius: BorderRadius.circular(24),
                        child: VeniChatbot(
                          initialPath: GoRouterState.of(context).uri.toString(),
                          onClose: () => setState(() => _isChatOpen = false),
                          onDrag: (delta) {
                            setState(() {
                              _veniPosition += delta;
                              // Ajustamos los límites para que el chat no se salga por ARRIBA (600px)
                              _veniPosition = Offset(
                                _veniPosition.dx.clamp(400.0, size.width),
                                _veniPosition.dy.clamp(600.0, size.height),
                              );
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                // 2. EL BOTÓN
                IgnorePointer(
                  ignoring: !showFAB,
                  child: AnimatedScale(
                    scale: showFAB ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutBack,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          _veniPosition += details.delta;
                          // Limites para el BOTÓN (aprox 120 ancho x 50 alto)
                          _veniPosition = Offset(
                            _veniPosition.dx.clamp(0.0, size.width - 20),
                            _veniPosition.dy.clamp(0.0, size.height - 6),
                          );
                        });
                      },
                      child: FloatingActionButton.extended(
                        heroTag: 'veni_fab_unique',
                        onPressed: () => setState(() => _isChatOpen = true),
                        label: const Text('Veni'),
                        icon: const Icon(Icons.auto_awesome_rounded),
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Método auxiliar para limpiar el build
  Widget _buildBaseApp(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        _Header(
          isSidebarVisible: _isSidebarVisible,
          onToggleSidebar: () => setState(() => _handleToggleSidebar()),
        ),
        Expanded(
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: _isSidebarVisible ? 250 : 0,
                child: OverflowBox(
                  // Evita que los hijos intenten recalcularse por falta de espacio
                  minWidth: 250,
                  maxWidth: 250,
                  alignment: Alignment.centerLeft,
                  child: const SidebarLayout(),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? colorScheme.surface
                        : colorScheme.surfaceContainerLowest,
                  ),
                  child: _isAnimating
                      ? const Center(child: CircularProgressIndicator())
                      : widget.child,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Header extends StatefulWidget {
  final bool isSidebarVisible;
  final VoidCallback onToggleSidebar;
  const _Header({
    required this.isSidebarVisible,
    required this.onToggleSidebar,
  });

  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final String avatarSeed = user?.name ?? l10n?.guest ?? 'Guest';

    return Container(
      height: 64, // Un poco más delgado para un look más Pro
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          IconButton(
            onPressed: widget.onToggleSidebar,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                widget.isSidebarVisible
                    ? Icons.menu_open_rounded
                    : Icons.menu_rounded,
                key: ValueKey(widget.isSidebarVisible),
                color: colorScheme.primary,
              ),
            ),
            tooltip: 'Menu',
          ),
          // Logo Minimalista
          _buildLogo(colorScheme, isDarkMode),

          SizedBox(width: MediaQuery.of(context).size.width * 0.025),

          // Barra de búsqueda con autocompletado
          const Expanded(flex: 3, child: InvenicumSearchBar()),
          const Spacer(),
          const StacSlot(slotName: 'inventory_header'),
          const Spacer(),

          // Perfil de Usuario
          Consumer<AlertProvider>(
            // 🚩 Escuchamos el AlertProvider
            builder: (context, alertProvider, child) {
              final int unread = alertProvider.unreadCount;
              return PulsingAvatar(
                isActive: unread > 0,
                child: Badge.count(
                  count: unread,
                  isLabelVisible: unread > 0,
                  offset: const Offset(
                    -35,
                    0,
                  ), // Ajusta la posición sobre el avatar
                  backgroundColor: Colors.redAccent,
                  child: PopupMenuButton<String>(
                    offset: const Offset(0, 48),
                    borderRadius: BorderRadius.circular(16),
                    elevation: 8,
                    onSelected: (value) async {
                      if (value == 'alerts') {
                        context.go('/alerts');
                      }
                      if (value == 'logout') {
                        context.read<InventoryItemProvider>().resetState();
                        await context.read<AuthProvider>().logout();
                        if (context.mounted) context.go('/login');
                      } else if (value == 'settings') {
                        context.go('/preferences');
                      } else if (value == 'profile') {
                        context.go('/myprofile');
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.primary.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child:
                            user?.avatarUrl != null &&
                                user!.avatarUrl!.isNotEmpty
                            ? Image.network(
                                user.avatarUrl!,
                                width: 38,
                                height: 38,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    RandomAvatar(
                                      avatarSeed,
                                      width: 38,
                                      height: 38,
                                    ),
                              )
                            : RandomAvatar(avatarSeed, width: 38, height: 38),
                      ),
                    ),
                    itemBuilder: (context) => [
                      if (unread > 0) ...[
                        _buildPopupItem(
                          'alerts',
                          // En lugar de pasar solo un IconData, personalizamos el icono con animación
                          Icons.notifications_active_outlined,
                          '${l10n?.alerts ?? 'Alertas'} ($unread)',
                          isHighlight: true,
                          leadingWidget: RingingBell(isActive: unread > 0),
                        ),
                        const PopupMenuDivider(),
                      ],
                      _buildPopupItem(
                        'profile',
                        Icons.person_outline_rounded,
                        l10n?.myProfile ?? 'Profile',
                      ),
                      _buildPopupItem(
                        'settings',
                        Icons.settings_outlined,
                        l10n?.settings ?? 'Settings',
                      ),
                      const PopupMenuDivider(),
                      _buildPopupItem(
                        'logout',
                        Icons.logout_rounded,
                        l10n?.logout ?? 'Logout',
                        isDestructive: true,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(ColorScheme colorScheme, bool isDarkMode) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 190,
          height: 80,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: Image.asset(
            'assets/images/invenicum_logo.png',
            fit: BoxFit.contain,
            scale: 1.8,
            alignment: Alignment.center,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Text(
                  'Invenicum',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                    fontSize: 14,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupItem(
    String value,
    IconData icon,
    String text, {
    bool isDestructive = false,
    bool isHighlight = false,
    Widget? leadingWidget,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          leadingWidget ??
              Icon(
                icon,
                size: 20,
                color: isDestructive
                    ? Colors.redAccent
                    : (isHighlight ? Colors.orange.shade700 : null),
              ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(color: isDestructive ? Colors.redAccent : null),
          ),
        ],
      ),
    );
  }
}
