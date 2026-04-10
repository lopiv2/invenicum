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
    _selectedDay = _focusedDay; // Initialize the selected day
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
    final l10n = AppLocalizations.of(context)!;
    final alertProvider = context.watch<AlertProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    // Split alerts into lists
    final alerts = alertProvider.alerts.where((a) => !a.isEvent).toList();
    final notifications = alertProvider.alerts.where((a) => a.isEvent).toList();
    final unreadAlerts = alertProvider.alerts
        .where((a) => !a.isEvent && !a.isRead)
        .length;
    final unreadEvents = alertProvider.alerts
        .where((a) => a.isEvent && !a.isRead)
        .length;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 700;
            final horizontalPadding = isMobile ? 12.0 : 20.0;

            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    isMobile ? 10 : 16,
                    horizontalPadding,
                    14,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primaryContainer.withValues(alpha: 0.35),
                        colorScheme.surface,
                      ],
                    ),
                    border: Border(
                      bottom: BorderSide(color: colorScheme.outlineVariant),
                    ),
                  ),
                  child: Column(
                    children: [
                      if (isMobile)
                        Column(
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton.filledTonal(
                                onPressed: () => alertProvider.loadAlerts(),
                                icon: const Icon(Icons.refresh_rounded),
                                tooltip: l10n.refresh,
                              ),
                            ),
                            Icon(
                              Icons.notifications_active_rounded,
                              size: 34,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              l10n.alerts,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.3,
                                    color: colorScheme.primary,
                                  ),
                            ),
                          ],
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.notifications_active_rounded,
                                    size: 40,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    l10n.alerts,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -0.5,
                                          color: colorScheme.primary,
                                        ),
                                  ),
                                ],
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: IconButton.filledTonal(
                                  onPressed: () => alertProvider.loadAlerts(),
                                  icon: const Icon(Icons.refresh_rounded),
                                  tooltip: l10n.refresh,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildHeaderStat(
                            context,
                            icon: Icons.warning_amber_rounded,
                            label: l10n.alertsTabLabel,
                            value: unreadAlerts,
                          ),
                          const SizedBox(width: 10),
                          _buildHeaderStat(
                            context,
                            icon: Icons.event_note_rounded,
                            label: l10n.calendarTabLabel,
                            value: unreadEvents,
                            accent: Colors.orange,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colorScheme.outlineVariant),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          dividerColor: Colors.transparent,
                          labelPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                          indicator: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          tabs: [
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Badge(
                                    label: Text(unreadAlerts.toString()),
                                    isLabelVisible: unreadAlerts > 0,
                                    child: const Icon(
                                      Icons.warning_amber_rounded,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(child: Text(l10n.alertsTabLabel)),
                                ],
                              ),
                            ),
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Badge(
                                    label: Text(unreadEvents.toString()),
                                    isLabelVisible: unreadEvents > 0,
                                    backgroundColor: Colors.orange,
                                    child: const Icon(Icons.event_note_rounded),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(child: Text(l10n.calendarTabLabel)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: alertProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildListView(alerts, alertProvider),
                            _buildEventsCalendar(notifications, alertProvider),
                          ],
                        ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUnifiedCreateDialog(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.newLabel),
      ),
    );
  }

  Widget _buildHeaderStat(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int value,
    Color? accent,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final tone = accent ?? colorScheme.primary;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: tone.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: tone.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: tone),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$value',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: tone,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildEventsCalendar(List<Alert> events, AlertProvider provider) {
    final PreferencesProvider preferencesProvider = context
        .watch<PreferencesProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: TableCalendar(
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
                      (e) =>
                          e.scheduledAt != null &&
                          isSameDay(e.scheduledAt, day),
                    )
                    .toList();
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: colorScheme.primary,
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
          ),
          const SizedBox(height: 8),
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
      ),
    );
  }

  Widget _buildListView(
    List<Alert> items,
    AlertProvider provider, {
    bool isEvent = false,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    if (items.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Text(
            isEvent ? l10n.noEventsForDay : l10n.noActiveAlerts,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final alert = items[index];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: alert.isRead
                ? colorScheme.surface
                : colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: alert.isRead
                  ? colorScheme.outlineVariant
                  : colorScheme.primary.withValues(alpha: 0.28),
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(
                  alpha: alert.isRead ? 0.03 : 0.06,
                ),
                blurRadius: alert.isRead ? 8 : 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _showDetailsDialog(context, alert),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 8, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: _buildLeadingIcon(
                            alert.type,
                            alert.isRead,
                            alert.isEvent,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                alert.title,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      fontWeight: alert.isRead
                                          ? FontWeight.w600
                                          : FontWeight.w800,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                alert.message,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              if (isEvent && alert.scheduledAt != null) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.tertiaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    DateFormat(
                                      'dd/MM/yyyy HH:mm',
                                    ).format(alert.scheduledAt!),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color:
                                              colorScheme.onTertiaryContainer,
                                        ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          if (isEvent)
                            IconButton(
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: Colors.blue,
                              ),
                              tooltip: l10n.editEventTitle,
                              onPressed: () =>
                                  _showEditEventDialog(context, alert),
                            ),
                          if (!alert.isRead)
                            IconButton(
                              icon: const Icon(
                                Icons.check_circle_outline,
                                color: Colors.green,
                              ),
                              tooltip: l10n.markAsReadLabel,
                              onPressed: () {
                                provider.markAsRead(alert.id);
                                ToastService.info(l10n.alertMarkedAsRead);
                              },
                            ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_sweep_outlined,
                              color: Colors.redAccent,
                            ),
                            tooltip: l10n.delete,
                            onPressed: () async {
                              await provider.deleteAlert(alert.id);
                              ToastService.success(l10n.notificationDeleted);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditEventDialog(BuildContext context, dynamic alert) {
    final l10n = AppLocalizations.of(context)!;
    final titleCtrl = TextEditingController(text: alert.title);
    final msgCtrl = TextEditingController(text: alert.message);

    // Current date of the event
    DateTime editedEventDate = alert.scheduledAt ?? DateTime.now();

    // Compute the current advance notice for the dropdown
    // If there's no notifyAt, use "0" (at event time)
    String advanceNotice = "0";
    if (alert.notifyAt != null && alert.scheduledAt != null) {
      final difference = alert.scheduledAt!
          .difference(alert.notifyAt!)
          .inMinutes;
      // Validate it's one of our standard values, otherwise default to "15"
      advanceNotice =
          ["0", "5", "15", "30", "60"].contains(difference.toString())
          ? difference.toString()
          : "15";
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.editEventTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.eventDataSection,
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
                Text(
                  l10n.configureReminderLabel,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                DropdownButton<String>(
                  value: advanceNotice,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(
                      value: "0",
                      child: Text(l10n.eventReminderAtTime),
                    ),
                    DropdownMenuItem(
                      value: "5",
                      child: Text(l10n.minutesBeforeLabel(5)),
                    ),
                    DropdownMenuItem(
                      value: "15",
                      child: Text(l10n.minutesBeforeLabel(15)),
                    ),
                    DropdownMenuItem(
                      value: "30",
                      child: Text(l10n.minutesBeforeLabel(30)),
                    ),
                    DropdownMenuItem(
                      value: "60",
                      child: Text(l10n.oneHourBeforeLabel),
                    ),
                  ],
                  onChanged: (val) =>
                      setDialogState(() => advanceNotice = val!),
                ),
                const Divider(),
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(labelText: l10n.alertTitle),
                ),
                TextField(
                  controller: msgCtrl,
                  decoration: InputDecoration(labelText: l10n.alertMessage),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                // Compute the new notifyAt based on the selection
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
                ToastService.success(l10n.eventUpdated);
              },
              child: Text(l10n.saveChanges),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailsDialog(BuildContext context, dynamic alert) {
    final l10n = AppLocalizations.of(context)!;
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
            Text(
              l10n.messageWithColon,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 5),
            Text(alert.message),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.closeLabel),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadingIcon(String type, bool isRead, bool isEvent) {
    if (isEvent) {
      return const Icon(Icons.calendar_today_rounded, color: Colors.indigo);
    }
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

  // --- CREATION LOGIC ---

  void _showUnifiedCreateDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    bool isEvent = false;
    DateTime selectedDate = DateTime.now();
    final titleCtrl = TextEditingController();
    final msgCtrl = TextEditingController();
    String advanceNotice = "15";

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.createAlertOrEventTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: Text(l10n.isEventQuestion),
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
                      if (date != null) {
                        setDialogState(
                          () => selectedDate = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            selectedDate.hour,
                            selectedDate.minute,
                          ),
                        );
                      }
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
                      if (time != null) {
                        setDialogState(
                          () => selectedDate = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            time.hour,
                            time.minute,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.remindMeLabel,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    value: advanceNotice,
                    isExpanded: true,
                    items: [
                      DropdownMenuItem(
                        value: "0",
                        child: Text(l10n.eventReminderAtTime),
                      ),
                      DropdownMenuItem(
                        value: "5",
                        child: Text(l10n.minutesBeforeLabel(5)),
                      ),
                      DropdownMenuItem(
                        value: "15",
                        child: Text(l10n.minutesBeforeLabel(15)),
                      ),
                      DropdownMenuItem(
                        value: "30",
                        child: Text(l10n.minutesBeforeLabel(30)),
                      ),
                      DropdownMenuItem(
                        value: "60",
                        child: Text(l10n.oneHourBeforeLabel),
                      ),
                    ],
                    onChanged: (val) =>
                        setDialogState(() => advanceNotice = val!),
                  ),
                ],
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(labelText: l10n.alertTitle),
                ),
                TextField(
                  controller: msgCtrl,
                  decoration: InputDecoration(labelText: l10n.alertMessage),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final minutes = int.parse(advanceNotice);
                // Compute the notification date by subtracting the advance notice from the chosen date
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
                ToastService.success(l10n.createdSuccessfully);
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
