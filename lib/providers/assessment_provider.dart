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

  Future<Assessment?> createAssessment(String title, String desc, int userId) async {
    final a = await _api.createAssessment(title, desc, userId);
    if (a != null) await fetchAssessments();
    return a;
  }

  Future<bool> submitValues(int assessmentId, List<Map<String, dynamic>> values) async {
    return await _api.submitValues(assessmentId, values);
  }
}