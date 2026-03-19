import 'package:flutter/material.dart';
import 'package:invenicum/core/utils/constants.dart';
import 'package:invenicum/screens/asset_types/local_widgets/condition_badge_widget.dart';
import 'package:invenicum/widgets/ui/bento_box_widget.dart';

class StatusSectionWidget extends StatelessWidget {
  final ItemCondition selectedCondition;
  final ValueChanged<ItemCondition> onConditionChanged;

  const StatusSectionWidget({
    super.key,
    required this.selectedCondition,
    required this.onConditionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BentoBoxWidget(
      width: 450,
      title: "Estado y Preferencias",
      icon: Icons.stars_outlined,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DropdownButtonFormField<ItemCondition>(
              value: selectedCondition,
              isExpanded: true, // Para que el badge tenga espacio
              decoration: const InputDecoration(
                labelText: "Estado del ítem",
                border: OutlineInputBorder(), // Opcional: para que encaje con tu estilo
              ),
              // Esta propiedad define cómo se ve el ítem seleccionado cuando el menú está cerrado
              selectedItemBuilder: (BuildContext context) {
                return ItemCondition.values.map((condition) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: ConditionBadgeWidget(condition: condition),
                  );
                }).toList();
              },
              items: ItemCondition.values.map((condition) {
                return DropdownMenuItem(
                  value: condition,
                  child: ConditionBadgeWidget(condition: condition), // 🚀 Usamos el badge aquí
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) onConditionChanged(val);
              },
            ),
          ),
        ],
      ),
    );
  }
}