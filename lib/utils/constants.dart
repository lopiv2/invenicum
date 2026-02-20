// lib/utils/constants.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/models/integration_field_type.dart';

class AppIntegrations {
  // IDs Únicos (Los que entiende el Backend)
  static const String gemini = 'gemini';
  static const String telegram = 'telegram';
  static const String whatsapp = 'whatsapp'; // Nuevo
  static const String ebay = 'ebay'; // Nuevo
  static const String qrLabels = 'qr_labels';
  static const String priceCharting = 'price_charting';
  static const String upcitemdb = 'upcitemdb';


  /// Retorna la lista de modelos completa para la UI
  static List<IntegrationModel> getAvailableIntegrations(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return [
      // --- IA ---
      IntegrationModel(
        id: gemini,
        name: 'Google Gemini AI',
        icon: Icons.auto_awesome,
        description: l10n.integrationGeminiDesc,
        fields: [
          IntegrationField(
            id: 'apiKey',
            label: 'API Key',
            type: IntegrationFieldType.text,
            helperText: l10n.helperGeminiKey,
          ),
          IntegrationField(
            id: 'model',
            label: l10n.geminiLabelModel,
            type: IntegrationFieldType.text,
            helperText: 'Default: gemini-3-flash-preview',
          ),
        ],
      ),

      // --- MENSAJERÍA ---
      IntegrationModel(
        id: telegram,
        name: 'Telegram Bot',
        icon: FontAwesomeIcons.telegram,
        description: l10n.integrationTelegramDesc,
        fields: [
          IntegrationField(
            id: 'bot_token',
            label: 'Bot Token',
            type: IntegrationFieldType.text,
            helperText: 'De @BotFather',
          ),
          IntegrationField(
            id: 'chat_id',
            label: 'Chat ID',
            type: IntegrationFieldType.text,
          ),
        ],
      ),
      IntegrationModel(
        id: whatsapp,
        name: 'WhatsApp Business',
        icon: FontAwesomeIcons.whatsapp,
        description: 'Envía alertas y estados de inventario por WhatsApp.',
        fields: [
          IntegrationField(
            id: 'phone_number_id',
            label: 'Phone Number ID',
            type: IntegrationFieldType.text,
          ),
          IntegrationField(
            id: 'access_token',
            label: 'Permanent Access Token',
            type: IntegrationFieldType.text,
            helperText: 'Configurado en Meta for Developers',
          ),
        ],
      ),

      // --- E-COMMERCE ---
      IntegrationModel(
        id: ebay,
        name: 'eBay Marketplace',
        icon: FontAwesomeIcons.ebay,
        description: 'Sincroniza stock y publica anuncios automáticamente.',
        fields: [
          IntegrationField(
            id: 'client_id',
            label: 'App ID (Client ID)',
            type: IntegrationFieldType.text,
          ),
          IntegrationField(
            id: 'client_secret',
            label: 'Cert ID (Client Secret)',
            type: IntegrationFieldType.text,
          ),
          IntegrationField(
            id: 'ru_name',
            label: 'RuName (Redirect URL Name)',
            type: IntegrationFieldType.text,
          ),
        ],
      ),

      // --- HERRAMIENTAS ---
      IntegrationModel(
        id: qrLabels,
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
        id: priceCharting,
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
      IntegrationModel(
        id: upcitemdb,
        name: 'UPCitemdb',
        icon: FontAwesomeIcons.barcode,
        description: 'Búsqueda global de precios por código de barras.',
        fields: [
          // Campo para que el usuario pegue su API Key de UPCitemdb
          IntegrationField(
            id: 'apiKey',
            label: 'API Key (user_key)',
            type: IntegrationFieldType.text
          ),
        ],
      ),
    ];
  }
}

class AppSlots {
  static const String dashboardTop = 'dashboard_top';
  static const String dashboardBottom = 'dashboard_bottom';
  static const String leftSidebar = 'left_sidebar';
  static const String inventoryHeader = 'inventory_header';
  static const String floatingActionButton = 'floating_action_button';

  static const List<String> allSlots = [
    dashboardTop,
    dashboardBottom,
    leftSidebar,
    inventoryHeader,
    floatingActionButton,
  ];

  static String getName(BuildContext context, String slot) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return slot;

    switch (slot) {
      case dashboardTop:
        return l10n.slotDashboardTop;
      case dashboardBottom:
        return l10n.slotDashboardBottom;
      case leftSidebar:
        return l10n.slotLeftSidebar;
      case inventoryHeader:
        return l10n.slotInventoryHeader;
      case floatingActionButton:
        return l10n.slotFloatingActionButton;
      default:
        return l10n.slotUnknown;
    }
  }
}
