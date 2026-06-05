// lib/providers/assessment_provider.dart
import 'package:flutter/material.dart';
import '../models/assessment.dart';
import '../services/api_service.dart';

class AssessmentProvider extends ChangeNotifier {
  List<Assessment> _assessments = [];
  bool _isLoading = false;
  final ApiService _api = ApiService();

  List<Assessment> get assessments => _assessments;
  bool get isLoading => _isLoading;

  Future<void> fetchAssessments() async {
    _isLoading = true;
    notifyListeners();
    _assessments = await _api.getAssessments();
    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> createAssessment(String title, String desc, List<int> alternativeIds) async {
    final res = await _api.createAssessment(title, desc, alternativeIds);
    if (res['success'] == true) await fetchAssessments();
    return res;
  }

  Future<Map<String, dynamic>> submitValues(int assessmentId, List<Map<String, dynamic>> values) async {
    return await _api.submitValues(assessmentId, values);
  }
  
  Future<Map<String, dynamic>> getAssessmentDetail(int id) async {
    return await _api.getAssessmentDetail(id);
  }
  
  Future<Map<String, dynamic>> calculateEdas(int assessmentId) async {
    final res = await _api.calculateEdas(assessmentId);
    if (res['success'] == true) {
      await fetchAssessments(); // Refresh list to update status
    }
    return res;
  }
  
  Future<Map<String, dynamic>> getEdasResults(int assessmentId) async {
    return await _api.getEdasResults(assessmentId);
  }
}