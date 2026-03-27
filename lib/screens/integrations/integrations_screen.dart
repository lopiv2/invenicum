import 'package:flutter/material.dart';
import 'package:invenicum/core/utils/constants.dart';
import 'package:invenicum/providers/integrations_provider.dart';
import 'package:invenicum/screens/integrations/local_widgets/integration_config_sheet.dart';
import 'package:invenicum/screens/integrations/local_widgets/hero_orbital_art.dart';
import 'package:invenicum/screens/integrations/local_widgets/hero_pill.dart';
import 'package:invenicum/screens/integrations/local_widgets/hero_text_block.dart';
import 'package:invenicum/screens/integrations/local_widgets/integration_section.dart';
import 'package:invenicum/screens/integrations/local_widgets/integration_section_data.dart';
import 'package:provider/provider.dart';

class IntegrationsScreen extends StatefulWidget {
  const IntegrationsScreen({super.key});

  @override
  State<IntegrationsScreen> createState() => _IntegrationsScreenState();
}

class _IntegrationsScreenState extends State<IntegrationsScreen> {
  void _openConfig(BuildContext context, String integrationId) {
    final availableIntegrations = AppIntegrations.getAvailableIntegrations(
      context,
    );

    final integration = availableIntegrations.firstWhere(
      (element) => element.id == integrationId,
      orElse: () =>
          throw Exception('Integración no encontrada: $integrationId'),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      builder: (context) => IntegrationConfigSheet(integration: integration),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IntegrationProvider>().loadStatuses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final integrations = AppIntegrations.getAvailableIntegrations(context);
    final integrationProv = context.watch<IntegrationProvider>();
    final theme = Theme.of(context);

    final sections = <IntegrationSectionData>[
      IntegrationSectionData(
        title: 'Inteligencia artificial',
        subtitle:
            'Motores conversacionales y asistentes para enriquecer flujos y automatizaciones.',
        icon: Icons.auto_awesome_rounded,
        accent: const Color(0xFFE16A3D),
        integrations: integrations
            .where(
              (integration) =>
                  integration.id == AppIntegrations.gemini ||
                  integration.id == AppIntegrations.openai ||
                  integration.id == AppIntegrations.claude,
            )
            .toList(),
      ),
      IntegrationSectionData(
        title: 'Mensajería y notificaciones',
        subtitle:
            'Canales de salida para avisos, bots, reportes y entregas automáticas.',
        icon: Icons.notifications_active_outlined,
        accent: const Color(0xFF2E6F95),
        integrations: integrations
            .where(
              (integration) =>
                  integration.id == AppIntegrations.telegram ||
                  integration.id == AppIntegrations.email,
            )
            .toList(),
      ),
      IntegrationSectionData(
        title: 'APIs de datos',
        subtitle:
            'Fuentes externas para enriquecer fichas, cartas, juegos y referencias de catálogo.',
        icon: Icons.hub_outlined,
        accent: const Color(0xFF4E8B57),
        integrations: integrations
            .where(
              (integration) =>
                  integration.id == AppIntegrations.bgg ||
                  integration.id == AppIntegrations.pokemon ||
                  integration.id == AppIntegrations.tcgdex,
            )
            .toList(),
      ),
      IntegrationSectionData(
        title: 'Valoración y mercado',
        subtitle:
            'Conectores para precios, códigos de barras y estimación de valor actualizado.',
        icon: Icons.query_stats_rounded,
        accent: const Color(0xFF8B5CF6),
        integrations: integrations
            .where(
              (integration) =>
                  integration.id == AppIntegrations.priceCharting ||
                  integration.id == AppIntegrations.upcitemdb,
            )
            .toList(),
      ),
      IntegrationSectionData(
        title: 'Hardware y etiquetas',
        subtitle:
            'Herramientas físicas y utilidades para impresión, codificación y operación.',
        icon: Icons.qr_code_2_rounded,
        accent: const Color(0xFF245C4A),
        integrations: integrations
            .where((integration) => integration.id == AppIntegrations.qrLabels)
            .toList(),
      ),
    ].where((section) => section.integrations.isNotEmpty).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        title: const Text('Integraciones y conexiones'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildHero(theme, integrationProv),
                const SizedBox(height: 24),
                for (final section in sections) ...[
                  IntegrationSection(
                    section: section,
                    isLinked: integrationProv.isLinked,
                    onTap: (id) => _openConfig(context, id),
                  ),
                  const SizedBox(height: 24),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(ThemeData theme, IntegrationProvider integrationProv) {
    final connectedCount = integrationProv.statuses.values
        .where((v) => v)
        .length;
    final colorScheme = theme.colorScheme;
    final accent = colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.scrim.withValues(alpha: 0.92),
            Color.lerp(colorScheme.scrim, accent, 0.3)!.withValues(alpha: 0.85),
            accent.withValues(alpha: 0.95),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.20),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 720;
          final summary = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              HeroPill(
                icon: Icons.link_rounded,
                label: '$connectedCount conexiones activas',
              ),
              const HeroPill(
                icon: Icons.dashboard_customize_outlined,
                label: 'Diseño modular por categorías',
              ),
              HeroPill(
                icon: integrationProv.isLoading
                    ? Icons.sync_rounded
                    : Icons.verified_outlined,
                label: integrationProv.isLoading
                    ? 'Comprobando estados'
                    : 'Estado sincronizado',
              ),
            ],
          );

          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeroTextBlock(summary: summary),
                const SizedBox(height: 20),
                const HeroOrbitalArt(),
              ],
            );
          }

          return Row(
            children: [
              Expanded(flex: 6, child: HeroTextBlock(summary: summary)),
              const SizedBox(width: 20),
              const Expanded(flex: 4, child: HeroOrbitalArt()),
            ],
          );
        },
      ),
    );
  }
}
