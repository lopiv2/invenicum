class ExpiringLoan {
  final String itemName;
  final String borrowerName;
  final int quantity;

  ExpiringLoan({
    required this.itemName, 
    required this.borrowerName,
    required this.quantity,
  });

  factory ExpiringLoan.fromJson(Map<String, dynamic> json) {
    return ExpiringLoan(
      itemName: json['itemName'] ?? '',
      borrowerName: json['borrowerName'] ?? 'Alguien',
      quantity: json['quantity'] ?? 1,
    );
  }
}

// Dentro de tu clase DashboardStats añade:
// final List<ExpiringLoan> loansExpiringToday;