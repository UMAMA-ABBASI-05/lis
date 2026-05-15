class UserModel {
  final int? userId;
  final int? labId;

  final String? userName;
  final String email;
  final String password;

  UserModel({
    this.userId,
    this.labId,
    this.userName,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    "user_name": userName,
    "email": email,
    "password": password,
    "lab_id": labId,
  };
}
