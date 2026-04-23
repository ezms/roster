import 'package:flutter/material.dart';
import 'package:mobile/core/models/student.dart';
import 'package:mobile/shared/repositories/student_repository.dart';

class AdminCardsController extends ChangeNotifier {
  final StudentRepository _repository;

  List<Student> students = [];
  bool isLoading = false;
  String? errorMessage;

  AdminCardsController(this._repository) {
    loadStudents();
  }

  int get totalWithCard => students.where((s) => s.card != null).length;
  int get totalWithoutCard => students.where((s) => s.card == null).length;

  Future<void> loadStudents() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      students = await _repository.fetchAll();
    } catch (e) {
      errorMessage = 'Não foi possível carregar os dados.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
