// lib/providers/criteria_provider.dart
import 'package:flutter/material.dart';
import '../models/criteria.dart';
import '../services/api_service.dart';

class CriteriaProvider extends ChangeNotifier {
  List<Criteria> _criteria = [];
  bool _isLoading = false;
  final ApiService _api = ApiService();

  List<Criteria> get criteria => _criteria;
  bool get isLoading => _isLoading;
  double get totalWeight => _criteria.fold(0, (sum, c) => sum + c.weight);

  Future<void> fetchCriteria() async {
    _isLoading = true;
    notifyListeners();
    _criteria = await _api.getCriteria();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addCriteria(String name, String desc, String type, double weight) async {
    final ok = await _api.createCriteria(name, desc, type, weight);
    if (ok) await fetchCriteria();
    return ok;
  }

  Future<bool> editCriteria(int id, String name, String desc, String type, double weight) async {
    final ok = await _api.updateCriteria(id, name, desc, type, weight);
    if (ok) await fetchCriteria();
    return ok;
  }

  Future<bool> removeCriteria(int id) async {
    final ok = await _api.deleteCriteria(id);
    if (ok) await fetchCriteria();
    return ok;
  }
}



