class NotificationSettings {
  final List<String> channelOrder;
  final bool alertStockLow;
  final bool alertPreSales;      // Cambiado para coincidir con el DTO (alertPreSales)
  final bool alertLoanReminders;
  final bool alertOverdueLoans;  // Añadida según la propuesta del schema
  final bool alertMaintenance;
  final bool alertPriceChange;

  NotificationSettings({
    this.channelOrder = const ['telegram', 'email'],
    this.alertStockLow = true,
    this.alertPreSales = true,
    this.alertLoanReminders = true,
    this.alertOverdueLoans = true,
    this.alertMaintenance = true,
    this.alertPriceChange = true,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      // 🔑 Mapeo con los nombres exactos que envía el DTO del backend
      channelOrder: List<String>.from(json['channelOrder'] ?? ['telegram', 'email']),
      alertStockLow: json['alertStockLow'] ?? true,
      alertPreSales: json['alertPreSales'] ?? true,
      alertLoanReminders: json['alertLoanReminders'] ?? true,
      alertOverdueLoans: json['alertOverdueLoans'] ?? true,
      alertMaintenance: json['alertMaintenance'] ?? true,
      alertPriceChange: json['alertPriceChange'] ?? true,    
    );
  }

  Map<String, dynamic> toJson() => {
    // 🚀 Estos nombres son los que recibirá el método UserPreferencesDTO.fromRequest
    'channelOrder': channelOrder,
    'alertStockLow': alertStockLow,
    'alertPreSales': alertPreSales,
    'alertLoanReminders': alertLoanReminders,
    'alertOverdueLoans': alertOverdueLoans,
    'alertMaintenance': alertMaintenance,
    'alertPriceChange': alertPriceChange,
  };

  NotificationSettings copyWith({
    List<String>? channelOrder,
    bool? alertStockLow,
    bool? alertPreSales,
    bool? alertLoanReminders,
    bool? alertOverdueLoans,
    bool? alertMaintenance,
    bool? alertPriceChange,
  }) {
    return NotificationSettings(
      channelOrder: channelOrder ?? this.channelOrder,
      alertStockLow: alertStockLow ?? this.alertStockLow,
      alertPreSales: alertPreSales ?? this.alertPreSales,
      alertLoanReminders: alertLoanReminders ?? this.alertLoanReminders,
      alertOverdueLoans: alertOverdueLoans ?? this.alertOverdueLoans,
      alertMaintenance: alertMaintenance ?? this.alertMaintenance,
      alertPriceChange: alertPriceChange ?? this.alertPriceChange,
    );
  }
}