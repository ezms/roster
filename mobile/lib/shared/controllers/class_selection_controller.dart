import 'package:flutter/material.dart';
import 'package:mobile/core/models/class.dart';
import 'package:mobile/shared/repositories/class_repository.dart';

class ClassSelectionController extends ChangeNotifier {
  final ClassRepository _repository;

  List<Class> classes = [];
  bool loaded = false;
  Class? selected;

  ClassSelectionController(this._repository) {
    _load();
  }

  Future<void> _load() async {
    classes = await _repository.fetchClasses();
    loaded = true;
    notifyListeners();
  }

  void select(Class? classroom) {
    selected = classroom;
    notifyListeners();
  }
}
