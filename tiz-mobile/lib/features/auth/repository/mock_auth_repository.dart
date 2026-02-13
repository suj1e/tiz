import 'package:flutter/foundation.dart';

import '../models/auth_models.dart';
import '../mock_data/auth_mock_data.dart';
import 'auth_repository.dart';

/// Mock implementation of AuthRepository for development
class MockAuthRepository implements AuthRepository {
  User? _currentUser;

  @override
  Future<bool> isAuthenticated() async {
    debugPrint('[MockAuthRepository] isAuthenticated: ${_currentUser != null}');
    return _currentUser != null;
  }

  @override
  Future<User?> getCurrentUser() async {
    debugPrint('[MockAuthRepository] getCurrentUser');
    return _currentUser;
  }

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    debugPrint('[MockAuthRepository] login: $email');

    // Simulate validation
    if (email == AuthMockData.testEmail && password == AuthMockData.testPassword) {
      _currentUser = AuthMockData.currentUser;
      return _currentUser!;
    }

    throw const AuthException('Invalid email or password', 401);
  }

  @override
  Future<User> register({
    required String email,
    required String password,
    required String username,
    String? fullName,
  }) async {
    debugPrint('[MockAuthRepository] register: $email / $username');

    // Simulate email already exists
    if (email == AuthMockData.testEmail) {
      throw const AuthException('Email already exists', 409);
    }

    _currentUser = User(
      id: 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      username: username,
      fullName: fullName,
      createdAt: DateTime.now(),
    );

    return _currentUser!;
  }

  @override
  Future<void> logout() async {
    debugPrint('[MockAuthRepository] logout');
    _currentUser = null;
  }

  @override
  Future<bool> refreshToken() async {
    debugPrint('[MockAuthRepository] refreshToken');
    return _currentUser != null;
  }
}
