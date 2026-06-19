class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String phone;
  final String address;
  final String? avatar;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.phone = '',
    this.address = '',
    this.avatar,
  });

  String get fullName => '${firstName} ${lastName}'.trim().isEmpty
      ? username
      : '${firstName} ${lastName}'.trim();

  bool get isMerchant => role == 'merchant';
  bool get isClient => role == 'client';
  bool get isAdmin => role == 'admin';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      role: json['role'] ?? 'client',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() => {
    'username': username,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'role': role,
    'phone': phone,
    'address': address,
  };
}
