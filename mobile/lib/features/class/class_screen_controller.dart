import 'package:flutter/material.dart';
import 'package:mobile/core/models/student.dart';
import 'package:mobile/shared/controllers/class_selection_controller.dart';
import 'package:mobile/shared/repositories/student_repository.dart';

class ClassScreenController extends ChangeNotifier {
  final ClassSelectionController _classSelectionController;
  final StudentRepository _repository;

  List<Student> students = [];
  bool loading = false;
  bool hasMore = true;
  int _page = 1;

  ClassScreenController(this._classSelectionController, this._repository) {
    _classSelectionController.addListener(_onClassChanged);
    if (_classSelectionController.selected != null) _load(reset: true);
  }

  Future<void> loadMore() => _load(reset: false);

  void _onClassChanged() => _load(reset: true);

  Future<void> _load({required bool reset}) async {
    final classId = _classSelectionController.selected?.id;
    if (classId == null) {
      students = [];
      hasMore = true;
      notifyListeners();
      return;
    }

    if (reset) {
      _page = 1;
      students = [];
      hasMore = true;
    }

    loading = true;
    notifyListeners();

    final result = await _repository.fetchByClass(classId: classId, page: _page);

    students = reset ? result.students : [...students, ...result.students];
    hasMore = _page < result.lastPage;
    _page++;
    loading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _classSelectionController.removeListener(_onClassChanged);
    super.dispose();
  }
}
