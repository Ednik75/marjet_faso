class Review {
  final int id;
  final int? userId;
  final String userName;
  final String username;
  final int? boutiqueId;
  final int? productId;
  final int rating;
  final String comment;
  final String? createdAt;

  Review({
    required this.id,
    this.userId,
    this.userName = '',
    this.username = '',
    this.boutiqueId,
    this.productId,
    required this.rating,
    this.comment = '',
    this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? 0,
      userId: json['user'],
      userName: json['user_name'] ?? '',
      username: json['username'] ?? '',
      boutiqueId: json['boutique'],
      productId: json['product'],
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() => {
    'boutique': boutiqueId,
    'product': productId,
    'rating': rating,
    'comment': comment,
  };
}
