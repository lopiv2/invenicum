class StorePlugin {
  final String id;
  final String name;
  final String version;
  final String description;
  final String author; // Agregado ya que está en tu JSON
  final String iconUrl;
  final String downloadUrl;

  StorePlugin({
    required this.id,
    required this.name,
    required this.version,
    required this.description,
    required this.author,
    required this.iconUrl,
    required this.downloadUrl,
  });

  factory StorePlugin.fromJson(Map<String, dynamic> json) {
    return StorePlugin(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      version: json['version'] ?? '1.0.0',
      description: json['description'] ?? '',
      author: json['author'] ?? '',
      iconUrl: json['icon_url'] ?? '',
      downloadUrl: json['download_url'] ?? '',
    );
  }
}