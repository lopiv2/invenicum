// screens/preferences/local_widgets/ai_provider_card_widget.dart
import 'package:flutter/material.dart';
import 'package:invenicum/core/utils/constants.dart';
import 'package:invenicum/data/services/veni_chatbot_service.dart';
import 'package:invenicum/providers/preferences_provider.dart';
import 'package:invenicum/data/services/toast_service.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class AiProviderCardWidget extends StatefulWidget {
  const AiProviderCardWidget({super.key});

  @override
  State<AiProviderCardWidget> createState() => _AiProviderCardWidgetState();
}

class _AiProviderCardWidgetState extends State<AiProviderCardWidget> {
  bool _isSaving = false;
  bool _isPurgingHistory = false;

  Future<void> _save(
    PreferencesProvider prov,
    String provider,
    String model,
    AppLocalizations l10n,
  ) async {
    setState(() => _isSaving = true);
    try {
      await prov.updateAiProvider(provider, model);
      if (mounted) ToastService.success(l10n.aiProviderUpdated);
    } catch (e) {
      if (mounted) ToastService.error('Error al guardar: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _confirmAndPurgeHistory(AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.purgeChatHistoryConfirmTitle),
        content: Text(l10n.purgeChatHistoryConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.purgeChatHistoryConfirmAction),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isPurgingHistory = true);
    try {
      await context.read<ChatService>().purgeRemoteHistory();
      if (mounted) {
        ToastService.success(l10n.purgeChatHistorySuccess);
      }
    } catch (_) {
      if (mounted) {
        ToastService.error(l10n.purgeChatHistoryError);
      }
    } finally {
      if (mounted) setState(() => _isPurgingHistory = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final prov = context.watch<PreferencesProvider>();

    final currentProvider = prov.aiProvider ?? AppIntegrations.gemini;
    final currentModel =
        prov.aiModel ?? AiModels.defaultFor(currentProvider);
    final availableModels = AiModels.forProvider(currentProvider);

    // Si el modelo guardado no está en la lista del proveedor actual, usamos el primero
    final validModel = availableModels.any((m) => m.id == currentModel)
        ? currentModel
        : availableModels.first.id;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cabecera ──────────────────────────────────────────────────
            Row(
              children: [
                Icon(Icons.psychology_outlined,
                    color: theme.colorScheme.primary, size: 22),
                const SizedBox(width: 10),
                Text(
                  l10n.aiAssistantTitle,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              l10n.selectAiProvider,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.hintColor),
            ),
            const SizedBox(height: 24),

            // ── Selector de proveedor ─────────────────────────────────────
            Text(l10n.aiProviderLabel,
                style: theme.textTheme.labelMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AiModels.providers.map((opt) {
                final selected = currentProvider == opt.id;
                return ChoiceChip(
                  avatar: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      selected ? Colors.white : opt.color,
                      BlendMode.srcIn,
                    ),
                    child: SizedBox(width: 16, height: 16, child: opt.icon),
                  ),
                  label: Text(opt.label),
                  selected: selected,
                  selectedColor: opt.color,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : null,
                    fontWeight:
                        selected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (_) {
                    final defaultModel = AiModels.defaultFor(opt.id);
                    _save(prov, opt.id, defaultModel, l10n);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // ── Selector de modelo ────────────────────────────────────────
            Text(l10n.aiModelLabel,
                style: theme.textTheme.labelMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: validModel,
              isExpanded: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
              ),
              items: availableModels
                  .map((m) => DropdownMenuItem(
                        value: m.id,
                        child: Text(m.label),
                      ))
                  .toList(),
              onChanged: (model) {
                if (model != null) _save(prov, currentProvider, model, l10n);
              },
            ),
            const SizedBox(height: 16),

            // ── Indicador de guardado ─────────────────────────────────────
            if (_isSaving)
              const Center(child: CircularProgressIndicator(strokeWidth: 2))
            else
              // Muestra el estado actual como resumen
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '${l10n.active}: ${AiModels.providerInfo(currentProvider).label} · $validModel',
                        style: theme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.error.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.purgeChatHistoryTitle,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.purgeChatHistoryDescription,
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: _isPurgingHistory
                          ? null
                          : () => _confirmAndPurgeHistory(l10n),
                      icon: _isPurgingHistory
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.delete_sweep_outlined),
                      label: Text(l10n.purgeChatHistoryButton),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}