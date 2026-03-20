import 'package:flutter/material.dart';
import 'package:invenicum/data/models/location.dart';

class LocationCardContent extends StatelessWidget {
  final Location location;
  final VoidCallback onTap;
  final bool isSelected;

  const LocationCardContent({
    super.key,
    required this.location,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final isRoot = location.parentId == null;

    final borderColor = isSelected
        ? Colors.orange.shade700
        : isRoot
            ? Colors.blue.shade300
            : Colors.transparent;

    final cardColor = isSelected
        ? Colors.orange.shade100
        : isRoot
            ? Colors.blue.shade50
            : Colors.grey.shade100;

    // Usamos GestureDetector con behavior.opaque para que el tap no se
    // pierda en zonas transparentes y para que no lo capture el GraphView.
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Card(
        elevation: 4,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                location.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isRoot ? Colors.blue.shade900 : Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (location.description != null &&
                  location.description!.isNotEmpty)
                Text(
                  location.description!,
                  style:
                      const TextStyle(fontSize: 10, color: Colors.black54),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }
}