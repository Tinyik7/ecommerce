class UserModel {
  final int id;
  final String username;
  final String email;
  final String? role;
  final String? name;
  final String? createdAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.role,
    this.name,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
        username: json['username'] as String? ?? json['name']?.toString() ?? '',
        email: json['email'] as String? ?? '',
        role: json['role']?.toString(),
        name: json['name']?.toString(),
        createdAt: json['createdAt']?.toString(),
      );
}
