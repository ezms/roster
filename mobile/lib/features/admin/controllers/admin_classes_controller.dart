import 'package:flutter/material.dart';
import 'package:mobile/shared/controllers/class_selection_controller.dart';
import 'package:mobile/shared/repositories/class_repository.dart';

class AdminClassesController extends ChangeNotifier {
  final ClassRepository _repository;
  final ClassSelectionController _classSelectionController;

  bool isLoading = false;
  String? errorMessage;

  AdminClassesController(this._repository, this._classSelectionController) {
    loadClasses();
  }

  Future<void> loadClasses() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _classSelectionController.setClasses(await _repository.fetchClasses());
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
      
      _classSelectionController.addClass(newClass);
      notifyListeners();
      
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateClass(int id, String name) async {
    try {
      final updatedClass = await _repository.updateClass(id, name);
      
      _classSelectionController.updateClassInList(updatedClass);
      notifyListeners();
      
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteClass(int id) async {
    try {
      final success = await _repository.deleteClass(id);
      
      if (success) {
        _classSelectionController.removeClassFromList(id);
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      return false;
    }
  }
}
