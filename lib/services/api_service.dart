import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
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
          options.headers['Accept'] = 'application/json';
        }
        handler.next(options);
      },
      onError: (DioException error, handler) async {
        // Auto-hapus token jika expired (401)
        if (error.response?.statusCode == 401) {
          await _storage.deleteAll();
        }
        handler.next(error);
      },
    ));
  }

  // Helper: cek apakah response Laravel berhasil
  // Laravel pakai { "status": "success", ... }
  bool _isSuccess(Response res) {
    return res.data['status'] == 'success';
  }

  // Helper: ambil pesan error dari response
  String _errorMessage(DioException e, [String fallback = 'Terjadi kesalahan']) {
    return e.response?.data?['message'] ?? e.message ?? fallback;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // AUTH
  // ─────────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final res = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
        'device_name': 'Flutter App',
      });

      // Response: { "status": "success", "data": { "token": "...", "user": {...} } }
      if (res.statusCode == 200 && _isSuccess(res)) {
        final token    = res.data['data']['token'];
        final userData = res.data['data']['user'];

        await _storage.write(key: 'token',     value: token);
        await _storage.write(key: 'user_id',   value: userData['id'].toString());
        await _storage.write(key: 'user_role',  value: userData['role'].toString());
        await _storage.write(key: 'user_name',  value: userData['name'].toString());

        return {'success': true, 'user': User.fromJson(userData)};
      }
      return {'success': false, 'message': res.data['message'] ?? 'Login gagal'};
    } on DioException catch (e) {
      if (e.response == null) {
        return {'success': false, 'message': 'Gagal terhubung ke server. Pastikan IP dan koneksi benar.'};
      }
      // 422 = validasi gagal (email/password salah)
      final msg = e.response?.data?['message']
          ?? e.response?.data?['errors']?.values?.first?.first
          ?? 'Email atau password salah';
      return {'success': false, 'message': msg};
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (_) {
      // Abaikan error — yang penting hapus token lokal
    } finally {
      await _storage.deleteAll();
    }
  }

  Future<Map<String, dynamic>> getMe() async {
    try {
      final res = await _dio.get('/auth/me');
      if (res.statusCode == 200 && _isSuccess(res)) {
        return {'success': true, 'data': res.data['data']};
      }
      return {'success': false, 'message': res.data['message']};
    } on DioException catch (e) {
      return {'success': false, 'message': _errorMessage(e)};
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // USERS (Admin only)
  // Response: { "status": "success", "data": { "users": [...], "meta": {...} } }
  // ─────────────────────────────────────────────────────────────────────────

  Future<List<User>> getUsers() async {
    try {
      final res = await _dio.get('/users');
      final List data = res.data['data']?['users'] ?? [];
      return data.map((e) => User.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, 'Gagal memuat daftar user'));
    }
  }

  Future<bool> createUser(String name, String email, String password, String role) async {
    try {
      final res = await _dio.post('/users', data: {
        'name': name, 'email': email, 'password': password, 'role': role
      });
      return res.statusCode == 201 && _isSuccess(res);
    } on DioException catch (_) {
      return false;
    }
  }

  Future<bool> updateUser(int id, String name, String email, String role) async {
    try {
      final res = await _dio.put('/users/$id', data: {
        'name': name, 'email': email, 'role': role
      });
      return res.statusCode == 200 && _isSuccess(res);
    } on DioException catch (_) {
      return false;
    }
  }

  Future<bool> deleteUser(int id) async {
    try {
      final res = await _dio.delete('/users/$id');
      return res.statusCode == 200 && _isSuccess(res);
    } on DioException catch (_) {
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CRITERIA (Admin only)
  // Response: { "status": "success", "data": { "criteria": [...] } }
  // ─────────────────────────────────────────────────────────────────────────

  Future<List<Criteria>> getCriteria() async {
    try {
      final res = await _dio.get('/criteria');
      final List data = res.data['data']?['criteria'] ?? [];
      return data.map((e) => Criteria.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, 'Gagal memuat kriteria'));
    }
  }

  Future<bool> createCriteria(String name, String description, String type, double weight) async {
    try {
      final res = await _dio.post('/criteria', data: {
        'name': name, 'description': description, 'type': type, 'weight': weight
      });
      return res.statusCode == 201 && _isSuccess(res);
    } on DioException catch (_) {
      return false;
    }
  }

  Future<bool> updateCriteria(int id, String name, String description, String type, double weight) async {
    try {
      final res = await _dio.put('/criteria/$id', data: {
        'name': name, 'description': description, 'type': type, 'weight': weight
      });
      return res.statusCode == 200 && _isSuccess(res);
    } on DioException catch (_) {
      return false;
    }
  }

  Future<bool> deleteCriteria(int id) async {
    try {
      final res = await _dio.delete('/criteria/$id');
      return res.statusCode == 200 && _isSuccess(res);
    } on DioException catch (_) {
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ALTERNATIVES
  // Response: { "status": "success", "data": { "alternatives": [...] } }
  // ─────────────────────────────────────────────────────────────────────────

  Future<List<Alternative>> getAlternatives() async {
    try {
      final res = await _dio.get('/alternatives?per_page=100');
      final List data = res.data['data']?['alternatives'] ?? [];
      return data.map((e) => Alternative.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, 'Gagal memuat alternatif'));
    }
  }

  Future<bool> createAlternative(String name, String description) async {
    try {
      // 'source' ditentukan otomatis oleh backend berdasarkan role user
      final res = await _dio.post('/alternatives', data: {
        'name': name, 'description': description
      });
      return res.statusCode == 201 && _isSuccess(res);
    } on DioException catch (_) {
      return false;
    }
  }

  Future<bool> updateAlternative(int id, String name, String description) async {
    try {
      final res = await _dio.put('/alternatives/$id', data: {
        'name': name, 'description': description
      });
      return res.statusCode == 200 && _isSuccess(res);
    } on DioException catch (_) {
      return false;
    }
  }

  Future<bool> deleteAlternative(int id) async {
    try {
      final res = await _dio.delete('/alternatives/$id');
      return res.statusCode == 200 && _isSuccess(res);
    } on DioException catch (_) {
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ASSESSMENTS
  // Response index: { "status": "success", "data": { "assessments": [...] } }
  // Response store: { "status": "success", "data": { AssessmentResource } }  HTTP 201
  // Response show:  { "status": "success", "data": { "assessment": {...}, "criteria": [...], "matrix": {...} } }
  // ─────────────────────────────────────────────────────────────────────────

  Future<List<Assessment>> getAssessments() async {
    try {
      final res = await _dio.get('/assessments?per_page=50');
      final List data = res.data['data']?['assessments'] ?? [];
      return data.map((e) => Assessment.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, 'Gagal memuat assessments'));
    }
  }

  Future<Map<String, dynamic>> getAssessmentDetail(int id) async {
    try {
      final res = await _dio.get('/assessments/$id');
      // data: { assessment, criteria, matrix, is_complete, filled_count, expected_count }
      return {'success': true, 'data': res.data['data'] ?? {}};
    } on DioException catch (e) {
      return {'success': false, 'message': _errorMessage(e)};
    }
  }

  Future<Map<String, dynamic>> createAssessment(
      String title, String description, List<int> alternativeIds) async {
    try {
      final res = await _dio.post('/assessments', data: {
        'title': title,
        'description': description,
        if (alternativeIds.isNotEmpty) 'alternative_ids': alternativeIds,
      });
      // HTTP 201: { "status": "success", "data": { AssessmentResource langsung } }
      if (res.statusCode == 201 && _isSuccess(res)) {
        final assessment = Assessment.fromJson(res.data['data']);
        return {'success': true, 'assessment': assessment};
      }
      return {'success': false, 'message': res.data['message'] ?? 'Gagal membuat assessment'};
    } on DioException catch (e) {
      return {'success': false, 'message': _errorMessage(e, 'Gagal membuat assessment')};
    }
  }

  Future<bool> updateAssessment(int id, {
    String? title,
    String? description,
    List<int>? alternativeIds,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (alternativeIds != null) data['alternative_ids'] = alternativeIds;

      final res = await _dio.put('/assessments/$id', data: data);
      return res.statusCode == 200 && _isSuccess(res);
    } on DioException catch (_) {
      return false;
    }
  }

  Future<bool> deleteAssessment(int id) async {
    try {
      final res = await _dio.delete('/assessments/$id');
      return res.statusCode == 200 && _isSuccess(res);
    } on DioException catch (_) {
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ASSESSMENT VALUES (Matrix input)
  // POST /assessments/{id}/values
  // Response: { "status": "success", "data": { filled_count, expected_count, is_complete } }
  // ─────────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> submitValues(
      int assessmentId, List<Map<String, dynamic>> values) async {
    try {
      final res = await _dio.post('/assessments/$assessmentId/values', data: {
        'values': values
      });
      if (res.statusCode == 200 && _isSuccess(res)) {
        return {'success': true, 'data': res.data['data']};
      }
      return {'success': false, 'message': res.data['message'] ?? 'Gagal menyimpan nilai'};
    } on DioException catch (e) {
      return {'success': false, 'message': _errorMessage(e, 'Gagal menyimpan nilai')};
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ASSESSMENT ALTERNATIVES
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> attachAlternatives(int assessmentId, List<int> alternativeIds) async {
    try {
      final res = await _dio.post('/assessments/$assessmentId/alternatives', data: {
        'alternative_ids': alternativeIds
      });
      return res.statusCode == 200 && _isSuccess(res);
    } on DioException catch (_) {
      return false;
    }
  }

  Future<bool> detachAlternative(int assessmentId, int alternativeId) async {
    try {
      final res = await _dio.delete('/assessments/$assessmentId/alternatives/$alternativeId');
      return res.statusCode == 200 && _isSuccess(res);
    } on DioException catch (_) {
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // EDAS - CALCULATE & RESULTS
  // POST /assessments/{id}/calculate
  // Response: { "status": "success", "data": { assessment_id, results: [...] } }
  //
  // GET  /assessments/{id}/results
  // Response: { "status": "success", "data": { assessment, results, top_recommendation } }
  //
  // CATATAN: field di results:
  //   rank, alternative{id,name,description}, sp, sn, nsp, nsn,
  //   as_score (= appraisal_score), quality_label, quality_color
  // ─────────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> calculateEdas(int assessmentId) async {
    try {
      final res = await _dio.post('/assessments/$assessmentId/calculate');
      if (res.statusCode == 200 && _isSuccess(res)) {
        return {
          'success': true,
          'message': res.data['message'] ?? 'Kalkulasi berhasil',
          'data': res.data['data'],
        };
      }
      return {'success': false, 'message': res.data['message'] ?? 'Gagal kalkulasi'};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _errorMessage(e, 'Terjadi kesalahan server'),
      };
    }
  }

  Future<Map<String, dynamic>> getEdasResults(int assessmentId) async {
    try {
      final res = await _dio.get('/assessments/$assessmentId/results');
      if (res.statusCode == 200 && _isSuccess(res)) {
        return {'success': true, 'data': res.data['data']};
      }
      return {'success': false, 'message': res.data['message'] ?? 'Gagal mengambil hasil'};
    } on DioException catch (e) {
      // 409 = assessment belum dikalkulasi
      if (e.response?.statusCode == 409) {
        return {'success': false, 'message': e.response?.data?['message'] ?? 'Belum dikalkulasi'};
      }
      return {'success': false, 'message': _errorMessage(e, 'Gagal mengambil hasil EDAS')};
    }
  }

  Future<void> downloadReport(int assessmentId, String format) async {
    try {
      final token = await _storage.read(key: 'token');
      final url = Uri.parse('$_baseUrl/assessments/$assessmentId/report/$format');
      
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      print('Download error: $e');
    }
  }
}
