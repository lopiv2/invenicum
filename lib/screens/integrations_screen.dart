import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:invenicum/models/integration_field_type.dart';
import 'package:invenicum/widgets/integration_config_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

class IntegrationsScreen extends StatelessWidget {
  IntegrationsScreen({super.key});

  final List<IntegrationModel> availableIntegrations = [
    IntegrationModel(
      id: 'telegram',
      name: 'Telegram Bot',
      icon: FontAwesomeIcons.telegram,
      description:
          'Recibe notificaciones y gestiona tu inventario desde Telegram.',
      fields: [
        IntegrationField(
          id: 'bot_token',
          label: 'Bot Token',
          type: IntegrationFieldType.text,
          helperText: 'Obtenido de @BotFather',
        ),
        IntegrationField(
          id: 'chat_id',
          label: 'Chat ID',
          type: IntegrationFieldType.text,
        ),
      ],
    ),
    IntegrationModel(
      id: 'qr_labels',
      name: 'Generador QR',
      icon: Icons.qr_code,
      description: 'Configura el formato de tus etiquetas imprimibles.',
      fields: [
        IntegrationField(
          id: 'page_size',
          label: 'Tamaño de Página (A4, Carta)',
          type: IntegrationFieldType.text,
        ),
        IntegrationField(
          id: 'margin',
          label: 'Margen (mm)',
          type: IntegrationFieldType.text,
        ),
      ],
    ),
    IntegrationModel(
      id: 'price_charting',
      name: 'PriceCharting',
      icon: Icons.show_chart_rounded,
      description: 'Configura tu API Key para obtener precios actualizados.',
      fields: [
        IntegrationField(
          id: 'api_key',
          label: 'API Key',
          type: IntegrationFieldType.text,
        ),
      ],
    ),
  ];

  void _openConfig(BuildContext context, String integrationId) {
    // Buscamos el modelo en la lista por su ID
    final integration = availableIntegrations.firstWhere(
      (element) => element.id == integrationId,
      orElse: () => IntegrationModel(
        id: 'unknown',
        name: 'Error',
        icon: Icons.error,
        description: '',
        fields: [],
      ),
    );

    if (integration.id == 'unknown') return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).canvasColor, // Para que se vea el redondeado
      builder: (context) => IntegrationConfigSheet(integration: integration),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Integraciones y Conexiones")),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionHeader("Mensajería y Notificaciones"),
          const SizedBox(height: 16),
          _buildIntegrationCard(
            context,
            title: "Telegram Bot",
            subtitle: "Configura alertas y bots de chat.",
            icon: FontAwesomeIcons.telegram,
            iconColor: const Color(0xFF26A5E4),
            isLinked: false,
            onTap: () => _openConfig(context, 'telegram'), // 🚩 Abre modal
          ),
          const SizedBox(height: 12),
          _buildIntegrationCard(
            context,
            title: "WhatsApp Webhook",
            subtitle: "Consulta tu inventario rápidamente por WhatsApp.",
            icon: FontAwesomeIcons.whatsapp,
            iconColor: const Color(0xFF25D366),
            isLinked: false,
            onTap: () {
              // Lógica de WhatsApp
            },
          ),
          const SizedBox(height: 32),
          _buildSectionHeader("Herramientas de Valoración"),
          _buildIntegrationCard(
            context,
            title: "PriceCharting",
            subtitle: "Historial de precios de videojuegos.",
            icon: Icons.show_chart_rounded,
            iconColor: Colors.orange,
            isLinked: false,
            onTap: () => _openConfig(context, 'price_charting'), // 🚩 Abre modal
          ),
          const SizedBox(height: 32),
          _buildSectionHeader("E-Commerce & Marketplaces"),
          const SizedBox(height: 16),
          _buildIntegrationCard(
            context,
            title: "eBay Connector",
            subtitle: "Sincroniza precios y publica anuncios automáticamente.",
            icon: FontAwesomeIcons.ebay,
            iconColor: const Color(0xFFE53238),
            isLinked: false,
            onTap: () {},
          ),
          const SizedBox(height: 32),
          _buildSectionHeader("Hardware y Etiquetas"),
          _buildIntegrationCard(
            context,
            title: "Generador de QR",
            subtitle: "Configura el formato de impresión.",
            icon: Icons.qr_code,
            iconColor: Colors.blueGrey,
            isLinked: false,
            onTap: () => _openConfig(context, 'qr_labels'), // 🚩 Abre modal
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: Colors.grey,
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
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: FaIcon(icon, color: iconColor, size: 28),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: isLinked
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _handleTelegramSetup(BuildContext context) async {
    // Aquí podrías abrir el bot directamente si ya tienes el nombre
    final url = Uri.parse("https://t.me/TuNombreDeBot");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}
