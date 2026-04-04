import 'package:flutter/material.dart';
import 'package:invenicum/data/models/integration_field_type.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'status_chip.dart';
import 'integration_visual.dart';

class IntegrationTile extends StatefulWidget {
  const IntegrationTile({
    super.key,
    required this.integration,
    required this.accent,
    required this.isLinked,
    required this.onTap,
  });

  final IntegrationModel integration;
  final Color accent;
  final bool isLinked;
  final VoidCallback onTap;

  @override
  State<IntegrationTile> createState() => _IntegrationTileState();
}

class _IntegrationTileState extends State<IntegrationTile> {
  late final ScrollController _descriptionScrollController;

  @override
  void initState() {
    super.initState();
    _descriptionScrollController = ScrollController();
  }

  @override
  void dispose() {
    _descriptionScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isMobile = MediaQuery.sizeOf(context).width < 700;

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, widget.accent.withValues(alpha: 0.06)],
          ),
          border: Border.all(color: widget.accent.withValues(alpha: 0.20)),
          boxShadow: [
            BoxShadow(
              color: widget.accent.withValues(alpha: 0.10),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        StatusChip(
                          label: widget.isLinked
                              ? l10n.integrationStatusConnected
                              : l10n.integrationStatusNotConfigured,
                          background: widget.isLinked
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFFFEDD5),
                          foreground: widget.isLinked
                              ? const Color(0xFF166534)
                              : const Color(0xFF9A3412),
                          icon: widget.isLinked
                              ? Icons.check_circle_rounded
                              : Icons.tune_rounded,
                        ),
                        StatusChip(
                          label: widget.integration.isDataSource
                              ? l10n.integrationTypeDataSource
                              : l10n.integrationTypeConnector,
                          background: widget.accent.withValues(alpha: 0.12),
                          foreground: widget.accent,
                          icon: widget.integration.isDataSource
                              ? Icons.cloud_download_outlined
                              : Icons.settings_input_component_rounded,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  IntegrationVisual(
                    icon: widget.integration.icon,
                    image: widget.integration.image,
                    accent: widget.accent,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                widget.integration.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: isMobile
                    ? Scrollbar(
                        controller: _descriptionScrollController,
                        thumbVisibility: true,
                        trackVisibility: true,
                        child: SingleChildScrollView(
                          controller: _descriptionScrollController,
                          child: Text(
                            widget.integration.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.35,
                            ),
                          ),
                        ),
                      )
                    : Text(
                        widget.integration.description,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  if (widget.integration.fields.isNotEmpty)
                    Text(
                      l10n.integrationFieldsCount(
                        widget.integration.fields.length,
                      ),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  else
                    Text(
                      l10n.integrationNoLocalCredentials,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  const Spacer(),
                  Material(
                    color: widget.accent,
                    borderRadius: BorderRadius.circular(999),
                    child: InkWell(
                      onTap: widget.onTap,
                      borderRadius: BorderRadius.circular(999),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.isLinked
                                  ? l10n.editLabel
                                  : l10n.configureLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.arrow_outward_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
