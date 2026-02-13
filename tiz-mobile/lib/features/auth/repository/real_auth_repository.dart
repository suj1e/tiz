import 'package:dio/dio.dart';

import '../models/auth_models.dart';
import '../../../core/api/api_client.dart';
import '../../../core/storage/storage_service.dart';
import 'auth_repository.dart';

/// Real implementation of AuthRepository using API
class RealAuthRepository implements AuthRepository {
  final ApiClient _apiClient;
  final StorageService _storageService;

  RealAuthRepository({
    required ApiClient apiClient,
    required StorageService storageService,
  })  : _apiClient = apiClient,
        _storageService = storageService;

  @override
  Future<bool> isAuthenticated() async {
    return await _storageService.isAuthenticated();
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final response = await _apiClient.get('/auth/me');
      if (response.statusCode == 200) {
        return User.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(
          response.data as Map<String, dynamic>,
        );

        await _storageService.saveAccessToken(authResponse.accessToken);
        await _storageService.saveRefreshToken(authResponse.refreshToken);
        await _storageService.saveUserData(authResponse.user.toJson());

        return authResponse.user;
      } else {
        throw AuthException(
          response.data['message'] ?? 'Login failed',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const AuthException('Invalid email or password', 401);
      } else if (e.response?.statusCode == 429) {
        throw const AuthException('Too many login attempts. Try again later.', 429);
      }
      throw AuthException(
        e.response?.data['message'] ?? 'Login failed',
        e.response?.statusCode,
      );
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<User> register({
    required String email,
    required String password,
    required String username,
    String? fullName,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'username': username,
          if (fullName != null) 'fullName': fullName,
        },
      );

      if (response.statusCode == 201) {
        final authResponse = AuthResponse.fromJson(
          response.data as Map<String, dynamic>,
        );

        await _storageService.saveAccessToken(authResponse.accessToken);
        await _storageService.saveRefreshToken(authResponse.refreshToken);
        await _storageService.saveUserData(authResponse.user.toJson());

        return authResponse.user;
      } else {
        throw AuthException(
          response.data['message'] ?? 'Registration failed',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw const AuthException('Email or username already exists', 409);
      }
      throw AuthException(
        e.response?.data['message'] ?? 'Registration failed',
        e.response?.statusCode,
      );
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _apiClient.post('/auth/logout');
    } catch (e) {
      // Continue with local logout even if API call fails
    } finally {
      await _storageService.clearAuthData();
    }
  }

  @override
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken == null) {
        return false;
      }

      final response = await _apiClient.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final accessToken = response.data['accessToken'] as String?;
        final newRefreshToken = response.data['refreshToken'] as String?;

        if (accessToken != null) {
          await _storageService.saveAccessToken(accessToken);
          if (newRefreshToken != null) {
            await _storageService.saveRefreshToken(newRefreshToken);
          }
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
