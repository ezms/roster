import 'package:flutter/material.dart';
import 'package:mobile/core/models/class.dart';
import 'package:mobile/shared/repositories/class_repository.dart';

class AdminClassesController extends ChangeNotifier {
  final ClassRepository _repository;

  List<Class> classes = [];
  bool isLoading = false;
  String? errorMessage;

  AdminClassesController(this._repository) {
    loadClasses();
  }

  Future<void> loadClasses() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      classes = await _repository.fetchClasses();
    } catch (e) {
      errorMessage = 'Não foi possível carregar as turmas.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createClass(String name) async {
    try {
      final newClass = await _repository.createClass(name);
      
      classes.add(newClass);
      notifyListeners();
      
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateClass(int id, String name) async {
    try {
      final updatedClass = await _repository.updateClass(id, name);
      
      final index = classes.indexWhere((c) => c.id == id);
      if (index != -1) {
        classes[index] = updatedClass;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteClass(int id) async {
    try {
      final success = await _repository.deleteClass(id);
      
      if (success) {
        classes.removeWhere((c) => c.id == id);
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      return false;
    }
  }
}
