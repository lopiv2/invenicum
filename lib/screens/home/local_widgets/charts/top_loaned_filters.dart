import 'package:flutter/material.dart';
import 'package:invenicum/screens/home/local_widgets/charts/glass_ui_elements.dart';
import 'package:invenicum/widgets/ui/month_dropdown.dart';

class TopLoanedFilters extends StatelessWidget {
  final int selectedYear;
  final int selectedMonth;
  final List<int> years;
  final Function(int) onYearChanged;
  final Function(int) onMonthChanged;

  const TopLoanedFilters({
    super.key,
    required this.selectedYear,
    required this.selectedMonth,
    required this.years,
    required this.onYearChanged,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GlassDropdown<int>(
          value: selectedYear,
          items: years
              .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
              .toList(),
          onChanged: (v) => onYearChanged(v!),
        ),
        const SizedBox(width: 12),
        MonthDropdown(selectedMonth: selectedMonth, onChanged: onMonthChanged),
      ],
    );
  }
}
