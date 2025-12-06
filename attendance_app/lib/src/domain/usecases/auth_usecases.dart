import '../repositories/auth_repository.dart';
import '../../data/models/user.dart';

/// Use case for Google OAuth sign in
class GoogleSignInUseCase {
  final AuthRepository repository;

  GoogleSignInUseCase({required this.repository});

  Future<User> execute(String googleToken) async {
    return await repository.signInWithGoogle(googleToken);
  }
}

/// Use case for getting current user
class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase({required this.repository});

  Future<User?> execute() async {
    return await repository.getCurrentUser();
  }
}

/// Use case for sign out
class SignOutUseCase {
  final AuthRepository repository;

  SignOutUseCase({required this.repository});

  Future<void> execute() async {
    return await repository.signOut();
  }
}
