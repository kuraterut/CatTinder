import 'package:cat_tinder/data/models/cat_breed.dart';
import 'package:cat_tinder/data/models/cat_image.dart';
import 'package:cat_tinder/data/repositories/cat_repository.dart';
import 'package:cat_tinder/domain/usecases/auth_usecases.dart';
import 'package:cat_tinder/presentation/pages/auth_page.dart';
import 'package:cat_tinder/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:cat_tinder/domain/entities/user.dart';
import 'package:cat_tinder/presentation/providers/cat_provider.dart';
import 'package:cat_tinder/presentation/providers/breeds_provider.dart';

class MockCatRepository extends Mock implements CatRepository {
  @override
  Future<List<CatImage>> getRandomCatImages({int limit = 1}) async {
    return [];
  }

  @override
  Future<List<CatBreed>> getAllBreeds() async {
    return [];
  }
}

// Создаем мок для AuthProvider
class MockAuthProvider extends ChangeNotifier implements AuthProvider {
  @override
  late final SignUpUseCase signUpUseCase;

  @override
  late final SignInUseCase signInUseCase;

  @override
  late final SignOutUseCase signOutUseCase;

  @override
  late final GetCurrentUserUseCase getCurrentUserUseCase;

  @override
  User? currentUser;

  @override
  bool isLoading = false;

  @override
  String? error;

  bool shouldSignInSucceed = true;
  bool shouldSignUpSucceed = true;

  @override
  bool get isAuthenticated => currentUser?.isAuthenticated ?? false;

  @override
  Future<bool> signIn(String email, String password) async {
    if (shouldSignInSucceed) {
      currentUser = User(
        id: '1',
        email: email,
        displayName: 'Test User',
        isAuthenticated: true,
      );
      notifyListeners();
      return true;
    }
    error = 'Неверный email или пароль';
    notifyListeners();
    return false;
  }

  @override
  Future<bool> signUp(String email, String password, String name) async {
    if (shouldSignUpSucceed) {
      currentUser = User(
        id: '2',
        email: email,
        displayName: name,
        isAuthenticated: true,
      );
      notifyListeners();
      return true;
    }
    error = 'Ошибка регистрации';
    notifyListeners();
    return false;
  }

  @override
  Future<void> signOut() async {
    currentUser = null;
    notifyListeners();
  }

  @override
  Future<void> checkAuthStatus() async {}

  @override
  void clearError() {
    error = null;
    notifyListeners();
  }
}

// Создаем мок для CatProvider
class MockCatProvider extends ChangeNotifier implements CatProvider {
  @override
  bool isLoading = false;

  @override
  String? error;

  @override
  int likesCount = 0;

  @override
  CatImage? currentCat;

  @override
  List<CatImage> catImages = [];

  @override
  late final CatRepository repository;

  MockCatProvider() {
    repository = MockCatRepository();
  }

  @override
  Future<void> loadRandomCat() async {}

  @override
  void likeCat() {}

  @override
  void dislikeCat() {}

  @override
  void clearError() {}
}

// Создаем мок для BreedsProvider
class MockBreedsProvider extends ChangeNotifier implements BreedsProvider {
  @override
  bool isLoading = false;

  @override
  String? error;

  @override
  List<CatBreed> breeds = [];

  @override
  late final CatRepository repository;

  MockBreedsProvider() {
    repository = MockCatRepository();
  }

  @override
  Future<void> loadAllBreeds() async {}

  @override
  void clearError() {}
}

void main() {
  group('AuthPage Widget Tests', () {
    testWidgets('should show login form by default', (tester) async {
      final mockAuthProvider = MockAuthProvider();
      final mockCatProvider = MockCatProvider();
      final mockBreedsProvider = MockBreedsProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
            ChangeNotifierProvider<CatProvider>.value(value: mockCatProvider),
            ChangeNotifierProvider<BreedsProvider>.value(value: mockBreedsProvider),
          ],
          child: const MaterialApp(
            home: AuthPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Вход'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Пароль'), findsOneWidget);
      expect(find.text('Имя'), findsNothing);
    });

    testWidgets('should show validation errors for empty fields', (tester) async {
      final mockAuthProvider = MockAuthProvider();
      final mockCatProvider = MockCatProvider();
      final mockBreedsProvider = MockBreedsProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
            ChangeNotifierProvider<CatProvider>.value(value: mockCatProvider),
            ChangeNotifierProvider<BreedsProvider>.value(value: mockBreedsProvider),
          ],
          child: const MaterialApp(
            home: AuthPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Нажимаем кнопку входа без заполнения полей
      await tester.tap(find.text('Войти'));
      await tester.pump();

      // Проверяем сообщения об ошибках валидации
      expect(find.text('Введите email'), findsOneWidget);
      expect(find.text('Введите пароль'), findsOneWidget);
    });

    testWidgets('should switch to registration form', (tester) async {
      final mockAuthProvider = MockAuthProvider();
      final mockCatProvider = MockCatProvider();
      final mockBreedsProvider = MockBreedsProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
            ChangeNotifierProvider<CatProvider>.value(value: mockCatProvider),
            ChangeNotifierProvider<BreedsProvider>.value(value: mockBreedsProvider),
          ],
          child: const MaterialApp(
            home: AuthPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Нажимаем на ссылку регистрации
      await tester.tap(find.text('Нет аккаунта? Зарегистрироваться'));
      await tester.pumpAndSettle();

      expect(find.text('Регистрация'), findsOneWidget);
      expect(find.text('Имя'), findsOneWidget);
    });

    testWidgets('should successfully login with valid credentials', (tester) async {
      final mockAuthProvider = MockAuthProvider();
      mockAuthProvider.shouldSignInSucceed = true;

      final mockCatProvider = MockCatProvider();
      final mockBreedsProvider = MockBreedsProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
            ChangeNotifierProvider<CatProvider>.value(value: mockCatProvider),
            ChangeNotifierProvider<BreedsProvider>.value(value: mockBreedsProvider),
          ],
          child: const MaterialApp(
            home: AuthPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Заполняем поля
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'test@test.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Пароль'), '123456');

      // Нажимаем кнопку входа
      await tester.tap(find.text('Войти'));
      await tester.pumpAndSettle();

      // Проверяем, что провайдер обновил состояние
      expect(mockAuthProvider.currentUser, isNotNull);
      expect(mockAuthProvider.currentUser?.email, 'test@test.com');
    });

    testWidgets('should show error message on failed login', (tester) async {
      final mockAuthProvider = MockAuthProvider();
      mockAuthProvider.shouldSignInSucceed = false;

      final mockCatProvider = MockCatProvider();
      final mockBreedsProvider = MockBreedsProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
            ChangeNotifierProvider<CatProvider>.value(value: mockCatProvider),
            ChangeNotifierProvider<BreedsProvider>.value(value: mockBreedsProvider),
          ],
          child: const MaterialApp(
            home: AuthPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Заполняем поля
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'wrong@test.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Пароль'), 'wrongpass');

      // Нажимаем кнопку входа
      await tester.tap(find.text('Войти'));
      await tester.pump();

      // Проверяем, что появилось сообщение об ошибке (теперь это красный контейнер, а не SnackBar)
      expect(find.text('Неверный email или пароль'), findsOneWidget);
    });

    testWidgets('should successfully register', (tester) async {
      final mockAuthProvider = MockAuthProvider();
      mockAuthProvider.shouldSignUpSucceed = true;

      final mockCatProvider = MockCatProvider();
      final mockBreedsProvider = MockBreedsProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
            ChangeNotifierProvider<CatProvider>.value(value: mockCatProvider),
            ChangeNotifierProvider<BreedsProvider>.value(value: mockBreedsProvider),
          ],
          child: const MaterialApp(
            home: AuthPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Переключаемся на форму регистрации
      await tester.tap(find.text('Нет аккаунта? Зарегистрироваться'));
      await tester.pumpAndSettle();

      // Заполняем поля
      await tester.enterText(find.widgetWithText(TextFormField, 'Имя'), 'New User');
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'new@test.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Пароль'), '123456');

      // Нажимаем кнопку регистрации
      await tester.tap(find.text('Зарегистрироваться'));
      await tester.pumpAndSettle();

      // Проверяем, что провайдер обновил состояние
      expect(mockAuthProvider.currentUser, isNotNull);
      expect(mockAuthProvider.currentUser?.email, 'new@test.com');
      expect(mockAuthProvider.currentUser?.displayName, 'New User');
    });
  });
}