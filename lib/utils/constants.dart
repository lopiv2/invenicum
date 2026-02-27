// lib/utils/constants.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/models/achievements_model.dart';
import 'package:invenicum/models/integration_field_type.dart';

class AppIntegrations {
  // IDs Únicos (Los que entiende el Backend)
  static const String gemini = 'gemini';
  static const String telegram = 'telegram';
  static const String email = 'email'; // Nuevo
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
            id: 'botToken', // Antes 'bot_token'
            label: 'Bot Token',
            type: IntegrationFieldType.text,
            helperText: 'De @BotFather',
          ),
          IntegrationField(
            id: 'chatId', // Antes 'chat_id'
            label: 'Chat ID',
            type: IntegrationFieldType.text,
            helperText: 'Usa @userinfobot para obtener tu ID',
          ),
        ],
      ),
      IntegrationModel(
        id: 'email',
        name: 'Resend Email',
        icon: Icons.alternate_email_rounded,
        description:
            'Envío de correos ultra-confiable. Ideal para reportes y alertas críticas.',
        fields: [
          IntegrationField(
            id: 'apiKey', // sensitiveIds lo ocultará automáticamente
            label: 'Resend API Key',
            type: IntegrationFieldType.text,
            helperText: 'Obtenida en resend.com/api-keys',
          ),
          IntegrationField(
            id: 'fromEmail',
            label: 'Remitente (From)',
            type: IntegrationFieldType.text,
            helperText: 'Ej: Invenicum <onboarding@resend.dev>',
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
            type: IntegrationFieldType.text,
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

class AppAchievements {
  // IDs para evitar errores de escritura (Hardcoded IDs)
  static const String firstItem = 'first_item';
  static const String catalogerSmall = 'cataloger_small';
  static const String catalogerMedium = 'cataloger_medium';
  static const String catalogerLarge = 'cataloger_large';
  static const String orderMaster = 'order_master';
  static const String eyeForValue = 'eye_for_value';
  static const String firstGrail = 'first_grail';
  static const String museumPiece = 'museum_piece';
  static const String growingWealth = 'growing_wealth';
  static const String wallStreetWolf = 'wall_street_wolf';
  static const String bargainHunter = 'bargain_hunter';
  static const String blindTrust = 'blind_trust';
  static const String librarian = 'librarian';
  static const String allInOrder = 'all_in_order';
  static const String legendaryLender = 'legendary_lender';
  static const String cyberCollector = 'cyber_collector';
  static const String hawkEye = 'hawk_eye';
  static const String polyglot = 'polyglot';
  static const String forecaster = 'forecaster';
  static const String masterUser = 'master_user';

  /// Retorna la lista oficial de los 20 logros de Invenicum
  static List<AchievementDefinition> getDefinitions(BuildContext context) {
    // Nota: Aquí podrías usar AppLocalizations.of(context) si quieres traducirlos
    return const [
      // --- COLECCIONISMO ---
      AchievementDefinition(
        id: firstItem,
        title: 'Bienvenido a la Mansión',
        desc: 'Añade tu primer objeto al inventario',
        icon: Icons.home_repair_service_outlined,
        category: 'collection',
      ),
      AchievementDefinition(
        id: catalogerSmall,
        title: 'Pequeño Almacén',
        desc: 'Registra 10 objetos en total',
        icon: Icons.inventory_2_outlined,
        category: 'collection',
      ),
      AchievementDefinition(
        id: catalogerMedium,
        title: 'Curador de Museo',
        desc: 'Registra 50 objetos en tu colección',
        icon: Icons.account_balance_outlined,
        category: 'collection',
      ),
      AchievementDefinition(
        id: catalogerLarge,
        title: 'Dueño de un Imperio',
        desc: 'Registra 200 objetos (Nivel Legendario)',
        icon: Icons.fort_outlined,
        category: 'collection',
        isLegendary: true,
      ),
      AchievementDefinition(
        id: orderMaster,
        title: 'Orden Absoluto',
        desc: 'Asigna una ubicación física a 20 objetos',
        icon: Icons.shelves,
        category: 'collection',
      ),

      // --- MERCADO ---
      AchievementDefinition(
        id: eyeForValue,
        title: 'Ojo para el Valor',
        desc: 'Registra el precio de compra de 5 objetos',
        icon: Icons.visibility_outlined,
        category: 'market',
      ),
      AchievementDefinition(
        id: firstGrail,
        title: 'Primer "Grial"',
        desc: 'Añade un objeto que valga más de 100€',
        icon: Icons.workspace_premium_outlined,
        category: 'market',
      ),
      AchievementDefinition(
        id: museumPiece,
        title: 'Pieza de Museo',
        desc: 'Añade un objeto de más de 500€',
        icon: Icons.diamond_outlined,
        category: 'market',
        isLegendary: true,
      ),
      AchievementDefinition(
        id: growingWealth,
        title: 'Patrimonio Creciente',
        desc: 'Tu inventario total supera los 1.000€',
        icon: Icons.trending_up_rounded,
        category: 'market',
      ),
      AchievementDefinition(
        id: wallStreetWolf,
        title: 'El Lobo de Wall Street',
        desc: 'Tu inventario total supera los 10.000€',
        icon: Icons.query_stats_rounded,
        category: 'market',
        isLegendary: true,
      ),
      AchievementDefinition(
        id: bargainHunter,
        title: 'Caza-Gangas',
        desc: 'Registra un objeto que valga el doble de lo que pagaste',
        icon: Icons.auto_graph_rounded,
        category: 'market',
      ),

      // --- PRÉSTAMOS ---
      AchievementDefinition(
        id: blindTrust,
        title: 'Confianza Ciega',
        desc: 'Realiza tu primer préstamo a un contacto',
        icon: Icons.handshake_outlined,
        category: 'loans',
      ),
      AchievementDefinition(
        id: librarian,
        title: 'Bibliotecario',
        desc: 'Gestiona 3 préstamos activos simultáneamente',
        icon: Icons.menu_book_rounded,
        category: 'loans',
      ),
      AchievementDefinition(
        id: allInOrder,
        title: 'Todo en Orden',
        desc: 'Recupera y marca como devuelto un objeto prestado',
        icon: Icons.assignment_turned_in_outlined,
        category: 'loans',
      ),
      AchievementDefinition(
        id: legendaryLender,
        title: 'Prestamista Legendario',
        desc: 'Completa 20 préstamos con éxito',
        icon: Icons.verified_user_outlined,
        category: 'loans',
        isLegendary: true,
      ),

      // --- HERRAMIENTAS E IA ---
      AchievementDefinition(
        id: cyberCollector,
        title: 'Ciber-Coleccionista',
        desc: 'Identifica un objeto usando la IA por primera vez',
        icon: Icons.psychology_outlined,
        category: 'tools',
      ),
      AchievementDefinition(
        id: hawkEye,
        title: 'Ojo de Halcón',
        desc: 'Usa Gemini para identificar 15 objetos',
        icon: Icons.camera_enhance_outlined,
        category: 'tools',
      ),
      AchievementDefinition(
        id: polyglot,
        title: 'Políglota',
        desc: 'Cambia la divisa global de la aplicación',
        icon: Icons.currency_exchange_rounded,
        category: 'tools',
      ),
      AchievementDefinition(
        id: forecaster,
        title: 'Previsor',
        desc: 'Activa 3 alertas de mantenimiento diferentes',
        icon: Icons.fmd_bad_outlined,
        category: 'tools',
      ),
      AchievementDefinition(
        id: masterUser,
        title: 'Usuario Maestro',
        desc: 'Personaliza el orden de tus notificaciones',
        icon: Icons.reorder_rounded,
        category: 'tools',
      ),
    ];
  }
}
