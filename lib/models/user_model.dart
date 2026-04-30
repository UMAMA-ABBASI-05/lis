class UserModel {
  final int? userId;
  final String userName;
  final String email;
  final String password;

  UserModel({
    this.userId,
    required this.userName,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    "user_name": userName,
    "email": email,
    "password": password,
  };
}
