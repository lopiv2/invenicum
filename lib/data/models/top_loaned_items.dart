class TopLoanedItem {
  final int id;
  final String name;
  final int count;
  final int assetTypeId;
  final int containerId;

  TopLoanedItem({
    required this.id,
    required this.name,
    required this.count,
    required this.assetTypeId,
    required this.containerId,
  });

  factory TopLoanedItem.fromJson(Map<String, dynamic> json) {
    return TopLoanedItem(
      // Usamos .toString() y parse para evitar errores de tipo si el back envía Strings
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? 'Sin nombre',
      count: int.tryParse(json['count']?.toString() ?? '0') ?? 0,
      assetTypeId: int.tryParse(json['assetTypeId']?.toString() ?? '0') ?? 0,
      containerId: int.tryParse(json['containerId']?.toString() ?? '0') ?? 0,
    );
  }
}