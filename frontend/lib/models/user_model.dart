class User {
  final int id;
  final String username;
  final String name;
  final String email;
  final String role;
  final String? groupName;
  final String? controlNumber;
  final int? semester;

  const User({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.role,
    this.groupName,
    this.controlNumber,
    this.semester,
  });

  bool get isAdmin => role == 'admin';

  String get roleLabel => isAdmin ? 'Administrador' : 'Estudiante';

  String get groupLabel {
    final group = groupName;
    if (group == null || group.isEmpty) return 'Administración';
    return group;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['id'] as num?)?.toInt() ?? 0,
      username: json['username']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Usuario',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'student',
      groupName: json['group_name']?.toString(),
      controlNumber: json['control_number']?.toString(),
      semester: (json['semester'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'email': email,
      'role': role,
      'group_name': groupName,
      'control_number': controlNumber,
      'semester': semester,
    };
  }
}
