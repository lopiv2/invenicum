import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invenicum/data/models/custom_field_definition.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class AppUtils {

  /// 🌐 Launches an external URL (Docs, Web, etc.)
  static Future<void> launchUrlWeb(String url) async {
    final Uri uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $uri');
    }
  }

  /// 📧 Opens the email client with a predefined subject
  static Future<void> sendEmail(String email, {String subject = ''}) async {
    final Uri uri = Uri.parse(
      'mailto:$email?subject=${Uri.encodeComponent(subject)}',
    );
    if (!await launchUrl(uri)) throw 'No se pudo abrir el correo';
  }

  /// 📅 Format a date in a readable way (e.g., Feb 10, 2026)
  static String formatDate(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.yMMMd(locale).format(date);
  }

  /// 📅 Generates the localized month name with the first letter capitalized
  static String getLocalizedMonth(
    int month,
    String locale, {
    bool short = false,
  }) {
    final DateTime date = DateTime(2000, month);

    // If short is true, use 'MMMMM' (which returns the initial: E, F, M...)
    // If short is false, use 'MMM' (which returns the abbreviation: Jan, Feb...)
    final String pattern = short ? 'MMMMM' : 'MMM';

    String monthName = DateFormat(pattern, locale).format(date);

    // Remove dots (common in 'Jan.' or 'Feb.')
    monthName = monthName.replaceAll('.', '');

    if (monthName.isEmpty) return "";

    // Capitalize the first letter
    return monthName[0].toUpperCase() + (short ? "" : monthName.substring(1));
  }

  /// 💰 Formats currency (e.g., 1,500.00 €)
  static String formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '€', locale: 'es_ES').format(amount);
  }

  /// 📋 Copies text to the clipboard
  static Future<void> copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.copiedToClipboard)));
    }
  }

  /// 🎨 Generates a color from a String (useful for Avatars)
  static Color stringToColor(String name) {
    return Color((name.hashCode & 0xFFFFFF) | 0xFF000000);
  }

  static CustomFieldType parseType(String? type) {
    switch (type?.toLowerCase()) {
      case 'number':
        return CustomFieldType.number;
      case 'date':
        return CustomFieldType.date;
      case 'boolean':
        return CustomFieldType.boolean;
      case 'dropdown':
        return CustomFieldType.dropdown;
      case 'url':
        return CustomFieldType.url;
      case 'price':
        return CustomFieldType.price;
      default:
        return CustomFieldType.text;
    }
  }

  /// 🔤 Sorts a list of strings in ascending order (case-insensitive).
  static List<String> sortAscending(List<String> items) {
    items.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return items;
  }

  /// 🔤 Sorts a list of strings in descending order (case-insensitive).
  static List<String> sortDescending(List<String> items) {
    items.sort((a, b) => b.toLowerCase().compareTo(a.toLowerCase()));
    return items;
  }
}
