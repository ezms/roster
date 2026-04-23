import 'package:flutter/material.dart';
import 'package:mobile/core/models/student.dart';
import 'package:mobile/shared/repositories/student_repository.dart';

class AdminStudentsController extends ChangeNotifier {
  final StudentRepository _repository;

  List<Student> students = [];
  bool isLoading = false;
  String? errorMessage;

  AdminStudentsController(this._repository) {
    loadStudents();
  }

  Future<void> loadStudents() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      students = await _repository.fetchAll();
    } catch (e) {
      errorMessage = 'Não foi possível carregar os alunos.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createStudent(String name) async {
    try {
      final student = await _repository.createStudent(name);
      students.add(student);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateStudent(int id, String name) async {
    try {
      final updated = await _repository.updateStudent(id, name);
      final index = students.indexWhere((s) => s.id == id);
      if (index != -1) {
        students[index] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteStudent(int id) async {
    try {
      final success = await _repository.deleteStudent(id);
      if (success) {
        students.removeWhere((s) => s.id == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      return false;
    }
  }
}
