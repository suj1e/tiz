import 'package:flutter/material.dart';

/// Simple mock authentication controller
/// Manages in-memory auth state for demo purposes
class AuthController extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _currentUserEmail;

  bool get isLoggedIn => _isLoggedIn;
  String? get currentUserEmail => _currentUserEmail;

  /// Login with email and password
  /// Mock validation: check if email contains "@" and password length > 6
  Future<bool> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock validation
    if (!email.contains('@')) {
      throw Exception('请输入有效的邮箱地址');
    }
    if (password.length <= 6) {
      throw Exception('密码长度必须大于6个字符');
    }

    _isLoggedIn = true;
    _currentUserEmail = email;
    notifyListeners();
    return true;
  }

  /// Register with name, email and password
  /// Mock validation: all fields required, passwords must match, password length > 6
  Future<bool> register(String name, String email, String password, String confirmPassword) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock validation
    if (name.trim().isEmpty) {
      throw Exception('请输入姓名');
    }
    if (!email.contains('@')) {
      throw Exception('请输入有效的邮箱地址');
    }
    if (password.length <= 6) {
      throw Exception('密码长度必须大于6个字符');
    }
    if (password != confirmPassword) {
      throw Exception('两次输入的密码不一致');
    }

    _isLoggedIn = true;
    _currentUserEmail = email;
    notifyListeners();
    return true;
  }

  /// Logout
  void logout() {
    _isLoggedIn = false;
    _currentUserEmail = null;
    notifyListeners();
  }
}
