class StorePlugin {
  final String id;
  final String name;
  final String author; // Nombre de usuario de GitHub
  final String version;
  final String description;
  final String slot;
  final Map<String, dynamic>? ui;
  final String? authorAvatar;
  final int downloadCount;
  final bool hasUpdate;
  final String latestVersion;

  final bool isMine; // Calculado por identidad
  final bool isActive; // Estado local del usuario
  final bool isPublic; // Si está en el Market

  StorePlugin({
    required this.id,
    required this.name,
    required this.author,
    required this.version,
    required this.description,
    required this.slot,
    this.ui,
    this.authorAvatar,
    this.isMine = false,
    this.isActive = true,
    this.isPublic = false,
    this.downloadCount = 0,
    this.hasUpdate = false,
    this.latestVersion = '1.0.0',
  });

  factory StorePlugin.fromJson(
    Map<String, dynamic> json, {
    String? currentUserGithub,
  }) {
    final String pluginAuthor = json['author']?.toString() ?? 'Anónimo';

    // Normalización de la UI integrada en el modelo
    Map<String, dynamic>? processedUi;
    if (json['ui'] != null) {
      processedUi = (json['ui'] is Map && json['ui'].containsKey('ui'))
          ? Map<String, dynamic>.from(json['ui']['ui'])
          : Map<String, dynamic>.from(json['ui']);
    }

    // Identidad Global: Si el autor coincide con mi usuario de GitHub, es mío
    final bool calculatedIsMine =
        currentUserGithub != null &&
        pluginAuthor.toLowerCase() == currentUserGithub.toLowerCase();

    return StorePlugin(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Sin nombre',
      author: pluginAuthor,
      version: json['version'] ?? '1.0.0',
      description: json['description'] ?? '',
      slot: json['slot'] ?? 'dashboard_top',
      authorAvatar: json['authorAvatar'] ?? json['icon_url'],
      ui: processedUi,
      isMine: calculatedIsMine,
      isActive: json['isActive'] ?? true,
      isPublic: json['isPublic'] ?? false,
      downloadCount: json['downloadCount'] ?? 0,
      hasUpdate: json['hasUpdate'] ?? false,
      latestVersion: json['latestVersion'] ?? '1.0.0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'author': author,
      'version': version,
      'description': description,
      'slot': slot,
      'ui': ui,
      'authorAvatar': authorAvatar,
      'isMine': isMine,
      'isActive': isActive,
      'isPublic': isPublic,
      'downloadCount': downloadCount,
      'hasUpdate': hasUpdate,
      'latestVersion': latestVersion,
    };
  }

  StorePlugin copyWith({bool? isActive, Map<String, dynamic>? ui, required String version, required bool hasUpdate}) {
    return StorePlugin(
      id: id,
      name: name,
      author: author,
      version: version,
      description: description,
      slot: slot,
      authorAvatar: authorAvatar,
      isPublic: isPublic,
      isMine: isMine,
      ui: ui ?? this.ui,
      isActive: isActive ?? this.isActive,
      downloadCount: downloadCount,
      hasUpdate: hasUpdate,
      latestVersion: latestVersion,
    );
  }
}
