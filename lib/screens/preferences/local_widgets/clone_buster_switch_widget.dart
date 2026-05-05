import 'dart:math';

import 'package:flutter/material.dart';
import 'package:invenicum/core/utils/cga_constants.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/providers/preferences_provider.dart';
import 'package:invenicum/data/services/toast_service.dart';
import 'package:invenicum/widgets/ui/CGA_dialog.dart';
import 'package:invenicum/widgets/ui/cga_widgets.dart';
import 'package:provider/provider.dart';

class CloneBusterSwitchWidget extends StatefulWidget {
  const CloneBusterSwitchWidget({super.key});

  @override
  State<CloneBusterSwitchWidget> createState() =>
      _CloneBusterSwitchWidgetState();
}

class _CloneBusterSwitchWidgetState extends State<CloneBusterSwitchWidget> {
  String _getRandomMessage(AppLocalizations l10n) {
    final messages = [
      l10n.cloneBusterMessage1,
      l10n.cloneBusterMessage2,
      l10n.cloneBusterMessage3,
      l10n.cloneBusterMessage4,
      l10n.cloneBusterMessage5,
      l10n.cloneBusterMessage6,
    ];
    return messages[Random().nextInt(messages.length)];
  }

  Future<void> _showActivationDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final message = _getRandomMessage(l10n);
    String currentLevel = 'Paranoid';

    final bool? confirmed = await showCGADialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => CGADialog(
          title: l10n.cloneBusterDialogTitle,
          body: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ── Message ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
                child: CGATextBox(text: message, maxLines: 4),
              ),

              const CGADivider(color: CGA.darkGray, padding: EdgeInsets.symmetric(horizontal: 12)),

              // ── Sensitivity level ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                child: Column(
                  children: [
                    CGASectionLabel(label: l10n.cloneBusterSensitivityLevel),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CGARadio<String>(
                          label: l10n.cloneBusterSensitivityLow,
                          value: 'Low',
                          groupValue: currentLevel,
                          onChanged: (v) => setStateDialog(() => currentLevel = v),
                        ),
                        CGARadio<String>(
                          label: l10n.cloneBusterSensitivityHigh,
                          value: 'High',
                          groupValue: currentLevel,
                          onChanged: (v) => setStateDialog(() => currentLevel = v),
                        ),
                        CGARadio<String>(
                          label: l10n.cloneBusterSensitivityParanoid,
                          value: 'Paranoid',
                          groupValue: currentLevel,
                          onChanged: (v) => setStateDialog(() => currentLevel = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.cloneBusterDisclaimer,
                      style: const TextStyle(
                        color: CGA.brightCyan,
                        fontFamily: 'monospace',
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const CGADivider(),

              // ── Buttons ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CGAButton(
                      label: l10n.cloneBusterDialogOk,
                      fgColor: CGA.brightGreen,
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                    CGAButton(
                      label: l10n.cloneBusterDialogCancel,
                      fgColor: CGA.brightRed,
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    CGAButton(
                      label: l10n.cloneBusterDialogHelp,
                      fgColor: CGA.yellow,
                      onPressed: () => ToastService.info(l10n.cloneBusterDescription),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<PreferencesProvider>().setCloneBusterEnabled(true);
      ToastService.success(l10n.preferencesUpdated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SwitchListTile(
      title: Localizations.localeOf(context).languageCode == 'de'
          ? Text.rich(TextSpan(
              text: 'The Clone-Buster-O-Matic™ ',
              children: [
                TextSpan(
                  text: l10n.enableCloneBuster,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ))
          : Text.rich(TextSpan(
              text: '${l10n.enableCloneBuster} ',
              children: [
                TextSpan(
                  text: 'The Clone-Buster-O-Matic™',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            )),
      subtitle: Text(l10n.enableCloneBusterDescription),
      secondary: const Icon(Icons.content_copy_outlined),
      value: context.watch<PreferencesProvider>().cloneBusterEnabled,
      onChanged: (val) {
        if (val == true) {
          _showActivationDialog(context);
        } else {
          context.read<PreferencesProvider>().setCloneBusterEnabled(false);
          ToastService.success(l10n.preferencesUpdated);
        }
      },
    );
  }
}