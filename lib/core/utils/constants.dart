// lib/utils/constants.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/data/models/achievements_model.dart';
import 'package:invenicum/data/models/integration_field_type.dart';

enum ItemCondition {
  mint, // Impecable, en caja original
  loose, // Sin caja, pero completo
  incomplete, // Le faltan piezas
  damaged, // Roto o con marcas claras
  new_, // Nuevo de tienda
  digital, // Bien no tangible
}

extension ItemConditionExtension on ItemCondition {
  /// Traducciones automáticas desde los archivos .arb
  String getLocalizedString(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    switch (this) {
      case ItemCondition.mint:
        return l10n.condition_mint;
      case ItemCondition.loose:
        return l10n.condition_loose;
      case ItemCondition.incomplete:
        return l10n.condition_incomplete;
      case ItemCondition.damaged:
        return l10n.condition_damaged;
      case ItemCondition.new_:
        return l10n.condition_new;
      case ItemCondition.digital:
        return l10n.condition_digital;
    }
  }

  /// Icono representativo de cada estado
  IconData get icon {
    switch (this) {
      case ItemCondition.mint:
        return Icons.archive_outlined;
      case ItemCondition.loose:
        return Icons.inventory_2_outlined;
      case ItemCondition.incomplete:
        return Icons.incomplete_circle_outlined;
      case ItemCondition.damaged:
        return Icons.heart_broken_outlined;
      case ItemCondition.new_:
        return Icons.new_releases_outlined;
      case ItemCondition.digital:
        return Icons.cloud_queue;
    }
  }

  /// Color temático asociado al estado
  Color get color {
    switch (this) {
      case ItemCondition.mint:
        return Colors.green;
      case ItemCondition.new_:
        return Colors.blue;
      case ItemCondition.loose:
        return Colors.orange;
      case ItemCondition.incomplete:
        return Colors.deepOrange;
      case ItemCondition.damaged:
        return Colors.red;
      case ItemCondition.digital:
        return Colors.purple;
    }
  }

  /// Helper para convertir String de DB a Enum
  static ItemCondition fromString(String? value) {
    if (value == null) return ItemCondition.loose;
    // Manejo especial para 'new' ya que el enum usa 'new_' por ser palabra reservada
    if (value == 'new' || value == 'new_') return ItemCondition.new_;

    return ItemCondition.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ItemCondition.loose,
    );
  }
}

class AppIntegrations {
  // IDs Únicos (Los que entiende el Backend)
  static const String gemini = 'gemini';
  static const String openai = 'openai';
  static const String claude = 'claude';
  static const String telegram = 'telegram';
  static const String email = 'email';
  static const String qrLabels = 'qr_labels';
  static const String priceCharting = 'price_charting';
  static const String upcitemdb = 'upcitemdb';
  static const String bgg = 'bgg';
  static const String pokemon = 'pokemon';

  /// Retorna la lista de modelos completa para la UI
  static List<IntegrationModel> getAvailableIntegrations(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return [
      // --- IA ---
      IntegrationModel(
        id: gemini,
        name: 'Google Gemini AI',
        isDataSource: false,
        icon: Icon(Icons.auto_awesome, color: Colors.deepPurpleAccent),
        description: l10n.integrationGeminiDesc,
        fields: [
          IntegrationField(
            id: 'apiKey',
            label: 'API Key',
            type: IntegrationFieldType.password,
            helperText: l10n.helperGeminiKey,
          ),
          IntegrationField(
            id: 'model',
            label: l10n.geminiLabelModel,
            type: IntegrationFieldType.dropdown,
            helperText: 'Default: gemini-3-flash-preview',
            options: AiModels.gemini.map((m) => m.id).toList(),
          ),
        ],
      ),
      IntegrationModel(
        id: openai,
        name: 'OpenAI (ChatGPT)',
        isDataSource: false,
        icon: FaIcon(FontAwesomeIcons.openai),
        //icon: Icon(Icons.auto_awesome_mosaic_outlined),
        description:
            'Usa GPT-4o y otros modelos de OpenAI como asistente inteligente.',
        fields: [
          IntegrationField(
            id: 'apiKey',
            label: 'API Key',
            type: IntegrationFieldType.password,
            helperText: 'Obtenida en platform.openai.com/api-keys',
          ),
          IntegrationField(
            id: 'model',
            label: 'Modelo',
            type: IntegrationFieldType.dropdown,
            helperText: 'Default: gpt-4o',
            options: AiModels.openai.map((m) => m.id).toList(),
          ),
        ],
      ),
      IntegrationModel(
        id: claude,
        name: 'Anthropic Claude',
        isDataSource: false,
        icon: FaIcon(FontAwesomeIcons.claude, color: Colors.orange[900]),
        description:
            'Usa Claude Sonnet, Opus y Haiku como asistente inteligente.',
        fields: [
          IntegrationField(
            id: 'apiKey',
            label: 'API Key',
            type: IntegrationFieldType.password,
            helperText: 'Obtenida en console.anthropic.com/settings/keys',
          ),
          IntegrationField(
            id: 'model',
            label: 'Modelo',
            type: IntegrationFieldType.dropdown,
            helperText: 'Default: claude-sonnet-4-6',
            options: AiModels.claude.map((m) => m.id).toList(),
          ),
        ],
      ),

      // --- MENSAJERÍA ---
      IntegrationModel(
        id: telegram,
        name: 'Telegram Bot',
        isDataSource: false,
        icon: FaIcon(FontAwesomeIcons.telegram),
        description: l10n.integrationTelegramDesc,
        fields: [
          IntegrationField(
            id: 'botToken', // Antes 'bot_token'
            label: 'Bot Token',
            type: IntegrationFieldType.password,
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
        isDataSource: false,
        icon: Icon(Icons.email_outlined),
        description:
            'Envío de correos ultra-confiable. Ideal para reportes y alertas críticas.',
        fields: [
          IntegrationField(
            id: 'apiKey', // sensitiveIds lo ocultará automáticamente
            label: 'Resend API Key',
            type: IntegrationFieldType.password,
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
      // --- MISCELLANEOUS ---
      IntegrationModel(
        id: 'bgg',
        name: 'BoardGameGeek',
        isDataSource: true,
        image: Image.asset(
          'assets/images/powered_by_BGG_02_MED.png', // Tu ruta de asset
          height: 35,
        ),
        icon: const FaIcon(FontAwesomeIcons.boardGameGeek, color: Colors.red),
        description:
            'Conecta tu cuenta de BGG para sincronizar tu colección y enriquecer tus datos automáticamente.',
        fields: [
          IntegrationField(
            id: 'bgg_username',
            label: 'BGG Username',
            type: IntegrationFieldType.text,
            // Esto es lo único que necesitamos del usuario para identificar su colección
          ),
        ],
      ),
      IntegrationModel(
        id: 'pokemon',
        name: 'PokeApi',
        isDataSource: true,
        icon: const Icon(Icons.catching_pokemon, color: Colors.red),
        description:
            'Conectate a la Api de Pokemon para sincronizar tu colección y enriquecer tus datos automáticamente.',
        fields: [],
      ),

      // --- HERRAMIENTAS ---
      IntegrationModel(
        id: qrLabels,
        name: 'Generador QR',
        isDataSource: false,
        icon: FaIcon(FontAwesomeIcons.qrcode),
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
        isDataSource: false,
        icon: FaIcon(FontAwesomeIcons.chartArea),
        description: 'Configura tu API Key para obtener precios actualizados.',
        fields: [
          IntegrationField(
            id: 'api_key',
            label: 'API Key',
            type: IntegrationFieldType.password,
          ),
        ],
      ),
      IntegrationModel(
        id: upcitemdb,
        name: 'UPCitemdb',
        isDataSource: false,
        icon: FaIcon(FontAwesomeIcons.barcode),
        description: 'Búsqueda global de precios por código de barras.',
        fields: [
          // Campo para que el usuario pegue su API Key de UPCitemdb
          IntegrationField(
            id: 'apiKey',
            label: 'API Key (user_key)',
            type: IntegrationFieldType.password,
          ),
        ],
      ),
    ];
  }
}

// ── Modelos de IA disponibles (espejo de aiConstants.js) ─────────────────────
class AiModelInfo {
  final String id;
  final String label;
  const AiModelInfo({required this.id, required this.label});
}

// Metadata visual de cada proveedor — única fuente de verdad para
// iconos, colores y labels usados en la UI (IntegrationsScreen,
// AiProviderCardWidget, etc.)
class AiProviderInfo {
  final String id;
  final String label;
  final Widget icon; // Widget para soportar Icon y FaIcon
  final Color color;
  const AiProviderInfo({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
  });
}

class AiModels {
  // ── Listas de modelos ─────────────────────────────────────────────────────
  static const List<AiModelInfo> gemini = [
    AiModelInfo(
      id: 'gemini-3-flash-preview',
      label: 'Gemini 3.0 Flash Preview',
    ),
    AiModelInfo(id: 'gemini-2.0-flash', label: 'Gemini 2.0 Flash'),
    AiModelInfo(
      id: 'gemini-2.0-flash-thinking',
      label: 'Gemini 2.0 Flash Thinking',
    ),
    AiModelInfo(id: 'gemini-1.5-pro', label: 'Gemini 1.5 Pro'),
  ];

  static const List<AiModelInfo> openai = [
    AiModelInfo(id: 'gpt-4o', label: 'GPT-4o'),
    AiModelInfo(id: 'gpt-4o-mini', label: 'GPT-4o Mini'),
    AiModelInfo(id: 'gpt-4-turbo', label: 'GPT-4 Turbo'),
  ];

  static const List<AiModelInfo> claude = [
    AiModelInfo(id: 'claude-sonnet-4-6', label: 'Claude Sonnet 4.6'),
    AiModelInfo(id: 'claude-opus-4-6', label: 'Claude Opus 4.6'),
    AiModelInfo(id: 'claude-haiku-4-5-20251001', label: 'Claude Haiku 4.5'),
  ];

  // ── Metadata visual de proveedores ────────────────────────────────────────
  static const List<AiProviderInfo> providers = [
    AiProviderInfo(
      id: AppIntegrations.gemini,
      label: 'Google Gemini',
      icon: Icon(Icons.auto_awesome),
      color: Color(0xFF8B5CF6),
    ),
    AiProviderInfo(
      id: AppIntegrations.openai,
      label: 'OpenAI (ChatGPT)',
      icon: FaIcon(FontAwesomeIcons.openai),
      color: Color(0xFF10A37F),
    ),
    AiProviderInfo(
      id: AppIntegrations.claude,
      label: 'Anthropic Claude',
      icon: FaIcon(FontAwesomeIcons.claude),
      color: Color(0xFFD4A27F),
    ),
  ];

  /// Devuelve el AiProviderInfo de un proveedor por su ID
  static AiProviderInfo providerInfo(String providerId) => providers.firstWhere(
    (p) => p.id == providerId,
    orElse: () => providers.first,
  );

  /// Todos los modelos de un proveedor dado por su ID string
  static List<AiModelInfo> forProvider(String provider) {
    switch (provider) {
      case 'openai':
        return openai;
      case 'claude':
        return claude;
      case 'gemini':
      default:
        return gemini;
    }
  }

  /// Modelo por defecto de un proveedor
  static String defaultFor(String provider) => forProvider(provider).first.id;
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
