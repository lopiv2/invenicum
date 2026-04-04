import 'package:flutter/material.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/data/services/report_service.dart';
import 'package:invenicum/data/services/toast_service.dart';
import 'package:provider/provider.dart';
import 'package:invenicum/providers/container_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedReportType = 'inventory'; // 'inventory', 'loans', 'assets'
  String _selectedFormat = 'pdf'; // 'pdf', 'excel'
  bool _isGenerating = false;
  int? _selectedContainerId;

  @override
  void initState() {
    super.initState();
    // Cargar contenedores al abrir la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final containerProvider = context.read<ContainerProvider>();
        if (containerProvider.containers.isEmpty) {
          containerProvider.loadContainers();
        } else if (_selectedContainerId == null &&
            containerProvider.containers.isNotEmpty) {
          // Seleccionar el primer contenedor por defecto
          setState(
            () => _selectedContainerId = containerProvider.containers.first.id,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final containerProvider = context.watch<ContainerProvider>();

    // Si no hay contenedor seleccionado y hay contenedores disponibles, seleccionar el primero
    if (_selectedContainerId == null &&
        containerProvider.containers.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(
            () => _selectedContainerId = containerProvider.containers.first.id,
          );
        }
      });
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;
        final isTablet =
            constraints.maxWidth >= 700 && constraints.maxWidth < 1100;
        final horizontalPadding = isMobile ? 16.0 : (isTablet ? 24.0 : 40.0);
        final sectionGap = isMobile ? 28.0 : 40.0;
        final maxContentWidth = isMobile ? double.infinity : 1080.0;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: isMobile ? 20 : 32,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroHeader(context),
                  SizedBox(height: sectionGap),

                  if (containerProvider.containers.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.loadingContainers,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    _buildContainerSelector(
                      context,
                      containerProvider,
                      isMobile: isMobile,
                    ),
                  SizedBox(height: sectionGap),

                  Container(
                    padding: EdgeInsets.all(isMobile ? 16 : 24),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: colorScheme.outlineVariant),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: 0.06),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(context, l10n.reportSectionType),
                        const SizedBox(height: 16),
                        _buildReportTypeSelector(
                          context,
                          availableWidth:
                              constraints.maxWidth - (horizontalPadding * 2),
                        ),
                        SizedBox(height: sectionGap),

                        _buildSectionTitle(context, l10n.reportSectionFormat),
                        const SizedBox(height: 16),
                        _buildFormatSelector(context),
                        SizedBox(height: sectionGap),

                        _buildPreviewSection(
                          context,
                          availableWidth:
                              constraints.maxWidth - (horizontalPadding * 2),
                        ),
                        SizedBox(height: sectionGap),

                        SizedBox(
                          width: double.infinity,
                          height: isMobile ? 52 : 56,
                          child: ElevatedButton.icon(
                            onPressed: _isGenerating
                                ? null
                                : () => _generateReport(context),
                            icon: _isGenerating
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        colorScheme.onPrimary,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.download),
                            label: Text(
                              _isGenerating
                                  ? l10n.reportGenerating
                                  : l10n.reportGenerate,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              textStyle: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withValues(alpha: 0.14),
            colorScheme.tertiary.withValues(alpha: 0.12),
            colorScheme.surfaceContainerHigh,
          ],
        ),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.reports,
            style: textTheme.headlineMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.reportsDescription,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContainerSelector(
    BuildContext context,
    ContainerProvider containerProvider, {
    required bool isMobile,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.reportSelectContainerTitle,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: _selectedContainerId,
            isExpanded: true,
            items: containerProvider.containers
                .map(
                  (container) => DropdownMenuItem<int>(
                    value: container.id,
                    child: Text(
                      container.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (int? newValue) {
              if (newValue != null) {
                setState(() => _selectedContainerId = newValue);
              }
            },
            hint: Text(l10n.selectContainerHint),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHigh,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Text(
      title,
      style: textTheme.titleLarge?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildReportTypeSelector(
    BuildContext context, {
    required double availableWidth,
  }) {
    final l10n = AppLocalizations.of(context)!;

    final reportTypes = [
      {
        'id': 'inventory',
        'label': l10n.inventoryLabel,
        'description': l10n.reportTypeInventoryDescription,
        'icon': Icons.inventory_2,
      },
      {
        'id': 'loans',
        'label': l10n.loans,
        'description': l10n.reportTypeLoansDescription,
        'icon': Icons.assignment_turned_in,
      },
      {
        'id': 'assets',
        'label': l10n.assets,
        'description': l10n.reportTypeAssetsDescription,
        'icon': Icons.category,
      },
    ];

    final crossAxisCount = availableWidth < 620
        ? 1
        : (availableWidth < 950 ? 2 : 3);
    final childAspectRatio = crossAxisCount == 1
        ? 2.75
        : (crossAxisCount == 2 ? 1.25 : 0.9);

    return GridView.builder(
      itemCount: reportTypes.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) {
        final type = reportTypes[index];
        final isSelected = _selectedReportType == type['id'];

        return _buildReportTypeCard(
          context,
          isSelected: isSelected,
          icon: type['icon'] as IconData,
          label: type['label'] as String,
          description: type['description'] as String,
          isWideCard: crossAxisCount == 1,
          onTap: () {
            setState(() => _selectedReportType = type['id'] as String);
          },
        );
      },
    );
  }

  Widget _buildReportTypeCard(
    BuildContext context, {
    required bool isSelected,
    required IconData icon,
    required String label,
    required String description,
    required bool isWideCard,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(16),
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.1)
                : colorScheme.surface,
          ),
          child: isWideCard
              ? Row(
                  children: [
                    Icon(
                      icon,
                      size: 30,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: textTheme.titleSmall?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 32,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      label,
                      style: textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildFormatSelector(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildFormatChip(
          context,
          label: l10n.reportFormatPdf,
          value: 'pdf',
          icon: Icons.picture_as_pdf,
        ),
        _buildFormatChip(
          context,
          label: l10n.reportFormatExcel,
          value: 'excel',
          icon: Icons.table_chart,
        ),
      ],
    );
  }

  Widget _buildFormatChip(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _selectedFormat == value;

    return FilterChip(
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedFormat = value);
        }
      },
      label: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
      backgroundColor: colorScheme.surface,
      selectedColor: colorScheme.primary.withValues(alpha: 0.2),
      side: BorderSide(
        color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
        width: isSelected ? 2 : 1,
      ),
    );
  }

  Widget _buildPreviewSection(
    BuildContext context, {
    required double availableWidth,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final containerProvider = context.watch<ContainerProvider>();
    final l10n = AppLocalizations.of(context)!;

    // Obtener el contenedor seleccionado
    final containerName = _selectedContainerId != null
        ? containerProvider.containers
                  .where((c) => c.id == _selectedContainerId)
                  .firstOrNull
                  ?.name ??
              l10n.reportNotSelected
        : l10n.reportNotSelected;

    final infoCards = [
      {
        'icon': Icons.folder_outlined,
        'label': l10n.reportLabelContainer,
        'value': containerName,
      },
      {
        'icon': Icons.description_outlined,
        'label': l10n.reportLabelType,
        'value': _getReportTypeLabel(context),
      },
      {
        'icon': Icons.save_outlined,
        'label': l10n.reportLabelFormat,
        'value': _selectedFormat.toUpperCase(),
      },
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(16),
        color: colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.reportSectionPreview,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            itemCount: infoCards.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: availableWidth < 760 ? 320 : 280,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: availableWidth < 760 ? 2.8 : 2.35,
            ),
            itemBuilder: (_, index) {
              final card = infoCards[index];
              return _buildInfoCard(
                icon: card['icon'] as IconData,
                label: card['label'] as String,
                value: card['value'] as String,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
        color: colorScheme.surfaceContainerHigh,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getReportTypeLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (_selectedReportType) {
      case 'inventory':
        return l10n.inventoryLabel;
      case 'loans':
        return l10n.loans;
      case 'assets':
        return l10n.assets;
      default:
        return l10n.reportUnknown;
    }
  }

  Future<void> _generateReport(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedContainerId == null) {
      ToastService.error(l10n.reportSelectContainerFirst);
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final reportService = context.read<ReportService>();

      await reportService.generateReport(
        containerId: _selectedContainerId!,
        reportType: _selectedReportType,
        format: _selectedFormat,
      );

      ToastService.success(
        l10n.reportDownloadedSuccess(_selectedFormat.toUpperCase()),
      );
    } catch (e) {
      ToastService.error(l10n.reportGenerateError(e.toString()));
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }
}
