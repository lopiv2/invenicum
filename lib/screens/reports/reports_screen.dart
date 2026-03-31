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
          setState(() =>
              _selectedContainerId = containerProvider.containers.first.id);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final containerProvider = context.watch<ContainerProvider>();

    // Si no hay contenedor seleccionado y hay contenedores disponibles, seleccionar el primero
    if (_selectedContainerId == null && 
        containerProvider.containers.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _selectedContainerId =
              containerProvider.containers.first.id);
        }
      });
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado
          Text(
            AppLocalizations.of(context)!.reports,
            style: textTheme.displaySmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Genera informes en PDF o Excel para imprimir o guardar en tu PC',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 40),

          // Selector de Contenedor
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
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            _buildContainerSelector(context, containerProvider),
          const SizedBox(height: 40),

          // Contenedor principal con tarjetas
          Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sección 1: Tipo de informe
                _buildSectionTitle(context, 'Tipo de Informe'),
                const SizedBox(height: 16),
                _buildReportTypeSelector(context),
                const SizedBox(height: 40),

                // Sección 2: Formato
                _buildSectionTitle(context, 'Formato de Salida'),
                const SizedBox(height: 16),
                _buildFormatSelector(context),
                const SizedBox(height: 40),

                // Sección 3: Vista previa
                _buildPreviewSection(context),
                const SizedBox(height: 40),

                // Botón de generación
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isGenerating ? null : () => _generateReport(context),
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
                          ? 'Generando...'
                          : 'Generar Informe',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      textStyle: textTheme.labelLarge,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContainerSelector(BuildContext context, ContainerProvider containerProvider) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecciona un Contenedor',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButton<int>(
          value: _selectedContainerId,
          isExpanded: true,
          items: containerProvider.containers
              .map(
                (container) => DropdownMenuItem<int>(
                  value: container.id,
                  child: Text(container.name),
                ),
              )
              .toList(),
          onChanged: (int? newValue) {
            if (newValue != null) {
              setState(() => _selectedContainerId = newValue);
            }
          },
          hint: Text(AppLocalizations.of(context)!.selectContainerHint),
          underline: Container(
            height: 2,
            color: colorScheme.primary,
          ),
        ),
      ],
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

  Widget _buildReportTypeSelector(BuildContext context) {

    final reportTypes = [
      {
        'id': 'inventory',
        'label': 'Inventario',
        'description': 'Listado completo del inventario',
        'icon': Icons.inventory_2,
      },
      {
        'id': 'loans',
        'label': 'Préstamos',
        'description': 'Préstamos activos y su estado',
        'icon': Icons.assignment_turned_in,
      },
      {
        'id': 'assets',
        'label': 'Activos',
        'description': 'Listado de activos por categoría',
        'icon': Icons.category,
      },
    ];

    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.85,
      children: reportTypes.map((type) {
        final isSelected = _selectedReportType == type['id'];
        return _buildReportTypeCard(
          context,
          isSelected: isSelected,
          icon: type['icon'] as IconData,
          label: type['label'] as String,
          description: type['description'] as String,
          onTap: () {
            setState(() => _selectedReportType = type['id'] as String);
          },
        );
      }).toList(),
    );
  }

  Widget _buildReportTypeCard(
    BuildContext context, {
    required bool isSelected,
    required IconData icon,
    required String label,
    required String description,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.1)
                : colorScheme.surface,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color:
                    isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormatSelector(BuildContext context) {

    return Row(
      children: [
        _buildFormatChip(
          context,
          label: 'PDF',
          value: 'pdf',
          icon: Icons.picture_as_pdf,
        ),
        const SizedBox(width: 16),
        _buildFormatChip(
          context,
          label: 'Excel',
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

  Widget _buildPreviewSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final containerProvider = context.watch<ContainerProvider>();
    
    // Obtener el contenedor seleccionado
    final containerName = _selectedContainerId != null
        ? containerProvider.containers
            .where((c) => c.id == _selectedContainerId)
            .firstOrNull
            ?.name ??
            'Sin seleccionar'
        : 'Sin seleccionar';

    final infoCards = [
      {
        'icon': Icons.folder_outlined,
        'label': 'Contenedor',
        'value': containerName,
      },
      {
        'icon': Icons.description_outlined,
        'label': 'Tipo de Informe',
        'value': _getReportTypeLabel(),
      },
      {
        'icon': Icons.save_outlined,
        'label': 'Formato',
        'value': _selectedFormat.toUpperCase(),
      },
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
        color: colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configuración actual',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.5,
            children: infoCards.map((card) {
              return _buildInfoCard(
                icon: card['icon'] as IconData,
                label: card['label'] as String,
                value: card['value'] as String,
              );
            }).toList(),
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

  String _getReportTypeLabel() {
    switch (_selectedReportType) {
      case 'inventory':
        return 'Inventario';
      case 'loans':
        return 'Préstamos';
      case 'assets':
        return 'Activos';
      default:
        return 'Desconocido';
    }
  }

 Future<void> _generateReport(BuildContext context) async {
    if (_selectedContainerId == null) {
      ToastService.error('Por favor selecciona un contenedor');
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
        'Informe ${_selectedFormat.toUpperCase()} descargado correctamente',
      );
    } catch (e) {
      ToastService.error('Error al generar informe: $e');
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }
}
