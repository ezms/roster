import 'package:flutter/material.dart';
import 'package:mobile/core/models/student.dart';
import 'package:mobile/shared/controllers/class_selection_controller.dart';
import 'package:mobile/shared/repositories/student_repository.dart';

class AdminStudentsController extends ChangeNotifier {
  final StudentRepository _repository;
  final ClassSelectionController classSelectionController;

  List<Student> students = [];
  bool isLoading = false;
  String? errorMessage;

  AdminStudentsController(this._repository, this.classSelectionController) {
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

  Future<bool> setStudentClass(int studentId, int? classId) async {
    try {
      final success = await _repository.setStudentClass(studentId, classId);
      if (success) {
        final index = students.indexWhere((s) => s.id == studentId);
        if (index != -1) {
          final current = students[index];
          final newClass = classId != null
              ? classSelectionController.classes.firstWhere((c) => c.id == classId)
              : null;
          students[index] = Student(
            id: current.id,
            name: current.name,
            code: current.code,
            photoUrl: current.photoUrl,
            card: current.card,
            currentClass: newClass,
          );
          notifyListeners();
        }
      }
      return success;
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
