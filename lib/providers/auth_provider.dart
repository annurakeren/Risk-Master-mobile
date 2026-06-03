import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../services/api_service.dart';

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
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Cek apakah sudah login dari Secure Storage
  Future<void> checkAuthStatus() async {
    final token = await _storage.read(key: 'token');
    final userIdStr = await _storage.read(key: 'user_id');
    final userRole = await _storage.read(key: 'user_role');
    final userName = await _storage.read(key: 'user_name');
    
    if (token != null && userIdStr != null && userRole != null && userName != null) {
      _currentUser = User(
        id: int.tryParse(userIdStr) ?? 0,
        name: userName,
        email: '', // Email not explicitly needed for current UI if not stored
        role: userRole,
      );
      notifyListeners();
    } else {
      await _storage.deleteAll();
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
