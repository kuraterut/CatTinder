import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/user.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FlutterSecureStorage secureStorage;
  final SharedPreferences sharedPreferences;

  static const String _usersKey = 'registered_users';
  static const String _currentUserKey = 'current_user_email';
  static const String _authKey = 'is_authenticated';

  AuthRepository({
    required this.secureStorage,
    required this.sharedPreferences,
  });

  List<UserModel> _getAllUsers() {
    final usersJson = sharedPreferences.getStringList(_usersKey) ?? [];
    return usersJson
        .map((json) => UserModel.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<void> _saveUsers(List<UserModel> users) async {
    final usersJson = users.map((u) => jsonEncode(u.toJson())).toList();
    await sharedPreferences.setStringList(_usersKey, usersJson);
  }

  Future<Either<String, User>> signIn(String email, String password) async {
    try {
      if (email.isEmpty || !email.contains('@')) {
        return const Left('Некорректный email');
      }
      if (password.isEmpty || password.length < 6) {
        return const Left('Пароль должен быть не менее 6 символов');
      }

      final users = _getAllUsers();
      final user = users.firstWhere(
            (u) => u.email == email,
        orElse: () => throw Exception('User not found'),
      );

      if (user.passwordHash != password) {
        return const Left('Неверный пароль');
      }

      await secureStorage.write(key: _authKey, value: 'true');
      await secureStorage.write(key: _currentUserKey, value: email);

      return Right(user.toUser());
    } catch (e) {
      if (e.toString().contains('User not found')) {
        return const Left('Аккаунт с таким email не существует');
      }
      return Left('Ошибка входа: ${e.toString()}');
    }
  }

  Future<Either<String, User>> signUp(String email, String password, String name) async {
    try {
      if (email.isEmpty || !email.contains('@')) {
        return const Left('Некорректный email');
      }
      if (password.isEmpty || password.length < 6) {
        return const Left('Пароль должен быть не менее 6 символов');
      }
      if (name.isEmpty) {
        return const Left('Имя не может быть пустым');
      }

      final users = _getAllUsers();
      if (users.any((u) => u.email == email)) {
        return const Left('Пользователь с таким email уже существует');
      }

      final newUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: name,
        passwordHash: password,
      );

      users.add(newUser);
      await _saveUsers(users);

      await secureStorage.write(key: _authKey, value: 'true');
      await secureStorage.write(key: _currentUserKey, value: email);

      return Right(newUser.toUser());
    } catch (e) {
      return Left('Ошибка регистрации: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    await secureStorage.delete(key: _authKey);
    await secureStorage.delete(key: _currentUserKey);
  }

  Future<User?> getCurrentUser() async {
    try {
      final isAuth = await secureStorage.read(key: _authKey);
      if (isAuth != 'true') return null;

      final email = await secureStorage.read(key: _currentUserKey);
      if (email == null) return null;

      final users = _getAllUsers();
      final user = users.firstWhere(
            (u) => u.email == email,
        orElse: () => throw Exception('User not found'),
      );

      return user.toUser();
    } catch (e) {
      return null;
    }
  }

  Future<bool> isAuthenticated() async {
    try {
      return await secureStorage.read(key: _authKey) == 'true';
    } catch (e) {
      return false;
    }
  }
}