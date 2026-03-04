import 'package:flutter/material.dart';
import 'package:invenicum/data/models/alert.dart';
import 'package:invenicum/providers/preferences_provider.dart';
import 'package:provider/provider.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/alert_provider.dart';
import '../../data/services/toast_service.dart';
import 'package:intl/intl.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedDay = _focusedDay; // Inicializar el día seleccionado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlertProvider>().loadAlerts();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alertProvider = context.watch<AlertProvider>();

    // Separación de listas
    final alerts = alertProvider.alerts.where((a) => !a.isEvent).toList();
    final notifications = alertProvider.alerts.where((a) => a.isEvent).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.alerts),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => alertProvider.loadAlerts(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            // Tab de Alertas
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Badge(
                    label: Text(
                      alertProvider.alerts
                          .where((a) => !a.isEvent && !a.isRead)
                          .length
                          .toString(),
                    ),
                    isLabelVisible: alertProvider.alerts.any(
                      (a) => !a.isEvent && !a.isRead,
                    ),
                    child: const Icon(Icons.warning_amber_rounded),
                  ),
                  const SizedBox(width: 8),
                  const Text("Alertas"),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Badge(
                    label: Text(
                      alertProvider.alerts
                          .where((a) => a.isEvent && !a.isRead)
                          .length
                          .toString(),
                    ),
                    isLabelVisible: alertProvider.alerts.any(
                      (a) => a.isEvent && !a.isRead,
                    ),
                    backgroundColor: Colors
                        .orange, // Color distinto para eventos si prefieres
                    child: const Icon(Icons.event_note_rounded),
                  ),
                  const SizedBox(width: 8),
                  const Text("Calendario"),
                ],
              ),
            ),
          ],
        ),
      ),
      body: alertProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildListView(alerts, alertProvider),
                _buildEventsCalendar(
                  notifications,
                  alertProvider,
                ), // Corregido: Llamada a la vista de calendario
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUnifiedCreateDialog(context),
        icon: const Icon(Icons.add),
        label: const Text("Nuevo"),
      ),
    );
  }

  // --- COMPONENTES DE UI ---

  Widget _buildEventsCalendar(List<Alert> events, AlertProvider provider) {
    final PreferencesProvider preferencesProvider = context
        .watch<PreferencesProvider>();

    return Column(
      children: [
        TableCalendar(
          locale: preferencesProvider.locale.toLanguageTag(),
          firstDay: DateTime.utc(1984, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          eventLoader: (day) {
            return events
                .where(
                  (e) => e.scheduledAt != null && isSameDay(e.scheduledAt, day),
                )
                .toList();
          },
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            selectedDecoration: const BoxDecoration(
              color: Colors.indigo,
              shape: BoxShape.circle,
            ),
            markerDecoration: const BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
        ),
        const Divider(),
        Expanded(
          child: _buildListView(
            events
                .where(
                  (e) =>
                      _selectedDay == null ||
                      isSameDay(e.scheduledAt, _selectedDay),
                )
                .toList(),
            provider,
            isEvent: true,
          ),
        ),
      ],
    );
  }

  Widget _buildListView(
    List<dynamic> items,
    AlertProvider provider, {
    bool isEvent = false,
  }) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          isEvent ? "Sin eventos para este día" : "No hay alertas activas",
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final alert = items[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          elevation: alert.isRead ? 0 : 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: alert.isRead
                ? BorderSide.none
                : BorderSide(color: Colors.indigo.withOpacity(0.2), width: 1),
          ),
          child: ListTile(
            onTap: () => _showDetailsDialog(context, alert),
            leading: _buildLeadingIcon(alert.type, alert.isRead, alert.isEvent),
            title: Text(
              alert.title,
              style: TextStyle(
                fontWeight: alert.isRead ? FontWeight.normal : FontWeight.bold,
                color: alert.isRead ? Colors.grey[700] : Colors.black87,
              ),
            ),
            subtitle: Text(alert.message),
            trailing: Row(
              mainAxisSize: MainAxisSize
                  .min, // Importante para que no ocupe todo el ancho
              children: [
                // --- BOTÓN EDITAR (Solo para eventos) ---
                if (isEvent)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                    onPressed: () => _showEditEventDialog(context, alert),
                  ),
                // Botón de Marcar como Leído (Solo se muestra si no está leído)
                if (!alert.isRead)
                  IconButton(
                    icon: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                    ),
                    tooltip: "Marcar como leído",
                    onPressed: () {
                      provider.markAsRead(alert.id);
                      ToastService.info("Marcada como leída");
                    },
                  ),
                // Botón de Eliminar
                IconButton(
                  icon: const Icon(
                    Icons.delete_sweep_outlined,
                    color: Colors.redAccent,
                  ),
                  tooltip: "Eliminar",
                  onPressed: () async {
                    // 1. Llamamos al borrado en el backend/estado
                    await provider.deleteAlert(alert.id);

                    // 2. Mostramos el mensaje de confirmación
                    ToastService.success(
                      "Notificación eliminada correctamente",
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditEventDialog(BuildContext context, dynamic alert) {
    final titleCtrl = TextEditingController(text: alert.title);
    final msgCtrl = TextEditingController(text: alert.message);

    // Fecha actual del evento
    DateTime editedEventDate = alert.scheduledAt ?? DateTime.now();

    // Calculamos la antelación actual para el desplegable
    // Si no hay notifyAt, ponemos "0" (a la hora del evento)
    String advanceNotice = "0";
    if (alert.notifyAt != null && alert.scheduledAt != null) {
      final difference = alert.scheduledAt!
          .difference(alert.notifyAt!)
          .inMinutes;
      // Validamos que sea uno de nuestros valores estándar, si no, por defecto "15"
      advanceNotice =
          ["0", "5", "15", "30", "60"].contains(difference.toString())
          ? difference.toString()
          : "15";
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Editar Evento"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Datos del evento",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.calendar_today,
                    color: Colors.indigo,
                  ),
                  title: Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(editedEventDate),
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: editedEventDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(editedEventDate),
                      );
                      if (time != null) {
                        setDialogState(() {
                          editedEventDate = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    }
                  },
                ),
                const SizedBox(height: 10),
                const Text(
                  "Configurar Aviso:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                DropdownButton<String>(
                  value: advanceNotice,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(
                      value: "0",
                      child: Text("A la hora del evento"),
                    ),
                    DropdownMenuItem(
                      value: "5",
                      child: Text("5 minutos antes"),
                    ),
                    DropdownMenuItem(
                      value: "15",
                      child: Text("15 minutos antes"),
                    ),
                    DropdownMenuItem(
                      value: "30",
                      child: Text("30 minutos antes"),
                    ),
                    DropdownMenuItem(value: "60", child: Text("1 hora antes")),
                  ],
                  onChanged: (val) =>
                      setDialogState(() => advanceNotice = val!),
                ),
                const Divider(),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: "Título"),
                ),
                TextField(
                  controller: msgCtrl,
                  decoration: const InputDecoration(labelText: "Mensaje"),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                // Calculamos el nuevo notifyAt basado en la selección
                final minutes = int.parse(advanceNotice);
                final newNotifyAt = editedEventDate.subtract(
                  Duration(minutes: minutes),
                );

                await context.read<AlertProvider>().updateAlert(alert.id, {
                  'title': titleCtrl.text,
                  'message': msgCtrl.text,
                  'scheduledAt': editedEventDate.toIso8601String(),
                  'notifyAt': newNotifyAt.toIso8601String(),
                  'isEvent': true,
                });

                Navigator.pop(context);
                ToastService.success("Evento actualizado");
              },
              child: const Text("Guardar Cambios"),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailsDialog(BuildContext context, dynamic alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            _buildLeadingIcon(alert.type, alert.isRead, alert.isEvent),
            const SizedBox(width: 10),
            Expanded(child: Text(alert.title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (alert.isEvent && alert.scheduledAt != null) ...[
              Row(
                children: [
                  const Icon(
                    Icons.calendar_month,
                    size: 18,
                    color: Colors.indigo,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('dd/MM/yyyy - HH:mm').format(alert.scheduledAt!),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Divider(),
            ],
            const Text(
              "Mensaje:",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 5),
            Text(alert.message),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadingIcon(String type, bool isRead, bool isEvent) {
    if (isEvent)
      return const Icon(Icons.calendar_today_rounded, color: Colors.indigo);
    IconData icon;
    Color color;
    switch (type) {
      case 'critical':
        icon = Icons.error_outline;
        color = Colors.red;
        break;
      case 'warning':
        icon = Icons.warning_amber_rounded;
        color = Colors.orange;
        break;
      default:
        icon = Icons.info_outline;
        color = Colors.blue;
    }
    return Icon(icon, color: isRead ? Colors.grey : color);
  }

  // --- LÓGICA DE CREACIÓN ---

  void _showUnifiedCreateDialog(BuildContext context) {
    bool isEvent = false;
    DateTime selectedDate = DateTime.now();
    final titleCtrl = TextEditingController();
    final msgCtrl = TextEditingController();
    String advanceNotice = "15";

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Crear Alerta/Evento"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text("¿Es un evento?"),
                  value: isEvent,
                  onChanged: (v) => setDialogState(() => isEvent = v),
                ),
                if (isEvent) ...[
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (date != null)
                        setDialogState(
                          () => selectedDate = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            selectedDate.hour,
                            selectedDate.minute,
                          ),
                        );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: Text(DateFormat('HH:mm').format(selectedDate)),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(selectedDate),
                      );
                      if (time != null)
                        setDialogState(
                          () => selectedDate = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            time.hour,
                            time.minute,
                          ),
                        );
                    },
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Avisarme:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    value: advanceNotice,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: "0",
                        child: Text("A la hora del evento"),
                      ),
                      DropdownMenuItem(
                        value: "5",
                        child: Text("5 minutos antes"),
                      ),
                      DropdownMenuItem(
                        value: "15",
                        child: Text("15 minutos antes"),
                      ),
                      DropdownMenuItem(
                        value: "30",
                        child: Text("30 minutos antes"),
                      ),
                      DropdownMenuItem(
                        value: "60",
                        child: Text("1 hora antes"),
                      ),
                    ],
                    onChanged: (val) =>
                        setDialogState(() => advanceNotice = val!),
                  ),
                ],
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: "Título"),
                ),
                TextField(
                  controller: msgCtrl,
                  decoration: const InputDecoration(labelText: "Mensaje"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                final minutes = int.parse(advanceNotice);
                // Calculamos la fecha de notificación restando la antelación a la fecha elegida
                final notificationDate = selectedDate.subtract(
                  Duration(minutes: minutes),
                );
                context.read<AlertProvider>().createAlert(
                  titleCtrl.text,
                  msgCtrl.text,
                  'info',
                  isEvent: isEvent,
                  scheduledAt: isEvent ? selectedDate : null,
                  notifyAt: isEvent ? notificationDate : null,
                );
                Navigator.pop(context);
                ToastService.success("Creado correctamente");
              },
              child: const Text("Guardar"),
            ),
          ],
        ),
      ),
    );
  }
}
