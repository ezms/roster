import 'package:flutter/material.dart';
import 'package:mobile/core/models/classes_admin_stats.dart';
import 'package:mobile/shared/repositories/class_repository.dart';

class AdminScreenController extends ChangeNotifier {
  final ClassRepository _classRepository;

  ClassesAdminStats? stats;
  bool isLoading = false;
  String? errorMessage;

  AdminScreenController(this._classRepository) {
    loadStats();
  }

  Future<void> loadStats() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      stats = await _classRepository.fetchAdminClassesStat();
    } catch (e) {
      errorMessage = 'Falha ao carregar as estatísticas.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
