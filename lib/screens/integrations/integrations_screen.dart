import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:invenicum/providers/integrations_provider.dart';
import 'package:invenicum/core/utils/constants.dart';
import 'package:invenicum/screens/integrations/local_widgets/integration_config_card.dart';
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
          IntegrationCard(
            title: "Google Gemini",
            subtitle: "Asistente inteligente con los modelos Gemini de Google.",
            icon: AppIntegrations.getAvailableIntegrations(context)
                .firstWhere((element) => element.id == AppIntegrations.gemini)
                .icon,
            isLinked: integrationProv.isLinked(AppIntegrations.gemini),
            onTap: () => _openConfig(context, AppIntegrations.gemini),
          ),
          IntegrationCard(
            title: "OpenAI (ChatGPT)",
            subtitle: "Usa GPT-4o y otros modelos de OpenAI.",
            icon: AppIntegrations.getAvailableIntegrations(context)
                .firstWhere((element) => element.id == AppIntegrations.openai)
                .icon,
            //icon: const Icon(Icons.auto_awesome_mosaic_outlined, color: Color(0xFF10A37F)),
            isLinked: integrationProv.isLinked(AppIntegrations.openai),
            onTap: () => _openConfig(context, AppIntegrations.openai),
          ),
          IntegrationCard(
            title: "Anthropic Claude",
            subtitle: "Usa Claude Sonnet, Opus y Haiku.",
            icon: AppIntegrations.getAvailableIntegrations(context)
                .firstWhere((element) => element.id == AppIntegrations.claude)
                .icon,
            isLinked: integrationProv.isLinked(AppIntegrations.claude),
            onTap: () => _openConfig(context, AppIntegrations.claude),
          ),
          const SizedBox(height: 24),

          // --- MENSAJERÍA ---
          _buildSectionHeader("Mensajería y Notificaciones"),
          IntegrationCard(
            title: "Telegram Bot",
            subtitle: "Configura alertas y bots de chat.",
            icon: FaIcon(FontAwesomeIcons.telegram, color: Color(0xFF26A5E4)),
            // CAMBIO AQUÍ: Ahora lee el estado real del Provider
            isLinked: integrationProv.isLinked(AppIntegrations.telegram),
            onTap: () => _openConfig(context, AppIntegrations.telegram),
          ),
          IntegrationCard(
            title: "E-Mail (A través de Resend)",
            subtitle: "Envío de reportes y alertas profesionales.",
            icon: Icon(Icons.mail_outline_rounded, color: Color(0xFF3CE426)),
            isLinked: integrationProv.isLinked(AppIntegrations.email),
            onTap: () => _openConfig(context, AppIntegrations.email),
          ),
          const SizedBox(height: 24),

          // --- Data APIs ---
          _buildSectionHeader("Miscellaneous Data APIs"),
          IntegrationCard(
            title: "BoardGameGeek",
            subtitle: "Obtain data from BoardGameGeek.com",
            icon: FaIcon(FontAwesomeIcons.boardGameGeek, color: Colors.red),
            isLinked: integrationProv.isLinked(AppIntegrations.bgg),
            onTap: () => _openConfig(context, AppIntegrations.bgg),
          ),
          IntegrationCard(
            title: "PokeApi",
            subtitle: "Obtain data from PokeApi.co",
            icon: Icon(Icons.catching_pokemon, color: Colors.red),
            isLinked: integrationProv.isLinked(AppIntegrations.pokemon),
            onTap: () => _openConfig(context, AppIntegrations.pokemon),
          ),
          const SizedBox(height: 24),
          // --- HERRAMIENTAS ---
          _buildSectionHeader("Herramientas de Valoración"),
          IntegrationCard(
            title: "PriceCharting",
            subtitle: "Historial de precios de videojuegos.",
            icon: FaIcon(FontAwesomeIcons.chartArea, color: Colors.orange),
            isLinked: integrationProv.isLinked(AppIntegrations.priceCharting),
            onTap: () => _openConfig(context, AppIntegrations.priceCharting),
          ),
          IntegrationCard(
            title: "UPCitemdb",
            subtitle: "Valoración por código de barras y EAN.",
            icon: FaIcon(FontAwesomeIcons.barcode, color: Colors.blueAccent),
            isLinked: integrationProv.isLinked(AppIntegrations.upcitemdb),
            onTap: () => _openConfig(context, AppIntegrations.upcitemdb),
          ),
          const SizedBox(height: 24),

          // --- HARDWARE Y ETIQUETAS ---
          _buildSectionHeader("Hardware y Etiquetas"),
          IntegrationCard(
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
}
