import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../api/api_client.dart';
import '../storage/storage_service.dart';
import '../config/mock_config.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_event.dart';
import '../../features/auth/bloc/auth_state.dart';
import '../../features/auth/repository/auth_repository.dart';
import '../../features/auth/repository/real_auth_repository.dart';
import '../../features/auth/repository/mock_auth_repository.dart';

class ServiceLocator {
  static const String _baseUrl = 'http://localhost:40004/api/v1';

  static late SharedPreferences _sharedPrefs;
  static late StorageService _storageService;
  static late ApiClient _apiClient;
  static late MockConfig _mockConfig;
  static late AuthRepository _authRepository;
  static late AuthBloc _authBloc;

  static Future<void> init() async {
    _sharedPrefs = await SharedPreferences.getInstance();
    _storageService = StorageServiceImpl(
      secureStorage: const FlutterSecureStorage(
        aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
        ),
      ),
      sharedPrefs: _sharedPrefs,
    );

    _apiClient = ApiClient(
      dio: _createDio(),
    );

    _mockConfig = MockConfig();

    // Conditionally inject based on Mock mode
    _authRepository = _createAuthRepository();

    _authBloc = AuthBloc(authRepository: _authRepository);
  }

  /// Create AuthRepository based on Mock mode
  static AuthRepository _createAuthRepository() {
    if (_mockConfig.isMockMode) {
      debugPrint('[ServiceLocator] Using MockAuthRepository');
      return MockAuthRepository();
    } else {
      debugPrint('[ServiceLocator] Using RealAuthRepository');
      return RealAuthRepository(
        apiClient: _apiClient,
        storageService: _storageService,
      );
    }
  }

  /// Reinitialize repositories (call after toggling Mock mode)
  static Future<void> reinitializeRepositories() async {
    _authRepository = _createAuthRepository();
    // Recreate BLoC
    _authBloc = AuthBloc(authRepository: _authRepository);
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    dio.interceptors.addAll([
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ),
    ]);

    return dio;
  }

  static List<SingleChildWidget> get providers => [
    Provider.value(value: _sharedPrefs),
    Provider.value(value: _storageService),
    Provider.value(value: _apiClient),
    Provider.value(value: _mockConfig),
    Provider.value(value: _authRepository),
    BlocProvider<AuthBloc>.value(value: _authBloc),
  ];

  static StorageService get storage => _storageService;
  static ApiClient get api => _apiClient;
  static MockConfig get mockConfig => _mockConfig;
  static AuthBloc get authBloc => _authBloc;
}
