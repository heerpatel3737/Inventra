class PurchaseModel {
  final String id;
  final String supplierName;
  final double amount;
  final String status;
  final DateTime createdAt;
  final DateTime expectedDelivery;

  const PurchaseModel({
    required this.id,
    required this.supplierName,
    required this.amount,
    required this.status,
    required this.createdAt,
    required this.expectedDelivery,
  });

  String get orderCode => id.startsWith('#') ? id : '#$id';

  PurchaseModel copyWith({
    String? id,
    String? supplierName,
    double? amount,
    String? status,
    DateTime? createdAt,
    DateTime? expectedDelivery,
  }) {
    return PurchaseModel(
      id: id ?? this.id,
      supplierName: supplierName ?? this.supplierName,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      expectedDelivery: expectedDelivery ?? this.expectedDelivery,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supplierName': supplierName,
      'amount': amount,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'expectedDelivery': expectedDelivery.toIso8601String(),
    };
  }

  factory PurchaseModel.fromMap(Map<String, dynamic> map) {
    return PurchaseModel(
      id: map['id'] as String,
      supplierName: map['supplierName'] as String,
      amount: (map['amount'] as num).toDouble(),
      status: map['status'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      expectedDelivery: DateTime.parse(map['expectedDelivery'] as String),
    );
  }
}
