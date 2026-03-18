import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:invenicum/providers/integrations_provider.dart';
import 'package:invenicum/core/utils/constants.dart';
import 'package:invenicum/screens/integrations/local_widgets/integration_config_sheet.dart';
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
            icon: Icon(Icons.auto_awesome, color: Colors.deepPurpleAccent),
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
            icon: FaIcon(FontAwesomeIcons.telegram, color: Color(0xFF26A5E4)),
            // CAMBIO AQUÍ: Ahora lee el estado real del Provider
            isLinked: integrationProv.isLinked(AppIntegrations.telegram),
            onTap: () => _openConfig(context, AppIntegrations.telegram),
          ),
          _buildIntegrationCard(
            context,
            title: "E-Mail (A través de Resend)",
            subtitle: "Envío de reportes y alertas profesionales.",
            icon: Icon(Icons.mail_outline_rounded, color: Color(0xFF3CE426)),
            isLinked: integrationProv.isLinked(AppIntegrations.email),
            onTap: () => _openConfig(context, AppIntegrations.email),
          ),
          const SizedBox(height: 24),

          // --- Data APIs ---
          _buildSectionHeader("Miscellaneous Data APIs"),
          _buildIntegrationCard(
            context,
            title: "BoardGameGeek",
            subtitle: "Obtain data from BoardGameGeek.com",
            icon: FaIcon(FontAwesomeIcons.boardGameGeek, color: Colors.red),
            isLinked: integrationProv.isLinked(AppIntegrations.bgg),
            onTap: () => _openConfig(context, AppIntegrations.bgg),
          ),
          const SizedBox(height: 24),
          _buildIntegrationCard(
            context,
            title: "PokeApi",
            subtitle: "Obtain data from PokeApi.co",
            icon: Icon(Icons.catching_pokemon, color: Colors.red),
            isLinked: integrationProv.isLinked(AppIntegrations.pokemon),
            onTap: () => _openConfig(context, AppIntegrations.pokemon),
          ),
          const SizedBox(height: 24),
          // --- HERRAMIENTAS ---
          _buildSectionHeader("Herramientas de Valoración"),
          _buildIntegrationCard(
            context,
            title: "PriceCharting",
            subtitle: "Historial de precios de videojuegos.",
            icon: FaIcon(FontAwesomeIcons.chartArea, color: Colors.orange),
            isLinked: integrationProv.isLinked(AppIntegrations.priceCharting),
            onTap: () => _openConfig(context, AppIntegrations.priceCharting),
          ),
          _buildIntegrationCard(
            context,
            title: "UPCitemdb",
            subtitle: "Valoración por código de barras y EAN.",
            icon: FaIcon(FontAwesomeIcons.barcode, color: Colors.blueAccent),
            isLinked: integrationProv.isLinked(AppIntegrations.upcitemdb),
            onTap: () => _openConfig(context, AppIntegrations.upcitemdb),
          ),
          const SizedBox(height: 24),

          // --- HARDWARE Y ETIQUETAS ---
          _buildSectionHeader("Hardware y Etiquetas"),
          _buildIntegrationCard(
            context,
            title: "Generador de QR",
            subtitle: "Configura el formato de impresión.",
            icon: FaIcon(FontAwesomeIcons.qrcode, color: Colors.blueGrey),
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
    required Widget icon,
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
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: SizedBox(child: icon),
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
