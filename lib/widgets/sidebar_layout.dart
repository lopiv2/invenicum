import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invenicum/widgets/sidebar_container_header.dart';
import 'package:invenicum/widgets/sidebar_nav_button.dart';
import 'package:invenicum/widgets/sidebar_tree_section.dart';

import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/widgets/stac_slot.dart';

class SidebarLayout extends StatelessWidget {
  const SidebarLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final String location = GoRouterState.of(context).uri.toString();

    return Container(
      width: 260,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colorScheme.surface, colorScheme.primary.withOpacity(0.05)],
        ),
        border: Border(
          right: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.4)),
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            // --- PARTE SUPERIOR ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SidebarNavButton(
                  icon: Icons.dashboard_customize_outlined,
                  title: AppLocalizations.of(context)!.dashboard,
                  selected: location == '/dashboard',
                  onTap: () => context.go('/dashboard'),
                ),
              ),
            ),

            // --- SECCIÓN DE CONTENEDORES (CABECERA) ---
            const SidebarContainerHeader(),

            // --- CUERPO DINÁMICO (ÁRBOL) ---
            const SidebarTreeSection(),

            // --- FOOTER (UTILIDADES) ---
            // 3. SECCIONES NUEVAS (A continuación del árbol)
            SliverList(
              delegate: SliverChildListDelegate([
                const Divider(indent: 16, endIndent: 16), // Separador visual
                const StacSlot(slotName: 'left_sidebar'), // Slot para plugins en la barra lateral
                SidebarNavButton(
                  icon: Icons
                      .integration_instructions_outlined, // Icono representativo de integraciones
                  title: AppLocalizations.of(context)!.integrations,
                  selected:
                      GoRouterState.of(context).matchedLocation ==
                      '/integrations',
                  onTap: () => context.go('/integrations'),
                ),
                SidebarNavButton(
                  icon: Icons.layers, // Icono representativo de integraciones
                  title: AppLocalizations.of(context)!.templates,
                  selected:
                      GoRouterState.of(context).matchedLocation ==
                      '/templates',
                  onTap: () => context.go('/templates'),
                ),
                SidebarNavButton(
                  icon: Icons
                      .extension_outlined, // Icono representativo de plugins
                  title: AppLocalizations.of(context)!.plugins,
                  selected:
                      GoRouterState.of(context).matchedLocation ==
                      '/plugins-admin',
                  onTap: () => context.go('/plugins-admin'),
                ),
                SidebarNavButton(
                  icon: Icons.notifications_none_rounded,
                  title: AppLocalizations.of(context)!.alerts,
                  selected: location == '/alerts',
                  onTap: () => context.go('/alerts'),
                  compact: true,
                ),
                SidebarNavButton(
                  icon: Icons.settings_outlined,
                  title: AppLocalizations.of(context)!.preferences,
                  selected: location == '/preferences',
                  onTap: () => context.go('/preferences'),
                ),

                const SizedBox(height: 20), // Espacio final
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
