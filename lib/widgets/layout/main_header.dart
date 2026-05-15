import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/core/routing/route_names.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/providers/alert_provider.dart';
import 'package:invenicum/providers/auth_provider.dart';
import 'package:invenicum/providers/inventory_item_provider.dart';
import 'package:invenicum/screens/home/local_widgets/pulsing_avatar_widget.dart';
import 'package:invenicum/screens/home/local_widgets/ringing_bell_widget.dart';
import 'package:invenicum/screens/home/local_widgets/search_bar_widget.dart';
import 'package:invenicum/widgets/ui/stac_slot.dart';
import 'package:provider/provider.dart';
import 'package:random_avatar/random_avatar.dart';

class MainHeader extends StatefulWidget {
  final bool isSidebarVisible;
  final VoidCallback onToggleSidebar;

  const MainHeader({
    super.key,
    required this.isSidebarVisible,
    required this.onToggleSidebar,
  });

  @override
  State<MainHeader> createState() => _MainHeaderState();
}

class _MainHeaderState extends State<MainHeader> {
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
      height: 64,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
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
          _buildLogo(colorScheme, isDarkMode),

          SizedBox(width: MediaQuery.of(context).size.width * 0.025),

          const Expanded(flex: 3, child: InvenicumSearchBar()),
          const Spacer(),
          const StacSlot(slotName: 'inventory_header'),
          const Spacer(),

          Consumer<AlertProvider>(
            builder: (context, alertProvider, child) {
              final int unread = alertProvider.unreadCount;
              return PulsingAvatar(
                isActive: unread > 0,
                child: Badge.count(
                  count: unread,
                  isLabelVisible: unread > 0,
                  offset: const Offset(-35, 0),
                  backgroundColor: Colors.redAccent,
                  child: PopupMenuButton<String>(
                    offset: const Offset(0, 48),
                    borderRadius: BorderRadius.circular(16),
                    elevation: 8,
                    onSelected: (value) async {
                      if (value == 'alerts') {
                        context.goNamed(RouteNames.alerts);
                      }
                      if (value == 'logout') {
                        context.read<InventoryItemProvider>().resetState();
                        await context.read<AuthProvider>().logout();

                        if (context.mounted) {
                          context.goNamed(RouteNames.login);
                        }
                      } else if (value == 'settings') {
                        context.goNamed(RouteNames.preferences);
                      } else if (value == 'profile') {
                        context.goNamed(RouteNames.myProfile);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.2),
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
            isDarkMode
                ? 'assets/images/invenicum_logo_dark.png'
                : 'assets/images/invenicum_logo.png',
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
