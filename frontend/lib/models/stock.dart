class Stock {
  final int id;
  final int productId;
  final String productName;
  final String boutiqueName;
  final int quantity;
  final int threshold;
  final bool isLow;

  Stock({
    required this.id,
    required this.productId,
    this.productName = '',
    this.boutiqueName = '',
    required this.quantity,
    this.threshold = 5,
    this.isLow = false,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      id: json['id'] ?? 0,
      productId: json['product'] ?? 0,
      productName: json['product_name'] ?? '',
      boutiqueName: json['boutique_name'] ?? '',
      quantity: json['quantity'] ?? 0,
      threshold: json['threshold'] ?? 5,
      isLow: json['is_low'] ?? false,
    );
  }
}

class StockMovement {
  final String movementType;
  final int quantity;
  final String reason;

  StockMovement({
    required this.movementType,
    required this.quantity,
    this.reason = '',
  });

  Map<String, dynamic> toJson() => {
        'movement_type': movementType,
        'quantity': quantity,
        'reason': reason,
      };
}
