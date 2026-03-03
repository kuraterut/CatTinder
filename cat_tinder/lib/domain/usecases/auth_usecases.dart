import 'package:dartz/dartz.dart';

import '../../data/repositories/auth_repository.dart';
import '../entities/user.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<Either<String, User>> call(String email, String password, String name) {
    return repository.signUp(email, password, name);
  }
}

class SignInUseCase {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  Future<Either<String, User>> call(String email, String password) {
    return repository.signIn(email, password);
  }
}

class SignOutUseCase {
  final AuthRepository repository;

  SignOutUseCase(this.repository);

  Future<void> call() {
    return repository.signOut();
  }
}

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<User?> call() {
    return repository.getCurrentUser();
  }
}