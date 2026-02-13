// lib/widgets/main_layout.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/providers/auth_provider.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/providers/inventory_item_provider.dart';
import 'package:invenicum/widgets/chatbot_veni_widget.dart';
import 'package:invenicum/widgets/search_bar_widget.dart';
import 'package:invenicum/widgets/sidebar_layout.dart';
import 'package:invenicum/widgets/stac_slot.dart';
import 'package:provider/provider.dart';
import 'package:random_avatar/random_avatar.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      // FAB Modernizado
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end, // Alineados a la derecha
        children: [
          // Slot para botones dinámicos (Stac)
          const StacSlot(slotName: 'floating_action_button'),

          // Espacio entre el botón dinámico y el tuyo
          const SizedBox(height: 12),

          FloatingActionButton.extended(
            onPressed: () => _showChatbot(context),
            label: Text(AppLocalizations.of(context)?.veniChatTitle ?? 'Veni'),
            icon: const Icon(Icons.auto_awesome_rounded, size: 20),
            elevation: 4,
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
          ),
        ],
      ),

      body: Column(
        children: [
          const _Header(),
          Expanded(
            child: Row(
              children: [
                const SidebarLayout(),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? colorScheme.surface
                          : colorScheme
                                .surfaceContainerLowest, // Fondo más limpio
                    ),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showChatbot(BuildContext context) {
    final String currentPath = GoRouterState.of(context).uri.toString();

    showDialog(
      context: context,
      barrierColor: Colors.black12,
      builder: (context) => Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 20, bottom: 90),
          child: Material(
            elevation: 12,
            borderRadius: BorderRadius.circular(24),
            child: VeniChatbot(initialPath: currentPath),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatefulWidget {
  const _Header();

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

    // FIX: Evitamos el "Unexpected null value" con un fallback seguro
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
          // Logo Minimalista
          _buildLogo(colorScheme, isDarkMode),

          SizedBox(width: MediaQuery.of(context).size.width * 0.025),

          // Barra de búsqueda con autocompletado
          const Expanded(flex: 3, child: InvenicumSearchBar()),
          const Spacer(),
          const StacSlot(slotName: 'inventory_header'),
          const Spacer(),

          // Perfil de Usuario
          PopupMenuButton<String>(
            offset: const Offset(0, 48),
            borderRadius: BorderRadius.circular(16),
            elevation: 8,
            onSelected: (value) async {
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
                child: user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
                    ? Image.network(
                        user.avatarUrl!,
                        width: 38,
                        height: 38,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            RandomAvatar(avatarSeed, width: 38, height: 38),
                      )
                    : RandomAvatar(avatarSeed, width: 38, height: 38),
              ),
            ),
            itemBuilder: (context) => [
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
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: isDestructive ? Colors.redAccent : null),
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
