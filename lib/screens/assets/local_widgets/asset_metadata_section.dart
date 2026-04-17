import 'package:flutter/material.dart';
import 'package:invenicum/core/utils/common_functions.dart';
import 'package:invenicum/l10n/app_localizations.dart';

class AssetMetadataSection extends StatelessWidget {
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? assetId;

  const AssetMetadataSection({
    Key? key,
    required this.createdAt,
    required this.updatedAt,
    required this.assetId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade600, size: 24),
              const SizedBox(width: 12),
              Text(
                l10n.additionalInformation,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            if (createdAt != null)
              _buildChip(
                context,
                Icons.access_time,
                l10n.createdAt,
                AppUtils.formatDate(context, createdAt!),
              ),
            if (updatedAt != null)
              _buildChip(
                context,
                Icons.update,
                l10n.updatedAt,
                AppUtils.formatDate(context, updatedAt!),
              ),
            if (assetId != null)
              _buildChip(context, Icons.tag, 'ID', assetId!, isId: true),
          ],
        ),
      ],
    );
  }

  Widget _buildChip(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    bool isId = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.blue.shade600),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Tooltip(
                message: value,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
