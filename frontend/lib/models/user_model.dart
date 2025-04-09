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
}
