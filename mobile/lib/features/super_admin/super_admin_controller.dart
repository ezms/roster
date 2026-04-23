import 'package:flutter/material.dart';
import 'package:mobile/core/models/school.dart';
import 'package:mobile/features/super_admin/super_admin_repository.dart';

class SuperAdminController extends ChangeNotifier {
  final SuperAdminRepository _repository;

  List<School> schools = [];
  Map<int, List<SuperAdminUser>> usersCache = {};
  bool isLoading = false;
  String? errorMessage;

  SuperAdminController(this._repository) {
    loadSchools();
  }

  Future<void> loadSchools() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      schools = await _repository.fetchSchools();
    } catch (_) {
      errorMessage = 'Não foi possível carregar as escolas.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<School?> createSchool(String name) async {
    try {
      final school = await _repository.createSchool(name);
      schools.add(school);
      notifyListeners();
      return school;
    } catch (_) {
      return null;
    }
  }

  Future<bool> deleteSchool(int id) async {
    try {
      await _repository.deleteSchool(id);
      schools.removeWhere((s) => s.id == id);
      usersCache.remove(id);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<SuperAdminUser>> fetchUsers(int schoolId) async {
    if (usersCache.containsKey(schoolId)) return usersCache[schoolId]!;
    final users = await _repository.fetchUsers(schoolId);
    usersCache[schoolId] = users;
    notifyListeners();
    return users;
  }

  Future<bool> createUser(
    int schoolId, {
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      final user = await _repository.createUser(
        schoolId,
        email: email,
        password: password,
        name: name,
        role: role,
      );
      usersCache[schoolId] = [...(usersCache[schoolId] ?? []), user];
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteUser(int schoolId, int userId) async {
    try {
      await _repository.deleteUser(schoolId, userId);
      usersCache[schoolId]?.removeWhere((u) => u.id == userId);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
