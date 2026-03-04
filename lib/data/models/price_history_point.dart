class PriceHistoryPoint {
  final double price;
  final DateTime createdAt;

  PriceHistoryPoint({required this.price, required this.createdAt});

  factory PriceHistoryPoint.fromJson(Map<String, dynamic> json) {
    return PriceHistoryPoint(
      // Prisma devuelve el precio como número (int o double)
      price: (json['price'] as num).toDouble(),
      // Prisma devuelve la fecha como String ISO8601
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}