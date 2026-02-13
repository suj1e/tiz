import '../models/auth_models.dart';

/// Mock data definitions
class AuthMockData {
  AuthMockData._();

  /// Test user credentials
  static const String testEmail = 'test@test.com';
  static const String testPassword = 'password123';

  /// Mock login response
  static AuthResponse get loginResponse => AuthResponse(
        accessToken: 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
        user: currentUser,
        expiresIn: 3600,
      );

  /// Mock register response
  static AuthResponse registerResponse({
    required String email,
    required String username,
    String? fullName,
  }) =>
      AuthResponse(
        accessToken: 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
        user: User(
          id: 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
          email: email,
          username: username,
          fullName: fullName,
          createdAt: DateTime.now(),
        ),
        expiresIn: 3600,
      );

  /// Mock current user
  static final User currentUser = User(
    id: 'mock_user_001',
    email: 'test@test.com',
    username: 'testuser',
    fullName: 'Test User',
    avatarUrl: 'https://i.pravatar.cc/150?img=1',
    emailVerified: true,
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
  );

  /// Mock Token refresh response
  static Map<String, dynamic> get tokenRefreshResponse => {
        'accessToken': 'mock_new_access_token_${DateTime.now().millisecondsSinceEpoch}',
        'refreshToken': 'mock_new_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
      };
}
