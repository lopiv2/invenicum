import 'package:flutter/material.dart';
import 'package:invenicum/core/utils/common_functions.dart';
import 'package:invenicum/data/models/inventory_item.dart';
import 'package:invenicum/l10n/app_localizations.dart';

class AssetMetadataWidget extends StatelessWidget {
  final InventoryItem item;
  final AppLocalizations l10n;

  const AssetMetadataWidget({
    super.key,
    required this.item,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildMetaRow(
          l10n.createdAt, 
          AppUtils.formatDate(context, item.createdAt!),
          Icons.calendar_today_rounded,
        ),
        const SizedBox(height: 12),
        _buildMetaRow(
          l10n.updatedAt, 
          AppUtils.formatDate(context, item.updatedAt!),
          Icons.update_rounded,
        ),
        const SizedBox(height: 12),
        _buildMetaRow(
          l10n.internalReferenceLabel,
          "#${item.id}",
          Icons.fingerprint_rounded,
        ),
      ],
    );
  }

  Widget _buildMetaRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[400]),
        const SizedBox(width: 8),
        Text(
          label, 
          style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12, 
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace', // Ideal para IDs y fechas
            ),
          ),
        ),
      ],
    );
  }
}