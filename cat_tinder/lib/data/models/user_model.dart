import '../../domain/entities/user.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String passwordHash;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.passwordHash,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'passwordHash': passwordHash,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    email: json['email'],
    name: json['name'],
    passwordHash: json['passwordHash'],
  );

  User toUser() => User(
    id: id,
    email: email,
    displayName: name,
    isAuthenticated: true,
  );
}