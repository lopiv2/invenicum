import 'package:flutter/material.dart';
import 'package:invenicum/core/utils/theme_name_localizer.dart';
import 'package:invenicum/data/models/custom_theme_model.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/providers/theme_provider.dart';
import 'package:invenicum/screens/preferences/local_widgets/ai_provider_card_widget.dart';
import 'package:invenicum/screens/preferences/local_widgets/general_settings_card_widget.dart';
import 'package:invenicum/screens/preferences/local_widgets/loan_management_card_widget.dart';
import 'package:invenicum/screens/preferences/local_widgets/about_card_widget.dart';
import 'package:invenicum/screens/preferences/local_widgets/theme_picker_modal_widget.dart';
import 'package:invenicum/screens/preferences/local_widgets/notification_settings_card_widget.dart';
import 'package:provider/provider.dart';

// Define the categories for the side menu
enum PreferenceCategory { general, ai, notifications, loans, about }

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  // Default selected category
  PreferenceCategory _selectedCategory = PreferenceCategory.general;

  @override
  Widget build(BuildContext context) {
    // Theme data required by the general widget
    final currentTheme = context.select<ThemeProvider, CustomTheme>(
      (p) => p.currentTheme,
    );
    final themeName = localizeThemeName(context, currentTheme);
    final themeColor = context.select<ThemeProvider, Color>(
      (p) => p.currentTheme.primaryColor,
    );
    final themeProvider = context.read<ThemeProvider>();

    return LayoutBuilder(
      builder: (context, constraints) {
        // If the width is less than 700px, use the classic list view (Mobile)
        if (constraints.maxWidth < 700) {
          return _buildMobileLayout(
            context,
            themeName,
            themeColor,
            themeProvider,
          );
        }

        // If there is space, use the split view (Desktop/Tablet)
        return _buildDesktopLayout(
          context,
          themeName,
          themeColor,
          themeProvider,
        );
      },
    );
  }

  // --- MOBILE LAYOUT (Vertical List) ---
  Widget _buildMobileLayout(
    BuildContext context,
    String themeName,
    Color themeColor,
    ThemeProvider provider,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          GeneralSettingsCardWidget(
            themeName: themeName,
            themeColor: themeColor,
            onThemePickerTap: () => showThemePickerModal(context, provider),
          ),
          const SizedBox(height: 16),
          const AiProviderCardWidget(),
          const SizedBox(height: 16),
          const NotificationSettingsCardWidget(),
          const SizedBox(height: 16),
          const LoanManagementCardWidget(),
          const SizedBox(height: 16),
          const AboutCardWidget(),
        ],
      ),
    );
  }

  // --- TABLET/DESKTOP LAYOUT (Sidebar + Content) ---
  Widget _buildDesktopLayout(
    BuildContext context,
    String themeName,
    Color themeColor,
    ThemeProvider provider,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Panel: Categories menu
        Container(
          width: 280,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 40),
              _buildCategoryItem(
                icon: Icons.settings_outlined,
                category: PreferenceCategory.general,
              ),
              _buildCategoryItem(
                icon: Icons.psychology_outlined,
                category: PreferenceCategory.ai,
              ),
              _buildCategoryItem(
                icon: Icons.notifications_none_outlined,
                category: PreferenceCategory.notifications,
              ),
              _buildCategoryItem(
                icon: Icons.handshake_outlined,
                category: PreferenceCategory.loans,
              ),
              _buildCategoryItem(
                icon: Icons.info_outline,
                category: PreferenceCategory.about,
              ),
            ],
          ),
        ),

        // Subtle vertical divider
        VerticalDivider(
          width: 1,
          thickness: 1,
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ),

        // Right Panel: Dynamic content
        Expanded(
          child: Container(
            color: Theme.of(
              context,
            ).scaffoldBackgroundColor.withValues(alpha: 0.5),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40.0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _buildSelectedCategoryContent(
                  themeName,
                  themeColor,
                  provider,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- UI HELPERS ---

  Widget _buildHeader(BuildContext context) {
    return Text(
      AppLocalizations.of(context)!.preferences,
      style: Theme.of(
        context,
      ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildCategoryItem({
    required IconData icon,
    required PreferenceCategory category,
  }) {
    final isSelected = _selectedCategory == category;
    final color = isSelected
        ? Theme.of(context).primaryColor
        : Theme.of(context).hintColor;

    final l10n = AppLocalizations.of(context)!;
    final categoryTitle = switch (category) {
      PreferenceCategory.general => l10n.generalSettingsMenuLabel,
      PreferenceCategory.ai => l10n.aiAssistantMenuLabel,
      PreferenceCategory.notifications => l10n.notificationsMenuLabel,
      PreferenceCategory.loans => l10n.loanManagementMenuLabel,
      PreferenceCategory.about => l10n.aboutMenuLabel,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        onTap: () => setState(() => _selectedCategory = category),
        leading: Icon(icon, color: color),
        title: Text(
          categoryTitle,
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).textTheme.bodyLarge?.color
                : color,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedTileColor: Theme.of(
          context,
        ).primaryColor.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSelectedCategoryContent(
    String themeName,
    Color themeColor,
    ThemeProvider provider,
  ) {
    // Each category returns its corresponding widget
    switch (_selectedCategory) {
      case PreferenceCategory.general:
        return GeneralSettingsCardWidget(
          key: const ValueKey('general'),
          themeName: themeName,
          themeColor: themeColor,
          onThemePickerTap: () => showThemePickerModal(context, provider),
        );
      case PreferenceCategory.ai:
        return const AiProviderCardWidget(key: ValueKey('ai'));
      case PreferenceCategory.notifications:
        return const NotificationSettingsCardWidget(key: ValueKey('notifs'));
      case PreferenceCategory.loans:
        return const LoanManagementCardWidget(key: ValueKey('loans'));
      case PreferenceCategory.about:
        return const AboutCardWidget(key: ValueKey('about'));
    }
  }
}
