import 'package:flutter/material.dart';
import 'package:mobile/core/auth_controller.dart';

class SchoolController extends ChangeNotifier {
  String schoolName = '';

  SchoolController() {
    _loadSchoolName();
  }

  Future<void> _loadSchoolName() async {
    final name = await AuthController().getSchoolName();
    schoolName = name ?? '';
    notifyListeners();
  }
}
