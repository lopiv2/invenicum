// lib/utils/constants.dart
import 'package:flutter/material.dart';
import 'package:invenicum/l10n/app_localizations.dart';

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

  /// Obtiene el nombre traducido del slot
  static String getName(BuildContext context, String slot) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return slot;

    switch (slot) {
      case dashboardTop: return l10n.slotDashboardTop;
      case dashboardBottom: return l10n.slotDashboardBottom;
      case leftSidebar: return l10n.slotLeftSidebar;
      case inventoryHeader: return l10n.slotInventoryHeader;
      case floatingActionButton: return l10n.slotFloatingActionButton;
      default: return l10n.slotUnknown;
    }
  }
}