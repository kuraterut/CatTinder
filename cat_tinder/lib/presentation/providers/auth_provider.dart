import 'package:flutter/material.dart';

import '../../domain/entities/user.dart';
import '../../domain/usecases/auth_usecases.dart';

class AuthProvider extends ChangeNotifier {
  final SignUpUseCase signUpUseCase;
  final SignInUseCase signInUseCase;
  final SignOutUseCase signOutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthProvider({
    required this.signUpUseCase,
    required this.signInUseCase,
    required this.signOutUseCase,
    required this.getCurrentUserUseCase,
  }) {
    checkAuthStatus();
  }

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser?.isAuthenticated ?? false;

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    _currentUser = await getCurrentUserUseCase();

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> signUp(String email, String password, String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await signUpUseCase(email, password, name);

    _isLoading = false;

    result.fold(
          (error) {
        _error = error;
        notifyListeners();
        return false;
      },
          (user) {
        _currentUser = user;
        notifyListeners();
        return true;
      },
    );

    return result.isRight();
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await signInUseCase(email, password);

    _isLoading = false;

    result.fold(
          (error) {
        _error = error;
        notifyListeners();
        return false;
      },
          (user) {
        _currentUser = user;
        notifyListeners();
        return true;
      },
    );

    return result.isRight();
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    await signOutUseCase();
    _currentUser = null;

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}