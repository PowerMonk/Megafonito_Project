class User {
  final String name;
  final String email;
  final String? role;
  final int? id;

  User({
    required this.name,
    required this.email,
    this.role,
    this.id,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'],
      id: json['id'],
    );
  }
}
