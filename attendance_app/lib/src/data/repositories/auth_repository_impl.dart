import '../datasources/local_data_source.dart';
import '../datasources/remote_data_source.dart';
import '../../domain/models/user.dart';
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
    try {
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
    } catch (e) {
      // TEMPORARY: For development without backend, create a mock user
      // TODO: Remove this when backend is ready
      print('Backend not available, using mock user for development: $e');
      
      final mockUser = User(
        id: 'dev-user-${DateTime.now().millisecondsSinceEpoch}',
        email: 'developer@example.com',
        displayName: 'Development User',
        photoUrl: null,
        googleId: googleToken.substring(0, 20),
        jwtToken: 'mock-jwt-token',
        createdAt: DateTime.now(),
        isActive: true,
      );

      // Save mock JWT
      await remoteDataSource.saveJwtToken('mock-jwt-token');

      // Save mock user locally
      await localDataSource.saveUser(mockUser);

      return mockUser;
    }
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
