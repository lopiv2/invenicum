import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:invenicum/providers/preferences_provider.dart';

class NotificationSettingsCardWidget extends StatelessWidget {
  const NotificationSettingsCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final prefsProv = context.watch<PreferencesProvider>();
    
    // 🔔 Accedemos a través de la nueva clase anidada
    final settings = prefsProv.notificationSettings;
    final channels = settings.channelOrder; 

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Gestión de Notificaciones", 
                 style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            
            const Text("Prioridad de Canales (Arrastra para ordenar)",
                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 12),
            
            // Sección Drag & Drop mejorada
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor.withOpacity(0.05),
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
                      channel == 'telegram' ? Icons.send_rounded : Icons.alternate_email_rounded,
                      color: channel == 'telegram' ? Colors.blue : Colors.green,
                    ),
                    title: Text(
                      channel == 'telegram' ? 'Telegram Bot' : 'Resend Email',
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
            
            // 🔔 Switches vinculados a la clase NotificationSettings
            _buildSwitch(
              context,
              "Stock Bajo",
              "Avisar cuando un producto baje del mínimo.",
              settings.alertStockLow,
              (val) => prefsProv.setNotificationAlert('stock', val),
            ),
            _buildSwitch(
              context,
              "Nuevas Preventas",
              "Notificar lanzamientos detectados por la IA.",
              settings.alertNewPreorder,
              (val) => prefsProv.setNotificationAlert('preorder', val),
            ),
            _buildSwitch(
              context,
              "Recordatorio de Préstamos",
              "Avisar antes de la fecha de devolución.",
              settings.alertLoanReminder,
              (val) => prefsProv.setNotificationAlert('loan', val),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitch(BuildContext context, String title, String sub, bool val, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontSize: 15)),
      subtitle: Text(sub, style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
      value: val,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      activeColor: Theme.of(context).primaryColor,
    );
  }
}