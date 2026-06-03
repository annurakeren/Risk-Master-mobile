import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';
import '../models/user.dart';
import '../models/criteria.dart';
import '../models/alternative.dart';
import '../models/assessment.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  void init() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      contentType: 'application/json',
      connectTimeout: const Duration(milliseconds: AppConfig.connectionTimeout),
      receiveTimeout: const Duration(milliseconds: AppConfig.receiveTimeout),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (DioException error, handler) async {
        // Auto-logout jika token expired (401)
        if (error.response?.statusCode == 401) {
          await _storage.deleteAll();
          // Idealnya kita lempar event/exception untuk dinavigasi ke login
        }
        handler.next(error);
      },
    ));
  }

  // --- AUTH ---

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final res = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
        'device_name': 'flutter_app',
      });
      
      if (res.statusCode == 200 && res.data['success'] == true) {
        final token = res.data['data']['token'];
        final userData = res.data['data']['user'];
        
        await _storage.write(key: 'token', value: token);
        await _storage.write(key: 'user_id', value: userData['id'].toString());
        await _storage.write(key: 'user_role', value: userData['role'].toString());
        await _storage.write(key: 'user_name', value: userData['name'].toString());
        
        return {'success': true, 'user': User.fromJson(userData)};
      }
      return {'success': false, 'message': res.data['message'] ?? 'Login failed'};
    } on DioException catch (e) {
      return {
        'success': false, 
        'message': e.response?.data?['message'] ?? e.message ?? 'Terjadi kesalahan'
      };
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password, String role) async {
    try {
      final res = await _dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'role': role
      });
      if (res.statusCode == 200 || res.statusCode == 201) {
        return {'success': true};
      }
      return {'success': false, 'message': res.data['message']};
    } on DioException catch (e) {
      return {'success': false, 'message': e.response?.data?['message'] ?? 'Gagal mendaftar'};
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (e) {
      // Abaikan error saat logout, yang penting hapus local token
    } finally {
      await _storage.deleteAll();
    }
  }

  // --- USERS (Admin only) ---

  Future<List<User>> getUsers() async {
    final res = await _dio.get('/users');
    final List data = res.data['data'] ?? [];
    return data.map((e) => User.fromJson(e)).toList();
  }

  Future<bool> createUser(String name, String email, String password, String role) async {
    final res = await _dio.post('/users', data: {
      'name': name, 'email': email, 'password': password, 'role': role
    });
    return res.statusCode == 201 || res.statusCode == 200;
  }

  Future<bool> updateUser(int id, String name, String email, String role) async {
    final res = await _dio.put('/users/$id', data: {
      'name': name, 'email': email, 'role': role
    });
    return res.statusCode == 200;
  }

  Future<bool> deleteUser(int id) async {
    final res = await _dio.delete('/users/$id');
    return res.statusCode == 200;
  }

  // --- CRITERIA (Admin only) ---

  Future<List<Criteria>> getCriteria() async {
    final res = await _dio.get('/criteria');
    final List data = res.data['data']?['criteria'] ?? res.data['data'] ?? [];
    return data.map((e) => Criteria.fromJson(e)).toList();
  }

  Future<bool> createCriteria(String name, String description, String type, double weight) async {
    final res = await _dio.post('/criteria', data: {
      'name': name, 'description': description, 'type': type, 'weight': weight
    });
    return res.statusCode == 201 || res.statusCode == 200;
  }

  Future<bool> updateCriteria(int id, String name, String description, String type, double weight) async {
    final res = await _dio.put('/criteria/$id', data: {
      'name': name, 'description': description, 'type': type, 'weight': weight
    });
    return res.statusCode == 200;
  }

  Future<bool> deleteCriteria(int id) async {
    final res = await _dio.delete('/criteria/$id');
    return res.statusCode == 200;
  }

  // --- ALTERNATIVES ---

  Future<List<Alternative>> getAlternatives() async {
    final res = await _dio.get('/alternatives?per_page=100');
    final List data = res.data['data']?['alternatives'] ?? res.data['data'] ?? [];
    return data.map((e) => Alternative.fromJson(e)).toList();
  }

  Future<bool> createAlternative(String name, String description, String source) async {
    final res = await _dio.post('/alternatives', data: {
      'name': name, 'description': description, 'source': source
    });
    return res.statusCode == 201 || res.statusCode == 200;
  }

  Future<bool> updateAlternative(int id, String name, String description) async {
    final res = await _dio.put('/alternatives/$id', data: {
      'name': name, 'description': description
    });
    return res.statusCode == 200;
  }

  Future<bool> deleteAlternative(int id) async {
    final res = await _dio.delete('/alternatives/$id');
    return res.statusCode == 200;
  }

  // --- ASSESSMENTS ---

  Future<List<Assessment>> getAssessments() async {
    final res = await _dio.get('/assessments?per_page=50');
    final List data = res.data['data']?['assessments'] ?? res.data['data'] ?? [];
    return data.map((e) => Assessment.fromJson(e)).toList();
  }
  
  Future<Map<String, dynamic>> getAssessmentDetail(int id) async {
    final res = await _dio.get('/assessments/$id');
    return res.data['data'] ?? {};
  }

  Future<Assessment?> createAssessment(String title, String description, List<int> alternativeIds) async {
    try {
      final res = await _dio.post('/assessments', data: {
        'title': title,
        'description': description,
        'alternative_ids': alternativeIds,
      });
      if (res.statusCode == 201 || res.statusCode == 200) {
        return Assessment.fromJson(res.data['data']?['assessment'] ?? res.data['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> submitValues(int assessmentId, List<Map<String, dynamic>> values) async {
    try {
      final res = await _dio.post('/assessments/$assessmentId/values', data: {
        'values': values
      });
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  Future<Map<String, dynamic>> calculateEdas(int assessmentId) async {
    try {
      final res = await _dio.post('/assessments/$assessmentId/calculate');
      if (res.statusCode == 200) {
        return {'success': true, 'message': 'Kalkulasi berhasil'};
      }
      return {'success': false, 'message': res.data['message'] ?? 'Gagal kalkulasi'};
    } on DioException catch (e) {
      return {'success': false, 'message': e.response?.data?['message'] ?? 'Terjadi kesalahan server'};
    }
  }
  
  Future<Map<String, dynamic>> getEdasResults(int assessmentId) async {
    try {
      final res = await _dio.get('/assessments/$assessmentId/results');
      if (res.statusCode == 200) {
        return {'success': true, 'data': res.data['data']};
      }
      return {'success': false, 'message': res.data['message']};
    } catch (e) {
      return {'success': false, 'message': 'Gagal mengambil hasil EDAS'};
    }
  }
}
