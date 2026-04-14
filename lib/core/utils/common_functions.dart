import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invenicum/data/models/custom_field_definition.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class AppUtils {
  /// 🌐 Lanza una URL externa (Docs, Web, etc.)

  static Future<void> launchUrlWeb(String url) async {
    final Uri uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $uri');
    }
  }

  /// 📧 Abre el gestor de correo
  static Future<void> sendEmail(String email, {String subject = ''}) async {
    final Uri uri = Uri.parse(
      'mailto:$email?subject=${Uri.encodeComponent(subject)}',
    );
    if (!await launchUrl(uri)) throw 'No se pudo abrir el correo';
  }

  ///  Format a date in a readable way (e.g., Feb 10, 2026)
  static String formatDate(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.yMMMd(locale).format(date);
  }

  /// Genera el nombre del mes localizado y con la primera letra en mayúscula
  static String getLocalizedMonth(
    int month,
    String locale, {
    bool short = false,
  }) {
    final DateTime date = DateTime(2000, month);

    // Si short es true, usamos 'MMMMM' (que devuelve la inicial: E, F, M...)
    // Si short es false, usamos 'MMM' (que devuelve la abreviatura: ene, feb...)
    final String pattern = short ? 'MMMMM' : 'MMM';

    String monthName = DateFormat(pattern, locale).format(date);

    // Limpiamos puntos (común en 'ene.' o 'feb.')
    monthName = monthName.replaceAll('.', '');

    if (monthName.isEmpty) return "";

    // Capitalizamos la primera letra
    return monthName[0].toUpperCase() + (short ? "" : monthName.substring(1));
  }

  /// 💰 Formatea moneda (ej: 1.500,00 €)
  static String formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '€', locale: 'es_ES').format(amount);
  }

  /// 📋 Copia texto al portapapeles
  static Future<void> copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.copiedToClipboard)));
    }
  }

  /// 🎨 Genera un color a partir de un String (útil para Avatares)
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
}
