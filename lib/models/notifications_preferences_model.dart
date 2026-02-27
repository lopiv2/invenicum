class NotificationSettings {
  final List<String> channelOrder;
  final bool alertStockLow;
  final bool alertNewPreorder;
  final bool alertLoanReminder;

  NotificationSettings({
    this.channelOrder = const ['telegram', 'email'],
    this.alertStockLow = true,
    this.alertNewPreorder = true,
    this.alertLoanReminder = true,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      channelOrder: List<String>.from(json['channelOrder'] ?? ['telegram', 'email']),
      alertStockLow: json['alertStockLow'] ?? true,
      alertNewPreorder: json['alertNewPreorder'] ?? true,
      alertLoanReminder: json['alertLoanReminder'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'channelOrder': channelOrder,
    'alertStockLow': alertStockLow,
    'alertNewPreorder': alertNewPreorder,
    'alertLoanReminder': alertLoanReminder,
  };

  NotificationSettings copyWith({
    List<String>? channelOrder,
    bool? alertStockLow,
    bool? alertNewPreorder,
    bool? alertLoanReminder,
  }) {
    return NotificationSettings(
      channelOrder: channelOrder ?? this.channelOrder,
      alertStockLow: alertStockLow ?? this.alertStockLow,
      alertNewPreorder: alertNewPreorder ?? this.alertNewPreorder,
      alertLoanReminder: alertLoanReminder ?? this.alertLoanReminder,
    );
  }
}