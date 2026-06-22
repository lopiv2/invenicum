import 'package:flutter/material.dart';
import 'package:invenicum/core/utils/common_functions.dart';
import 'package:invenicum/core/utils/retro/retro_dialog_helper.dart';
import 'package:invenicum/data/models/asset_type_model.dart';
import 'package:invenicum/data/models/custom_field_definition.dart';
import 'package:invenicum/data/models/custom_field_definition_model.dart';
import 'package:invenicum/data/services/toast_service.dart';
import 'package:provider/provider.dart';
import 'package:invenicum/providers/container_provider.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/screens/asset_types/local_widgets/action_button.dart';

class AssetTypeCard extends StatefulWidget {
  final String containerId;
  final AssetType assetType;
  final int assetCount;
  final bool isCollection;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  const AssetTypeCard({
    super.key,
    required this.containerId,
    required this.assetType,
    required this.assetCount,
    required this.isCollection,
    this.onTap,
    this.onEdit,
  });

  @override
  State<AssetTypeCard> createState() => _AssetTypeCardState();
}

class _AssetTypeCardState extends State<AssetTypeCard> {
  bool _hovered = false;

  // ─── Colores según tipo ───────────────────────────────────────────────────

  Color get _accentColor => widget.isCollection ? Colors.green : Colors.blue;

  Color get _accentContainer => widget.isCollection
      ? Colors.green.withValues(alpha: 0.78)
      : Colors.blue.withValues(alpha: 0.18);

  Color get _onAccentContainer =>
      widget.isCollection ? Colors.green.shade200 : Colors.blue.shade600;

  LinearGradient get _badgeGradient {
    final base = _accentColor;
    final dark = Color.lerp(base, Colors.black, 0.35)!;
    final light = Color.lerp(base, Colors.white, 0.25)!;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [dark, base, light],
    );
  }

  // ─── Lógica (sin cambios) ─────────────────────────────────────────────────

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showAppDialog<bool>(
          context: context,
          title: AppLocalizations.of(context)!.confirmDeletion,
          body: Text(
            AppLocalizations.of(
              context,
            )!.confirmDeleteAssetType(widget.assetType.name),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(AppLocalizations.of(context)!.delete),
            ),
          ],
        ) ??
        false;
  }

  void _showConfigureCollectionDialog(BuildContext context) async {
    if (!widget.isCollection) {
      ToastService.error(
        AppLocalizations.of(context)!.possessionDesiredOnlyInCollection,
      );
      return;
    }
    if (widget.assetType.isSerialized) {
      ToastService.error(
        AppLocalizations.of(context)!.collectionFieldsOnlyForNonSerialized,
      );
      return;
    }

    String? possessionFieldId = widget.assetType.possessionFieldId;
    String? desiredFieldId = widget.assetType.desiredFieldId;

    final booleanFields = widget.assetType.fieldDefinitions
        .where((f) => f.type == CustomFieldType.boolean)
        .toList();

    if (!context.mounted) return;

    final result = await showAppDialog<Map<String, String?>>(
      context: context,
      title: AppLocalizations.of(context)!.configureCollectionFields,
      body: StatefulBuilder(
        builder: (context, setDialogState) => SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.selectBooleanFields,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              _buildDropdownLabel(
                AppLocalizations.of(context)!.possessionFieldDef,
              ),
              _buildDropdown(
                context,
                value: possessionFieldId,
                fields: booleanFields,
                onChanged: (val) =>
                    setDialogState(() => possessionFieldId = val),
              ),
              const SizedBox(height: 20),
              _buildDropdownLabel(AppLocalizations.of(context)!.desiredField),
              _buildDropdown(
                context,
                value: desiredFieldId,
                fields: booleanFields,
                onChanged: (val) => setDialogState(() => desiredFieldId = val),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => Navigator.pop(context, {
            'possession': possessionFieldId,
            'desired': desiredFieldId,
          }),
          child: Text(AppLocalizations.of(context)!.save),
        ),
      ],
    );

    if (result != null && context.mounted) {
      try {
        final containerIdInt = int.tryParse(widget.containerId);
        if (containerIdInt == null) return;
        await context.read<ContainerProvider>().updateAssetTypeCollectionFields(
          containerId: containerIdInt,
          assetTypeId: widget.assetType.id,
          possessionFieldId: result['possession'],
          desiredFieldId: result['desired'],
        );
        if (context.mounted) {
          ToastService.success(
            AppLocalizations.of(context)!.configurationSaved,
          );
        }
      } catch (e) {
        if (context.mounted)
          ToastService.error(
            AppLocalizations.of(context)!.errorSaving(e.toString()),
          );
      }
    }
  }

  void _handleDelete(BuildContext context) async {
    final confirmed = await _showDeleteConfirmationDialog(context);
    if (confirmed) {
      try {
        await context.read<ContainerProvider>().deleteAssetType(
          int.parse(widget.containerId),
          widget.assetType.id,
        );
        if (context.mounted) {
          ToastService.success(
            AppLocalizations.of(
              context,
            )!.assetTypeDeletedSuccess(widget.assetType.name),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ToastService.error(AppLocalizations.of(context)!.unknownError);
        }
      }
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = widget.assetType.images.isNotEmpty;
    final fullImageUrl = hasImage
        ? AppUtils.buildImageUrl(widget.assetType.images.first.url)
        : '';

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.75),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
          boxShadow: [
            if (_hovered)
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.9),
                blurRadius: 15,
                offset: const Offset(0, 12),
              ),
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.7),
              blurRadius: _hovered ? 8 : 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Material(
            color: Colors.transparent, // necesario para InkWell
            child: InkWell(
              onTap: widget.onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _buildImageSection(theme, hasImage, fullImageUrl),
                  ),
                  _buildFooter(theme, hasImage),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Sección imagen ───────────────────────────────────────────────────────

  Widget _buildImageSection(ThemeData theme, bool hasImage, String imageUrl) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (hasImage)
          AnimatedScale(
            scale: _hovered ? 1.04 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              color: theme.colorScheme.scrim.withValues(alpha: 0.15),
              colorBlendMode: BlendMode.darken,
              errorBuilder: (_, __, ___) => _buildPlaceholder(theme),
            ),
          )
        else
          _buildPlaceholder(theme),

        if (hasImage)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  theme.colorScheme.scrim.withValues(alpha: 0.72),
                ],
                stops: const [0.25, 1.0],
              ),
            ),
          ),

        Positioned(
          top: 10,
          left: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              gradient: _badgeGradient,
              borderRadius: BorderRadius.circular(7),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.22),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              widget.isCollection
                  ? AppLocalizations.of(context)!.collectionLabel.toUpperCase()
                  : AppLocalizations.of(context)!.standardLabel.toUpperCase(),
              style: TextStyle(
                color: theme.colorScheme.onPrimary,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.9,
              ),
            ),
          ),
        ),

        if (hasImage)
          Positioned(
            bottom: 10,
            left: 12,
            right: 12,
            child: Text(
              widget.assetType.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

        Positioned(
          top: 8,
          right: 8,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isCollection)
                ActionButton(
                  icon: Icons.tune_rounded,
                  tooltip: AppLocalizations.of(
                    context,
                  )!.configureCollectionFields,
                  hoverColor: theme.colorScheme.outline.withValues(alpha: 0.88),
                  defaultColor: theme.colorScheme.onPrimary.withValues(
                    alpha: 0.80,
                  ),
                  onPressed: () => _showConfigureCollectionDialog(context),
                ),
              ActionButton(
                icon: Icons.edit_rounded,
                tooltip: AppLocalizations.of(context)!.edit,
                hoverColor: theme.colorScheme.secondary.withValues(alpha: 0.88),
                defaultColor: theme.colorScheme.onPrimary.withValues(
                  alpha: 0.80,
                ),
                onPressed: widget.onEdit,
              ),
              ActionButton(
                icon: Icons.delete_outline_rounded,
                tooltip: AppLocalizations.of(context)!.delete,
                hoverColor: theme.colorScheme.error.withValues(alpha: 0.88),
                defaultColor: theme.colorScheme.onPrimary.withValues(
                  alpha: 0.80,
                ),
                onPressed: () => _handleDelete(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.category_outlined,
          size: 36,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.25),
        ),
      ),
    );
  }

  // ─── Footer ───────────────────────────────────────────────────────────────

  Widget _buildFooter(ThemeData theme, bool hasImage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _accentColor.withValues(alpha: 0.06),
        border: Border(top: BorderSide(color: _accentColor, width: 3)),
      ),
      child: Row(
        children: [
          if (!hasImage) ...[
            Expanded(
              child: Text(
                widget.assetType.name,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 10),
          ],
          if (hasImage) const Spacer(),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: _accentContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  AppLocalizations.of(context)!.assetCount(widget.assetCount),
                  style: TextStyle(
                    color: _onAccentContainer,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers para diálogos ────────────────────────────────────────────────

  Widget _buildDropdownLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '$label:',
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildDropdown(
    BuildContext context, {
    required String? value,
    required List<CustomFieldDefinition> fields,
    required Function(String?) onChanged,
  }) {
    final dropdownTheme = Theme.of(context);
    if (fields.isEmpty) {
      return Text(
        AppLocalizations.of(context)!.noBooleanFields,
        style: TextStyle(
          color: dropdownTheme.colorScheme.onSurface.withValues(alpha: 0.5),
          fontSize: 13,
        ),
      );
    }
    return DropdownButtonFormField<String?>(
      initialValue: value,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: dropdownTheme.colorScheme.surfaceContainerHighest,
      ),
      hint: Text(AppLocalizations.of(context)!.selectField),
      items: [
        DropdownMenuItem(
          value: null,
          child: Text(AppLocalizations.of(context)!.none),
        ),
        ...fields.map(
          (field) => DropdownMenuItem(
            value: field.id.toString(),
            child: Text(field.name),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}
