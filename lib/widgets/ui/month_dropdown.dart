import 'package:flutter/material.dart';
import 'package:invenicum/core/utils/common_functions.dart';
import 'package:invenicum/screens/home/local_widgets/charts/glass_ui_elements.dart';

class MonthDropdown extends StatelessWidget {
  final int selectedMonth;
  final Function(int) onChanged;

  const MonthDropdown({
    super.key,
    required this.selectedMonth,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Detectamos el locale automáticamente del contexto
    final String locale = Localizations.localeOf(context).languageCode;

    return GlassDropdown<int>(
      value: selectedMonth,
      items: List.generate(12, (i) => i + 1).map((m) {
        return DropdownMenuItem(
          value: m,
          child: Text(AppUtils.getLocalizedMonth(m, locale)),
        );
      }).toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}