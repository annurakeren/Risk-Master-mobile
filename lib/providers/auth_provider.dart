// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/dummy_data.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  final ApiService _api = ApiService();

  // Cek apakah sudah login dari SharedPreferences
  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getInt('user_id');
    if (token != null && userId != null) {
      try {
        _currentUser = DummyData.users.firstWhere((u) => u.id == userId);
        notifyListeners();
      } catch (_) {
        await prefs.clear();
      }
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _api.login(email, password);

    _isLoading = false;
    if (result['success']) {
      _currentUser = result['user'] as User;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, String role) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _api.register(name, email, password, role);

    _isLoading = false;
    if (result['success']) {
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _api.logout();
    _currentUser = null;
    notifyListeners();
  }
}
