class SalesModel {
  final String id;
  final String clientName;
  final double amount;
  final String status;
  final DateTime createdAt;

  const SalesModel({
    required this.id,
    required this.clientName,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  String get orderCode => id.startsWith('#') ? id : '#$id';

  SalesModel copyWith({
    String? id,
    String? clientName,
    double? amount,
    String? status,
    DateTime? createdAt,
  }) {
    return SalesModel(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientName': clientName,
      'amount': amount,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SalesModel.fromMap(Map<String, dynamic> map) {
    return SalesModel(
      id: map['id'] as String,
      clientName: map['clientName'] as String,
      amount: (map['amount'] as num).toDouble(),
      status: map['status'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
