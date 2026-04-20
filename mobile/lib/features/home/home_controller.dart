import 'package:flutter/material.dart';
import 'package:mobile/core/auth_controller.dart';

class HomeController extends ChangeNotifier {
  String schoolName = '';

  HomeController() {
    _loadSchoolName();
  }

  Future<void> _loadSchoolName() async {
    final name = await AuthController().getSchoolName();
    schoolName = name ?? '';
    notifyListeners();
  }
}
