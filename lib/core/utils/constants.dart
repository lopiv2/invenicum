// lib/utils/constants.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/data/models/achievements_model.dart';
import 'package:invenicum/data/models/custom_theme_model.dart';
import 'package:invenicum/data/models/integration_field_type.dart';

enum ItemCondition {
  mint, // Mint, inside box, like new
  loose, // Loose, without box, but complete
  incomplete, // Missing pieces
  damaged, // Broken or with clear marks
  new_, // New from store
  digital, // Non-tangible item
}

extension ItemConditionExtension on ItemCondition {
  /// Automatic translations from .arb files
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

  /// Representative icon for each condition
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

  /// Thematic color associated with the condition
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

  /// Helper to convert String from DB to Enum
  static ItemCondition fromString(String? value) {
    if (value == null) return ItemCondition.loose;
    // Special handling for 'new' since the enum uses 'new_' due to reserved word
    if (value == 'new' || value == 'new_') return ItemCondition.new_;

    return ItemCondition.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ItemCondition.loose,
    );
  }
}

class AppIntegrations {
  // Unique IDs (The ones understood by the Backend)
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
  static const String tcgdex = 'tcgdex';

  /// Returns the complete list of models for the UI
  static List<IntegrationModel> getAvailableIntegrations(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return [
      // --- AI ---
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
            helperText: l10n.integrationModelDefaultGemini,
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
        description: l10n.integrationOpenaiDesc,
        fields: [
          IntegrationField(
            id: 'apiKey',
            label: 'API Key',
            type: IntegrationFieldType.password,
            helperText: l10n.integrationOpenaiApiKeyHint,
          ),
          IntegrationField(
            id: 'model',
            label: l10n.geminiLabelModel,
            type: IntegrationFieldType.dropdown,
            helperText: l10n.integrationModelDefaultOpenai,
            options: AiModels.openai.map((m) => m.id).toList(),
          ),
        ],
      ),
      IntegrationModel(
        id: claude,
        name: 'Anthropic Claude',
        isDataSource: false,
        icon: FaIcon(FontAwesomeIcons.claude, color: Colors.orange[900]),
        description: l10n.integrationClaudeDesc,
        fields: [
          IntegrationField(
            id: 'apiKey',
            label: 'API Key',
            type: IntegrationFieldType.password,
            helperText: l10n.integrationClaudeApiKeyHint,
          ),
          IntegrationField(
            id: 'model',
            label: l10n.geminiLabelModel,
            type: IntegrationFieldType.dropdown,
            helperText: l10n.integrationModelDefaultClaude,
            options: AiModels.claude.map((m) => m.id).toList(),
          ),
        ],
      ),

      // --- MESSAGING ---
      IntegrationModel(
        id: telegram,
        name: 'Telegram Bot',
        isDataSource: false,
        icon: FaIcon(FontAwesomeIcons.telegram),
        description: l10n.integrationTelegramDesc,
        fields: [
          IntegrationField(
            id: 'botToken', // Previously 'bot_token'
            label: 'Bot Token',
            type: IntegrationFieldType.password,
            helperText: l10n.integrationTelegramBotTokenHint,
          ),
          IntegrationField(
            id: 'chatId', // Previously 'chat_id'
            label: 'Chat ID',
            type: IntegrationFieldType.text,
            helperText: l10n.integrationTelegramChatIdHint,
          ),
        ],
      ),
      IntegrationModel(
        id: 'email',
        name: 'Resend Email',
        isDataSource: false,
        icon: Icon(Icons.email_outlined),
        description: l10n.integrationEmailDesc,
        fields: [
          IntegrationField(
            id: 'apiKey', // sensitiveIds will automatically hide it
            label: 'Resend API Key',
            type: IntegrationFieldType.password,
            helperText: l10n.integrationEmailApiKeyHint,
          ),
          IntegrationField(
            id: 'fromEmail',
            label: l10n.integrationEmailFromLabel,
            type: IntegrationFieldType.text,
            helperText: l10n.integrationEmailFromHint,
          ),
        ],
      ),
      // --- MISCELLANEOUS ---
      IntegrationModel(
        id: 'bgg',
        name: 'BoardGameGeek',
        isDataSource: true,
        image: Image.asset(
          'assets/images/powered_by_BGG_02_MED.png', // Your asset path
          height: 35,
        ),
        icon: const FaIcon(FontAwesomeIcons.boardGameGeek, color: Colors.red),
        description: l10n.integrationBggDesc,
        fields: [],
      ),
      IntegrationModel(
        id: 'pokemon',
        name: 'PokeApi',
        isDataSource: true,
        icon: const Icon(Icons.catching_pokemon, color: Colors.red),
        description: l10n.integrationPokemonDesc,
        fields: [],
      ),
      IntegrationModel(
        id: tcgdex,
        name: 'TCGdex',
        isDataSource: true,
        icon: const Icon(Icons.style_outlined, color: Colors.deepOrange),
        description: l10n.integrationTcgdexDesc,
        fields: [],
      ),

      // --- TOOLS ---
      /*IntegrationModel(
        id: qrLabels,
        name: l10n.integrationQrGeneratorName,
        isDataSource: false,
        icon: FaIcon(FontAwesomeIcons.qrcode),
        description: l10n.integrationQrLabelsDesc,
        fields: [
          IntegrationField(
            id: 'page_size',
            label: l10n.integrationQrPageSizeLabel,
            type: IntegrationFieldType.text,
          ),
          IntegrationField(
            id: 'margin',
            label: l10n.integrationQrMarginLabel,
            type: IntegrationFieldType.text,
          ),
        ],
      ),*/
      /*IntegrationModel(
        id: priceCharting,
        name: 'PriceCharting',
        isDataSource: false,
        icon: FaIcon(FontAwesomeIcons.chartArea),
        description: l10n.integrationPriceChartingDesc,
        fields: [
          IntegrationField(
            id: 'api_key',
            label: 'API Key',
            type: IntegrationFieldType.password,
          ),
        ],
      ),*/
      IntegrationModel(
        id: upcitemdb,
        name: 'UPCitemdb',
        isDataSource: false,
        icon: FaIcon(FontAwesomeIcons.barcode),
        description: l10n.integrationUpcitemdbDesc,
        fields: [
          // Field for the user to paste their UPCitemdb API Key
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

// ── Available AI Models (mirror of aiConstants.js) ─────────────────────
class AiModelInfo {
  final String id;
  final String label;
  const AiModelInfo({required this.id, required this.label});
}

// Visual metadata for each provider — single source of truth for
// icons, colors, and labels used in the UI (IntegrationsScreen,
// AiProviderCardWidget, etc.)
class AiProviderInfo {
  final String id;
  final String label;
  final Widget icon; // Widget to support both Icon and FaIcon
  final Color color;
  const AiProviderInfo({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
  });
}

class AiModels {
  // ── Lists of models ─────────────────────────────────────────────────────
  static const List<AiModelInfo> gemini = [
    AiModelInfo(
      id: 'gemini-3-flash-preview',
      label: 'Gemini 3.0 Flash Preview',
    ),
    AiModelInfo(id: 'gemini-2.5-flash', label: 'Gemini 2.5 Flash'),
    AiModelInfo(id: 'gemini-2.5-flash-lite', label: 'Gemini 2.5 Flash Lite'),
    AiModelInfo(id: 'gemini-2.5-pro', label: 'Gemini 2.5 Pro'),
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

  // ── Visual metadata for providers ────────────────────────────────────────
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

  /// Returns the AiProviderInfo of a provider by its ID
  static AiProviderInfo providerInfo(String providerId) => providers.firstWhere(
    (p) => p.id == providerId,
    orElse: () => providers.first,
  );

  /// Returns all models of a provider given its ID string
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

  /// Default model for a provider
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
  static const String firstItem = 'firstItem';
  static const String catalogerSmall = 'catalogerSmall';
  static const String catalogerMedium = 'catalogerMedium';
  static const String catalogerLarge = 'catalogerLarge';
  static const String orderMaster = 'orderMaster';
  static const String eyeForValue = 'eyeForValue';
  static const String firstGrail = 'firstGrail';
  static const String museumPiece = 'museumPiece';
  static const String growingWealth = 'growingWealth';
  static const String wallStreetWolf = 'wallStreetWolf';
  static const String bargainHunter = 'bargainHunter';
  static const String blindTrust = 'blindTrust';
  static const String librarian = 'librarian';
  static const String allInOrder = 'allInOrder';
  static const String legendaryLender = 'legendaryLender';
  static const String cyberCollector = 'cyberCollector';
  static const String hawkEye = 'hawkEye';
  static const String polyglot = 'polyglot';
  static const String forecaster = 'forecaster';
  static const String masterUser = 'masterUser';

  /// Returns the official list of the 20 Invenicum achievements
  static List<AchievementDefinition> getDefinitions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      // --- COLLECTION ---
      AchievementDefinition(
        id: AppAchievements.firstItem,
        title: l10n.achievementFirstItemTitle,
        desc: l10n.achievementFirstItemDesc,
        icon: Icons.home_repair_service_outlined,
        category: 'collection',
      ),
      AchievementDefinition(
        id: AppAchievements.catalogerSmall,
        title: l10n.achievementCatalogerSmallTitle,
        desc: l10n.achievementCatalogerSmallDesc,
        icon: Icons.inventory_2_outlined,
        category: 'collection',
      ),
      AchievementDefinition(
        id: AppAchievements.catalogerMedium,
        title: l10n.achievementCatalogerMediumTitle,
        desc: l10n.achievementCatalogerMediumDesc,
        icon: Icons.account_balance_outlined,
        category: 'collection',
      ),
      AchievementDefinition(
        id: AppAchievements.catalogerLarge,
        title: l10n.achievementCatalogerLargeTitle,
        desc: l10n.achievementCatalogerLargeDesc,
        icon: Icons.fort_outlined,
        category: 'collection',
        isLegendary: true,
      ),
      AchievementDefinition(
        id: AppAchievements.orderMaster,
        title: l10n.achievementOrderMasterTitle,
        desc: l10n.achievementOrderMasterDesc,
        icon: Icons.shelves,
        category: 'collection',
      ),

      // --- MARKET ---
      AchievementDefinition(
        id: AppAchievements.eyeForValue,
        title: l10n.achievementEyeForValueTitle,
        desc: l10n.achievementEyeForValueDesc,
        icon: Icons.visibility_outlined,
        category: 'market',
      ),
      AchievementDefinition(
        id: AppAchievements.firstGrail,
        title: l10n.achievementFirstGrailTitle,
        desc: l10n.achievementFirstGrailDesc,
        icon: Icons.workspace_premium_outlined,
        category: 'market',
      ),
      AchievementDefinition(
        id: AppAchievements.museumPiece,
        title: l10n.achievementMuseumPieceTitle,
        desc: l10n.achievementMuseumPieceDesc,
        icon: Icons.diamond_outlined,
        category: 'market',
        isLegendary: true,
      ),
      AchievementDefinition(
        id: AppAchievements.growingWealth,
        title: l10n.achievementGrowingWealthTitle,
        desc: l10n.achievementGrowingWealthDesc,
        icon: Icons.trending_up_rounded,
        category: 'market',
      ),
      AchievementDefinition(
        id: AppAchievements.wallStreetWolf,
        title: l10n.achievementWallStreetWolfTitle,
        desc: l10n.achievementWallStreetWolfDesc,
        icon: Icons.query_stats_rounded,
        category: 'market',
        isLegendary: true,
      ),
      AchievementDefinition(
        id: AppAchievements.bargainHunter,
        title: l10n.achievementBargainHunterTitle,
        desc: l10n.achievementBargainHunterDesc,
        icon: Icons.auto_graph_rounded,
        category: 'market',
      ),

      // --- LOANS ---
      AchievementDefinition(
        id: AppAchievements.blindTrust,
        title: l10n.achievementBlindTrustTitle,
        desc: l10n.achievementBlindTrustDesc,
        icon: Icons.handshake_outlined,
        category: 'loans',
      ),
      AchievementDefinition(
        id: AppAchievements.librarian,
        title: l10n.achievementLibrarianTitle,
        desc: l10n.achievementLibrarianDesc,
        icon: Icons.menu_book_rounded,
        category: 'loans',
      ),
      AchievementDefinition(
        id: AppAchievements.allInOrder,
        title: l10n.achievementAllInOrderTitle,
        desc: l10n.achievementAllInOrderDesc,
        icon: Icons.assignment_turned_in_outlined,
        category: 'loans',
      ),
      AchievementDefinition(
        id: AppAchievements.legendaryLender,
        title: l10n.achievementLegendaryLenderTitle,
        desc: l10n.achievementLegendaryLenderDesc,
        icon: Icons.verified_user_outlined,
        category: 'loans',
        isLegendary: true,
      ),

      // --- TOOLS AND AI ---
      AchievementDefinition(
        id: AppAchievements.cyberCollector,
        title: l10n.achievementCyberCollectorTitle,
        desc: l10n.achievementCyberCollectorDesc,
        icon: Icons.psychology_outlined,
        category: 'tools',
      ),
      AchievementDefinition(
        id: AppAchievements.hawkEye,
        title: l10n.achievementHawkEyeTitle,
        desc: l10n.achievementHawkEyeDesc,
        icon: Icons.camera_enhance_outlined,
        category: 'tools',
      ),
      AchievementDefinition(
        id: AppAchievements.polyglot,
        title: l10n.achievementPolyglotTitle,
        desc: l10n.achievementPolyglotDesc,
        icon: Icons.currency_exchange_rounded,
        category: 'tools',
      ),
      AchievementDefinition(
        id: AppAchievements.forecaster,
        title: l10n.achievementForecasterTitle,
        desc: l10n.achievementForecasterDesc,
        icon: Icons.fmd_bad_outlined,
        category: 'tools',
      ),
      AchievementDefinition(
        id: AppAchievements.masterUser,
        title: l10n.achievementMasterUserTitle,
        desc: l10n.achievementMasterUserDesc,
        icon: Icons.reorder_rounded,
        category: 'tools',
      ),
    ];
  }
}

// ── Predefined Themes & Brand Identity ──────────────────────────────────────
class AppCurrencies {
  static const String defaultCurrency = 'USD';

  static const String eur = 'EUR';
  static const String usd = 'USD';
  static const String gbp = 'GBP';
  static const String jpy = 'JPY';
  static const String mxn = 'MXN';

  static const List<String> allCodes = [eur, usd, gbp, jpy, mxn];

  static String getSymbol(String currencyCode) {
    switch (currencyCode) {
      case eur:
        return '€';
      case gbp:
        return '£';
      case jpy:
        return '¥';
      case mxn:
      case usd:
      default:
        return '\$';
    }
  }

  static bool usesTrailingSymbol(String currencyCode) {
    return currencyCode == eur;
  }

  static int getDecimalDigits(String currencyCode) {
    return currencyCode == jpy ? 0 : 2;
  }

  static Map<String, String> getLabels(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return {
      eur: l10n.currencyEur,
      usd: l10n.currencyUsd,
      gbp: l10n.currencyGbp,
      jpy: l10n.currencyJpy,
      mxn: l10n.currencyMxn,
    };
  }

  static String getLabel(BuildContext context, String code) {
    return getLabels(context)[code] ?? code;
  }
}

class AppThemes {
  static final CustomTheme brand = CustomTheme(
    id: 'brand',
    name: 'Invenicum (Brand)',
    primaryColor: const Color(0xFF1A237E),
    brightness: Brightness.light,
  );

  static final List<CustomTheme> predefined = [
    CustomTheme(id: 'emerald', name: 'Emerald', primaryColor: Colors.teal),
    CustomTheme(id: 'sunset', name: 'Sunset', primaryColor: Colors.orange),
    CustomTheme(id: 'ocean', name: 'Indian Ocean', primaryColor: Colors.blue),
    CustomTheme(
      id: 'lavender',
      name: 'Sweet Lavender',
      primaryColor: Colors.purple.shade300,
    ),
    CustomTheme(
      id: 'forest',
      name: 'Deep Forest',
      primaryColor: Colors.green.shade900,
    ),
    CustomTheme(id: 'cherry', name: 'Cherry', primaryColor: Colors.redAccent),
    CustomTheme(
      id: 'indigo',
      name: 'Electric Night',
      primaryColor: Colors.indigoAccent,
    ),
    CustomTheme(id: 'amber', name: 'Amber Gold', primaryColor: Colors.amber),
    CustomTheme(
      id: 'sakura',
      name: 'Cherry Blossom',
      primaryColor: Colors.pink.shade200,
    ),
    CustomTheme(
      id: 'slate',
      name: 'Modern Slate',
      primaryColor: Colors.blueGrey.shade700,
    ),
    CustomTheme(
      id: 'cyberpunk',
      name: 'Cyberpunk',
      primaryColor: Colors.pinkAccent,
      brightness: Brightness.dark,
    ),
    CustomTheme(
      id: 'nordic',
      name: 'Arctic Nord',
      primaryColor: Colors.lightBlue.shade100,
      brightness: Brightness.light,
    ),
    CustomTheme(
      id: 'dark_mode',
      name: 'Deep Night',
      primaryColor: Colors.blueGrey,
      brightness: Brightness.dark,
    ),
  ];
}
