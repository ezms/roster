import 'package:flutter/material.dart';
import 'package:mobile/core/models/user.dart';
import 'package:mobile/shared/repositories/user_repository.dart';

class UserController extends ChangeNotifier {
  final UserRepository _repository;

  User? user;

  UserController(this._repository) {
    _load();
  }

  Future<void> _load() async {
    user = await _repository.fetchMe();
    notifyListeners();
  }
}
