// lib/services/api_service.dart
// Saat backend Laravel sudah siap, uncomment bagian Dio dan comment bagian dummy

import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/criteria.dart';
import '../models/alternative.dart';
import '../models/assessment.dart';
import 'dummy_data.dart';

// ============================================================
// UNCOMMENT INI SAAT BACKEND SUDAH SIAP
// ============================================================
// import 'package:dio/dio.dart';
// import '../config/app_config.dart';
// ============================================================

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // ============================================================
  // UNCOMMENT INI SAAT BACKEND SUDAH SIAP
  // ============================================================
  // late final Dio _dio;
  // void init() {
  //   _dio = Dio(BaseOptions(
  //     baseUrl: AppConfig.baseUrl,
  //     contentType: 'application/json',
  //     connectTimeout: Duration(milliseconds: AppConfig.connectionTimeout),
  //     receiveTimeout: Duration(milliseconds: AppConfig.receiveTimeout),
  //   ));
  //   _dio.interceptors.add(InterceptorsWrapper(
  //     onRequest: (options, handler) async {
  //       final prefs = await SharedPreferences.getInstance();
  //       final token = prefs.getString('token');
  //       if (token != null) {
  //         options.headers['Authorization'] = 'Bearer $token';
  //       }
  //       handler.next(options);
  //     },
  //     onError: (error, handler) {
  //       if (error.response?.statusCode == 401) {
  //         // Token expired - handle logout
  //       }
  //       handler.next(error);
  //     },
  //   ));
  // }
  // ============================================================

  // --- AUTH ---

  Future<Map<String, dynamic>> login(String email, String password) async {
    // DUMMY
    await Future.delayed(const Duration(milliseconds: 800)); // simulasi network
    final user = DummyData.login(email, password);
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', 'dummy_token_${user.id}');
      await prefs.setInt('user_id', user.id);
      await prefs.setString('user_role', user.role);
      await prefs.setString('user_name', user.name);
      return {'success': true, 'user': user};
    }
    return {'success': false, 'message': 'Email tidak ditemukan'};

    // GANTI DENGAN INI SAAT BACKEND SIAP:
    // final res = await _dio.post('/login', data: {'email': email, 'password': password});
    // final token = res.data['token'];
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setString('token', token);
    // return {'success': true, 'user': User.fromJson(res.data['user'])};
  }

  Future<Map<String, dynamic>> register(String name, String email, String password, String role) async {
    // DUMMY
    await Future.delayed(const Duration(milliseconds: 800));
    final exists = DummyData.users.any((u) => u.email == email);
    if (exists) return {'success': false, 'message': 'Email sudah terdaftar'};
    final newUser = User(id: DummyData.users.length + 1, name: name, email: email, role: role);
    DummyData.users.add(newUser);
    return {'success': true};

    // GANTI DENGAN INI SAAT BACKEND SIAP:
    // final res = await _dio.post('/register', data: {'name': name, 'email': email, 'password': password, 'role': role});
    // return {'success': true};
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // TAMBAHKAN INI SAAT BACKEND SIAP:
    // await _dio.post('/logout');
  }

  // --- USERS (Admin only) ---

  Future<List<User>> getUsers() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return DummyData.users;
    // GANTI: final res = await _dio.get('/users'); return (res.data['data'] as List).map((e) => User.fromJson(e)).toList();
  }

  Future<bool> createUser(String name, String email, String password, String role) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newUser = User(id: DummyData.users.length + 1, name: name, email: email, role: role);
    DummyData.users.add(newUser);
    return true;
    // GANTI: await _dio.post('/users', data: {...}); return true;
  }

  Future<bool> updateUser(int id, String name, String email, String role) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final idx = DummyData.users.indexWhere((u) => u.id == id);
    if (idx == -1) return false;
    DummyData.users[idx] = User(id: id, name: name, email: email, role: role);
    return true;
    // GANTI: await _dio.put('/users/$id', data: {...}); return true;
  }

  Future<bool> deleteUser(int id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    DummyData.users.removeWhere((u) => u.id == id);
    return true;
    // GANTI: await _dio.delete('/users/$id'); return true;
  }

  // --- CRITERIA (Admin only) ---

  Future<List<Criteria>> getCriteria() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return DummyData.criteria;
    // GANTI: final res = await _dio.get('/criteria'); return (res.data['data'] as List).map((e) => Criteria.fromJson(e)).toList();
  }

  Future<bool> createCriteria(String name, String description, String type, double weight) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final c = Criteria(id: DummyData.criteria.length + 1, name: name, description: description, type: type, weight: weight);
    DummyData.criteria.add(c);
    return true;
  }

  Future<bool> updateCriteria(int id, String name, String description, String type, double weight) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final idx = DummyData.criteria.indexWhere((c) => c.id == id);
    if (idx == -1) return false;
    DummyData.criteria[idx] = Criteria(id: id, name: name, description: description, type: type, weight: weight);
    return true;
  }

  Future<bool> deleteCriteria(int id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    DummyData.criteria.removeWhere((c) => c.id == id);
    return true;
  }

  // --- ALTERNATIVES ---

  Future<List<Alternative>> getAlternatives() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return DummyData.alternatives;
  }

  Future<bool> createAlternative(String name, String description, String source) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final a = Alternative(id: DummyData.alternatives.length + 1, name: name, description: description, source: source);
    DummyData.alternatives.add(a);
    return true;
  }

  Future<bool> updateAlternative(int id, String name, String description) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final idx = DummyData.alternatives.indexWhere((a) => a.id == id);
    if (idx == -1) return false;
    final old = DummyData.alternatives[idx];
    DummyData.alternatives[idx] = Alternative(id: id, name: name, description: description, source: old.source, createdBy: old.createdBy);
    return true;
  }

  Future<bool> deleteAlternative(int id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    DummyData.alternatives.removeWhere((a) => a.id == id);
    return true;
  }

  // --- ASSESSMENTS ---

  Future<List<Assessment>> getAssessments() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return DummyData.assessments;
  }

  Future<Assessment?> createAssessment(String title, String description, int userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final a = Assessment(id: DummyData.assessments.length + 1, userId: userId, title: title, description: description, status: 'draft');
    DummyData.assessments.add(a);
    return a;
  }

  Future<bool> submitValues(int assessmentId, List<Map<String, dynamic>> values) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // Di dummy ini cukup return true, nanti di backend yang hitung EDAS
    return true;
  }
}
