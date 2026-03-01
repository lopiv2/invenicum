import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invenicum/models/custom_field_definition.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class AppUtils {
  /// 🌐 Lanza una URL externa (Docs, Web, etc.)
  static Future<void> launchWebUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'No se pudo abrir la URL: $url';
    }
  }

  /// 📧 Abre el gestor de correo
  static Future<void> sendEmail(String email, {String subject = ''}) async {
    final Uri uri = Uri.parse('mailto:$email?subject=${Uri.encodeComponent(subject)}');
    if (!await launchUrl(uri)) throw 'No se pudo abrir el correo';
  }

  /// 📅 Formatea una fecha de forma legible (ej: 10 Feb 2026)
  static String formatDate(DateTime date, {String locale = 'es'}) {
    return DateFormat.yMMMd(locale).format(date);
  }

  /// 💰 Formatea moneda (ej: 1.500,00 €)
  static String formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '€', locale: 'es_ES').format(amount);
  }

  /// 📋 Copia texto al portapapeles
  static Future<void> copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Copiado al portapapeles")),
      );
    }
  }

  /// 🎨 Genera un color a partir de un String (útil para Avatares)
  static Color stringToColor(String name) {
    return Color((name.hashCode & 0xFFFFFF) | 0xFF000000);
  }

    static CustomFieldType parseType(String? type) {
    switch (type?.toLowerCase()) {
      case 'number': return CustomFieldType.number;
      case 'date': return CustomFieldType.date;
      case 'boolean': return CustomFieldType.boolean;
      case 'dropdown': return CustomFieldType.dropdown;
      case 'url': return CustomFieldType.url;
      case 'price': return CustomFieldType.price;
      default: return CustomFieldType.text;
    }
  }
}