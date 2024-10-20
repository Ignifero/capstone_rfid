class UserModel {
  final String id;
  final String username;
  final String password;

  UserModel({
    required this.id,
    required this.username,
    required this.password,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['nombre'],
      password: json['email'],
    );
  }



}