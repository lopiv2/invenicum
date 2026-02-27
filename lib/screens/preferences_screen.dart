import 'package:flutter/material.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/providers/theme_provider.dart';
import 'package:invenicum/widgets/general_settings_card_widget.dart';
import 'package:invenicum/widgets/loan_management_card_widget.dart';
import 'package:invenicum/widgets/about_card_widget.dart';
import 'package:invenicum/widgets/theme_picker_modal_widget.dart';
import 'package:invenicum/widgets/notification_settings_card_widget.dart';
import 'package:provider/provider.dart';

// Definimos las categorías para el menú lateral
enum PreferenceCategory { general, notifications, loans, about }

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  // Categoría seleccionada por defecto
  PreferenceCategory _selectedCategory = PreferenceCategory.general;

  @override
  Widget build(BuildContext context) {
    // Datos de tema necesarios para el widget general
    final themeName = context.select<ThemeProvider, String>(
      (p) => p.currentTheme.name,
    );
    final themeColor = context.select<ThemeProvider, Color>(
      (p) => p.currentTheme.primaryColor,
    );
    final themeProvider = context.read<ThemeProvider>();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Si el ancho es menor a 700px, usamos la vista clásica de lista (Móvil)
        if (constraints.maxWidth < 700) {
          return _buildMobileLayout(
            context,
            themeName,
            themeColor,
            themeProvider,
          );
        }

        // Si hay espacio, usamos la vista dividida (Desktop/Tablet)
        return _buildDesktopLayout(
          context,
          themeName,
          themeColor,
          themeProvider,
        );
      },
    );
  }

  // --- DISEÑO PARA MÓVIL (Lista Vertical) ---
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
          const NotificationSettingsCardWidget(),
          const SizedBox(height: 16),
          const LoanManagementCardWidget(),
          const SizedBox(height: 16),
          const AboutCardWidget(),
        ],
      ),
    );
  }

  // --- DISEÑO PARA TABLET/ESCRITORIO (Barra lateral + Contenido) ---
  Widget _buildDesktopLayout(
    BuildContext context,
    String themeName,
    Color themeColor,
    ThemeProvider provider,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Panel Izquierdo: Menú de Categorías
        Container(
          width: 280,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 40),
              _buildCategoryItem(
                title: "Ajustes Generales",
                icon: Icons.settings_outlined,
                category: PreferenceCategory.general,
              ),
              _buildCategoryItem(
                title: "Notificaciones",
                icon: Icons.notifications_none_outlined,
                category: PreferenceCategory.notifications,
              ),
              _buildCategoryItem(
                title: "Gestión Préstamos",
                icon: Icons.handshake_outlined,
                category: PreferenceCategory.loans,
              ),
              _buildCategoryItem(
                title: "Información",
                icon: Icons.info_outline,
                category: PreferenceCategory.about,
              ),
            ],
          ),
        ),

        // Divisor vertical sutil
        VerticalDivider(
          width: 1,
          thickness: 1,
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),

        // Panel Derecho: Contenido dinámico
        Expanded(
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
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

  // --- HELPERS DE UI ---

  Widget _buildHeader(BuildContext context) {
    return Text(
      AppLocalizations.of(context)!.preferences,
      style: Theme.of(
        context,
      ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildCategoryItem({
    required String title,
    required IconData icon,
    required PreferenceCategory category,
  }) {
    final isSelected = _selectedCategory == category;
    final color = isSelected
        ? Theme.of(context).primaryColor
        : Theme.of(context).hintColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        onTap: () => setState(() => _selectedCategory = category),
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).textTheme.bodyLarge?.color
                : color,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSelectedCategoryContent(
    String themeName,
    Color themeColor,
    ThemeProvider provider,
  ) {
    // Cada categoría devuelve su widget correspondiente
    switch (_selectedCategory) {
      case PreferenceCategory.general:
        return GeneralSettingsCardWidget(
          key: const ValueKey('general'),
          themeName: themeName,
          themeColor: themeColor,
          onThemePickerTap: () => showThemePickerModal(context, provider),
        );
      case PreferenceCategory.notifications:
        return const NotificationSettingsCardWidget(key: ValueKey('notifs'));
      case PreferenceCategory.loans:
        return const LoanManagementCardWidget(key: ValueKey('loans'));
      case PreferenceCategory.about:
        return const AboutCardWidget(key: ValueKey('about'));
    }
  }
}
