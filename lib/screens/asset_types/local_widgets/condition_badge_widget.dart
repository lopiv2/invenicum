import 'package:flutter/material.dart';
import 'package:invenicum/core/utils/constants.dart';

class ConditionBadgeWidget extends StatelessWidget {
  final ItemCondition condition;

  const ConditionBadgeWidget({super.key, required this.condition});

  @override
  Widget build(BuildContext context) {
    final color = condition.color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(condition.icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            condition.getLocalizedString(context),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}