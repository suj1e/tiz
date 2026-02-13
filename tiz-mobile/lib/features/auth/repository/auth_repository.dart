import '../models/auth_models.dart';

/// Repository for authentication operations
abstract class AuthRepository {
  Future<bool> isAuthenticated();
  Future<User?> getCurrentUser();
  Future<User> login({required String email, required String password});
  Future<User> register({
    required String email,
    required String password,
    required String username,
    String? fullName,
  });
  Future<void> logout();
  Future<bool> refreshToken();
}
