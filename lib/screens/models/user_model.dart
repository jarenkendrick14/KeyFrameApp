class User {
  final int userId;
  final String username;
  final String email;
  final String fullName;
  final String membershipTier;
  final String authProvider;
  final Map<String, dynamic>? address;
  final Map<String, dynamic>? paymentMethod;

  User({
    required this.userId,
    required this.username,
    required this.email,
    required this.fullName,
    this.membershipTier = 'STANDARD',
    this.authProvider = 'LOCAL',
    this.address,
    this.paymentMethod,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] is int ? json['user_id'] : int.parse(json['user_id'].toString()),
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      membershipTier: json['membership_tier'] ?? 'STANDARD',
      authProvider: json['auth_provider'] ?? 'LOCAL',
      address: json['address'],
      paymentMethod: json['payment_method'],
    );
  }
}
