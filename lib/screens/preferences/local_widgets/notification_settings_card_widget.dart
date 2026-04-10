import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:invenicum/providers/preferences_provider.dart';
import 'package:invenicum/l10n/app_localizations.dart';

class NotificationSettingsCardWidget extends StatelessWidget {
  const NotificationSettingsCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final prefsProv = context.watch<PreferencesProvider>();

    // 🔔 Accedemos a través de la nueva estructura
    final settings = prefsProv.notificationSettings;
    final channels = settings.channelOrder;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.notificationSettingsTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            Text(
              l10n.channelPriorityLabel,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 12),

            // Sección Drag & Drop
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: channels.length,
                onReorder: (oldIndex, newIndex) {
                  prefsProv.reorderChannels(oldIndex, newIndex);
                },
                itemBuilder: (context, index) {
                  final channel = channels[index];
                  return ListTile(
                    key: ValueKey(channel),
                    leading: Icon(
                      channel == 'telegram'
                          ? Icons.send_rounded
                          : Icons.alternate_email_rounded,
                      color: channel == 'telegram' ? Colors.blue : Colors.green,
                    ),
                    title: Text(
                      channel == 'telegram' ? l10n.telegramBotLabel : l10n.resendEmailLabel,
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing: const Icon(Icons.drag_indicator_rounded),
                  );
                },
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(),
            ),

            // 🔔 Switches vinculados a los nuevos nombres del Modelo y Provider
            _buildSwitch(
              context,
              l10n.lowStockLabel,
              l10n.lowStockHint,
              settings.alertStockLow,
              (val) => prefsProv.setNotificationAlert('stock', val),
            ),
            _buildSwitch(
              context,
              l10n.newPresalesLabel,
              l10n.newPresalesHint,
              settings.alertPreSales,
              (val) => prefsProv.setNotificationAlert('preorder', val),
            ),
            _buildSwitch(
              context,
              l10n.loanReminderLabel,
              l10n.loanReminderHint,
              settings.alertLoanReminders,
              (val) => prefsProv.setNotificationAlert('loan', val),
            ),
            _buildSwitch(
              context,
              l10n.overdueLoansLabel,
              l10n.overdueLoansHint,
              settings.alertOverdueLoans,
              (val) => prefsProv.setNotificationAlert('overdue', val),
            ),
            _buildSwitch(
              context,
              l10n.maintenanceLabel,
              l10n.maintenanceHint,
              settings.alertMaintenance,
              (val) => prefsProv.setNotificationAlert('maintenance', val),
            ),
            _buildSwitch(
              context,
              l10n.priceChangeLabel,
              l10n.priceChangeHint,
              settings.alertPriceChange,
              (val) => prefsProv.setNotificationAlert('price', val),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitch(
    BuildContext context,
    String title,
    String sub,
    bool val,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontSize: 15)),
      subtitle: Text(
        sub,
        style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
      ),
      value: val,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      activeThumbColor: Theme.of(context).primaryColor,
    );
  }
}
