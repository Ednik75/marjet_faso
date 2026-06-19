class Order {
  final int id;
  final int? clientId;
  final String clientName;
  final int boutiqueId;
  final String boutiqueName;
  final String status;
  final double totalAmount;
  final String deliveryAddress;
  final String notes;
  final List<OrderItem> items;
  final String? createdAt;

  Order({
    required this.id,
    this.clientId,
    this.clientName = '',
    required this.boutiqueId,
    this.boutiqueName = '',
    this.status = 'pending',
    this.totalAmount = 0,
    this.deliveryAddress = '',
    this.notes = '',
    this.items = const [],
    this.createdAt,
  });

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'confirmed':
        return 'Confirmée';
      case 'preparing':
        return 'En préparation';
      case 'ready':
        return 'Prête';
      case 'delivered':
        return 'Livrée';
      case 'cancelled':
        return 'Annulée';
      default:
        return status;
    }
  }

  String get totalFormatted => '${totalAmount.toStringAsFixed(0)} FCFA';

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      clientId: json['client'],
      clientName: json['client_name'] ?? '',
      boutiqueId: json['boutique'] ?? 0,
      boutiqueName: json['boutique_name'] ?? '',
      status: json['status'] ?? 'pending',
      totalAmount:
          double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0,
      deliveryAddress: json['delivery_address'] ?? '',
      notes: json['notes'] ?? '',
      items: (json['items'] as List? ?? [])
          .map((i) => OrderItem.fromJson(i))
          .toList(),
      createdAt: json['created_at'],
    );
  }
}

class OrderItem {
  final int? id;
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  OrderItem({
    this.id,
    required this.productId,
    this.productName = '',
    required this.quantity,
    this.unitPrice = 0,
    this.subtotal = 0,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      productId: json['product'] ?? 0,
      productName: json['product_name'] ?? '',
      quantity: json['quantity'] ?? 1,
      unitPrice: double.tryParse(json['unit_price']?.toString() ?? '0') ?? 0,
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {'product': productId, 'quantity': quantity};
}
