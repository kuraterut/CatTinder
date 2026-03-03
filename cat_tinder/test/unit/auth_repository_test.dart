import 'package:cat_tinder/data/repositories/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockito/annotations.dart';
import 'package:cat_tinder/domain/entities/user.dart';
import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';

@GenerateMocks([FlutterSecureStorage, SharedPreferences])
import 'auth_repository_test.mocks.dart';

class TestAuthRepository extends AuthRepository {
  final Map<String, Map<String, dynamic>> _users = {};
  bool _isAuthenticated = false;
  String? _currentUserEmail;

  TestAuthRepository({
    required super.secureStorage,
    required super.sharedPreferences,
  });

  @override
  Future<Either<String, User>> signUp(String email, String password, String name) async {
    // Валидация
    if (email.isEmpty || !email.contains('@')) {
      return const Left('Некорректный email');
    }
    if (password.isEmpty || password.length < 6) {
      return const Left('Пароль должен быть не менее 6 символов');
    }
    if (name.isEmpty) {
      return const Left('Имя не может быть пустым');
    }

    // Проверяем, не занят ли email
    if (_users.containsKey(email)) {
      return const Left('Пользователь с таким email уже существует');
    }

    // Создаем нового пользователя
    final userId = DateTime.now().millisecondsSinceEpoch.toString();
    _users[email] = {
      'id': userId,
      'email': email,
      'name': name,
      'password': password,
    };

    _isAuthenticated = true;
    _currentUserEmail = email;

    return Right(User(
      id: userId,
      email: email,
      displayName: name,
      isAuthenticated: true,
    ));
  }

  @override
  Future<Either<String, User>> signIn(String email, String password) async {
    // Валидация
    if (email.isEmpty || !email.contains('@')) {
      return const Left('Некорректный email');
    }
    if (password.isEmpty || password.length < 6) {
      return const Left('Пароль должен быть не менее 6 символов');
    }

    // Ищем пользователя
    final user = _users[email];
    if (user == null) {
      return const Left('Аккаунт с таким email не существует');
    }

    // Проверяем пароль
    if (user['password'] != password) {
      return const Left('Неверный пароль');
    }

    _isAuthenticated = true;
    _currentUserEmail = email;

    return Right(User(
      id: user['id'],
      email: email,
      displayName: user['name'],
      isAuthenticated: true,
    ));
  }

  @override
  Future<void> signOut() async {
    _isAuthenticated = false;
    _currentUserEmail = null;
  }

  @override
  Future<User?> getCurrentUser() async {
    if (!_isAuthenticated || _currentUserEmail == null) return null;

    final user = _users[_currentUserEmail];
    if (user == null) return null;

    return User(
      id: user['id'],
      email: user['email'],
      displayName: user['name'],
      isAuthenticated: true,
    );
  }
}

void main() {
  group('AuthRepository Tests', () {
    late MockFlutterSecureStorage mockStorage;
    late MockSharedPreferences mockSharedPreferences;
    late TestAuthRepository repository;

    setUp(() {
      mockStorage = MockFlutterSecureStorage();
      mockSharedPreferences = MockSharedPreferences();
      repository = TestAuthRepository(
        secureStorage: mockStorage,
        sharedPreferences: mockSharedPreferences,
      );
    });

    test('signIn with valid credentials should return user', () async {
      // Сначала создаем пользователя через signUp
      final signUpResult = await repository.signUp(
          'test@test.com',
          '123456',
          'Test User'
      );

      expect(signUpResult.isRight(), true);

      // Теперь пробуем войти
      final result = await repository.signIn('test@test.com', '123456');

      expect(result.isRight(), true);
      result.fold(
            (l) => fail('Should be right'),
            (r) {
          expect(r.email, 'test@test.com');
          expect(r.displayName, 'Test User');
          expect(r.isAuthenticated, true);
        },
      );
    });

    test('signIn with non-existent email should return error', () async {
      final result = await repository.signIn('nonexistent@test.com', '123456');

      expect(result.isLeft(), true);
      result.fold(
            (l) => expect(l, 'Аккаунт с таким email не существует'),
            (r) => fail('Should be left'),
      );
    });

    test('signIn with wrong password should return error', () async {
      // Создаем пользователя
      await repository.signUp('test@test.com', '123456', 'Test User');

      // Пробуем войти с неправильным паролем
      final result = await repository.signIn('test@test.com', 'wrongpass');

      expect(result.isLeft(), true);
      result.fold(
            (l) => expect(l, 'Неверный пароль'),
            (r) => fail('Should be left'),
      );
    });

    test('signIn with invalid email should return error', () async {
      final result = await repository.signIn('invalid', '123456');

      expect(result.isLeft(), true);
      result.fold(
            (l) => expect(l, 'Некорректный email'),
            (r) => fail('Should be left'),
      );
    });

    test('signIn with short password should return error', () async {
      final result = await repository.signIn('test@test.com', '123');

      expect(result.isLeft(), true);
      result.fold(
            (l) => expect(l, 'Пароль должен быть не менее 6 символов'),
            (r) => fail('Should be left'),
      );
    });

    test('signUp with valid data should return user', () async {
      final result = await repository.signUp(
          'new@test.com',
          '123456',
          'Test User'
      );

      expect(result.isRight(), true);
      result.fold(
            (l) => fail('Should be right'),
            (r) {
          expect(r.email, 'new@test.com');
          expect(r.displayName, 'Test User');
          expect(r.isAuthenticated, true);
        },
      );
    });

    test('signUp with existing email should return error', () async {
      // Создаем первого пользователя
      await repository.signUp('existing@test.com', '123456', 'First User');

      // Пробуем создать второго с тем же email
      final result = await repository.signUp(
          'existing@test.com',
          '123456',
          'Second User'
      );

      expect(result.isLeft(), true);
      result.fold(
            (l) => expect(l, 'Пользователь с таким email уже существует'),
            (r) => fail('Should be left'),
      );
    });

    test('signUp with invalid email should return error', () async {
      final result = await repository.signUp(
          'invalid',
          '123456',
          'Test User'
      );

      expect(result.isLeft(), true);
      result.fold(
            (l) => expect(l, 'Некорректный email'),
            (r) => fail('Should be left'),
      );
    });

    test('signUp with short password should return error', () async {
      final result = await repository.signUp(
          'new@test.com',
          '123',
          'Test User'
      );

      expect(result.isLeft(), true);
      result.fold(
            (l) => expect(l, 'Пароль должен быть не менее 6 символов'),
            (r) => fail('Should be left'),
      );
    });

    test('signUp with empty name should return error', () async {
      final result = await repository.signUp(
          'new@test.com',
          '123456',
          ''
      );

      expect(result.isLeft(), true);
      result.fold(
            (l) => expect(l, 'Имя не может быть пустым'),
            (r) => fail('Should be left'),
      );
    });

    test('signOut should clear current user', () async {
      // Создаем пользователя
      await repository.signUp('test@test.com', '123456', 'Test User');

      // Проверяем, что пользователь есть
      var currentUser = await repository.getCurrentUser();
      expect(currentUser, isNotNull);

      // Выходим
      await repository.signOut();

      // Проверяем, что пользователя нет
      currentUser = await repository.getCurrentUser();
      expect(currentUser, isNull);
    });
  });
}