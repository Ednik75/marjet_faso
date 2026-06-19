class Payment {
  final int id;
  final int orderId;
  final String method;
  final String methodDisplay;
  final double amount;
  final String status;
  final String statusDisplay;
  final String? transactionId;
  final String? createdAt;

  Payment({
    required this.id,
    required this.orderId,
    required this.method,
    this.methodDisplay = '',
    required this.amount,
    this.status = 'pending',
    this.statusDisplay = '',
    this.transactionId,
    this.createdAt,
  });

  String get amountFormatted => '${amount.toStringAsFixed(0)} FCFA';

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? 0,
      orderId: json['order'] ?? 0,
      method: json['method'] ?? 'cash',
      methodDisplay: json['method_display'] ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      status: json['status'] ?? 'pending',
      statusDisplay: json['status_display'] ?? '',
      transactionId: json['transaction_id'],
      createdAt: json['created_at'],
    );
  }
}
