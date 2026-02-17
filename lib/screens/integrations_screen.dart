import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:invenicum/providers/integrations_provider.dart';
import 'package:invenicum/utils/constants.dart';
import 'package:invenicum/widgets/integration_config_sheet.dart';
import 'package:provider/provider.dart';

class IntegrationsScreen extends StatefulWidget {
  const IntegrationsScreen({super.key});

  @override
  State<IntegrationsScreen> createState() => _IntegrationsScreenState();
}

class _IntegrationsScreenState extends State<IntegrationsScreen> {
  /// Abre el modal de configuración buscando el modelo por ID en las constantes
  void _openConfig(BuildContext context, String integrationId) {
    final availableIntegrations = AppIntegrations.getAvailableIntegrations(
      context,
    );

    final integration = availableIntegrations.firstWhere(
      (element) => element.id == integrationId,
      orElse: () =>
          throw Exception("Integración no encontrada: $integrationId"),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(
        context,
      ).cardColor, // Permite bordes redondeados en el sheet
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
    final integrationProv = context.watch<IntegrationProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Integraciones y Conexiones"),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          // --- INTELIGENCIA ARTIFICIAL ---
          _buildSectionHeader("Inteligencia Artificial"),
          _buildIntegrationCard(
            context,
            title: "Google Gemini",
            subtitle: "Habilita el asistente inteligente y análisis Pro.",
            icon: Icons.auto_awesome,
            iconColor: Colors.deepPurpleAccent,
            isLinked: integrationProv.isLinked(AppIntegrations.gemini),
            onTap: () => _openConfig(context, AppIntegrations.gemini),
          ),
          const SizedBox(height: 24),

          // --- MENSAJERÍA ---
          _buildSectionHeader("Mensajería y Notificaciones"),
          _buildIntegrationCard(
            context,
            title: "Telegram Bot",
            subtitle: "Configura alertas y bots de chat.",
            icon: FontAwesomeIcons.telegram,
            iconColor: const Color(0xFF26A5E4),
            isLinked: false,
            onTap: () => _openConfig(context, AppIntegrations.telegram),
          ),
          _buildIntegrationCard(
            context,
            title: "WhatsApp Business",
            subtitle: "Notificaciones oficiales de stock.",
            icon: FontAwesomeIcons.whatsapp,
            iconColor: const Color(0xFF25D366),
            isLinked: false,
            onTap: () => _openConfig(context, AppIntegrations.whatsapp),
          ),
          const SizedBox(height: 24),

          // --- E-COMMERCE ---
          _buildSectionHeader("E-Commerce & Marketplaces"),
          _buildIntegrationCard(
            context,
            title: "eBay Connector",
            subtitle: "Sincroniza stock y publica anuncios.",
            icon: FontAwesomeIcons.ebay,
            iconColor: const Color(0xFFE53238),
            isLinked: false,
            onTap: () => _openConfig(context, AppIntegrations.ebay),
          ),
          const SizedBox(height: 24),

          // --- HERRAMIENTAS ---
          _buildSectionHeader("Herramientas de Valoración"),
          _buildIntegrationCard(
            context,
            title: "PriceCharting",
            subtitle: "Historial de precios de videojuegos.",
            icon: Icons.show_chart_rounded,
            iconColor: Colors.orange,
            isLinked: false,
            onTap: () => _openConfig(context, AppIntegrations.priceCharting),
          ),
          const SizedBox(height: 24),

          _buildSectionHeader("Hardware y Etiquetas"),
          _buildIntegrationCard(
            context,
            title: "Generador de QR",
            subtitle: "Configura el formato de impresión.",
            icon: Icons.qr_code,
            iconColor: Colors.blueGrey,
            isLinked: false,
            onTap: () => _openConfig(context, AppIntegrations.qrLabels),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildIntegrationCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isLinked,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.08),
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: FaIcon(icon, color: iconColor, size: 24),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
          trailing: isLinked
              ? const Icon(Icons.check_circle, color: Colors.green, size: 24)
              : const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: onTap,
        ),
      ),
    );
  }
}
