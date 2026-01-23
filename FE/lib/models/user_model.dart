class UserModel {
  final String username;
  final String role;

  UserModel({required this.username, required this.role});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'username': username, 'role': role};
}
