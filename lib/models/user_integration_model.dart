enum IntegrationType { GEMINI, TELEGRAM, SHOPIFY, CUSTOM }

class UserIntegration {
  final IntegrationType type;
  final bool isEnabled;
  final Map<String, dynamic> config; // El JSON flexible

  UserIntegration({
    required this.type,
    required this.isEnabled,
    required this.config,
  });

  factory UserIntegration.fromJson(Map<String, dynamic> json) {
    return UserIntegration(
      type: IntegrationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => IntegrationType.CUSTOM,
      ),
      isEnabled: json['isEnabled'] ?? false,
      config: json['config'] ?? {},
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'isEnabled': isEnabled,
    'config': config,
  };
}