import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get error => _error;
  bool get isMerchant => _user?.isMerchant ?? false;
  bool get isClient => _user?.isClient ?? false;

  Future<void> init() async {
    await _api.loadTokens();
    if (_api.isAuthenticated) {
      try {
        await fetchProfile();
      } catch (_) {
        await _api.clearTokens();
      }
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.post(
        ApiConfig.login,
        body: {'username': username, 'password': password},
      );

      final tokens = response['tokens'];
      await _api.saveTokens(tokens['access'], tokens['refresh']);
      _user = User.fromJson(response['user']);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String passwordConfirm,
    required String role,
    String firstName = '',
    String lastName = '',
    String phone = '',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.post(
        ApiConfig.register,
        body: {
          'username': username,
          'email': email,
          'password': password,
          'password_confirm': passwordConfirm,
          'role': role,
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
        },
      );

      final tokens = response['tokens'];
      await _api.saveTokens(tokens['access'], tokens['refresh']);
      _user = User.fromJson(response['user']);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchProfile() async {
    final response = await _api.get(ApiConfig.profile);
    _user = User.fromJson(response);
    notifyListeners();
  }

  Future<void> logout() async {
    await _api.clearTokens();
    _user = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
