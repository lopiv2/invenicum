import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/widgets/layout/sidebar_container_header.dart';
import 'package:invenicum/widgets/ui/sidebar_nav_button.dart';
import 'package:invenicum/widgets/layout/sidebar_tree_section.dart';
import 'package:invenicum/widgets/layout/webp_animator_version.dart';

import 'package:invenicum/config/environment.dart';
import 'package:invenicum/core/utils/constants.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/widgets/ui/stac_slot.dart';
import 'package:invenicum/core/routing/route_names.dart';

class SidebarLayout extends StatelessWidget {
  const SidebarLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: 260,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colorScheme.surface, colorScheme.primary.withValues(alpha: 0.05)],
        ),
        border: Border(
          right: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // --- PARTE SUPERIOR ---
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: SidebarNavButton(
                        icon: Icons.dashboard_customize_outlined,
                        title: AppLocalizations.of(context)!.dashboard,
                        routeName: RouteNames.dashboard,
                        onTap: () => context.goNamed(RouteNames.dashboard),
                      ),
                    ),
                  ),

                  // --- SECCIÓN DE CONTENEDORES (CABECERA) ---
                  const SidebarContainerHeader(),

                  // --- CUERPO DINÁMICO (ÁRBOL) ---
                  const SidebarTreeSection(),

                  // --- FOOTER (UTILIDADES) ---
                  SliverList(
                    delegate: SliverChildListDelegate([
                      const Divider(indent: 16, endIndent: 16),
                      SidebarNavButton(
                        icon: Icons.collections,
                        title: 'Sprite Vault™',
                        routeName: RouteNames.spriteVault,
                        onTap: () => context.goNamed(RouteNames.spriteVault),
                        customIcon: const FaIcon(FontAwesomeIcons.skull),
                      ),
                      const StacSlot(slotName: 'left_sidebar'),
                      SidebarNavButton(
                        icon: Icons.emoji_events_outlined,
                        title: l10n.myAchievements,
                        routeName: RouteNames.achievements,
                        onTap: () => context.goNamed(RouteNames.achievements),
                      ),
                      SidebarNavButton(
                        icon: Icons.integration_instructions_outlined,
                        title: AppLocalizations.of(context)!.integrations,
                        routeName: RouteNames.integrations,
                        onTap: () => context.goNamed(RouteNames.integrations),
                      ),
                      SidebarNavButton(
                        icon: Icons.layers,
                        title: AppLocalizations.of(context)!.templates,
                        routeName: RouteNames.templates,
                        onTap: () => context.goNamed(RouteNames.templates),
                      ),
                      SidebarNavButton(
                        icon: Icons.extension_outlined,
                        title: AppLocalizations.of(context)!.plugins,
                        routeName: RouteNames.plugins,
                        onTap: () => context.goNamed(RouteNames.plugins),
                      ),
                      SidebarNavButton(
                        icon: Icons.notifications_none_rounded,
                        title: AppLocalizations.of(context)!.alerts,
                        routeName: RouteNames.alerts,
                        onTap: () => context.goNamed(RouteNames.alerts),
                        compact: true,
                      ),
                      SidebarNavButton(
                        icon: Icons.description_outlined,
                        title: AppLocalizations.of(context)!.reports,
                        routeName: RouteNames.reports,
                        onTap: () => context.goNamed(RouteNames.reports),
                      ),
                      SidebarNavButton(
                        icon: Icons.settings_outlined,
                        title: AppLocalizations.of(context)!.preferences,
                        routeName: RouteNames.preferences,
                        onTap: () => context.goNamed(RouteNames.preferences),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: WebpAnimatorVersion(
                versionArt: VersionArt.findByVersion(Environment.appVersion) ??
                    VersionArt.all.last,
                appVersion: Environment.appVersion,
              ),
            ),
          ],
        ),
      ),
    );
  }
}