import '../models/user.dart';

/// Repository interface for authentication
abstract class AuthRepository {
  /// Sign in using Google OAuth
  Future<User> signInWithGoogle(String googleToken);

  /// Get currently logged-in user
  Future<User?> getCurrentUser();

  /// Sign out the current user
  Future<void> signOut();

  /// Refresh user profile from server
  Future<User> refreshUserProfile();

  /// Check if JWT token is still valid
  Future<bool> isTokenValid();
}
