import '../datasources/local_data_source.dart';
import '../datasources/remote_data_source.dart';
import '../models/user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final LocalDataSource localDataSource;
  final RemoteDataSource remoteDataSource;

  AuthRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<User> signInWithGoogle(String googleToken) async {
    // Verify token with backend
    final response = await remoteDataSource.verifyGoogleToken(googleToken);

    // Extract user and JWT from response
    final userData = response['user'] as Map<String, dynamic>;
    final jwtToken = response['token'] as String;

    final user = User(
      id: userData['id'],
      email: userData['email'],
      displayName: userData['displayName'],
      photoUrl: userData['photoUrl'],
      googleId: userData['googleId'],
      jwtToken: jwtToken,
      createdAt: DateTime.parse(userData['createdAt'] as String),
      isActive: true,
    );

    // Save JWT securely
    await remoteDataSource.saveJwtToken(jwtToken);

    // Save user locally
    await localDataSource.saveUser(user);

    return user;
  }

  @override
  Future<User?> getCurrentUser() async {
    final userJson = await localDataSource.getUser();
    if (userJson != null) {
      return User.fromJson(userJson);
    }
    return null;
  }

  @override
  Future<void> signOut() async {
    // Clear JWT token
    await remoteDataSource.clearJwtToken();

    // Clear user from local storage
    await localDataSource.clearUser();

    // TODO: Optionally clear all offline data
    // await localDataSource.clearAllAttendanceLogs();
  }

  @override
  Future<User> refreshUserProfile() async {
    final response = await remoteDataSource.getUserProfile();
    final user = User.fromJson(response);

    // Update locally
    await localDataSource.saveUser(user);

    return user;
  }

  @override
  Future<bool> isTokenValid() async {
    final token = await remoteDataSource.getJwtToken();
    if (token == null) return false;

    // In a real implementation, you would verify token expiry
    // For now, we just check if it exists
    return true;
  }
}
