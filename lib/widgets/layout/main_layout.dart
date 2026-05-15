// lib/widgets/main_layout.dart

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/providers/alert_provider.dart';
import 'package:invenicum/providers/container_provider.dart';
import 'package:invenicum/providers/inventory_item_provider.dart';
import 'package:invenicum/providers/loan_provider.dart';
import 'package:invenicum/providers/preferences_provider.dart';
import 'package:invenicum/core/utils/constants.dart';
import 'package:invenicum/core/utils/retro/retro_theme_extension.dart';
import 'package:invenicum/screens/home/local_widgets/chatbot_veni_widget.dart';
import 'package:invenicum/widgets/layout/sidebar_layout.dart';
import 'package:invenicum/widgets/layout/main_header.dart';
import 'package:invenicum/widgets/layout/floating_overlay_image.dart';
import 'package:provider/provider.dart';

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
      // Safe initial position: slightly away from the edges (bottom-right)
      _veniPosition = Offset(size.width - 60, size.height - 20);
      _isInitialized = true;
    }
  }

  @override
  void initState() {
    super.initState();
    // Run initial load after the first frame
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

      // 3. 🛡️ If the list is empty, WAIT for it to load
      if (containerProvider.containers.isEmpty) {
        await containerProvider.loadContainers();
      }

      if (!mounted) return;

      // 4. We search safely (without throwing if it doesn't exist)
      final container = containerProvider.containers.firstWhereOrNull(
        (c) => c.id == containerId,
      );

      if (container != null) {
        // Load data for Sidebar (custom lists + loans)
        await Future.wait([
          containerProvider.loadDataLists(containerId),
          loanProvider.fetchLoans(containerId),
        ]);

        // Load data for the asset types grid
        if (location.contains('/asset-types')) {
          for (var assetType in container.assetTypes) {
            itemProvider.loadInventoryItems(
              containerId: containerId,
              assetTypeId: assetType.id,
            );
          }
        }
      } else {
        if (kDebugMode) {
          debugPrint(
            " Hydration: Container $containerId was not found after loading.",
          );
        }
      }
    }
  }

  void _handleToggleSidebar() {
    setState(() {
      _isSidebarVisible = !_isSidebarVisible;
      _isAnimating = true; // Start the animation
    });

    // Duration matches the AnimatedContainer (300ms)
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _isAnimating = false); // End the animation
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final aiEnabled = context.watch<PreferencesProvider>().aiEnabled;
    final colorScheme = Theme.of(context).colorScheme;
    final retroTheme = Theme.of(context).extension<RetroThemeExtension>()?.retro;
    final size = MediaQuery.of(context).size;

    final showFAB = aiEnabled && !_isChatOpen;
    final showChat = aiEnabled && _isChatOpen;

    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          _buildBaseApp(context),

          // Overlay image (collectibles) that floats across the screen randomly
          // Add entries to AppOverlayImages.defaultImages in constants.dart
          FloatingOverlayImage(
            configs: AppOverlayImages.defaultImages,
          ),

          // Use a single Positioned for the "Veni" container
          // Important: Do not give fixed width/height here so it doesn't block the screen
          Positioned(
            right: size.width - _veniPosition.dx,
            bottom: size.height - _veniPosition.dy,
            child: Stack(
              clipBehavior: Clip.none,
              // Align center so the chat expansion is symmetrical
              // or keep bottomRight if you prefer it to grow upwards/leftwards
              alignment: Alignment.bottomRight,
              children: [
                // 1. THE CHAT (drawn first so the button can sit on top if overlapping)
                IgnorePointer(
                  ignoring: !showChat,
                  child: AnimatedScale(
                    scale: showChat ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutBack,
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
                              // Adjust limits so the chat doesn't go off the TOP (600px)
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

                // 2. THE BUTTON
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
                          // Limits for the BUTTON (approx 120 width x 50 height)
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
                        backgroundColor: retroTheme?.buttonOk ?? colorScheme.primary,
                        foregroundColor: retroTheme != null ? Colors.black : colorScheme.onPrimary,
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

  // Helper method to keep the build clean
  Widget _buildBaseApp(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        MainHeader(
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
                  // Prevents children from trying to re-layout due to lack of space
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
