// lib/models/user.dart
class User {
  final int id;
  final String name;
  final String email;
  final String role; // 'admin' atau 'user'

  User({required this.id, required this.name, required this.email, required this.role});

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    role: json['role'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role,
  };

  bool get isAdmin => role == 'admin';
}
