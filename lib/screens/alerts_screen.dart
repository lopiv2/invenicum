// lib/screens/alerts_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alert_provider.dart';
import '../services/toast_service.dart';
import 'package:intl/intl.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlertProvider>().loadAlerts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final alertProvider = context.watch<AlertProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertas y Notificaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => alertProvider.loadAlerts(),
          ),
        ],
      ),
      body: alertProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : alertProvider.alerts.isEmpty
              ? const Center(child: Text('No hay notificaciones'))
              : ListView.builder(
                  itemCount: alertProvider.alerts.length,
                  itemBuilder: (context, index) {
                    final alert = alertProvider.alerts[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      elevation: alert.isRead ? 0 : 2,
                      color: alert.isRead ? Colors.grey[50] : Colors.white,
                      child: ListTile(
                        leading: _buildLeadingIcon(alert.type, alert.isRead),
                        title: Text(
                          alert.title,
                          style: TextStyle(
                            fontWeight: alert.isRead ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(alert.message),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('dd/MM/yyyy HH:mm').format(alert.createdAt),
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!alert.isRead)
                              IconButton(
                                icon: const Icon(Icons.mark_email_read_outlined, size: 20),
                                onPressed: () => alertProvider.markAsRead(alert.id),
                              ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                              onPressed: () => _confirmDelete(context, alert),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAlertDialog(context),
        child: const Icon(Icons.add_alert),
      ),
    );
  }

  Widget _buildLeadingIcon(String type, bool isRead) {
    IconData iconData;
    Color color;

    switch (type) {
      case 'critical':
        iconData = Icons.error_outline;
        color = isRead ? Colors.grey : Colors.red;
        break;
      case 'warning':
        iconData = Icons.warning_amber_rounded;
        color = isRead ? Colors.grey : Colors.orange;
        break;
      default:
        iconData = Icons.info_outline;
        color = isRead ? Colors.grey : Colors.blue;
    }

    return Icon(iconData, color: color, size: 30);
  }

  void _confirmDelete(BuildContext context, alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Alerta'),
        content: const Text('¿Estás seguro de que deseas eliminar esta notificación?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<AlertProvider>().deleteAlert(alert.id);
              Navigator.pop(context);
              ToastService.success('Notificación eliminada');
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddAlertDialog(BuildContext context) {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String selectedType = 'info';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nueva Alerta Manual'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Título')),
              TextField(controller: messageController, decoration: const InputDecoration(labelText: 'Mensaje')),
              DropdownButton<String>(
                value: selectedType,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'info', child: Text('Información')),
                  DropdownMenuItem(value: 'warning', child: Text('Advertencia')),
                  DropdownMenuItem(value: 'critical', child: Text('Crítico')),
                ],
                onChanged: (val) => setState(() => selectedType = val!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                context.read<AlertProvider>().createAlert(
                  titleController.text,
                  messageController.text,
                  selectedType,
                );
                Navigator.pop(context);
                ToastService.success('Alerta creada');
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}