import 'package:flutter/material.dart';
import 'package:invenicum/core/utils/common_functions.dart';
import 'package:invenicum/data/models/custom_field_definition_model.dart';
import 'package:provider/provider.dart';
import 'package:invenicum/data/models/inventory_item.dart';
import 'package:invenicum/data/models/asset_type_model.dart';
import 'package:invenicum/data/models/container_node.dart';
import 'package:invenicum/data/models/custom_field_definition.dart';
import 'package:invenicum/providers/container_provider.dart';

class AssetTechnicalSpecsWidget extends StatelessWidget {
  final InventoryItem item;
  final String containerId;
  final String assetTypeId;

  const AssetTechnicalSpecsWidget({
    super.key,
    required this.item,
    required this.containerId,
    required this.assetTypeId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final containerProvider = context.watch<ContainerProvider>();

    // 1. Localización segura del Asset Type
    final container = containerProvider.containers.cast<ContainerNode?>().firstWhere(
          (c) => c?.id.toString() == containerId,
          orElse: () => null,
        );
    final assetType = container?.assetTypes.cast<AssetType?>().firstWhere(
          (at) => at?.id.toString() == assetTypeId,
          orElse: () => null,
        );

    if (assetType == null) return const SizedBox.shrink();

    // 2. Filtrado de campos que tienen valor
    final fieldsWithValues = assetType.fieldDefinitions.where((fd) {
      final val = item.customFieldValues?[fd.id.toString()] ?? item.customFieldValues?[fd.name];
      return val != null && val.toString().isNotEmpty;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.description != null && item.description!.isNotEmpty) ...[
          Text(item.description!, style: theme.textTheme.bodyMedium),
          const Divider(height: 32),
        ],
        
        if (fieldsWithValues.isEmpty)
          const Text("No hay especificaciones disponibles", style: TextStyle(color: Colors.grey))
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              mainAxisExtent: 50,
              crossAxisSpacing: 10,
              mainAxisSpacing: 15,
            ),
            itemCount: fieldsWithValues.length,
            itemBuilder: (context, index) {
              final fd = fieldsWithValues[index];
              final val = item.customFieldValues?[fd.id.toString()] ?? item.customFieldValues?[fd.name];
              return _buildFieldItem(fd, val);
            },
          ),
      ],
    );
  }

  Widget _buildFieldItem(CustomFieldDefinition fd, dynamic val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          fd.name.toUpperCase(),
          style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        const SizedBox(height: 4),
        Expanded(child: _buildValueWidget(fd, val)),
      ],
    );
  }

  Widget _buildValueWidget(CustomFieldDefinition fd, dynamic val) {
    if (fd.type == CustomFieldType.url) {
      return InkWell(
        onTap: () => AppUtils.launchUrlWeb(val.toString()),
        child: Text(
          val.toString(),
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline, fontSize: 13),
        ),
      );
    }
    if (fd.type == CustomFieldType.boolean) {
      return Icon(
        val == true ? Icons.check_circle : Icons.cancel,
        color: val == true ? Colors.green : Colors.red,
        size: 18,
      );
    }
    return Text(
      val.toString(),
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      overflow: TextOverflow.ellipsis,
    );
  }
}