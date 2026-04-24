import 'package:flutter/material.dart';
import 'package:mobile/core/auth_controller.dart';
import 'package:mobile/core/models/school.dart';

class LoginController extends ChangeNotifier {
  final AuthController _authController = AuthController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _needsSchoolSelection = false;

  bool _isSuperUser = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get needsSchoolSelection => _needsSchoolSelection;
  bool get isSuperUser => _isSuperUser;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authController.login(email, password);
      if (!success) {
        _errorMessage = 'Credenciais inválidas.';
        return false;
      }
      _isSuperUser = await _authController.checkIsSuperUser();
      await _resolveSchoolSelection();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectSchool(School school) async {
    await _authController.selectSchool(school);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _resolveSchoolSelection() async {
    if (AuthController.schools.isEmpty) return;
    if (AuthController.schools.length > 1) {
      _needsSchoolSelection = true;
      notifyListeners();
    } else {
      await _authController.selectSchool(AuthController.schools.first);
    }
  }
}
