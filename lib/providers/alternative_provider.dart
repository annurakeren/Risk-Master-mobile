// lib/providers/alternative_provider.dart
import 'package:flutter/material.dart';
import '../models/alternative.dart';
import '../services/api_service.dart';

class AlternativeProvider extends ChangeNotifier {
  List<Alternative> _alternatives = [];
  bool _isLoading = false;
  final ApiService _api = ApiService();

  List<Alternative> get alternatives => _alternatives;
  bool get isLoading => _isLoading;

  Future<void> fetchAlternatives() async {
    _isLoading = true;
    notifyListeners();
    _alternatives = await _api.getAlternatives();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addAlternative(String name, String desc) async {
    final ok = await _api.createAlternative(name, desc);
    if (ok) await fetchAlternatives();
    return ok;
  }

  Future<bool> editAlternative(int id, String name, String desc) async {
    final ok = await _api.updateAlternative(id, name, desc);
    if (ok) await fetchAlternatives();
    return ok;
  }

  Future<bool> removeAlternative(int id) async {
    final ok = await _api.deleteAlternative(id);
    if (ok) await fetchAlternatives();
    return ok;
  }
}