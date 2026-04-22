import 'package:flutter/material.dart';
import 'package:mobile/shared/repositories/account_repository.dart';

class ChangePasswordController extends ChangeNotifier {
  final AccountRepository _repository;

  bool loading = false;
  String? errorMessage;
  bool success = false;

  ChangePasswordController(this._repository);

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    loading = true;
    errorMessage = null;
    success = false;
    notifyListeners();

    try {
      await _repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      success = true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
