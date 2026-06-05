import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_auth/local_auth.dart';
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
  final LocalAuthentication _localAuth = LocalAuthentication();

  // ── Cek apakah sudah login dari Secure Storage ──────────────────────────
  Future<void> checkAuthStatus() async {
    final token = await _storage.read(key: 'token');
    final userIdStr = await _storage.read(key: 'user_id');
    final userRole = await _storage.read(key: 'user_role');
    final userName = await _storage.read(key: 'user_name');

    if (token != null && userIdStr != null && userRole != null && userName != null) {
      _currentUser = User(
        id: int.tryParse(userIdStr) ?? 0,
        name: userName,
        email: '',
        role: userRole,
      );
      notifyListeners();
    } else {
      await _storage.deleteAll();
    }
  }

  // ── Login ───────────────────────────────────────────────────────────────
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

  // ── Register ────────────────────────────────────────────────────────────
  Future<bool> register(String name, String email, String password, String passwordConfirmation) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _api.register(name, email, password, passwordConfirmation);

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

  // ── Forgot Password ─────────────────────────────────────────────────────
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _api.forgotPassword(email);

    _isLoading = false;
    notifyListeners();
    return result;
  }

  Future<Map<String, dynamic>> resetPassword(String email, String token, String password, String passwordConfirmation) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _api.resetPassword(email, token, password, passwordConfirmation);

    _isLoading = false;
    notifyListeners();
    return result;
  }

  // ── Google Login ────────────────────────────────────────────────────────
  Future<bool> googleLogin() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Initialize Google Sign-In
      await GoogleSignIn.instance.initialize();
      
      // Trigger Google Sign-In flow
      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        _isLoading = false;
        _errorMessage = 'Gagal mendapatkan token dari Google';
        notifyListeners();
        return false;
      }

      // Send idToken to backend
      final result = await _api.googleLogin(idToken);

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
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Login Google gagal: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // ── Biometric Login ─────────────────────────────────────────────────────
  Future<bool> get canUseBiometric async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      final hasToken = await _storage.read(key: 'token') != null;
      return isAvailable && isDeviceSupported && hasToken;
    } catch (_) {
      return false;
    }
  }

  Future<List<BiometricType>> get availableBiometrics async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  Future<bool> biometricLogin() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Verifikasi identitas untuk masuk ke Risk Master',
      );

      if (!authenticated) {
        _isLoading = false;
        _errorMessage = 'Autentikasi biometrik gagal';
        notifyListeners();
        return false;
      }

      // Biometric passed — restore session from secure storage
      final token = await _storage.read(key: 'token');
      final userIdStr = await _storage.read(key: 'user_id');
      final userRole = await _storage.read(key: 'user_role');
      final userName = await _storage.read(key: 'user_name');

      if (token != null && userIdStr != null && userRole != null && userName != null) {
        _currentUser = User(
          id: int.tryParse(userIdStr) ?? 0,
          name: userName,
          email: '',
          role: userRole,
        );
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _errorMessage = 'Sesi login sebelumnya tidak ditemukan. Silakan login manual.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Biometrik tidak tersedia: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // ── Logout ──────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await _api.logout();
    try { await GoogleSignIn.instance.disconnect(); } catch (_) {}
    _currentUser = null;
    notifyListeners();
  }
}
