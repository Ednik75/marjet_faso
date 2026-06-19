class Boutique {
  final int id;
  final int? ownerId;
  final String ownerName;
  final String name;
  final String description;
  final String address;
  final String phone;
  final String email;
  final String? image;
  final double latitude;
  final double longitude;
  final String category;
  final String status;
  final bool isActive;
  final String openingHours;
  final double? distance;
  final String? createdAt;

  Boutique({
    required this.id,
    this.ownerId,
    this.ownerName = '',
    required this.name,
    this.description = '',
    required this.address,
    this.phone = '',
    this.email = '',
    this.image,
    required this.latitude,
    required this.longitude,
    this.category = '',
    this.status = 'pending',
    this.isActive = true,
    this.openingHours = '',
    this.distance,
    this.createdAt,
  });

  factory Boutique.fromJson(Map<String, dynamic> json) {
    return Boutique(
      id: json['id'] ?? 0,
      ownerId: json['owner'],
      ownerName: json['owner_name'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      image: json['image'],
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      status: json['status'] ?? 'pending',
      isActive: json['is_active'] ?? true,
      openingHours: json['opening_hours'] ?? '',
      distance: json['distance']?.toDouble(),
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'address': address,
    'phone': phone,
    'email': email,
    'latitude': latitude,
    'longitude': longitude,
    'category': category,
    'opening_hours': openingHours,
  };
}
