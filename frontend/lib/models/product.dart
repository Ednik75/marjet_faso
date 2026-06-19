class Product {
  final int id;
  final int boutiqueId;
  final String boutiqueName;
  final String name;
  final String description;
  final double price;
  final String? image;
  final String category;
  final bool isAvailable;
  final int? stockQuantity;
  final String? createdAt;

  Product({
    required this.id,
    required this.boutiqueId,
    this.boutiqueName = '',
    required this.name,
    this.description = '',
    required this.price,
    this.image,
    this.category = 'autre',
    this.isAvailable = true,
    this.stockQuantity,
    this.createdAt,
  });

  String get priceFormatted => '${price.toStringAsFixed(0)} FCFA';

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      boutiqueId: json['boutique'] ?? 0,
      boutiqueName: json['boutique_name'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      image: json['image'],
      category: json['category'] ?? 'autre',
      isAvailable: json['is_available'] ?? true,
      stockQuantity: json['stock_quantity'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() => {
    'boutique': boutiqueId,
    'name': name,
    'description': description,
    'price': price.toString(),
    'category': category,
    'is_available': isAvailable,
  };
}
