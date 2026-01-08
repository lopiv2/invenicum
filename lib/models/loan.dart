// lib/models/loan.dart

class Loan {
  final int id;
  final int containerId;
  final int inventoryItemId;
  final String itemName;
  final String? borrowerName;
  final String? borrowerEmail;
  final String? borrowerPhone;
  final DateTime loanDate;
  final DateTime? expectedReturnDate;
  final DateTime? actualReturnDate;
  final String? notes;
  final String status; // 'active', 'returned', 'overdue'

  Loan({
    required this.id,
    required this.containerId,
    required this.inventoryItemId,
    required this.itemName,
    this.borrowerName,
    this.borrowerEmail,
    this.borrowerPhone,
    required this.loanDate,
    this.expectedReturnDate,
    this.actualReturnDate,
    this.notes,
    required this.status,
  });

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: json['id'] as int,
      containerId: json['containerId'] as int,
      inventoryItemId: json['inventoryItemId'] as int,
      itemName: json['itemName'] as String? ?? '',
      borrowerName: json['borrowerName'] as String?,
      borrowerEmail: json['borrowerEmail'] as String?,
      borrowerPhone: json['borrowerPhone'] as String?,
      loanDate: json['loanDate'] != null
          ? DateTime.parse(json['loanDate'] as String)
          : DateTime.now(),
      expectedReturnDate: json['expectedReturnDate'] != null
          ? DateTime.parse(json['expectedReturnDate'] as String)
          : null,
      actualReturnDate: json['actualReturnDate'] != null
          ? DateTime.parse(json['actualReturnDate'] as String)
          : null,
      notes: json['notes'] as String?,
      status: json['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'containerId': containerId,
      'inventoryItemId': inventoryItemId,
      'itemName': itemName,
      'borrowerName': borrowerName,
      'borrowerEmail': borrowerEmail,
      'borrowerPhone': borrowerPhone,
      'loanDate': loanDate.toLocal().toString().split(' ')[0],
      'expectedReturnDate': expectedReturnDate != null
          ? expectedReturnDate!.toLocal().toString().split(' ')[0]
          : null,
      'actualReturnDate': actualReturnDate != null
          ? actualReturnDate!.toLocal().toString().split(' ')[0]
          : null,
      'notes': notes,
      'status': status,
    };
  }

  /// Serializa solo los campos que se pueden editar (excluyendo id, inventoryItemId, loanDate)
  Map<String, dynamic> toJsonForUpdate() {
    return {
      'borrowerName': borrowerName,
      'borrowerEmail': borrowerEmail,
      'borrowerPhone': borrowerPhone,
      'expectedReturnDate': expectedReturnDate != null
          ? expectedReturnDate!.toLocal().toString().split(' ')[0]
          : null,
      'notes': notes,
      'status': status,
    };
  }

  Loan copyWith({
    int? id,
    int? containerId,
    int? inventoryItemId,
    String? itemName,
    String? borrowerName,
    String? borrowerEmail,
    String? borrowerPhone,
    DateTime? loanDate,
    DateTime? expectedReturnDate,
    DateTime? actualReturnDate,
    String? notes,
    String? status,
  }) {
    return Loan(
      id: id ?? this.id,
      containerId: containerId ?? this.containerId,
      inventoryItemId: inventoryItemId ?? this.inventoryItemId,
      itemName: itemName ?? this.itemName,
      borrowerName: borrowerName ?? this.borrowerName,
      borrowerEmail: borrowerEmail ?? this.borrowerEmail,
      borrowerPhone: borrowerPhone ?? this.borrowerPhone,
      loanDate: loanDate ?? this.loanDate,
      expectedReturnDate: expectedReturnDate ?? this.expectedReturnDate,
      actualReturnDate: actualReturnDate ?? this.actualReturnDate,
      notes: notes ?? this.notes,
      status: status ?? this.status,
    );
  }

  bool get isOverdue {
    if (status != 'active' || expectedReturnDate == null) return false;
    return DateTime.now().isAfter(expectedReturnDate!);
  }
}
